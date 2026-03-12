(view-artifacts-as-metadata)=
# How to use Artifacts as Metadata

In addition to TSV metadata files, QIIME 2 also supports viewing some kinds of artifacts as metadata.
An example of this is artifacts of type `SampleData[AlphaDiversity]`.

To get started with understanding artifacts as metadata, first download an example artifact:

```shell
curl -sL \
  "https://data.qiime2.org/2021.4/tutorials/metadata/faith_pd_vector.qza" > \
  "faith_pd_vector.qza"
```

To view this artifact as metadata, simply pass it in to any method or visualizer that expects to see metadata (e.g. `metadata tabulate` or `emperor plot`):

```shell
qiime metadata tabulate \
    --m-input-file faith_pd_vector.qza \
    --o-visualization tabulated-faith-pd-metadata.qzv
```

When an artifact is viewed as metadata, the result includes that artifact's provenance in addition to its own.
