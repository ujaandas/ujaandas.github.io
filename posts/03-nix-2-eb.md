---
title: "More on Nix"
template: "post"
tags: ["post", "nix"]
date: "March 29, 2025"
---

Nix has a reputation for being impossibly complicated, but the core idea is surprisingly straightforward.

You give Nix:

- some source code
- a list of dependencies
- instructions for how to build something

...and Nix turns that into a package.

The important part is that Nix treats the *entire build process* as data.

### Derivations

In Nix, packages are defined using the Nix language. These package definitions are called *derivations*.

A derivation describes:
- where the source code comes from
- what dependencies are needed
- what commands should run to build it
- what the final output should look like

It's basically a recipe. Once you've written a derivation, Nix now has everything it needs to build your package.

### Hashing

Before building anything, Nix computes a hash from all the derivation's inputs.

That includes things like:
- source code
- dependency versions
- compiler versions
- build scripts
- environment configuration
- patches
- build flags

Basically, if it could affect the output, it goes into the hash.

This hash becomes the identity of the build.

### Building

Once the derivation has been hashed, Nix creates an isolated build environment.

This is one of the biggest differences between Nix and traditional package managers.

Normally, builds end up depending on all kinds of accidental garbage from the host system:

- globally installed libraries
- random tools in `$PATH`
- environment variables
- leftover packages from years ago

Nix tries very hard to prevent this (you can circumvent it).

Instead, builds only see the dependencies explicitly declared in the derivation.

If you forgot to declare something, the build fails.

### Storing

If the build succeeds, the result gets placed into `/nix/store`.

Importantly, nothing in the store gets modified in-place.

Nix doesn't "upgrade" packages the traditional way. Instead, every build exists independently.

That means you can have:
- multiple versions of the same library
- multiple compiler versions
- multiple entire development environments

all installed simultaneously without them stepping on each other.

### Installing

When you "install" a package with Nix, you're usually not copying files around your system.

Instead, Nix creates symlinks pointing to packages inside `/nix/store`.

Your environment is basically a carefully constructed forest of references to immutable build outputs.

This also makes rollbacks incredibly cheap.

Switching generations often just means changing which symlinks are active.

### Caching

Of course, rebuilding the entire universe from source every time would be terrible.

So before building anything locally, Nix checks whether someone has already built the exact same derivation.

If a matching hash exists in a binary cache, Nix just downloads the pre-built result instead.

Which means someone else has already turned their laptop into a jet engine compiling Chromium for you.

At the end of the day, most of Nix boils down to one idea:

> If builds are fully described and fully isolated, they become predictable.

Everything else is mostly implementation details, increasingly concerning amounts of bracket syntax, and occasional encounters with the Nix language parser.