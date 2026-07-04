---
title: "Baby's guide to attention"
template: "post"
tags: ["post", "ai"]
date: "July 4, 2026"
---

### What is self-attention?

Self-attention is the mechanism that allows each token to "look at" other tokens in the sequence and decide which ones are relevant.

But instead of directly comparing tokens to each other, the model first projects each token into three different representations:

- Query (Q) - what am I looking for?
- Key (K) - what do I contain?
- Value (V) - what information do I actually pass along?

For every token vector `x`, the model computes:

```
Q = xWq
K = xWk
V = xWv
```

where `W_q`, `W_k`, `W_v` are learned weight matrices.

> I need to add KaTeX support, huh...?

At this point, nothing has really *happened* yet - we've just created three different "views" of the same token.

Another way to think about it:
- Query = the question this token is asking
- Key = the label this token offers to others
- Value = the actual content this token contributes

So instead of tokens directly interacting, we've set up a kind of lookup system.

### How do tokens communicate?

Each token's **Query** is compared against every other token's **Key** using a dot product:

```
score(i, j) = Q_i \cdot K_j
```

This gives us a raw measure of how much token `i` *cares* about token `j`.

So if we're at token "he" in a sentence like "Alice gave Bob the book because he...", the model is effectively asking which earlier tokens is *relevant* to "he"?

These scores are then scaled and normalized:

```
attention(i, j) = softmax(Q_i · K_j / sqrt(d))
```

> The `sqrt` term stabalizes crazy large vector values.

Thus, after softmax, we now have a proper distribution:
- Everything is positive
- Everything sums to 1
- We can interpret it as "how much attention each token gets"

### Mixing information

Once we have these attention weights, we use them to mix information from the **Value** vectors:

```
output(i) = \sum attention(i, j) * V_j
```

So each token becomes a weighted combination of all previous tokens, which ties in to the key idea behind attention in the first place, that **each token is rewritten as a mixture of other tokens, weighted by relevance**.

So instead of `"he"` being just `"he"`, it becomes something like:

```
- 0.8 * "Bob"
- 0.1 * "Alice"
- 0.05 * "book"
- 0.05 * "because"
```

After this step, every token now contains *context*.

### With great power...

So, it should be pretty obvious why this is powerful! It's what allows transformers to handle pronouns, long-range dependencies, implicit relationships, structure in messy text, etc...

It's also why transformers replaced older architectures like RNNs - because they don't have to process text strictly left-to-right in their *internal representation*.

But it's also what's caused some of the biggest problems with modern LLMs - context! When we say context, we are almost always referring to the extent to which attention can be computed. We need to "look back" at our previous tokens to compute attention.

> That is to say, every token compares itself to every other token! For a sequence of length `n`, we compute an `n x n` attention matrix, meaning the attention cost grows quadratically with sequence length! This is why long context models are expensive, and why so much research goes into making attention faster (FlashAttention, sparse attention, etc).

In any case, we still need to maintain those _huge_ vectors in our VRAM. As such, as models and needs grow, we need more and more compute. Thus, datacenters. Oh well.