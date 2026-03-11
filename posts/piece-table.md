---
title: "I'm Doing How Many Heap Allocations per Keystroke???"
template: "post"
tags: ["posts"]
date: "March 11, 2026"
---

So, I've been making a lot of changes to my editor, `snip`, lately. One of them was adding a `libuv`-style reactor, making my entire "backend" event-driven and asynchronous. Neat! But that's not where my problem today arose.

Currently, I hold my state in a POD-struct like so:

```cpp
struct State {
  // UI and Viewport
  WindowState window;
  CursorState cursor;
  int scrollOffset = 0;

  // Data Storage
  std::vector<std::string> buffer; // The full file contents
  GapBufferedLine curLine;         // The active line being edited

  // Metadata
  std::string debugText = "";
  std::string filename = "";
};
```

Okay, fine so far. The problem is that because my app's update function (which runs on every keystroke) is pure, I copy old state over. Yes. A _deep_-copy.

Because I'm using a `std::vector<std::string>`, C++ does a deep copy of the entire document every single time a message is processed. So for instance, if I had a 10,000-line source file, I'd have 10,000 strings. When I press `j` to move down, a new message is created, update is ran, and my app copies all 10,000 strings into a new vector. What does this mean?

I'm doing _thousands_ of heap allocations per keystroke. While my background threading was initially keeping the UI from freezing during I/O, my main thread would eventually choke just trying to copy the state.

Not to mention, what a _terrible_ way to accomodate edits. `std::vector` is terrible for inserting or deleting lines. If I pressed `Enter` on line 2 of a 100,000-line file, the vector has to physically shift _99,998_ strings down one slot in memory.

### Fixing It

Text editors never store files as arrays of strings. To fix this while keeping my purely functional framework, I had three main options in front of me.

#### Pointer Sharing

The most obvious fix was pointer-sharing. If I wanted to keep the `std::vector` for now (development velocity?) but stop the massive copy overhead, I could have used structural sharing. By changing my buffer to:

```cpp
std::vector<std::shared_ptr<const std::string>> buffer;
```

When `State newState = currentState;` happens, C++ would only copy the pointers and increment a ref count. The actual string data stays in one place. If I edited a line, I would only allocate a new string for that specific line and swap the pointer. This makes state copying almost instantaneous.

#### Piece Tables

Doing some more research, I found that most modern editors use something called a piece table.
Instead of a vector, you store the text in two flat, append-only memory blocks:

1. The original file buffer (read-only, never changes).
2. The add buffer(append-only, stores everything the user types).

Your "document" is just a list of pointers (pieces) saying "read 10 chars from original, then read 5 chars from add, then read 50 chars from original." Copying a piece table is lightning fast, undo/redo is practically free, and it handles multi-gigabyte files much, _much_ faster.

#### Ropes

Another popular option. A rope is a binary tree where the leaves hold short strings. Inserting text splits a leaf; deleting text merges them. Because it's a tree, copying the state is cheap - you only copy the nodes that changed (persistent data structures), leaving the rest of the tree untouched.

### Final Decision

So, which did I pick? I don't really know yet. Part of me still thinks that optimizing before _actually_ running into issues is a little silly. Apparently VSCode used an array of strings until 2018, so that's something. I'm leaning away from ropes just because they sound more complex than warranted (for now, at least), and I don't know if I want to count newlines at every node just to get to line 50, especially for someone who has a tendency to hold `j` instead of pressing `50j`. I also didn't really like the gap buffer to begin with, figuring out undo/redo would be a PITA, and I found some cool articles on piece tables, so I might read up some more before making my choice.

- [The Piece Table - the Unsung Hero of Your Text Editor](https://dev.to/_darrenburns/the-piece-table---the-unsung-hero-of-your-text-editor-al8)
- [Text Editor Data Structures](https://cdacamar.github.io/data%20structures/algorithms/benchmarking/text%20editors/c++/editor-data-structures/)
