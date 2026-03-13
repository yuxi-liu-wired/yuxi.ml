---
title: "The cost of O'Neil habitation"
author: "Yuxi Liu"
date: "2025-04-18"
date-modified: "2025-04-18"
categories: [fun, scifi, economics]
format:
  html:
    code-fold: true
    toc: true
    resources:
        "figure/**"
description: "To win (?) a twitter argument, we calculated the energetic cost of O'Neil habitat per person. Oddly, it is just affordable by modern standards, ~0.72 million USD per person. Let it be known that the SF housing crisis is cheaper to solve by building O'Neil cylinders."
image: "figure/O'Neil%20cylinder.png"

status: "finished"
confidence: "log"
importance: 1
shorturls: [oneil]
---

{{< include ../../../static/_macros.tex >}}

## How expensive is a standard O'Neil cylinder?

Assuming standard golden-age sci-fi technology, the marginal cost per person on an O'Neil cylinder should be about 24 TJ, just to get all the raw material off the moon/asteroid and into orbit. The cost is 25× if launching from earth. The construction costs are unknown, but should be less than that.

| item | mass/ton | cost / TJ |
|---|---|---|---|
| farm with vineyard | 2000 | 20 |
| suburb house with yard and white picket fence | 160 | 1.6 |
| standard parkland (per person) | 250 | 2.5 |

