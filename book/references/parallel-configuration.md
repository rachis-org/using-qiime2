(parallel-configuration)=
# Parallel Pipeline configuration

QIIME 2 provides formal support for parallel computing of {term}`Pipelines <pipeline>` through [Parsl](https://parsl.readthedocs.io/en/stable/1-parsl-introduction.html>).

## Parsl configuration

A [Parsl configuration](https://parsl.readthedocs.io/en/stable/userguide/configuring.html) tells Parsl what resources are available and how to use them, and is required to use Parsl.
The [Parsl documentation](https://parsl.readthedocs.io/en/stable/) provides full detail on [Parsl configuration](https://parsl.readthedocs.io/en/stable/userguide/configuring.html#).

In the context of QIIME 2, Parsl configuration information is maintained in a QIIME 2 configuration file.
QIIME 2 configuration files are stored on disk in [TOML](https://toml.io/en/) files.

### Default Parsl configuration

For basic multi-processor usage, QIIME 2 writes a default configuration file the first time it's needed (e.g., if you instruct QIIME 2 to execute in parallel without a particular configuration).

The default `qiime2_config.toml` file, as of QIIME 2 2024.10, looks like the following:

(default-parsl-configuration-file)=
```
[parsl]
strategy = "None"

[[parsl.executors]]
class = "ThreadPoolExecutor"
label = "tpool"
max_threads = ...

[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
max_workers = ...

[parsl.executors.provider]
class = "LocalProvider"
```

When this file is written to disk, the `max_threads` and `max_workers` values (represented above by `...`) are computed by QIIME 2 as one less than the CPU count on the computer where it is running (`max(psutil.cpu_count() - 1, 1)`).

This configuration defines two `Executors`.

1. The [`ThreadPoolExecutor`](https://parsl.readthedocs.io/en/stable/stubs/parsl.executors.ThreadPoolExecutor.html?highlight=Threadpoolexecutor) that parallelizes jobs across multiple threads in a process.
2. The [`HighThroughputExecutor`](https://parsl.readthedocs.io/en/stable/stubs/parsl.executors.HighThroughputExecutor.html?highlight=HighThroughputExecutor) that parallelizes jobs across multiple processes.

In this case, the `HighThroughputExecutor` is designated as the default by nature of it's `label` value being `default`.
Your Parsl configuration **must** define an executor with the label `default`, and this is the executor that QIIME 2 will use to dispatch your jobs to if you do not specify an alternative.

````{admonition} The parsl.Config object
:class: tip

This Parsl configuration is ultimately read into a `parsl.Config` object internally in QIIME 2.
The `parsl.Config` object that corresponds to the above example would look like the following:

```python
config = parsl.Config(
    executors=[
        ThreadPoolExecutor(
            label='tpool',
            max_threads=... # will be an integer value
        ),
        HighThroughputExecutor(
            label='default',
            max_workers=..., # will be an integer value
            provider=LocalProvider()
        )
    ],
    strategy=None
)
```
````

### Parsl configuration, line-by-line

This first line of [the default configuration file presented above](#default-parsl-configuration-file) indicates that this is the Parsl section (or [table](https://toml.io/en/v1.0.0#table), to use TOML's terminology) of our configuration file.

```
[parsl]
```

The next line:

```
strategy = "None"
```

is a top-level Parsl configuration parameter that you can [read more about in the Parsl documentation](https://parsl.readthedocs.io/en/stable/userguide/configuring.html#multi-threaded-applications).
This may need to be set differently depending on your system.

Next, the first executor is added.

```
[[parsl.executors]]
class = "ThreadPoolExecutor"
label = "tpool"
max_threads = 7
```

The double square brackets (`[[ ... ]]`) indicates that [this is an array](https://toml.io/en/v1.0.0#array-of-tables), `executors`, that is nested under the `parsl` table.
`class` indicates the specific Parsl class that is being configured ([`parsl.executors.ThreadPoolExecutor`](https://parsl.readthedocs.io/en/stable/stubs/parsl.executors.ThreadPoolExecutor.html#parsl.executors.ThreadPoolExecutor) in this case); `label` provides a label that you can use to refer to this executor elsewhere; and `max_threads` is a configuration value for the ThreadPoolExecutor class which corresponds to a parameter name for the class's constructor.
In this example a value of 7 is specified for `max_threads`, but as noted above this will be computed specifically for your machine when this file is created.

Parsl's `ThreadPoolExecutor` runs on a single node, so we provide a second executor which can utilize up to 2000 nodes.

```
[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
max_workers = 7

[parsl.executors.provider]
class = "LocalProvider"
```

The definition of this executor, [`parsl.executors.HighThroughputExecutor`](https://parsl.readthedocs.io/en/stable/stubs/parsl.executors.HighThroughputExecutor.html#parsl.executors.HighThroughputExecutor), looks similar to the definition of the `ThreadPoolExecutor`, but it additionally defines a `provider`.
The provider class provides access to computational resources.
In this case, we use [`parsl.providers.LocalProvider`](https://parsl.readthedocs.io/en/stable/stubs/parsl.providers.LocalProvider.html), which provides access to local resources (i.e., on the laptop or workstation).
[Other providers are available as well](https://parsl.readthedocs.io/en/stable/reference.html#providers), including for Slurm, Amazon Web Services, Kubernetes, and more.

### The run_dir parameter

Another parameter to the config that we do not set but that you should definitely be aware of is `run_dir`.
This indicates the directory that Parsl will write logging info to and it defaults to `./runinfo`.
This means that if you run a QIIME 2 Pipeline in parallel without this parameter set, a `runinfo` directory will be created inside the directory that you ran the action from.

### Mapping {term}`Actions <action>` to executors

An executor mapping can be added to your Parsl configuration that defines which actions should run on which executors.
If an action is unmapped, it will run on the default executor.
This can be specified as follows:

```
[parsl.executor_mapping.plugin_name]
action_name = "tpool"
other_action_name = "tpool"

[parsl.executor_mapping.other_plugin_name]
action_name = "tpool"
```

(view-parsl-configuration)=
### Viewing the current configuration

Using {term}`q2cli`, you can see your current `qiime2_config.toml` file by running:

```shell
qiime info --config-level 2
```

(qiime2-configuration-precedence)=
### QIIME 2 configuration file precedence

When QIIME 2 needs configuration information, the following precedence order is followed to load a configuration file:

1. The path specified in the environment variable `$QIIME2_CONFIG`.
2. The file at `<user_config_dir>/qiime2/qiime2_config.toml`
3. The file at `<site_config_dir>/qiime2/qiime2_config.toml`
4. The file at `$CONDA_PREFIX/etc/qiime2_config.toml`

If no configuration is found after checking those four locations, QIIME 2 writes a default configuration file to `$CONDA_PREFIX/etc/qiime2_config.toml` and uses that.
This implies that after your first time running QIIME 2 in parallel without a config in at least one of the first 3 locations, the path referenced in step 4 will exist and contain a configuration file.

Alternatively, when using {term}`q2cli`, you can provide a specific configuration for use in configuring Parsl using the `--parallel-config` option.
If provided, this overrides the priority order above.

Similarly, when using the {term}`Python 3 API`, you can provide a specific configuration by passing a `parsl.Config` object into your `ParallelConfig` context manager.

````{admonition} user_config_dir and site_config_dir
:class: note
On Linux, `user_config_dir` will usually be `$HOME/.config/qiime2/`.
On macOS, it will usually be `$HOME/Library/Application Support/qiime2/`.

You can get find the directory used on your system by running the following command:

```bash
python -c "import appdirs; print(appdirs.user_config_dir('qiime2'))"
```

On Linux `site_config_dir` will usually be something like `/etc/xdg/qiime2/`, but it may vary based on Linux distribution.
On macOS it will usually be `/Library/Application Support/qiime2/`.

You can get find the directory used on your system by running the following command:

```bash
python -c "import appdirs; print(appdirs.site_config_dir('qiime2'))"
```
````

### Configuring Parsl for HPC

Parsl supports a large number of compute environments via its [providers](https://parsl.readthedocs.io/en/stable/reference.html#providers).
The HPC cluster used by the QIIME 2 Framework development team, for example, uses [Slurm](https://slurm.schedmd.com/documentation.html).
As such, we will give an example here of configuring a QIIME 2 action to run in parallel on a Slurm based HPC cluster using Parsl's SlurmProvider.

This is what a QIIME 2 config for running on Slurm looks like at a high level.

```
[parsl]

[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
max_workers = ...

[parsl.executors.provider]
class = "SlurmProvider"
...
```

Note we are still using a HighThroughputExecutor but with a different provider.
In the default config, we were using the LocalProvider which doesn't take any real configuration to start using.
In this case we are using the SlurmProvider which requires a lot more configuration.
Let's break down how to configure the SlurmProvider.

````{admonition} Omit "strategy=None"
:class: note
It is important to omit the "strategy=None" seen in the default config.
This setting will prevent Parsl from properly parallelizing in an HPC environment.
````

#### SlurmProvider parameters

The full docs for the Parsl SlurmProvider may be found [here](https://parsl.readthedocs.io/en/stable/stubs/parsl.providers.SlurmProvider.html#parsl.providers.SlurmProvider).
In our documentation, we will break down the ones we have found most necessary.

`max_blocks`: The maximum number of blocks (Parsl jobs) to maintain.
 Parsl will submit *max_blocks* Slurm jobs, but it is not guaranteed they will all actually run.
 When and how they get scheduled is determined by Slurm.

`nodes_per_block`: How many compute nodes to request per Slurm job submitted.

`cores_per_node:` The number of CPU cores to request per compute node.

`mem_per_node`: The amount of memory to request per compute node in gigabytes.

`walltime`: The max time for the Slurm jobs submitted.
 Each block represents a Parsl job in "HH:MM:SS" format.

`exclusive`: Whether to request nodes that are free from other running jobs or not (Slurm will make sure we have access to the resources we asked for regardless of whether there are other jobs on the node).

`worker_init`: Bash commands to run on the worker jobs submitted by Parsl.
 You may need to activate your QIIME 2 conda environment here.

#### Example Slurm config

This is an example of a config we have actually used to run analyses on our HPC cluster. Let's break down what these parameters mean.

```
[parsl]

[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
cores_per_worker = 20
max_workers_per_node = 1

[parsl.executors.provider]
class = "SlurmProvider"
max_blocks = 10
nodes_per_block = 1
cores_per_node = 20
mem_per_node = 100
walltime = "10:00:00"
exclusive = false
worker_init = "module load anaconda3; conda activate qiime2-shotgun-dev;"
```

`max_blocks = 10`: We will run up to 10 Slurm jobs.

`nodes_per_block = 1`: Each job will use one compute node.

`cores_per_node = 20`: 20 cores will be used per compute node.

`mem_per_node = 100`: 100GB of RAM will be used per compute node.

`walltime = "10:00:00"`: Each Slurm job (block) will run for up to 10 hours.

`exclusive = false`: We don't care if there are other jobs running on the nodes we use.

`worker_init = "module load anaconda3; conda activate qiime2-shotgun-dev;"`: Activate the necessary QIIME 2 conda environment for each worker job.

And finally, let's take a look at those parameters given to the HighThroughputExecutor.

`cores_per_worker = 20`: Each worker will have access to 20 cores.
 This was set to match `cores_per_node / max_workers_per_node`, just to ensure all our resources are set to be available.

`max_workers_per_node = 1`: Each compute node will only have one worker and only be able to handle one job at a time.

This config will queue 10 Slurm jobs that will run for up to 10 hours each. Each job will use 20 cores and 100GB of RAM on one compute node.
Due to the `max_workers_per_node = 1`, each of these Slurm jobs with these resources will be able to handle one QIIME 2 action at a time.

### Example Slurm job

This is the Slurm job we submitted that used the above config.
We call this job that we actually submit directly the "pilot job."
This job will itself submit the "worker jobs," which are the ones that will actually do the work,

```bash
#!/bin/bash

#SBATCH -e /scratch/<uname>/kraken2/kraken2.err
#SBATCH -o /scratch/<uname>/kraken2/kraken2.out
#SBATCH --job-name=kraken2
#SBATCH --time=24:00:00
#SBATCH --mem=8G

module load anaconda3
conda activate q2-shotgun-dev

export TMPDIR=/scratch/<uname>/tmp
export CACHE=/scratch/<uname>/cache

qiime moshpit classify-kraken2 \
        --i-seqs "$CACHE:mp-demux" \
        --i-kraken2-db "$CACHE:workshop-kraken-db" \
        --p-threads 20 \
        --p-partitions 10 \
        --p-memory-mapping false \
        --o-hits "$CACHE:kraken_hits" \
        --o-reports "$CACHE:kraken_reports" \
        --parallel-config /scratch/<uname>/kraken2/conf.toml \
        --use-cache "$CACHE" \
        --verbose
```

`classify-kraken2` is a pipeline that was written specifically to take advantage of QIIME 2's parallel capabilities.
It requires a significant amount of compute resources to match a large number of sequences against a very large kraken database hence the large amount of RAM requested in the Parsl config, and the need to run in parallel in the first place.

It will split the input sequences into `--p-num-partitions` (defaults to splitting each sample into its own partition) sets and then classify them in parallel.
The 10 partitions here corresponds to our 10 blocks.
We will have 10 different sets of sequences each of which can be submitted to its own block.
The 20 threads here corresponds to our 20 `cores_per_worker`.
This allows us to classify `num_blocks * workers_per_block * cores_per_worker` or `10 * 1 * 20 = 200` sequences at a time.

We make sure to set our `TMPDIR` and the [Artifact Cache](#artifact-cache-tutorial) we are using for this action to a location that is accessible globally on the HPC we are using.
It is important that you do this to make sure your actions which will be spread across compute nodes are writing information that needs to be shared amongst them to a location they can all see.

This job has a walltime of 24 hours which is significantly longer than the jobs we will be submitting.
This is because it can take some time after your pilot job starts running for your worker jobs to actually start running.
This job also only asks for 8GB of RAM.
This is because this job doesn't do any of the actual computation, so it doesn't require a large amount of compute resources.

````{admonition} We understand this can be difficult!
:class: note
We understand that figuring out how to set up your parallel config for a given action can be difficult.
It requires you to understand not only your data and the action you are trying to run but also your compute system.
If you need help with this do not hesitate to post on [the QIIME 2 forum](https://forum.qiime2.org).
````
