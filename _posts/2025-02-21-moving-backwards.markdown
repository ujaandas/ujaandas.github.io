---
layout: post
title: "Moving Backwards? Next.js to Jekyll"
date: 2025-02-21 00:50:20 +0800
categories: jekyll next.js webdev
---

I find it a little ironic that my first _real_ blog post isn't even on the site I spent the most time working on, but rather on the one that was up and running in less than half a day.

As the title implies, I recently switched my personal website and mini "dev" blog from Next.js to Jekyll. You might wonder, why make the switch? Honestly, I'm still trying to come up with reasons myself, but I think the simplest explanation is this:

--- **I didn't need it.** ---

I don't need server components (it's all statically rendered anyway). I don't need TailwindCSS. I don't need the hundreds of unnecessary levels of abstraction and component inheritance. Javascript is dumb, slow and so totally overkill for a static site. I don't need the bloat.

And in hindsight, what the hell was I thinking? With options like Astro, Hugo, Gatsby, etc... there are about a million and three better options for SSG, and I go and pick the single worst one.

I won't deny that Next.js has a good DX, I enjoy the JS ecosystem, and I am entirely comfortable with that stack, but I simply did not need any of it!!!

In any case, Jekyll was a breeze to set up, and its straightforwardness was genuinely appreciated. I didn't have to wrestle with convoluted build processes or endless configurations. Everything just worked, and it was refreshing to get back to the basics and rawdog some HTML.

Jekyll cuts out all the unnecessary complexities, allowing me to focus on what truly matters — creating content. It's lightweight, fast, and perfect for my needs. Plus, the extensive plugin ecosystem means I can still add the functionalities I want without the extra bulk _(ahem, ahem, node_modules)_.

I'll write another blog post soon about how I set up my project with Flakes. For now, I just hope I don't end up ditching this website next year and reverting to just plain HTML.
