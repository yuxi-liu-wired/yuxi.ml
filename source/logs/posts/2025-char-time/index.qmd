---
title: "Characteristic time in finance"
author: "Yuxi Liu"
date: "2025-05-01"
date-modified: "2025-05-01"
categories: [finance, physics]
format:
  html:
    code-fold: true
    toc: true
    resources:
        "figure/**"
description: "Application of a simple concept from physics to personal finance."

status: "finished"
confidence: "log"
importance: 3
shorturls: [char-time-finance]
---

A simple physics concept: characteristic time.

What's a "characteristic X"? It's the minimal "chunk of X" that you can use to simulate a continuous physical system as a discrete system, and still get roughly the same thing.

Different systems have different characteristic scales, and pinning them down is a big part of "getting a feel" for any problem. When physicists "babble around" a new system, they are really hunting for those characteristic times, lengths, energies, and so on. Study a system out of characteristic, and you miss the point entirely.

The standard example is the climate versus weather distinction. For global climate, the characteristic time and length are on the order of a day and a kilometer. For local weather, they shrink to a minute and a meter. Trying to predict a summer thunderstorm with climate-scale spacetime is like using a world map to find the nearest supermarket.

Financial markets follow the same rule. Every trading agent -- human or otherwise -- has a personal characteristic time. When markets are inefficient, trading is profitable, but only if you act within your characteristic time. Trade faster than that and your "information" dissolves into noise.

Both markets and weather have changed over the last century. Once upon a time, some humans could profitably trade on characteristic times of hours or even minutes. Those days are gone. [HFT](https://en.wikipedia.org/wiki/High-frequency_trading) algorithms now slice that interval into a million statistical arbitrages. Because of this, since about 2010, the viable characteristic time for humans has stretched to roughly one week to one month. Day-trading is no longer possible for any biohuman; at most, analyze, plan a portfolio rebalance, and execute next week or next month.

-- Unless you enjoy trading. If that is the case, sure, go forth and day-trade. The price is that you must bleed and shed skin for the HFT piranhas.

> One reason is that they like to do it. Another is that there is so much noise around that they don't know they are trading on noise. They think they are trading on information. Neither of these reasons fits into a world where people do things only to maximize expected utility of wealth, and where people always make the best use of available information. Once we let trading enter the utility function directly (as a way of saying that people like to trade), it's hard to know where to stop. If anything can be in the utility function, the notion that people act to maximize expected utility is in danger of losing much of its content.
>
> [@blackNoise1986]

-- Unless you hold truly high-grade information, but in that case, why are you reading this? Go make your insider's fortune.

## Metadata {.appendix}

Originally posted on [twitter](https://x.com/layer07_yuxi/status/1910111404558008454) on 2025-04-09.