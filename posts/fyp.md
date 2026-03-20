---
title: "The Autonomous Follow-Me Robot System"
template: "project"
tags: ["projects"]
date: "May 14, 2025"
thumbnail: "/static/robot.jpg"
---

Or, better known colloqually as _"Gyatbott"_, was our undergraduate final year project. To note, I was studying computer engineering, so while I had a fair amount of experience with lower-level systems like embedded, robotics was a completely new foray.

In any case, this was shortly after Covid-19, so in brainstorming, we came across one pretty big problem across all of Hong Kong.

### Overview

Healthcare systems are... kind of overwhelmed right now. Between aging populations and post-COVID strain, nurses are dealing with heavier workloads than ever - and a lot of that work is repetitive, manual, and error-prone.

Between identifying patients, retrieving prescriptions, and manually handling medication, a lot of time goes into tasks that are repetitive — and, more importantly, error-prone.

So we asked: what if a robot could just handle that?

This project is an autonomous robotic assistant that follows a nurse during their rounds, identifies patients, and dispenses the correct medication — all without requiring any technical interaction.

The goal wasn't just to build something that works in a lab, but something that could realistically slot into a hospital workflow.

### What We Built

At a high level, this is a fully autonomous mobile robot that can:

- Follow a specific person (the nurse) at ~1m distance
- Recognize patients via facial recognition (~90% accuracy)
- Retrieve and dispense medication automatically
- Navigate through real-world, dynamic environments

It's completely self-contained, runs on battery (~3–4 hours), and is designed to work without requiring technical knowledge from the user.

From the nurse's perspective, there's basically no interface — they wear a tag, and the robot follows.

### Architecture

The robot is constantly pulling in data from multiple places:

- A camera for patient recognition
- A LiDAR for mapping and obstacle avoidance
- A UWB system for tracking the nurse (courtesy of yours, truly!)
- Internal state from motors and encoders

All of this feeds into a ROS2-based software stack running on the onboard computer.

![diagram](/static/robot-diagram.png)

### Following People is Weird

A big part of making the system feel "natural" is the following behavior.

It's not enough to just know where the nurse is - you need to:

- Smooth out noisy sensor data
- Handle sudden movement changes
- Deal with temporary occlusions
- Avoid overcorrecting (no jittery robot!)

The system uses ultra-wideband tracking to estimate position, then continuously feeds that into the navigation stack as a moving goal. So instead of planning once, the robot is constantly replanning — effectively chasing a target that never stops moving. When it works well, it feels surprisingly smooth. When it doesn't... it really doesn't.

### End Results

We were surprised by how well it actually worked. We set up various obstacle courses, mazes and whatnot that it would try and follow the person through, and it accomplished most of them with ease. The main issues when it came to tracking was really just to do with speed and power. Not to mention, we were basically running the Raspberry Pi with someone's portable power bank.

At the end of the day, we didn't really expect this to be actively deployed in hospitals. We did _ask_ some doctors if we could, but were met with a resounding _no_. But hey, if someone were to take this idea and better align it with internal policies and whatnot, maybe it could be a real thing!

Check out our final report [here](/static/FYP.pdf).
