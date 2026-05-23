---
title: "Refocusing snip's direction"
template: "post"
tags: ["post", "projects", "c++"]
date: "May 23, 2026"
---

I'd been working on a text-editor called [snip](https://github.com/ujaandas/snip) for quite some time now. 

It was, like most of my projects, a re-invention of the wheel. I don't really like the idea of framing a project as a "product" from the get-go, I think they serve me (personally) better as learning experiences.

But now that I'd been working with snip for a while, and gotten more and more acquianted with the idea of maybe actually using it, I did want to start thinking in a more practical sense.

I didn't need to implement my own event-reactor-backend (think [libuv](https://github.com/libuv/libuv)), my own ASCII-rendering pipeline, or a lot of the other hand-written "pipelines" I wrote to understand the overarching system.

So, taking a step back, I re-framed what I wanted snip to be. 

Snip should be a Nix-first editor. I wanted to rely on [nixpkgs](https://search.nixos.org/packages) for my LSPs, linters, or any other code-tooling. It should be performant, simple enough to reason-about, and get out of your way.

As such, I've recently begun work on refactoring snip to:

1. Get out of the terminal, we're using Qt now instead
2. Focus on tooling instead of movement (for now)

Using Qt has been pretty cool so far, it's actually very pleasant and the `qtl` is awesome. 

Obviously, it's my first time working with a framework this big outside of the STL, so there's a lot of hiccups and things slowing me down, namely the black-hole that is text rendering.

Also exams and interview prep have forced me to put it on the backburner for now, but I'm looking forward to grinding it out this Summer.