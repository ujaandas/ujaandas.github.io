---
title: "Graphic design is my passion!"
template: "post"
tags: ["posts", "web"]
date: "May 19, 2026"
---
Just kidding. I kind of suck at it. But I think that's part of my charm.

![](https://www.marketingbrew.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fbl383u0v%2Fproduction%2Fb8bf3938336ab457e1045e90fe737ce0c59f1cde-1500x1000.jpg%3Frect%3D1%2C0%2C1498%2C1000%26w%3D412%26h%3D275%26q%3D80%26fit%3Dmax%26auto%3Dformat%26dpr%3D2.625&w=828&q=75)

Anyways, I made some pretty neat stylistic changes to [ujaan.me](https://ujaan.me/)! You'd be surprised at how little it takes to make your website look a little cooler.

Previously, I had a stark white background, now, it's a little warmer, using Tailwind's very handy-dandy `bg-stone-50` (which corresponds to `#fafaf9`).

On top of that, I made my links slate by default, and turn a darker blue instead of staying neon blue throughout. Also, I added the transition property and some funky tweaks to animate the underline fade-in:

```css
a {
    @apply underline decoration-transparent hover:decoration-current transition-all underline-offset-4 decoration-2 duration-100
}
```

Oh, I also added more/better tags to posts, and just threw everything on the landing page instead of splitting posts and projects up. 

I also updated to the new and improved `oojsite`!

I'll probably be re-writing a bunch of my old project posts too. Stay tuned for those.