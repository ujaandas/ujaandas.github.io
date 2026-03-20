---
title: "Terraviz - Actionable Environmental Data"
template: "project"
tags: ["projects"]
date: "February 1, 2026"
thumbnail: "/static/terraviz.png"
---

TerraVysers was our weekend-long descent into the world of geospatial intelligence at IC Hack '26. The challenge prompt was about "using data for predictions and decision-making," which is one of those phrases that sounds straightforward until you realise the data in question is scattered across a dozen global datasets, half of which require some obscure, random API.

Still, we figured: environmental data is everywhere, but actionable environmental insight... not so much. So what if we built something that could take all that raw climate, soil, and satellite information and turn it into something a policymaker, a farmer, or even a market maker could understand?

### The Big Idea

The core premise behind TerraVysers is simple: pick a region on a map, and we tell you something meaningful about it, actual predictions - things that help you make decisions.

We ended up building a platform that could:

- Forecast soil erosion risk using a RUSLE-inspired model
- Estimate carbon sequestration potential for reforestation
- Flag crop yield risk for wheat across Europe

Basically, if it lives on land and depends on climate, we tried to model it.

The system is modular, so new datasets or models can slot in without rewriting the whole pipeline - a small miracle considering we built this in under 48 hours and half the team met each other for the first time on Saturday morning.

### Inner Workings

Under the hood, TerraVysers pulls from:

- Global rainfall datasets for erosion drivers
- Soil property APIs for composition and erodibility
- Sentinel‑2 NDVI for vegetation cover
- A modular prediction layer for carbon and crop models
- A reporting layer that spits out GeoTIFFs and summary stats

Everything is aligned to a consistent grid so the overlays don't look like a geological ransom note.

### So, Then What?

By the end, we had:

- A unified pipeline that fused satellite, soil, and climate data
- A carbon sequestration model that actually produced reasonable outputs
- A crop yield risk predictor for wheat across Europe
- A 3D map-driven interface that turned all of this into something a policymaker could _actually_ read!

![diagram](/static/terraviz-demo.png)

And yes, we did manage to explain it to the judges in under 180 seconds - though one of them did think we built a tool to find wet soil, which is... technically not wrong, just not really the point.

### What's Next

TerraVysers isn't meant to be a pretty map. It's meant to be a decision engine - a way to turn environmental data into operational guidance for land use, climate strategy, and food security.

And for a weekend project, I think we got surprisingly close!
