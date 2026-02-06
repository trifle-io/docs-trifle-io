---
title: Trifle
description: Learn how Trifle uses Trifle::Docs right here!
nav_order: 1
---

# Trifle Documentation

*Link*: [docs.trifle.io](https://docs.trifle.io) 

Yeah, this documentation is build on top of `Trifle::Docs`. You can see its sourcecode in the public [repository](https://github.com/trifle-io/docs-trifle-io).

I could try to show you all the building blocks of this page, but that would be like having dream within a dream.

![logsinception](trifle/inception.png)

Instead, let me give you little back story. I've been fan of static site generators for quite some time. Trifle started way before the docs has came to my mind. Previous version of documentation has been build on top of Hugo. Hugo version was live throughout 2021 and most of 2022 until Docs inception (pun intended). Back in 2020 I've worked on another Open Source project called [LedgerSync](https://ledgersync.dev). This documentation has been build on top of Jekyll. I've had also my personal homepage build on top of Hugo (but I've discared it since).

Both Jekyll and Hugo gives you a great toolset for writing your content. I believe the target user for both of these are developers. Unfortunately as a developer I've always struggled with two parts: their data and their themes.

For whatever reason, they try to do too much. And I get that, its a static site, so to do _somewhat_ dynamic stuff, you need sections and paginations and data files and liquid templating and omg it keeps adding up.

That brings me to my next issue. When you add all these together, building a theme for it is not straightforward process. Same goes for modifying any existing one. I've been stuck one too many times trying to figure out why something wasnt reflecting in the UI.

As I said before, I always liked the simplicity of writing down markdown files and using folder structure to map it to URLs, but I rarely enjoyed or needed any of the additional complexity.

Another thing that has always puzzled me is how companies are OK with having their homepage and documentation having completely different feel. I understand 3rd party services may not let you do much customisation, but many of the docs are build inhouse and they simply feel like docs has been outsourced.

Therefore insteaad of trying to fit my usecase into existing tool, I've decided to create one myself. After all, it's just a router and renderer for a static markdown files. How hard could that be.
