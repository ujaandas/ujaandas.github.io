---
title: "FlowLens - Graph-Based Agent Testing"
template: "project"
tags: ["projects"]
date: "November 19, 2025"
thumbnail: "/static/flowlens.jpg"
---

AI agents are everywhere now - customer support, workflow automation, internal tooling - but almost nobody is testing them for security vulnerabilities in a structured manner. Prompt injection? Input sanitisation? State leakage? Most people just ship their LangGraph agent to production and pray.

So we built a visual red‑teaming platform specifically for LangGraph systems. Think of it as a security playground where you can drag‑and‑drop attack nodes onto your agent workflow and watch, in real time, as your "robust" AI gets absolutely folded by a fuzzer or a prompt injection attack.

### The Stack

- FastAPI on the backend for streaming execution (Server‑Sent Events, because we wanted real‑time logs without WebSocket overhead)
- Next.js on the frontend for a smooth, interactive graph editor
- LangGraph as the execution engine, with our testing nodes injected directly into the workflow
- An OpenAI API compatible LLM of your choosing powering the fuzzer node for adversarial prompt generation

![diagram](/static/flowlens-diagram.png)

### What It Does

At its core, the platform lets you:

- Load any LangGraph workflow as a visual graph
- Drag testing nodes (fuzzer, prompt injection, validation, etc.) directly onto the graph
- Execute the entire workflow with attacks injected at specific points
- Watch nodes light up in real time as logs stream in
- Get an AI‑generated security report the moment execution finishes

![diagram](/static/flowlens-demo.png)
![diagram](/static/flowlens-1.png)

Check out the repo [here](https://github.com/ujaandas/gah2025/)!
