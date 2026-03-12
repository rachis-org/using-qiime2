(artifact-cache-tutorial)=
# Using an Artifact Cache

An artifact cache allows users to have finer control over where and how QIIME 2 {term}`Results <Result>` are stored on disk.

Artifact caches serve two primary purposes:
1. Providing the user with control over where QIIME 2 stores its working (temporary) files.
2. Avoiding the overhead of unzipping QIIME 2 `Results` every time they're used.

Users can create and interact with artifact caches via both the Python API and the CLI.
This tutorial will provide instructions for both.

An artifact cache is created in a specific location on your file system.
After an artifact cache is created, it can be used to store `Results` as unzipped directories, as opposed to as `.qza` or `.qzv` files.
`Results` in a cache are referred to by the path to the cache followed by a user-defined key.

```{warning}
Users should **not** edit or otherwise write to the cache directory directly.
The directory should only be modified via the provided QIIME 2 APIs.
The only exception is if you'd like to delete a cache, in which case you can just remove the top-level directory.
```

## A use case for the artifact cache

Consider a use case where you have a very large artifact, say an 80 gigabyte reference sequence database, and you are regularly using this database as an input to QIIME 2 {term}`Actions <Action>` on a cluster.
It would be ideal to avoid constantly unzipping this large database into and out of a `.qza` file.
It may also be ideal to store this artifact in a location that all users and all worker nodes on the cluster have access to, to avoid multiple copies of this file being stored on the system (e.g., under different users' home directories).

These issues can be resolved by putting the reference data artifact in a cache in a location on the cluster's file system that is globally accessible by the users and worker nodes.
By nature of being stored in a cache, the artifact will be stored unzipped, so the action will not need to unzip the artifact before using it.
As long as the cache is stored in a location that all worker nodes can access, it will not need to be moved around the filesystem before the action can execute.

## Tutorial

![](#tutorial_environment_block)

The following steps will illustrate how to create a new cache, add an artifact to it, use an artifact from it, and more.
Note that the steps in the tutorial may require that some or all of the preceding steps have been run.

First, have QIIME 2 generate some data that we can use.

```python
qiime dwq2 search-and-summarize --example-data ss-usage
```

Then, change to the directory containing the data.

```shell
cd ss-usage/Serial
```

### Creating a cache

Now, let's create a new artifact cache in the current working directory:

`````{tab-set}

````{tab-item} Command line interface
```shell
qiime tools cache-create --cache my-cache
```
````

````{tab-item} Python 3 API

This will create a cache at the given path if one does not exist.
It is also how you get an object (`cache` in this case) referring to an existing cache, if the given path does exist.

```python
from qiime2 import Cache

cache = Cache('./my-cache')
```
````
`````

### Loading entries in a cache

Next, let's simulate the example described above where you have a reference data set that you'd like to store in the cache, so it doesn't need to be unzipped every time it's used.

```{note}
Because the example data is so small, the performance difference between using an artifact that is stored in a cache versus the same artifact stored in a `.qza` will be negligible, but for large data artifacts the performance difference can be enormous.
```

This will store an artifact in the specified cache (`my-cache`) with the specified key (`my-reference`).

`````{tab-set}

````{tab-item} Command line interface
```shell
qiime tools cache-store \
   --cache my-cache \
   --artifact-path ./reference-seqs.qza \
   --key my-reference
```
````

````{tab-item} Python 3 API
```python
from qiime2 import Artifact

reference_seqs = Artifact.load('./reference-seqs.qza')
cache.save(reference_seqs, 'my-reference')
```
````
`````

```{note}
The cache is specified as a path, so example above assumes that you're working in the directory where your cache is stored.
If your cache is elsewhere, you would reference it as you would any path to a directory.
For example, I might refer to my cache as `/home/greg/my-cache` or `$HOME/my-cache` if that's where it existed.
```

### Reviewing entries in a cache

You can confirm that the Artifact was added to the cache as follows.

`````{tab-set}
````{tab-item} Command line interface
```shell
qiime tools cache-status --cache my-cache
```
````

````{tab-item} Python 3 API
The `cache-status` command in q2cli (i.e., the command line interface equivalent of this command) is currently the easiest way to get information about what's in a cache.
You can access similar information through the Cache API.
```python
cache.get_keys()
cache.load('my-reference')
```
````
`````

### Using caches with Actions

Now, you can reference the artifact from the cache when calling Actions.
Artifacts in a cache are referenced as `path-to-cache:key`.
So, as long as you're working in the same directory as where your cache is stored, the following command should run.
(This command does take a couple of minutes to run.
If you want it to go faster, you can run it in parallel](#parallel-tutorial).)

`````{tab-set}
````{tab-item} Command line interface
```shell
qiime dwq2 search-and-summarize \
    --i-query-seqs query-seqs.qza \
    --i-reference-seqs my-cache:my-reference \
    --m-reference-metadata-file reference-metadata.tsv \
    --p-split-size 1 \
    --o-hits hits.qza \
    --o-hits-table hits-table.qzv
```
````

````{tab-item} Python 3 API
```python
from qiime2.plugins.dwq2.actions import search_and_summarize
from qiime2 import Metadata

reference_from_cache = cache.load('my-reference')
reference_metadata = Metadata.load('./reference-metadata.tsv')

hits, hits_table = search_and_summarize(
    query_seqs=query_seqs,
    reference_seqs=reference_from_cache,
    reference_metadata=reference_metadata,
    split_size=1)
```
````
`````

``````{admonition} Outputting Results directly to a cache
:class: tip, dropdown
It's also possible to write outputs from QIIME 2 Actions to a cache.
To do that, you'd reference the cache and key in the same way as for an input.
In this example, the `hits` output artifact is being written to the cache.

`````{tab-set}
````{tab-item} Command line interface
```shell
qiime dwq2 search-and-summarize \
    --i-query-seqs query-seqs.qza \
    --i-reference-seqs my-cache:my-reference \
    --m-reference-metadata-file reference-metadata.tsv \
    --p-split-size 1 \
    --o-hits my-cache:my-hits \
    --o-hits-table hits-table.qzv \
    --parallel
```
````
````{tab-item} Python 3 API
When using the Python 3 API, you can save an Artifact directly to the cache.
```python
cache.save(hits, 'my-hits')
```
````
`````

After that completes, how can you check that the resulting Artifact was written to the cache?
(Hint: we used this command above.)
``````

### Remove a Result from the cache

If there's an item in your cache that you no longer need, you can remove.
We can remove our reference data.

`````{tab-set}
````{tab-item} Command line interface
```shell
qiime tools cache-remove \
   --cache my-cache \
   --key my-reference
```
````

````{tab-item} Python 3 API
```python
cache.remove('my-reference')
```
````
`````

After removing the artifact, check the status of your cache to confirm that it was removed.

### Other cache-related functionality

There are some other command line tools and APIs accessible to help you interact with your cache(s).
You can learn about these as follows.

`````{tab-set}
````{tab-item} Command line interface
```shell
qiime tools --help
```
See the tools that begin with `cache-`.
````

````{tab-item} Python 3 API
We're working on getting the API docs for Cache hosted somewhere, but in the meantime you can access them with Python's `help` function.
```python
help(cache)
```
````
`````

### Remove a cache

If you no longer need your cache, you can just remove the directory from disk as follows.

```{warning}
As always, be very careful with `rm` - there's no undo!
```


```shell
rm -r my-cache
```



