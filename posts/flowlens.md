---
title: "Break Your Agents with FlowLens"
template: "project"
tags: ["projects"]
date: "November 19, 2025"
thumbnail: "/static/flowlens.jpg"
---

AI agents are everywhere now - customer support, workflow automation, internal tooling - but almost nobody is testing them for security vulnerabilities. Prompt injection? Input sanitisation? State leakage? Most people just ship their LangGraph agent to production and pray.

So we built a visual red‑teaming platform specifically for LangGraph systems. Think of it as a security playground where you can drag‑and‑drop attack nodes onto your agent workflow and watch, in real time, as your "robust" AI gets absolutely folded by a fuzzer or a prompt injection attack.

### The Stack

We went full-stack for this one:

- FastAPI on the backend for streaming execution (Server‑Sent Events, because we wanted real‑time logs without WebSocket overhead)
- Next.js on the frontend for a smooth, interactive graph editor
- LangGraph as the execution engine, with our testing nodes injected directly into the workflow
- Ollama powering the fuzzer node for adversarial prompt generation

The testing nodes integrate directly into LangGraph's state machine, so you're not testing a mock - you're testing the real workflow with real state transitions.

![diagram](/static/flowlens-diagram.png)

### What It Actually Does

At its core, the platform lets you:

- Load any LangGraph workflow as a visual graph
- Drag testing nodes (fuzzer, prompt injection, validation, etc.) directly onto the graph
- Execute the entire workflow with attacks injected at specific points
- Watch nodes light up in real time as logs stream in
- Get an AI‑generated security report the moment execution finishes

It's not a simulation. You're testing the actual agent, with its real state, real prompts, and real logic.

![diagram](/static/flowlens-demo.png)
![diagram](/static/flowlens-1.png)

We also added Attack Mode, which lets you point the tool at any external API, attach testing nodes, and see how it holds up. It's like Burp Suite, but built specifically for AI systems.

Check out the repo [here](https://github.com/ujaandas/gah2025/)!
