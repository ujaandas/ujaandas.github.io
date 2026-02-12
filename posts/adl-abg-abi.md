---
title: "C++ Has Too Many Acronyms"
template: "post"
tags: ["posts"]
date: "February 12, 2026"
---

I was working on my custom editor the other day - specifically the gap‑buffer class - and I wanted to make the API a bit nicer. You know, add some operator overloads, make indexing feel natural, that sort of thing. Nothing wild. And then, out of nowhere, C++ decided to teach me a lesson I didn’t ask for.

At first I thought I’d broken something deep, like the ABI. Maybe I’d miscompiled something, or mismatched flags, or angered the linker gods. But no - the ABI was innocent (for now). The real culprit was something much sneakier:

**Argument‑Dependent Lookup (ADL).**

> Can I just say, I know C++ is huge, but there are _way_ too many acronyms.

## Argument-Dependent Lookup

ADL (Argument‑Dependent Lookup) is one of those C++ features that you vaguely know exists but never think about until it ruins your day. The idea is simple: when you call a function without qualifying it, the compiler looks not just in the current namespace, but also in the namespaces associated with the argument types.

It's basically the rule that decides _where_ the compiler looks for unqualified function calls. When you write:

```cpp
std::cout << myGapLine;
```

The compiler tries to find an `operator<<` that matches. But here’s the catch:

- The left‑hand side is `std::ostream`
- The right‑hand side is your type
- ADL only looks in the namespaces associated with the arguments

And here’s the fun part:
if your operator lives in your namespace, but the left‑hand side is `std::ostream`, ADL won’t look there.

So even though you know your operator exists, `std::cout` does not.

## Fixing It

In any case, after some very helpful SO posts (I still maintain that SO was a net _positive_ to the programming community, unlike many others who seem to be glad it's dead thanks to AI), everything clicked. My operator wasn’t broken. My build wasn’t broken. The compiler wasn’t broken. I just put the overload in the wrong place.

So, for reference, for `operator<<` and `operator>>`, the rule of thumb is:

- The overload must live in the same namespace as the right‑hand type
- Not in std (obviously)
- Not in some random utility namespace
- Not in the global namespace unless your type is also global

If your type is `my::GapLine`, then your operator must also be in namespace `my`.

Otherwise, the ADL shrugs. Put your operator in the same namespace as your type.

For what it's worth, I don't think I even ended up using this, I realized I made a new class called `CursorCol` which stored an integer, and then overloaded all the integer operations with regular integer operations (why?), so I ditched everything, but hey, nice lesson anyways!

Anyway, I’m back to writing my editor. Hopefully without discovering another obscure corner of the language next week.
