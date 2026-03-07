(how-to-get-involved)=
# How to get involved in the QIIME 2 community

There are many ways to get involved in the QIIME 2 community, and these approaches span different skill sets: you don't have to be a software developer to get involved!
Here are some recommendations.

## Become active on the QIIME 2 Forum

["The Forum"](https://forum.qiime2.org) is the hub of the QIIME 2 community, and getting involved generally starts there.
Start by answering questions in areas that are relevant to your expertise.

Additionally, if the team that you work on (if applicable) has built existing tools that are in use by the community, consider stewarding those if there isn't already an active maintainer.
That could include:
- Answering questions about those tools on the forum when they come up.
 [You can configure your forum account](https://meta.discourse.org/t/understanding-discourse-for-new-users/96331) to notify you based on posts to categories or tags.
- Testing old installation instructions and tutorials, and bringing them up to date as needed.
- Formally deprecating tools if your team no longer thinks they're relevant, or if they're in a non-working state and aren't maintained any longer.
 This usually includes adding a prominent note to the tool's website or code repository to help new users who stumble on it avoid wasting time ([here's an example](https://github.com/mortonjt/q2-ancombc/blob/main/README.md)).

## Teach a workshop

Anyone can teach a QIIME 2 workshop.
To make it easier, we created and maintain a workshop version of our Docker containers.
You can find instructions on how to use this in [](#workshop-container).
You can also find full video courses on QIIME 2 on our [YouTube channel](https://youtube.com/qiime2) - feel free to reference those and/or reuse any content (just be sure to attribute it to the creator as necessary).

It's never too early to start teaching what you know, and it's a fantastic way to solidify your knowledge and build your skill set.
If you've never done something like this before, start small: for example, present to other students in your cohort, or to your lab group.
From there, you can go bigger: your department, university, or local region.
If you want to reach a really big audience, consider doing this online and/or creating a video or video series.[^online-workshops]
If you're allowing others to register for your workshop, please consider posting about it on the QIIME 2 Forum.

A couple of examples of workshop series that have been running for multiple years and were advertised on the QIIME 2 Forum are [Metabarcoding in Microbial Ecology](https://forum.qiime2.org/t/online-course-metabarcoding-in-microbial-ecology-feb-2025/31362) and [ISB Virtual Microbiome Series](https://forum.qiime2.org/t/course-announcement-2023-isb-virtual-microbiome-series/27656).

```{note}
We're in the process of updating our workshop listing, previously at `https://workshops.qiime2.org`.
When the new page goes live, [we'll provide instructions](https://github.com/caporaso-lab/using-qiime2/issues/24) for adding your workshop to the list.
```

## Build a plugin

If you're a developer and want to add functionality to the QIIME 2 ecosystem, consider creating a plugin.
You can find detailed documentation in [*Developing with QIIME 2*](https://develop.qiime2.org) on [how to build a plugin](https://develop.qiime2.org/en/latest/plugins/tutorials/intro.html), [how to have it listed on the QIIME 2 Library](https://develop.qiime2.org/en/latest/plugins/how-to-guides/distribute-on-library.html), [tips on how to publicize it](https://develop.qiime2.org/en/latest/plugins/how-to-guides/publicize.html), and more.

For the sake of efficiency, QIIME 2 functionality is intentionally decentralized.
It's generally much quicker to get your tools out there if you're building and distributing your own plugins as opposed to adding functionality to other people's plugins.
If you're building your own, you're in charge of when it's ready to go out to users; if you're contributing to someone else's plugin, their code review schedule may be a bottleneck for you.

You can find additional notes about contributing code in the [Contributing Guide](https://github.com/qiime2/.github/blob/main/CONTRIBUTING.md).

## Create and share documentation, or something else that can help other users

Documentation created by users makes up some of the most highly accessed content on the QIIME 2 Forum.
For example, as of this writing, 7 of the 10 most view posts on the Forum are documentation products led by users:

```{image} ../_static/2025.03.03-top-forum-posts.png
:alt: List of top posts on the QIIME 2 Forum as of 3 March 2025.
```

For examples of the other types of content or tools created as contributions to the QIIME 2 ecosystem, see [Community Contributions](https://forum.qiime2.org/c/community-contributions/15) on the Forum.
Creating and sharing things that you find useful is a great way to get involved in the community and to connect with others with similar interests.
Just be sure that what you're sharing is reliable, and be responsive to questions you get.

```{note}
We're in the process of updating the QIIME 2 Library to contain a catalog of documentation.
When that functionality goes live, [we'll provide instructions](https://github.com/caporaso-lab/using-qiime2/issues/25) for adding your documentation to the catalog.
```

## Thank you!

Thanks for your interest in getting involved in the QIIME 2 community - we couldn't do it without you!
See you on the [QIIME 2 Forum](https://forum.qiime2.org)!

[^online-workshops]: For a discussion of our experience with teaching online workshops, see [Dillon *et al.* (2021)](https://doi.org/10.1371/journal.pcbi.1009056).
