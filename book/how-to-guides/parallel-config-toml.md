(parallel-config-toml)=
# How to write a Parsl configuration file for QIIME 2

This guide provides two ready-to-adapt [Parsl](https://parsl.readthedocs.io/en/stable/) configuration files: one for running QIIME 2 [Pipelines](xref:rachis-news-target#term-pipeline) in parallel on a single computer, and one for running them on a [Slurm](https://slurm.schedmd.com/documentation.html)-based HPC cluster.
For a line-by-line explanation of each setting, refer to [](#parallel-configuration).
For a worked example of running a `Pipeline` end-to-end on Slurm using the second configuration, refer to [](#parallel-on-slurm).

## Local configuration

This configuration runs all parallel work on the machine where you launch the `Pipeline`.
Use it on a personal workstation, a laptop, a single VM, or an interactive session on a single HPC compute node.

(parallel-config-local-toml)=
```toml
[parsl]
strategy = "None"

[[parsl.executors]]
class = "ThreadPoolExecutor"
label = "tpool"
max_threads = 2

[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
max_workers_per_node = 2

[parsl.executors.provider]
class = "LocalProvider"
```

Tune `max_threads` and `max_workers_per_node` to your machine.
A reasonable default is one less than the CPU count.
If your `Pipeline` actions are memory-hungry, lower `max_workers_per_node` until each worker has enough RAM (see the [troubleshooting section](#parallel-on-slurm-troubleshooting) of the Slurm guide for an example of what running out of memory looks like).

```{admonition} Parsl parameter rename
:class: note
In Parsl 2026.02 and later, `HighThroughputExecutor`'s `max_workers` parameter was renamed to `max_workers_per_node`.
The example above uses the new name.
If you are reading older configuration examples that use `max_workers`, you may need to update them.
```

## Slurm configuration

This configuration submits Parsl worker blocks as Slurm jobs through Parsl's [`SlurmProvider`](https://parsl.readthedocs.io/en/stable/stubs/parsl.providers.SlurmProvider.html).
The `Pipeline` itself ("the pilot") is launched outside of Slurm (typically on the cluster's login node, or in a long-running interactive session); Parsl then submits one or more worker blocks via `sbatch` on your behalf.

(parallel-config-slurm-toml)=
```toml
[parsl]

[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
cores_per_worker = 4
max_workers_per_node = 1

[parsl.executors.provider]
class = "SlurmProvider"
partition = "debug"
max_blocks = 1
nodes_per_block = 1
cores_per_node = 4
mem_per_node = 6
walltime = "00:45:00"
exclusive = false
worker_init = "source /path/to/miniforge3/etc/profile.d/conda.sh; conda activate <your-qiime2-env>;"
```

Edit the following before using this file:

- `partition`: the Slurm partition to submit worker blocks to.
- `max_blocks`, `nodes_per_block`, `cores_per_node`, `mem_per_node`, `walltime`: size each worker block to fit your cluster's policies and your `Pipeline`'s resource needs.
- `cores_per_worker` / `max_workers_per_node`: control how many simultaneous tasks each worker block runs. Increase `max_workers_per_node` (and decrease `cores_per_worker` to match) when your tasks are small and many; keep it at `1` (with `cores_per_worker` equal to `cores_per_node`) when each task needs the whole node's resources.
- `worker_init`: shell commands run inside each worker block before Parsl starts the worker process. **You almost always need to activate your QIIME 2 conda environment here.**

```{admonition} Omit `strategy = "None"` for HPC
:class: warning
The local configuration above includes `strategy = "None"`, but the Slurm configuration deliberately omits it.
Setting `strategy = "None"` prevents Parsl from scaling worker blocks correctly in an HPC environment.
See [](#parallel-configuration) for more on this setting.
```

## Using a configuration file

Save either configuration to a file (for example, `parsl-local.toml` or `parsl-slurm.toml`), then point QIIME 2 at it with `--parallel-config` when you run a `Pipeline`:

```shell
qiime <plugin> <action> \
    ... \
    --parallel \
    --parallel-config parsl-local.toml
```

For details on where QIIME 2 looks for configuration files when `--parallel-config` is not provided, refer to [](#qiime2-configuration-precedence).
