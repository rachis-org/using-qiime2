(pipeline-resumption)=
# How to resume failed Pipeline runs

If a [Pipeline](xref:rachis-news-target#term-pipeline) fails at some point during its execution, and you rerun it, QIIME 2 can attempt to reuse the results that were calculated by the `Pipeline` before it failed.

## Pipeline resumption through the command line interface (CLI)

By default, when you run a [Pipeline](xref:rachis-news-target#term-pipeline) on the CLI, QIIME 2 will create a pool in its cache (either the default cache, or the cache specified using the `--use-cache` parameter).
This pool will named based on the scheme: `recycle_<plugin>_<action>_<sha1('plugin_action')>`.
This pool will store all intermediate [Results](xref:rachis-news-target#term-result) created by the [Pipeline](xref:rachis-news-target#term-pipeline).

Should the `Pipeline` run succeed, this pool will be removed.
However, should the `Pipeline` run fail, you can rerun the `Pipeline` using the same command you ran the first time, and the intermediate [Results](xref:rachis-news-target#term-result) stored in the pool will be reused to avoid redoing steps in the Pipeline that had already completed.

If you wish to specify the pool that you would like QIIME 2 should use, either on a `Pipeline`'s first run or on a resumption, you can specify the pool using the `--recycle-pool` option, followed by the name of the pool you wish to use.
This pool will be created in the cache if it does not already exist.
The `--no-recycle` flag may be passed if you do not want QIIME 2 to attempt to recycle any past [Results](xref:rachis-news-target#term-result) or to save its [Results](xref:rachis-news-target#term-result) from this run for future reuse.

It is not necessarily possible to reuse prior [Results](xref:rachis-news-target#term-result) if your inputs to the `Pipeline` differ on resumption with respect to what was provided on the initial run.
In this situation, QIIME 2 will still try to reuse any [Results](xref:rachis-news-target#term-result) that are not dependent on the inputs that changed, but there is no guarantee any will be usable.

## Pipeline resumption through the Python 3 API

When using the Python API, pools are specified using context managers (i.e., using Python's `with` statement).
If you don't want to enable resumption, don't use the context manager.

```python
from qiime2.core.cache import Cache

cache = Cache('cache_path')
pool = cache.create_pool('pool', reuse=True)

with pool:
    # run your pipeline here
```
