---
layout: post
title: "[Guide] Getting Started with Nix on MacOS"
date: 2025-02-20 13:46:20 +0800
categories: nix
---

So, you want to get started with Nix and MacOS?

First things first, don’t jump the gun and uninstall Homebrew just yet — we’re going to build up your Nix ecosystem one step at a time.

Next, make sure you’re _really_ ready. Nix can be a bit daunting, especially if you dive straight into flakes, home-manager, and the full setup. I highly recommend taking it slow and focusing on growing your system alongside your understanding of Nix (which is why this guide will only cover getting a basic configuration.nix working).

This guide will help you get started with the basics and teach you how to set up a functional Nix environment, including a simple configuration that features something fun like cowsay.

---

### What is Nix?

Nix is a declarative package manager, meaning that instead of manually installing and configuring software, you describe the desired state of your system or environment in a configuration file, and Nix takes care of ensuring that state is applied.

Some key benefits of Nix:

- **Reproducibility**: You can reproduce the exact same environment or system on any machine.
- **Isolation**: Nix environments are isolated and don’t interfere with each other.
- **Flexibility**: Manage your entire system (on macOS, Linux, or NixOS), user environments, or even development projects declaratively.

If you want to learn more, check out my other article.

---

### Get Started

#### Step 1: Install Nix

To begin, use the [Determinate installer](https://github.com/DeterminateSystems/nix-installer) to install Nix. It’s more modern and user-friendly compared to the older installer and includes features like a graphical interface, mounted store, and easy uninstallation.

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
 sh -s -- install
```

This installs Nix and sets up the Nix store, a special directory where all Nix-managed packages and configurations live.

After completing the installation, verify that Nix is working:

```shell
nix --version
```

If you see a version number, congratulations! You’ve installed Nix.

#### Step 2: Enable Flakes

Flakes are an experimental feature in Nix that make configuration management simpler and more powerful. They allow you to define declarative environments and systems using a standardized format. Think of flakes as a way to _describe_ what your project provides and how it works, all in one place. If you want to learn more, check out this article on flakes().

1. You can create your first flake anywhere you like - I've placed mine in `~/.config/nix`:
2. To initialize the flake, run the following command:

```sh
nix flake init --extra-experimental-features nix-command --extra-experimental-features flakes
```

What’s happening here?

- `nix flake init` generates a default `flake.nix` template in your directory.
- The `--extra-experimental-features` flags temporarily enable both `nix-command` and `flakes` for this command since they aren't already enabled in our configuration file (which we'll now write using flakes).

After running the command, you’ll see a `flake.nix` file created in the directory.

3. Open the `flake.nix` file to see what was generated for you. It should look something like this:

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
```

This is essentially just one big function. `outputs` is a function that takes `self` (the flake itself) and `nixpkgs` (the Nix package repository) as arguments, and is is where you describe the functionality of the flake itself.

In our case, this everything inside `outputs` is utterly and entirely useless.

### Step 3: Making our Flake Usable
