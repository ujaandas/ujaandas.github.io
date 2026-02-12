---
title: "Building an Editor: Part 1"
template: "post"
tags: ["projects"]
date: "February 10, 2026"
---

In my spare time, I’ve been working on a little editor/TUI framework called **snip**, mostly because I wanted something nicer than Vim for quick edits, but also because I didn’t want to go full NeoVim‑guru and maintain a config that looks like a PhD thesis. I know enough Vim to get by over SSH, but that’s about it. I think my `.vimrc` is like 20 lines? I wanted something simple, predictable, and Nix‑first.

> Editor's Note: I now realize that by making this "Nix-first", I won't really be able to use it super well on my university machines... I'll figure that out later.

So anyways, I wrote my own editor. Obviously.

This was a _slightly_ bigger project than I had initially intended, but it's working out alright so far.

When I realized that, I decided I wanted something extensible, so the runtime is the bit I ended up spending a lot of my initial time on, and honestly, it’s probably the cleanest part of the whole project. It’s tiny, it’s boring, and it does exactly what I need it to do - which is kind of the point.

### Architecture

snip follows a TEA‑ish, Elm‑ish architecture. I say "‑ish" because I’m not trying to be academically correct here; I just like the idea of pure state transitions and deferred effects. The TUI framework is very, very, **very** heavily inspired by Bubble Tea, except written in C++ because I enjoy suffering.

The gist:

- Messages are just data.
- The update loop is pure.
- Side‑effects are deferred as commands.
- The runtime is the only impure part.

This keeps everything testable and predictable. (Do I test it? No. But I _could_, and that’s what matters.)

### Messages: Tiny Blobs of Meaning

Everything that happens in snip is a message. Keypress? Message. Window resize? Message. File opened? Message. They’re just variants — no inheritance, no polymorphism, no "clever" abstractions.

```cpp
struct QuitMsg {};
struct KeypressMsg { char key; };
struct WindowDimensionsMsg { int width; int height; };
struct FilepathMsg { std::string path; };

using Msg = std::variant<
    QuitMsg,
    KeypressMsg,
    WindowDimensionsMsg,
    FilepathMsg
>;
```

I like this because it forces me to keep things simple. A message is just a message. The update loop decides what to do with it.

Also, I spent wayyyyyyy too much of my C++ career (career might be a stretch) with `C++97` (thanks, HKUST), or just not using the STL in general. This is also a pretty nice way of stretching my boundaries and learning some of the newer paradigms.

### Commands: Side‑Effects, But Polite

The update loop never touches I/O directly. Instead, it returns commands, which the runtime executes later. A command might eventually produce a message, or it might not. Basically, a deferred action.

```cpp
using Cmd = std::function<std::optional<Msg>()>;

Cmd Quit(Program &p);
Cmd Send(Msg m);
Cmd OpenFile(std::string path);
```

This keeps the core pure, which makes it easier to reason about. Also, it means I can test state transitions without needing a terminal attached.

### The Event Loop: Pure In, Pure Out

Every update returns two things:

1. A new state
2. A list of commands

No mutation, no sneaky side‑effects, no "surprise, this function also writes to disk."

```cpp
struct UpdateResult {
    State newState;
    std::vector<Cmd> commands;
};
```

It’s very functional‑programming‑core in C++, which is either charming or cursed depending on your tolerance for templates.

### The Actual Runtime

The `Program` class is where the real world leaks in. It owns the message queue, executes commands, handles input, and calls your update/render functions. Everything else is pure.

```cpp
class Program {
    State &state;
    std::queue<Msg> msgQ;
    std::queue<Cmd> cmdQ;
    std::atomic<bool> running = true;

public:
    Program(State &m) : state(m) {}
    std::vector<Cmd> init();
    UpdateResult update(const State &state, Msg &msg);
    std::string render(const State &state);
    void run();
    void executeCmd(const Cmd &cmd);
    void requestQuit();
};
```

The runtime is intentionally tiny - I want as little logic here as possible. It just shuffles messages around, executes commands, and calls the pure functions. That’s it. The editor logic lives elsewhere, which makes it easier to swap things out later if I ever decide to change how rendering works or add a different input backend.

### That’s Basically It

This is the foundation everything else sits on. Next up, I’ll probably write a a bit more about how I implement the `Program` class.

Check out the repo [here](https://github.com/ujaandas/snip/tree/main).
