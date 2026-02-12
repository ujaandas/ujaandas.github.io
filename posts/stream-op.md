---
title: "The Hell of Overloading Stream Operators"
template: "post"
tags: ["posts"]
date: "February 12, 2026"
---

I was working on my custom editor the other day - specifically the gap‑buffer class - and I wanted to make the API a bit nicer by adding some operator overloads. But for whatever reason, the compiler just _refused_ to see/acknowledge it.

## Argument-Dependent Lookup

I feel like there's not a day that goes by without me discovering some new, obscure feature of C++. In any case, the idea is simple: when you call a function without qualifying it, the compiler looks not just in the current namespace, but also in the namespaces associated with the argument types.

> The ADL is not the only way operators are found, first a normal unqualified lookup happens first, then the ADL augments it!

It's basically the rule that decides _where_ the compiler looks for unqualified function calls. When you write:

```cpp
std::cout << myGapLine;
```

The compiler tries to find an `operator<<` that matches. And here’s the part I completely glossed over at first: my `operator<<` was actually a member function of the class. Which sounds reasonable until you remember one extremely cursed C++ fact:

**Stream operators cannot be member functions of your type.**

Why? Because in an expression like:

```cpp
std::cout << myGapLine;
```

the left‑hand side is `std::cout`, which is a `std::ostream`.
So the operator being invoked must be:

- A member of `std::ostream` (which I obviously cannot add), or
- A free function that takes (`std::ostream&`, `const GapLine&`).

A member function of my class only works if my type is on the left‑hand side:

```cpp
myGapLine << std::cout; // completely backwards, obviously wrong
```

So the compiler never even _considered_ my member operator. It wasn’t a namespace issue. It wasn’t the ADL being weird. It was simply the fact that I put the operator in a place where the language would never look for it.

## Fixing It

After some very helpful SO posts (I still maintain that SO was a net _positive_ to the programming community, unlike many others who seem to be glad it's dead thanks to AI), everything clicked. My operator wasn’t broken. My build wasn’t broken. The compiler wasn’t broken. I just defined the overload in the wrong shape.

The fix was to make the operator a free function - and the easiest way to do that without exposing all my internals was to declare it as a `friend` inside the class:

```cpp
class GapLine {
    friend std::ostream& operator<<(std::ostream&, const GapLine&);
};
```

This does two things:

- It creates a proper free function that can be called with `std::cout << x`.
- It associates the operator with the type so ADL can actually find it.

> Also note that the friend declaration injects the function into the surrounding namespace only if the function is defined inline inside the class, otherwise you (obviously) still need to define it in the namespace manually

Suddenly everything worked, and the universe made sense again (well, C++‑sense).

So, for reference, for `operator<<` and `operator>>`, the rule of thumb is:

- They should be free functions, not members
- They should be visible to ADL
- Which usually means: put them in the same namespace as your type
- Or, if you’re not using namespaces, declare them as friends inside the class
- Definitely don’t put them in `std`
- Definitely don’t hide them in some random utility namespace

> To clarify, you _can_ have stream operator member functions, just note that the order will be flipped and they will only work when your type is on the LHS

If your type is `my::GapLine`, then your operator should also be in namespace `my`.
If your type is just `GapLine` in the global namespace, then a friend function works perfectly.

Otherwise, the ADL just shrugs.

Anyway, I’m back to writing my editor. Hopefully without discovering another obscure corner of the language next week.
