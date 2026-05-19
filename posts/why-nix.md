---
title: "Nix?"
template: "post"
tags: ["posts", "nix"]
date: "March 26, 2025"
---

Hi there. If you're reading this, that probably means I sent you this in response to a problem you were facing, in a snarky, somewhat sarcastic way of saying "you should use Nix". If, however, you found this organically, wow, I'm honoured. In any case, you should use Nix. Maybe.

### What is Nix?

At a very basic level, Nix is a package manager and configuration system focused on reproducibility.

It sounds boring, but solves many, *many* problems:
- "It works on my machine"
- dependency hell
- mysterious CI failures
- reinstalling your setup on a new laptop for the n-th time
- upgrading one package and somehow breaking six unrelated things

Nix approaches all of this by making environments declarative and isolated. Instead of manually edging your system into the right state, you describe the environment you want, and Nix builds it the same way *every* time.

In practice, that means:

1. **Reproducibility:** If something works for one person, it should work for everyone else too.

2. **Declarative configuration:** Your setup becomes code you can version, share, and rebuild.

3. **Rollbacks and isolation:** Upgrades are safer, and projects stop trampling over each other's dependencies.

### Let's all love Nix!

> Did you know that [nixpkgs is larger than the AUR](https://repology.org/repositories/statistics/total) (sort of)? 

The only problem with widespread adoption is, unfortunately, Nix itself. Nix, the language, can be quite finicky and hard to learn. The many libraries that come with it are not super-well documented, either. Getting started can be a bit of a pain.

But, once you get the ball rolling, it *rolls*, alright. 

If you're interested, I recommend checking out these resources:
1. [nix.dev](https://nix.dev/)
2. [NixOS and Flakes Book](https://nixos-and-flakes.thiscute.world/)
3. [Vimjoyer's Youtube Channel](https://www.youtube.com/@vimjoyer)