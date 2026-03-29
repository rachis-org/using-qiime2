(metadata-validation)=
# How to validate metadata

QIIME 2 will automatically validate a metadata file anytime it is used.
This will inform you of any errors in your metadata formatting, which you can then correct.
To test this, you can use the `qiime metadata tabulate` command, which will read your metadata file and produce a nicely formatting view in a QIIME 2 [Visualization](xref:rachis-news-target#term-visualization).

```{admonition} Warning: Do not include confidential information in your metadata.
:class: warning
QIIME 2 goes to great lengths to ensure that your bioinformatics workflow will be reproducible.
This includes recording information about your analysis inside of your Results' data provenance, and the recorded information includes metadata that you provided to run specific commands.
For this and other reasons, we strongly recommend that you **never include confidential information, such as Personally Identifying Information (PII), in your QIIME 2 metadata**.
**Because QIIME 2 stores metadata in your data provenance, confidential information that you use in a QIIME 2 analysis will persist in downstream Results.**

Instead of including confidential information in your metadata, you should encode it with variables that only authorized individuals have access to.
For example, subject names should be replaced with anonymized subject identifiers before use with QIIME 2.
```
