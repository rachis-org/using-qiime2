(parallel-tutorial)=
# Using parallel Pipeline execution

QIIME 2 provides formal support for parallel computing of [Pipelines](xref:rachis-news-target#term-pipeline) through [Parsl](https://parsl.readthedocs.io/en/stable/1-parsl-introduction.html>).[^formal-informal-parallel]
This allows for faster execution of QIIME 2 `Pipelines`, assuming the compute resources are available, by ensuring that pipeline steps that can run simultaneously do run simultaneously.

Parallel Pipeline execution is accessible in different ways depending on which interface you're using.
Here we illustrate how to run `Pipelines` in parallel using [q2cli` and {term}`QIIME 2's Python 3 API](xref:rachis-news-target#term-python 3 API).

````{admonition} Reminder
:class: tip
:label: tutorial_environment_block

These examples assume that you have a QIIME 2 deployment that includes the [q2-dwq2](https://github.com/caporaso-lab/q2-dwq2) educational plugin.
Follow the instructions in [](#tutorial-setup) if you'd like to follow along with this tutorial.
If you've already followed those instructions, before following this tutorial be sure to activate your conda environment as follows:

```python
conda activate using-qiime2
```
````

## q2cli

Review the help text for a QIIME 2 `Pipeline`.
Pay special attention to the usage examples at the bottom of the help text.

```shell
qiime dwq2 search-and-summarize --help
```

Have QIIME 2 generate example data that can be used to run the usage example.

```shell
qiime dwq2 search-and-summarize --example-data ss-usage
```

This will create a new directory for `search-and-summarize` usage example data.
Change into that new directory by running:

```shell
cd ss-usage/Serial
```

Run the usage example serially first.
Note that in the following commands the output filenames are adapted from the usage example to **prepend `serial-` to each file name**.

```{note}
The following command may take several minutes to run.
On my Apple MacBook Pro (M3) it ran for approximately 6 minutes.
```

```shell
qiime dwq2 search-and-summarize \
    --i-query-seqs query-seqs.qza \
    --i-reference-seqs reference-seqs.qza \
    --m-reference-metadata-file reference-metadata.tsv \
    --p-split-size 1 \
    --o-hits serial-hits.qza \
    --o-hits-table serial-hits-table.qzv
```

To re-run this `Pipeline` in parallel, append the `--parallel` flag.
This will run this command in parallel using a default parallel configuration (learn more about this in [](#parallel-configuration)).
Note that the output filenames this time are adapted to **prepend `parallel-` to each file name**.

```shell
qiime dwq2 search-and-summarize \
    --i-query-seqs query-seqs.qza \
    --i-reference-seqs reference-seqs.qza \
    --m-reference-metadata-file reference-metadata.tsv \
    --p-split-size 1 \
    --o-hits parallel-hits.qza \
    --o-hits-table parallel-hits-table.qzv \
    --parallel
```

If you're using a system with parallel computing capabilities (e.g., at least six cores) the parallel execution of this command should have run faster than the serial execution.

## Python 3 API

Parallel Pipeline execution through the Python API is done using a `ParallelConfig` object as a context manager.
These objects take a `parsl.Config` object and an optional dictionary mapping action names to executor names as input.
If no config is provided your default configuration will be used (see [](#qiime2-configuration-precedence)).

```python
from qiime2.sdk.parallel_config import ParallelConfig
from qiime2.plugins.dwq2.pipelines import search_and_summarize
from qiime2 import Artifact, Metadata

query_seqs = Artifact.load('query-seqs.qza')
reference_seqs = Artifact.load('reference-seqs.qza')
reference_metadata = Metadata.load('reference-metadata.tsv')

with ParallelConfig():
    future = search_and_summarize.parallel(query_seqs=query_seqs,
                                           reference_seqs=reference_seqs,
                                           reference_metadata=reference_metadata,
                                           split_size=1)
    # call future._result() inside of the context manager
    result = future._result()
```

To use a specific configuration, you can create it directly, or load one from file.
For example:

```python
from qiime2.sdk.parallel_config import ParallelConfig, get_config_from_file
from qiime2.plugins.dwq2.pipelines import search_and_summarize
from qiime2 import Artifact, Metadata

query_seqs = Artifact.load('query-seqs.qza')
reference_seqs = Artifact.load('reference-seqs.qza')
reference_metadata = Metadata.load('reference-metadata.tsv')

path_to_config_file = # set this to the path to the file you'd like to load

c, m = get_config_from_file(path_to_config_file)

with ParallelConfig(parallel_config=c, action_executor_mapping=m):
    future = search_and_summarize.parallel(query_seqs=query_seqs,
                                           reference_seqs=reference_seqs,
                                           reference_metadata=reference_metadata,
                                           split_size=1)
    # call future._result() inside of the context manager
    result = future._result()
```

## Parsl configuration

To learn how to configure Parsl for your own usage, refer to [](#parallel-configuration).

[^formal-informal-parallel]: QIIME 2 [Actions](xref:rachis-news-target#term-action) can provide formal (i.e., Parsl-based) or informal (e.g., multi-threaded execution of a third party program) parallel computing support.
 To learn more about the distinction, see [](#types-of-parallel-support).
