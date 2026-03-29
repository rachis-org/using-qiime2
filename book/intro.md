# *Using QIIME 2*

**Your guide to becoming a QIIME 2 and MOSHPIT power user.**

## Start reading here 👋

:::{div}
:class: col-body-left
As the ecosystem of [distributions](xref:rachis-news-target#term-distribution) and [plugins](xref:rachis-news-target#term-plugin) continues to grow, it has become necessary to make a split in the documentation between general-purpose information that describes how to use `rachis` ([formerly known as the QIIME 2 Framework or Q2F](xref:rachis-news-target#q2f-transition)), and how to apply the tools that build on it to achieve your data analysis goals.
:::

:::{div}
:class: col-gutter-right
<!-- Can't see to get both of these classes working at the same time -->
<!-- :class: dark:hidden -->

```{image} _static/dwq2-light.png
:height: 175px
```
:::

<!--
:::{div}
:class: col-gutter-right
:class: hidden dark:block

```{image} _static/dwq2-dark.png
:height: 175px
```
:::
-->

We know that you're interested in QIIME 2, MOSHPIT, and other `rachis`-based tools primarily for the latter - to achieve specific analysis goals related to microbiome data science - so we'll start by providing references to where you can find that information.
Generally, the [QIIME 2 Library *Stacks*](https://library.qiime2.org/docs) are the place to go to find links to all of the documentation sources.


### Distribution documentation

If you're looking for documentation on how to analyze microbiome marker gene (i.e., amplicon) data, you should refer to the *QIIME 2 amplicon distribution* documentation.
That documentation is in transition and can now be found at https://amplicon-docs.qiime2.org.

If you want to analyze microbiome metagenomic data, refer to the [MOSHPIT](https://doi.org/10.1101/2025.01.27.635007) documentation at https://moshpit.qiime2.org.
(MOSHPIT was referred to as the *QIIME 2 metagenome distribution* during its early development.)

If you're looking for documentation on the `tiny` distribution, you're most likely interested in plugin development.
Welcome!
Your best reference will be [*Developing with QIIME 2*](https://develop.qiime2.org), **our free, online Research Software Engineering text**.

### Plugin documentation

Stand-alone plugins are those that are not included in existing distributions, and these will generally provide their own documentation linked from the [QIIME 2 Library](https://library.qiime2.org).
The list of these is growing, but some current (as of 28 February 2025) examples include:
- [`q2-micom`](https://library.qiime2.org/plugin/micom-dev/q2-micom)
- [`genome-sampler`](https://library.qiime2.org/plugin/caporaso-lab/genome-sampler)
- [`q2-metnet`](https://library.qiime2.org/plugin/PlanesLab/q2-metnet)
- [`q2-boots`](https://library.qiime2.org/plugin/caporaso-lab/q2-boots)
- [`q2-amrfinderplus`](https://library.qiime2.org/plugin/bokulich-lab/q2-amrfinderplus)
- [`q2-fmt`](https://library.qiime2.org/plugin/qiime2/q2-fmt)

### Dataset-specific documentation

We expect to increasingly have documentation that is focused on analysis of specific interesting data sets.
Good examples are the new [gut-to-soil tutorial](https://gut-to-soil-tutorial.readthedocs.io/en/latest/) and the classic [Moving Pictures tutorial](https://moving-pictures-tutorial.readthedocs.io/en/latest/).
These will sometimes cross distributions and stand-alone plugins, for example integrating tools from *QIIME 2* and *MOSHPIT* , and perhaps even [metabolomics plugins](https://doi.org/10.1038/s41596-024-01046-3), to illustrate microbiome multi-omics analysis workflows.

### `rachis` documentation 💃🏻

So what is *Using QIIME 2?*[^1]

*Using QIIME 2* serves as a source for you to refer to when you need to accomplish specific tasks that are general to using `rachis`.
The distributions and plugins described above are all built on `rachis`, so *Using QIIME 2* presents information that is general to all of them.
That includes things like [using `Artifacts` as metadata](#view-artifacts-as-metadata), [replaying provenance](https://github.com/caporaso-lab/using-qiime2/issues/13), [creating and using an artifact cache](#artifact-cache-tutorial), [configuring](#parallel-configuration) and [using](#parallel-tutorial) our [Parsl](http://parsl-project.org/)-based parallel computing framework, and more.

*Using QIIME 2* will also include chapters that can help you understand the system when you want to go deeper, including things like what [Artifacts](xref:rachis-news-target#term-artifact) (e.g., [.qza](xref:rachis-news-target#term-qza) files) and [Visualizations](xref:rachis-news-target#term-visualization) (e.g., [.qzv](xref:rachis-news-target#term-qzv) files) [are](https://github.com/caporaso-lab/using-qiime2/issues/11), and [why you need to import your data before using QIIME 2](https://github.com/caporaso-lab/using-qiime2/issues/12).
**Understanding these topics will help you carry out advanced biological data science workflows and manage the corresponding data, but they aren't strictly necessary for performing data with tools that build on QIIME 2.**

If you're ready to become a `rachis` power user, read on...


```{admonition} Development status of this content
:class: warning
At this time (19 June 2025), *Using QIIME 2* is still in relatively early development as we write new content and pull from existing resources.
As a result some URLs may change, and some content maybe incomplete or have formatting problems.

Searching and reading the [QIIME 2 Forum](https://forum.qiime2.org) can help you answer many of your own questions as it now represents nearly 10 years of questions, answers, and discussion about microbiome data science.
```

## Organization of *Using QIIME 2*

*Using QIIME 2* is organized under the [Diátaxis](https://diataxis.fr/) framework, which categorizes content into *sections* containing *Tutorials*, *How-To-Guides*, *Explanations*, and *References*.
Each serves a different goal for the reader:

```{list-table}
:header-rows: 1

* - Chapter
  - Purpose

* - Tutorials
  - Provide a guided exploration of a topic for **learning**.

* - How To Guides
  - Provide step-by-step instructions on how to **accomplish specific goals**.

* - Explanations
  - Provide a discussion intended to aid in **understanding** a specific topic.

* - References
  - Provide specific **information** (e.g., a list of utilities available through [q2cli](xref:rachis-news-target#term-q2cli)).
```

You can navigate these sections on the left sidebar.

(acknowledgements)=
## Acknowledgements
*Using QIIME 2* is the result of past, present, and future (🤞) collaborative efforts.

The authors would like to thank [those who have contributed](https://github.com/qiime2/docs/graphs/contributors) to the writing of the original QIIME 2 User Documentation.
Some of the content in *Using QIIME 2* is sourced directly from that material.

The QIIME 2 Forum [moderators](https://forum.qiime2.org/g/q2-mods) and [community members](https://forum.qiime2.org/u?order=likes_received&period=all) have also been instrumental to the development of ideas and content presented here.

Finally, as this project gets further along, you can see [who has contributed directly to *Using QIIME 2*](https://github.com/caporaso-lab/using-qiime2/graphs/contributors).

## Getting Help
For the most up-to-date information on how to get help with QIIME 2, as a user or developer, see [here](https://github.com/qiime2/.github/blob/main/SUPPORT.md).

## Funding 🙏
This work was funded in part by NIH National Cancer Institute Informatics Technology for Cancer Research grant [1U24CA248454-01](https://reporter.nih.gov/project-details/9951750).

This book is built with MyST Markdown and Jupyter Book, which are supported in part with [funding](https://sloan.org/grant-detail/6620) from the Alfred P. Sloan Foundation.

Initial support for the development of QIIME 2 was provided through a [grant](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1565100) from the National Science Foundation.

## License

 <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://use.qiime2.org">Using QIIME 2</a> led by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://cap-lab.bio">Greg Caporaso</a> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0.</p>

[^1]: *Using QIIME 2* will soon be renamed *Using rachis*, to reflect [the recent rebrand of the QIIME 2 Framework](xref:rachis-news-target#q2f-transition).
