---
title: "Baby's guide to LLMs"
template: "post"
tags: ["post", "ai"]
date: "July 4, 2026"
---

My dissertation essentially involves writing an inference library to enable better/more "correct" constrained generation, so with that comes learning as much about LLM internals as possible. So, I figured I might as well put it into writing, not just to help me understand it better, but perhaps to also help "redistribute" some knowledge.

This post covers some of the more "foundational" aspects thereof.

### What is an LLM?

At it's core, an LLM is a function, akin to any other "classical" language model:

```
f(tokens) -> probability distributions over next token
```

Thus, given a "prompt", internally, it converts it to a set of tokens, and calculates the probability distribution of next possible tokens, and picks the most likely one (though, in the case of modern LLMs, this is not the case, and some element of randomness is applied here, thus why the same prompt can lead to several different outputs at times).

> Strictly speaking, an LLM does _not_ return probabilities like a classical LM, but rather, **logits** - unnormalized scores that can range from `-infty` to `+infty`.

### What are tokens?

As we all know, computers don't understand words. They need something numerical which can eventually be represented in binary. So before an LLM can do anything useful, your input needs to be converted into a sequence of integers.

This process is called **tokenization**.

An LLM ships with a **tokenizer**, whose sole job is to translate between text and token IDs:

```
"The capital of France is Paris."

->

[791, 3941, 328, 9822, 374, 8543, 13]
```

While it might look like `token == word`, this is not really the case.

Some tokens *are* whole words, but others are *parts* of a word, like various stems/lemmas (e.g. "un", "believ", "able"). Others are punctuation, whitespace, etc...

Exactly how text is split depends on the tokenizer, but the important thing is that the *model never sees text*. As far as it's concerned, everything is just a sequence of integers.

### What are embeddings?

Still, these numbers don't really *tell* us anything. They don't *mean* anything. 

Suppose the tokenizer tells us:

```
Paris -> 8543
London -> 10392
Banana -> 271
```

`8543` isn't "closer" to `10392` than it is to `271`, even though Paris and London are much more semantically related.

The first thing an LLM therefore does is look up every token in a gigantic table called the **embedding matrix**.

Thus, instead of representing a token with a single integer, we now represent it with a long vector of floating-point numbers,
where each dimension of the vector represents some abstract meaning or concept associated with the word. 

> The precise meaning of each dimension is largely irrelevant, though you can probably figure out what they might mean. A fun experiment or "example" we often learn is that in Word2Vec, an embedding database, the distance between the "queen" and "king" vectors is largely similar to the distance between "woman" and "man"!

Modern models might use vectors with thousands of dimensions (4096 isn't uncommon).

Again, you don't really need to know what every number means - the important part is that tokens which appear in similar contexts end up with similar vectors.

Thus, we now have a way to represent *meaning*, rather than just text.

### What is a transformer?

Now, assuming we have some list of vectors that represent our sentence, in an LLM, these vectors are often passed through a stack of **tranformer blocks**. 

Modern LLMs might have anywhere from a couple dozen to over a hundred of these blocks, but they all do roughly the same thing.

Each block takes the current vectors, updates them, and passes them to the next block, and to the next, and to the next, and so forth, until the end where we receive our probabilities/logits.

Obviously the deeper intrinsics of the transformer model are way beyond the scope of this post, but what's interesting is *how* those vector updates are made.

### What is attention?

Suppose we're halfway through reading this sentence:

>Alice gave Bob the book because **he...**

When we encounter the word "he", we naturally ask ourselves:

> Who is "he" referring to?

The transformer asks a surprisingly similar question.

For every token, it decides how much attention it should pay to every previous token in the sequence.

For example, "he" might attend mostly to "Bob":

```
Alice      0.08
gave       0.04
Bob        0.79
the        0.02
book       0.05
because    0.02
```

Those numbers become weights that determine how information flows through the network.

This mechanism is called **self-attention**, because every token can "look at" every previous token.

It's this ability to relate different parts of a sentence that made transformers such a huge leap over previous language models.