Modern humans consume about 10 kW per person, so the cost of getting everything into orbit is about equal to 72 years of power consumption. This makes it just about affordable by modern economic standards. Assuming modern electricity price, it would cost about \$0.72M, which is half the median price of listed houses in San Francisco ([Source](https://www.redfin.com/city/17151/CA/San-Francisco/housing-market)).

![The O'Neil cylinder art used as reference.](figure/O'Neil%20cylinder.png)

Talked over with [GPT o3](https://chatgpt.com/share/6802d4a2-7f08-800a-8545-7c2de08e4b21).

### Why bother?

Because [someone might be wrong on the Internet](https://xkcd.com/386/)!

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">this is me: <a href="https://t.co/2PTP1LpJ4d">https://t.co/2PTP1LpJ4d</a></p>&mdash; croissanthology (\@croissanthology) <a href="https://twitter.com/croissanthology/status/1913216595993776186?ref_src=twsrc%5Etfw">April 18, 2025</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

your desires are out of date  
click >>HERE<< to hypernovate

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">I&#39;m sorry, but this is just the most asinine thing imaginable, I mean just look at that, pure 70s suburbanite boomer logic scaled way beyond its paygrade <a href="https://t.co/xahab9pHXO">pic.twitter.com/xahab9pHXO</a></p>&mdash; Yuxi on the Wired (\@layer07_yuxi) <a href="https://twitter.com/layer07_yuxi/status/1913348670445203579?ref_src=twsrc%5Etfw">April 18, 2025</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

### Mass cost

The general rule: 1 m² of land or 1-person building, requires ~1 m of depth and ~1 ton of mass. Water has density ~1 ton/m³, and loose dry soil has density ~1.3 ton/m³. This general rule is correct within a factor of 10 under most variations. For growing plants and crops, the mass ratio of soil to water is about 5 to 1.

The farmland to support a person is between 0.5 to 2 acres depending on the specific diet. ([Source](https://news.cornell.edu/stories/2007/10/diet-little-meat-more-efficient-many-vegetarian-diets)) The hypothetical suburban solarpunk probably wants to stick to the vegetarian + diary diet and work with their own two hands, so 0.5 acres = 2000 m² should be enough.

As for the vineyard, the French consumes [6 liters of wine a year](https://ourworldindata.org/grapher/wine-consumption-per-capita), which requires about 20 kg of grapes. Vineyard can produce about 1 to 3 ton/acre ([Source](https://www.enologyinternational.com/yield9.php)), so that gives about 40 m², which is negligible. There should be plenty of room for the extras. Together, let's say it would take 2200 m² of farmland.

The typical root depth for most crops is ~0.6 m, giving 1300 m³ of soil, or 2000 ton.

The standard parkland in American cities averages to about 1 acre per 100 people, or about 40 m² per person. ([Source](https://www.nrpa.org/about-national-recreation-and-park-association/press-room/new-report-shows-the-typical-park-and-rec-agency-has-one-park-for-every-2181-residents/)) Most of the park can be grassland, so we assume 0.3 m of depth.

It is unclear how much of the parkland area is portioned for water. Looking at a satellite map of the NYC central park, it seems like ¼. The artificial lake should be about 10 m deep (the depth of the [NYC central park's lake](https://en.wikipedia.org/wiki/Jacqueline_Kennedy_Onassis_Reservoir)), but that is quite expensive. So, about 100 m³ of soil and 100 m³ of water, giving about 250 ton.

To build the classic suburban house with a small grassland and white picket fence ~~and 2.5 kids~~, we need two parts: the ground and the house.

The ground just needs to support grass, so again 0.3 m deep. US Census shows single‑family lots of 0.32 ac (≈1 300 m²) for 1970‑era builds ([Source](https://www.census.gov/content/dam/Census/programs-surveys/ahs/working-papers/Housing-by-Year-Built.pdf#page=3)). That gives 400 m³ = 500 ton of soil. The water in the soil would be about 100 ton.

A standard house on earth needs a deeper foundation, but they don't need that on an O'Neil cylinder, since it can be directly supported on the "bedrock" below. As for the mass of the house itself, according to ["The Weight of New York City" (2023)](https://doi.org/10.1029/2022EF003465), the mass of the built environment in New York City is about 1 ton/m². So taking that as the cost of housing per person, including the concrete, the steel, etc, we estimate the housing cost is about 200 ton.

So the 1970s suburb house costs about 800 ton, for a family of 5, or 160 ton/person.

### Launch cost

The prompt:

> Something that would make sense in a hard golden age sci-fi. Something in which an ONeil cylinder might feature without being out of place. Not too weak but not too strong either, since either way, the ONeil cylinder would be out of place, much like it would be out of place for a horserider to deliver a flashdrive.

The cost of launching mass into space varies. The most expensive method is to launch from earth using chemical rockets. The main cost are two: paying the gravitational energy (63 MJ/kg), and the wasted energy in accelerating the rocket and the fuel. Using some kind of pure launch system (such as a coil gun or a space elevator) would come close to eliminating the second kind of waste.

Mining from moon would decrease the first kind (The escape velocity of moon is 1/5 that of earth, so the energy saving is ~25×, to just 3 MJ/kg). Mining from asteroids would mostly eliminate the first kind.

GPT o3 suggested that the cost of pure-launch from the moon is about 7 MJ/kg, which seems kind of accurate? Feels too optimistic to only cost 2× that of the bare minimum. Rounding it up to 10 MJ/kg.

### Upkeep cost

Apparently *after* launching all that stuff into orbit, the upkeep for all that stuff is not more expensive than on earth, assuming that the structural components holding the cylinder together and the air inside from leaking don't cost much energy to maintain. Carbon-glass fibers are okay. Rocket engines constantly pushing the hull inwards are not. Purpose-engineered organisms with infused self-healing biomineral bones and sinews... possibly?

So that would be about 10 kW/person, the average power consumption per Canadian human in 2023. ([Source](https://ourworldindata.org/grapher/per-capita-energy-use))

## Is image segmentation with Gemini 2.5 worth it?

[Simon Willison reports](https://simonwillison.net/2025/Apr/18/gemini-image-segmentation/) that Gemini 2.5 can return image segmentation masks as base64 encoded PNGs embedded in JSON strings, and estimated that the cheapest option is by Gemini 2.5 Flash non-thinking. Specifically, for a photo of resolution 1000×1000, with 2 non-overlapping objects (2 pelicans in flight), masking and boxing cost 303 input tokens and 123 output tokens, for a price of \$1e-4/image.

How good is it compared to standard SOTA methods, like SAM and YOLO?

The SAM 2 series of models take 0.01 to 0.03 seconds per image ([Source](https://github.com/facebookresearch/sam2?tab=readme-ov-file#sam-2-checkpoints)) on an Nvidia A100 as of 2024. Current price of A100 rental is about \$1.5/hr, so the cost is \$4e-6 to \$1e-5/image in batch mode.

As for YOLO, the YOLOv8x achieved 280 frames per second on A100, ([Source](https://arxiv.org/pdf/2406.10139v1)) so that costs about \$1.5e-6/image.

How about latency? YOLO and SAM are both locally hostable, but Gemini is only available across an API call. The throughput is about 1 second per 100 tokens, while the latency (time until first token) is about 10 seconds, so let's call it 1--10 seconds. ([Source](https://artificialanalysis.ai/models/gemini-2-5-flash))

| model | latency (ms) | cost per million image (USD) |
|----|----|----|
| `YOLOv8x` | 4 | 1.5 |
| `sam2_hiera_tiny` | 10  | 4 |
| `sam2_hiera_large` | 30 | 10 |
| `Gemini 2.5 Flash` (nonthinking) | 1000--10000 | 100 |
: Summary table for the cost and latency of various object boxing and masking systems.

Well, it's certainly not good for any large-batch processing, but pretty impressive that it is within a factor of 10 compared to `sam2_hiera_large`.

## Appendix: the tweet thread {.appendix}

### Thread 1

([Source](https://x.com/croissanthology/status/1910846754657890798))

**niplav** `@niplav_site` — Apr 11  
> likely  
>  
> (I'm very in favor of doing the efficient thing)  
>  
> I suspect it entails not dyson swarms but disassembling the stars and/or forging them into black holes, maybe aestivating  

**croissanthology** `@croissanthology` — Apr 11  
> yeah definitely not dyson swarms either, I just think they also happen to be cuter than shkadov thrusters  

**niplav** `@niplav_site` — Apr 11  
> hm  
>  
> cuteness: dyson swarms>shkadov thrusters>criswell star lifting  
> awesomeness: shkadov thrusters>criswell star lifting>dyson swarms  
> terror: criswell star lifting>shkadov thrusters>dyson swarms  

**croissanthology** `@croissanthology` — 5:05 PM · Apr 11 · 186 Views  
> I'm sorry, but this is just the most asinine thing imaginable, I mean just look at that, pure caveman logic scaled way beyond its paygrade  

\[Image of a Shkadov thruster\]

**croissanthology** `@croissanthology` — Apr 11  
> groo want shiny round thing move, groo redirect surface radiation of thing with giant mirror, groo satisfied, groo wait, groo patient, groo worried embers of shiny round thing go out, but groo patient  

**croissanthology** `@croissanthology` — Apr 11  
> it grow dark for groo. groo patient. groo faithful. groo still hopes. another day come for groo. groo hopes.  

**niplav** `@niplav_site` — Apr 11  
> yes, it's great :-D  
>  
> "I am launching a star in your general direction. Pray I don't launch more."  
>  
> it's so barbaric I love it  

**croissanthology** `@croissanthology` — Apr 11  
> thag look with worry at shiny round thing coming his way. groo patient. thag worried. shiny round thing slow. thag laugh. thag go on with life. this seem like problem for great-grand-thag.  

**Manic Pixie AGI** `@manic_pixie_agi` — Apr 12  
> *great grand thag reporients the device back at great grand groo*  
> "A problem for great great great grand groo"

### Thread 2

([Source](https://x.com/layer07_yuxi/status/1913358799844655152))

**near** `@nearcyan` — Apr 16  
> seems kinda clear we are definitely getting the 'software singularity' far, far before the 'hardware singularity', which seems.. more delayed than ever  
>  
> and paul christiano-esque takes seem to have panned out very well  
>  
> so, kinda full cyberpunk timeline? almost too predictable?

**imit** `@imitationlearn` — Apr 17  
> how is this cyberpunk? cyberpunk seems like it requires quite a bit of hardware dev to me

**croissanthology** `@croissanthology` — Apr 17  
> I'd call a reality where everything is the same as now but we're all wearing VR / ghibligoggles all the time cyberpunk, despite that being almost entirely software.  
>  
> Similarly, when I walk past parks in french suburbia and half the people are sitting or standing in the shade watching tik tokk, that feels very cyberpunk to me

**Yuxi on the Wired** `@layer07_yuxi` — 19h  
> eh that seems way too utopian to be cyberpunk

**croissanthology** `@croissanthology` — 14h  
> I think I'm a lot more narrowly anthropic/humanist than people in my simcluster. Glued to VR is one of the hopeful timelines but still it manages to disgust me, and so seemed suitably cyberpunk.  
>  
> to be clear my circle under "humanist" comprises LLMs and whatever it is Yuxi is. Maybe it's from being fed endless classic futurism as a kid, but my brain can't manage to extrapolate a better future than  
>  
> "solarpunk animism shire galaxy harvesting o'neill cylinder sit under his own vine greener grass transhumanism"  
>  
> very primal and hunter gathery of me, I admit. But anyway my dystopian tolerance is pretty low, as my environment  measures such things.

**Yuxi on the Wired** `@layer07_yuxi`  
> I'm sorry, but this is just the most asinine thing imaginable, I mean just look at that, pure 70s suburbanite boomer logic scaled way beyond its paygrade

\[Image of that O'Neil cylinder\]

**croissanthology** `@croissanthology` — 5h  
> yeah tbc I do know these are inefficient as hell and everything that lives will end up running on a ~chip, and the O'Neill cylinders were just generally gesturing in the direction my brain currently thinks of as "utopia"

**Yuxi on the Wired** `@layer07_yuxi` — 5h  
> Yes, we understand. We have desires too that are too inefficient to exist and will be burnt away in the coming Singularity like morning dew.  
> In Bostrom's words, these desires are "astronomical waste".  
> But just for the record, here is what we understand as cyberpunk:

\[Screenshot of [*Meltdown*](http://www.ccru.net/swarm1/1_melt.htm) going from "[[ ]] Meltdown has a place for you" to "untouched by human feeling.". \]

**norvid_studies** `@norvid_studies` — 4h  
> i think that's pretty much the exact opposite of what bostrom meant by the term lol. not that terminological repurposing isn't the birthright of every free twittizen

**Yuxi on the Wired** `@layer07_yuxi` — 4h  
> Exact opposite? This is clearly just standard Bostromian astronomical waste: Building O'Neil cylinders to house like 1 million slow beings, when all that energy could have been used to power a micro-sector of a Dyson swarm containing 1 trillion trillion fast beings?

**norvid_studies** `@norvid_studies` — 4h  
> if the successor entities have the same desires just run much faster and denser, then yes the bioform version is astronomical waste in the bostrom sense-- you're leaving fat juicy qualia on the table

**norvid_studies** `@norvid_studies` — 4h  
> if they don't and it's more of a 'disneyland with no children scenario' then  
>  
> the so-called waste being competed out of existence is the original desired thing we were bemoaning was being wasted by the dead empty cosmos in the first place; in which scenario it would be "the opposite" of what he meant there.