---
title: "Building an Editor: Part 2"
template: "post"
tags: ["projects"]
date: "February 12, 2026"
---

In Part 1, I talked about the architecture behind snip - messages, commands, pure update loop, etc. That’s all nice in theory, but the runtime is where everything actually happens. This is the glue: input, command execution, rendering, and the main event loop that ties it all together.

It’s also the part I kept rewriting because I couldn’t decide how fancy I wanted it to be. The current version is small, predictable, and doesn’t make me want to throw my laptop, so I’m calling that good enough.

## The `Program` runtime

The `Program` class is the “runtime” in the TEA sense. It owns:

- the current state
- a message queue
- a command queue
- a couple of worker threads
- and a `running` flag that everything checks like a nervous chihuahua

The update loop stays pure; the runtime does all the messy stuff. Most of it is just plumbing - queues, locks, and condition variables to keep everything from stepping on each other.

As a reminder, a command is a deferred action that may/may not return a message. A message is a block of information. All commands are executed on a separate thread to the core runtime.

## Input Handling: The "Please Stop Busy‑Waiting" Thread

The runtime implements `handleInput()`, which is a dedicated thread that does two things:

1. Reads keyboard input
2. Checks for window size changes

Both get turned into messages and pushed into the queue for processing.

```cpp
void Program::handleInput() {
  while (running.load()) {
    char c;
    if (read(STDIN_FILENO, &c, 1) > 0) {
      std::unique_lock<std::mutex> lock(msgQMutex);
      msgQ.push(KeypressMsg{c});
      msgCv.notify_one();
    }

    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    if (w.ws_col != state.window.width || w.ws_row != state.window.height) {
      std::unique_lock<std::mutex> lock(msgQMutex);
      msgQ.push(WindowDimensionsMsg{w.ws_col, w.ws_row});
      msgCv.notify_one();
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(10));
  }
}
```

This is honestly one of the parts I struggled with for a while, and NOT for the many obvious problems here. I was not sure whether or not I should allow direct pushing to the message queue, or if these should also be deferred actions. I might change it later, but for now, it makes sense that my input handler has direct access to it.

Anyways, yes, I’m polling the window size. Yes, I know about signals. No, I haven’t fixed it yet.
Also, the `sleep_for` is there because otherwise this thread will happily spin at 100% CPU doing absolutely nothing.

## Commands: The "Do This Later" Queue

Commands are deferred side‑effects. The update loop returns them, and the runtime executes them in a separate thread:

```cpp
void Program::executeCmd(const Cmd &cmd) {
  if (auto maybeMsg = cmd()) {
    std::unique_lock<std::mutex> lock(msgQMutex);
    msgQ.push(*maybeMsg);
    msgCv.notify_one();
  }
}
```

If a command returns a message, it gets fed right back into the event loop. This is how file loading works: the update loop says "open this file," the runtime does it, and sends back a `FilepathMsg`.

`handleCmd()` is just a worker thread that waits for commands and runs them:

```cpp
void Program::handleCmd() {
  while (running.load()) {
    Cmd cmd;
    {
      std::unique_lock<std::mutex> lock(cmdQMutex);
      while (cmdQ.empty() && running.load()) {
        cmdCv.wait(lock);
      }
      if (!running.load() && cmdQ.empty()) break;
      cmd = cmdQ.front();
      cmdQ.pop();
    }
    executeCmd(cmd);
  }
}
```

> Note: I define all my commands elsewhere in `cmds.cpp`

## The Main Loop

`run()` ties everything together:

```cpp
void Program::run() {
  Terminal term;
  term.init(0);

  std::thread input(&Program::handleInput, this);
  std::thread cmd(&Program::handleCmd, this);

  for (auto cmd : init()) {
    std::unique_lock<std::mutex> lock(cmdQMutex);
    cmdQ.push(cmd);
    cmdCv.notify_one();
  }

  while (running.load()) {
    Msg msg;
    {
      std::unique_lock<std::mutex> lock(msgQMutex);
      while (msgQ.empty() && running.load()) {
        msgCv.wait(lock);
      }
      if (!running.load() && msgQ.empty()) break;
      msg = msgQ.front();
      msgQ.pop();
    }

    auto result = update(state, msg);
    state = result.newState;
    std::cout << render(state) << std::flush;

    for (auto &cmd : result.commands) {
      std::unique_lock<std::mutex> lock(cmdQMutex);
      cmdQ.push(cmd);
      cmdCv.notify_one();
    }
  }

  input.join();
}
```

