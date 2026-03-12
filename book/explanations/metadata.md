(metadata-explanation)=
# Sample and feature metadata

Metadata provides the key to gaining biological insight from your data.
In QIIME 2, **sample metadata** may include technical details, such as the DNA barcodes that were used for each sample in a multiplexed sequencing run, or descriptions of the samples, such as which subject, time point, and body site each sample came from in a human microbiome time series.
**Feature metadata** is often a feature annotation, such as the taxonomy assigned to an amplicon sequence variant (ASV).
Sample and feature metadata are used by many plugins, and examples are provided throughout *Using QIIME 2* and other documentation illustrating how to work with metadata in QIIME 2.

Sample metadata is usually specific to a given microbiome study, and compiling it is typically a step you will have started before beginning your QIIME 2 analysis.
It is up to the investigator to decide what information is collected and tracked as metadata.
QIIME 2 does not place restrictions on what types of metadata are expected to be present; there is no generally enforced required metadata.
This is your opportunity to track whatever information you think may be important to your analyses.
When in doubt, collect as much metadata as possible, as you may not be able to retroactively collect certain types of information.

While QIIME 2 does not enforce standards for what types of metadata to collect, the [MIxS and MIMARKS standards](https://doi.org/10.1038/nbt.1823) provide recommendations for microbiome studies and may be helpful in determining what information to collect in your study.
If you plan to deposit your data in a data archive (e.g. [ENA](https://www.ebi.ac.uk/ena) or [Qiita](https://qiita.ucsd.edu/)), it is also important to determine the types of metadata expected by that resource.
Different data archives have their own requirements.

For information on how to format your metadata, see [](#metadata-formatting-reference).

````{margin}
```{admonition} Video
[This video](https://www.youtube.com/watch?v=hh6pqmzJWds) on the QIIME 2 YouTube channel presents a discussion of sample metadata.
```
````

```{admonition} Jargon: metadata files or mapping files?
You may sometimes hear TSV metadata files referred to as *mapping files*.
The QIIME 1 documentation often referred to *metadata files* as mapping files; the term *metadata files* is used here because it's more descriptive, but they are conceptually the same thing as QIIME 1 mapping files.
QIIME 2 metadata files are backwards-compatible with QIIME 1 mapping files, meaning that you can use existing QIIME 1 mapping files in QIIME 2 without needing to make modifications to the file.
```