(metadata-merge)=
# How to merge metadata

Metadata can come from many different sources, and some QIIME 2 artifacts also [look and behave a lot like metadata](#view-artifacts-as-metadata).
QIIME 2 therefore has a few different ways to handle metadata merging.

## Implicit merging

This supports merging of metadata that contains **overlapping ids, but not overlapping column names**.
Simply passing ``--m-input-file`` multiple times will combine the metadata columns in the specified files:

```shell
qiime metadata tabulate \
    --m-input-file sample-metadata-1.tsv \
    --m-input-file sample-metadata-2.tsv \
    --o-visualization tabulated-combined-metadata.qzv
```

The resulting metadata after the merge will contain the intersection of the identifiers across all of the specified files (i.e., an inner join).
In other words, the merged metadata will only contain identifiers that are shared across all provided metadata files.

Implicit metadata merging is supported anywhere that metadata is accepted in QIIME 2.

## Explicit merging

Explicit merging of metadata supports merging of metadata that contains **overlapping ids or overlapping column names, but not both overlapping ids and overlapping column names**.
This can be achieved with the `merge` action provided by the `q2-metadata` plugin.
The result will be the union (i.e., outer join) of the ids and columns from the two metadata inputs.
Merging metadata with **neither overlapping ids or overlapping column names** is also possible with this action.

Call `qiime metadata merge --help` for detailed information on how to use this command.

Attempting to merge metadata with both overlapping ids and overlapping columns will currently fail because conflicting column values for a sample are not resolved.
See [](#merge-metadata-conflict) for more discussion of this topic.

To explicitly merge more than two metadata objects, run this command multiple times, iteratively, using the output of the previous run as one of the metadata inputs.

The output of `qiime metadata merge` is an `ImmutableMetadata` artifact (because QIIME 2 methods only ever produce artifacts).
This artifact can be used anywhere that a metadata file can be used, or it can be exported to a metadata `.tsv` file in the typical format.

## Merging Artifacts with Metadata

Both implicit and explicit merging of metadata also works with artifacts that can be viewed as metadata.
(See [](#view-artifacts-as-metadata) for details on this concept.)
For example, it might be interesting to have the option to color points in an Emperor plot based on the sample alpha diversity, in addition to the typical sample metadata.
This can be accomplished by providing both the sample metadata file *and* the ``SampleData[AlphaDiversity]`` artifact as metadata files in an implicit merge:

```shell
curl -sL \
  "https://data.qiime2.org/2021.4/tutorials/metadata/unweighted_unifrac_pcoa_results.qza" > \
  "unweighted_unifrac_pcoa_results.qza"

qiime emperor plot \
    --i-pcoa unweighted_unifrac_pcoa_results.qza \
    --m-metadata-file sample-metadata.tsv \
    --m-metadata-file faith_pd_vector.qza \
    --o-visualization unweighted-unifrac-emperor-with-alpha.qzv
```

(merge-metadata-conflict)=
## Merging metadata with potentially conflicting values

QIIME 2 does not have support for merging metadata with potentially conflicting values.
This can arise if different metadata that you want to merge has **overlapping identifiers *and* overlapping column names**.
For example if the both metadata files being merged have an `age` column, each could provide a different `age` value for the same sample.
QIIME 2 doesn't attempt to resolve that - it's up to you to do that.

Our current recommendations for how to handle a case like this are:
 - If the overlapping columns do not contain conflicting information, don't duplicate them across metadata files.
   Instead, delete the duplicated column(s) from one of the files.
   Duplicating this type of information is generally considered to be a bad research data management practice, and is a violation of the {term}`DRY` principle.
 - If the overlapping column(s) do contain conflicting information, determine whether this is an error or not.
   If it's an error, figure out which of the conflicting values are the right one, fix the issue, and delete the duplicated column from one of the files.
   If it's not an error, that probably means that the column(s) are not named well (i.e., the same name is being used to mean two different things).
   Come up with a more specific name, and rename the overlapping column(s) in one or both of the metadata files.
