---
title: "Robots are hard!"
template: "post"
tags: ["projects", "robotics", "c++", "python"]
date: "May 14, 2025"
---

In the final year of my computer engineering bachelor's, we built _"The Autonomous Follow-Me Robot System"_ - or, more colloquially, _"Gyatbott"_ (iykyk).

Despite having a fair amount of experience with lower-level systems and embedded programming, robotics was completely new territory for me.

![robot](/static/robot.jpg)

### Some context

Post-Covid, a lot of healthcare systems in HK were under heavy strain.

Between identifying patients, retrieving prescriptions, and manually handling medication, a lot of time went into repetitival, menial - and, more importantly, error-prone tasks.

So we asked: what if a robot could just handle that?

We wanted to make an autonomous robotic assistant that follows a nurse during their rounds, identifies patients, and dispenses the correct medication - all without requiring any technical interaction.

### Our goals

At a high level, this would be a fully autonomous mobile robot that can:

- Follow a specific person (the nurse) at ~1m distance
- Recognize patients via facial recognition (~90% accuracy)
- Retrieve and dispense medication automatically
- Navigate through real-world, dynamic environments

It would be completely self-contained, run on battery, and work without requiring any technical knowledge from the user.

From the nurse's perspective, there's basically no interface - they wear a tag, and the robot follows.

### Internally...

The robot is constantly pulling in data from multiple places:

- A camera for patient recognition
- A LiDAR for mapping and obstacle avoidance
- A UWB system for tracking the nurse (courtesy of yours truly!)
- Internal state from motors and encoders

All of this feeds into a ROS2-based software stack running on the onboard computer.

This was NOT easy. How I _wish_ all it entailed was just... plugging in various components to one-another.

Some issues we ran into:
- UWB is a pain in the ass - I spent weeks writing drivers for the wrong sensors, which would cost thousands more (and eat away at our budget) and require us to install fixed-point sensors across any room we wanted to navigate around
- Nix and ROS do _not_ play nice with one another, I spent far too long trying to make this happen
- Running (multiple!!!) transformer models on a Raspberry Pi powered by a powerbank _while_ it's consuming UWB data packets, running ROS, LiDAR, etc... is a bad idea, we crashed the robot multiple times and was convinced we'd kill the Pi at some point
- Single 180 degree sensor in the front + a slow robot = the signal gets flipped when the user walks behind the robot before it can turn around
- Smoothing noisy UWB data is an adventure (we used something we dubbed "cow filtering" because we found the approach from a paper that used UWB tags to track cow movement on farms)

![diagram](/static/robot-diagram.png)

### End results

We set up obstacle courses, makeshift mazes, and all sorts of weird paths for it to navigate, and it handled most of them surprisingly well.

At the end of the day, we didn't really expect this to be actively deployed in hospitals. We did _ask_ some doctors if we could, but were met with a resounding _"no"_. But hey, if someone were to take this idea and better align it with internal policies and whatnot, maybe it could be a real thing!

Check out our final report [here](/static/FYP.pdf).