The `run()` loop is really the centre of the whole runtime - everything else is just scaffolding around it. What I like about this loop is that it’s extremely literal: it does exactly what the architecture diagram says it should do, no more, no less.

The structure is basically:

1. Spin up the terminal
2. Start the input + command worker threads
3. Enqueue any initial commands
4. Enter the message -> update -> render cycle
5. Keep doing that until something tells us to stop

There’s no hidden state machine, no clever coroutine magic, no “surprise, this function also handles rendering.” It’s just a blocking wait on the message queue, followed by a pure update, followed by a render.

One thing that surprised me is how _little_ the main loop actually needs to know. It doesn’t care what the message is, what the commands do, or what the renderer outputs. It just shuffles data around:

- Messages come in
- Commands go out
- State gets replaced
- The screen gets redrawn

That’s it.

The other subtle thing is that `run()` is the only place where state mutation happens. Everywhere else, state is passed by const reference and replaced wholesale. This makes debugging a lot easier - if something weird happens, it’s either in `update()` or in the renderer, because nothing else touches the state.

Again, there are many things I want to improve about this. I want to make rendering asynchronous, add pipelined updates, done something fancy with `epoll`, etc...

## The Update Loop

`update()` is where all the editor logic lives, and it's where all the "functionality" is implemented. It takes the current state and a message, and returns:

- A new state
- A list of commands

No mutation, no I/O, no side‑effects. Just a big `std::visit` over the message variant.

```cpp
UpdateResult Program::update(const State &state, Msg &msg) {
  State newState = state;
  std::vector<Cmd> cmds;

  std::visit(
      [&cmds, &newState, this](auto &&m) {
        using T = std::decay_t<decltype(m)>;

        if constexpr (std::is_same_v<T, QuitMsg>) {
          cmds.push_back(Quit(*this));
        }

        else if constexpr (std::is_same_v<T, KeypressMsg>) {
          newState.debugText = m.key;
          switch (m.key) {
          case 'q':
            cmds.push_back(Send(QuitMsg{}));
            break;

          case 'j':
            // move cursor down...
            break;

          case 'k':
            // move cursor up...
            break;

          case 'h':
            // move cursor left...
            break;

          case 'l':
            // move cursor right...
            break;
          }
        }

        else if constexpr (std::is_same_v<T, WindowDimensionsMsg>) {
          // handle window size change
        }

        else if constexpr (std::is_same_v<T, FilepathMsg>) {
          // handle file open
        }
      },
      msg);

  return UpdateResult{newState, std::move(cmds)};
}
```

Again, the `update()` function is basically the "brain: of the editor. It’s the only place where actual editor behaviour lives - cursor movement, scrolling, file loading, quitting, all of it. Everything else in the runtime is just shuffling messages around so `update()` can make a decision.

What I like about this setup is that `update()` is completely pure. It takes the current state and a message, and returns a _new_ state plus a list of commands. That’s it. No mutation, no I/O, no weird side‑effects hiding in a corner somewhere. If something breaks, it’s almost always because I messed up the logic here, which makes debugging a lot easier.

The other nice thing is that `update()` ends up being very explicit. Because it’s just a big `std::visit`, every message type has to be handled deliberately. There’s no "oh, this function implicitly changes the cursor" nonsense - if the cursor moves, you can see exactly where and why. It forces me to keep the editor logic honest.

Eventually I’ll probably split this into smaller functions (cursor movement, scrolling, file operations, etc...), but for now, having it all in one place makes it easy to iterate on.

## The Render Loop

Unfortunately, `render()` is the opposite of `update()` - it’s pure, but it’s not elegant. It’s just ANSI escape codes and string building. And honestly for now, that’s fine. Terminal rendering is always a bit ugly.

The important part is that `render()` also has zero side‑effects. It doesn’t write to stdout directly; it just returns a string. The main loop decides when to actually print it. This keeps rendering predictable and makes it easier to swap out later if I ever decide to do something fancier (double‑buffering, partial redraws, syntax highlighting, whatever).

Eventually I might replace the ANSI soup with a proper abstraction, but for now, it works, and it keeps the runtime small.

## Wrapping Up

The runtime is the least glamorous part of snip, but it’s the part that makes everything else possible. It handles input, executes commands, and keeps the update loop pure. It’s also surprisingly small - most of the editor logic lives in `update()` and `render()`, which is why if you check out the repo, `Program`'s implementation is split into `main.cpp` and `runtime.cpp`.

Check out the repo [here](https://github.com/ujaandas/snip/tree/main).
