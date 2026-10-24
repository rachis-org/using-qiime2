(parallel-on-slurm)=
# How to run a QIIME 2 Pipeline in parallel on Slurm

This guide walks through running a QIIME 2 [Pipeline](xref:rachis-news-target#term-pipeline) in parallel on a [Slurm](https://slurm.schedmd.com/documentation.html)-based HPC cluster, using QIIME 2's [Parsl](https://parsl.readthedocs.io/en/stable/)-based parallel computing support.

We start with a small sanity-check run that completes in about a minute, then scale up using the same configuration with a larger input.
The example uses [`q2-boots`](https://library.qiime2.org/plugin/caporaso-lab/q2-boots)' `kmer-diversity` `Pipeline`, applied to data from the [gut-to-soil tutorial](https://gut-to-soil-tutorial.readthedocs.io/en/latest/).

This is a goal-oriented guide.
If you instead want a guided introduction to QIIME 2's parallel `Pipeline` execution on a single computer, refer to the [parallel `Pipeline` tutorial](#parallel-tutorial).
For a line-by-line breakdown of Parsl configuration, refer to [](#parallel-configuration).

## Prerequisites

Before starting:

- You have an account on a Slurm-based HPC cluster.
- You have a QIIME 2 conda environment installed and accessible from the cluster's compute nodes (typically through a shared filesystem). This guide was written using a `rachis-qiime2` distribution that provides `q2-boots`.
- You can run `sbatch`, `squeue`, and `scontrol show partition <partition>` from the cluster's login node.
- You know which partition to submit jobs to and what the partition's resource limits are (`scontrol show partition <partition>` will tell you).

## Step 1: Stage input data

From the login node, in a directory on a filesystem that is shared with the compute nodes, download the gut-to-soil ASV feature table, ASV sequences, and sample metadata:

```shell
curl -sLO https://zenodo.org/records/15390940/files/asv-table.qza
curl -sLO https://zenodo.org/records/15390940/files/asv-seqs.qza
curl -sLo sample-metadata.tsv \
    https://zenodo.org/records/15390940/files/gut-to-soil-tutorial-sample-metadata.tsv
```

Activate your QIIME 2 conda environment.
The exact command depends on how conda is installed on your cluster (some sites require `module load anaconda3` first); ask your sysadmin if you're unsure.

```shell
conda activate <your-qiime2-env>
```

Build a small three-sample feature table that we'll use for the sanity-check run.
First, write a TSV listing three sample IDs that have at least 10,000 reads:

```shell
cat > sample-ids-small.tsv <<'EOF'
sample-id
00b62637
00ce9aa6
016287d9
EOF
```

Then filter the full ASV table down to those three samples:

```shell
qiime feature-table filter-samples \
    --i-table asv-table.qza \
    --m-metadata-file sample-ids-small.tsv \
    --o-filtered-table asv-table-small.qza
```

## Step 2: Write the Parsl configuration

Save the following as `parsl-slurm.toml`, editing the values marked `<...>` to match your cluster:

```toml
[parsl]

[[parsl.executors]]
class = "HighThroughputExecutor"
label = "default"
cores_per_worker = 4
max_workers_per_node = 1

[parsl.executors.provider]
class = "SlurmProvider"
partition = "<your-partition>"
max_blocks = 1
nodes_per_block = 1
cores_per_node = 4
mem_per_node = 6
walltime = "00:45:00"
exclusive = false
worker_init = "source <path-to-conda>/etc/profile.d/conda.sh; conda activate <your-qiime2-env>;"
```

This requests up to one Slurm worker block at a time (`max_blocks = 1`) on one compute node (`nodes_per_block = 1`) with four cores and six gigabytes of memory.
Each worker block runs one worker process (`max_workers_per_node = 1`) which uses all four cores per task (`cores_per_worker = 4`).

For a line-by-line explanation of each setting (and a copy-paste-ready local-only configuration), refer to [](#parallel-config-toml).
For the underlying reference, refer to [](#parallel-configuration).

```{admonition} The pilot does not run inside Slurm
:class: tip
Notice we did not write an `sbatch` script here.
The `qiime ... --parallel` command in the next step is "the pilot": it runs in your shell on the login node and uses the `SlurmProvider` configured above to submit worker blocks via `sbatch` on your behalf.
This is the typical pattern on Slurm-based HPCs.
You can wrap the pilot itself in a long-walltime, low-resource Slurm job if your cluster prohibits long-running processes on the login node; refer to [](#parallel-configuration) for an example.
```

## Step 3: Run the sanity-check Pipeline

Run `boots kmer-diversity` against the three-sample table, with `--parallel` and `--parallel-config` pointing at the file you just wrote:

```shell
qiime boots kmer-diversity \
    --i-table asv-table-small.qza \
    --i-sequences asv-seqs.qza \
    --p-sampling-depth 10000 \
    --p-no-replacement \
    --m-metadata-file sample-metadata.tsv \
    --p-n 3 \
    --output-dir kmer-diversity-small \
    --parallel \
    --parallel-config parsl-slurm.toml \
    --verbose
```

While this runs, you can watch your worker block in the Slurm queue from another terminal:

```shell
squeue --me
```

You should see one job whose name starts with `parsl.default.block-0.` — that is the worker block that the pilot submitted.

When the command finishes, you'll see saved output paths printed to stderr ending with `kmer-diversity-small/scatter_plot.qzv`.

## Step 4: Confirm the run actually ran in parallel

Two places independently confirm that the work went through Parsl and Slurm.

First, look in `runinfo/`.
Parsl writes one numbered subdirectory per `ParallelConfig` it creates (so `000/` for the first run, `001/` for the second, and so on).
Inside, you'll find a `parsl.log` and a `submit_scripts/` directory containing the actual `sbatch` script Parsl generated:

```shell
ls runinfo/000/
ls runinfo/000/submit_scripts/
```

Open one of the `parsl.default.block-0.*` files (without an extension); it is a real `sbatch` script and you'll see your `partition`, `mem`, `cpus-per-task`, `walltime`, and `worker_init` settings rendered into `#SBATCH` directives.

Second, the [provenance](xref:rachis-news-target#term-provenance) of any output `Artifact` records the execution context.
The relevant block in `provenance/action/action.yaml` looks like this:

```yaml
execution:
    ...
    execution_context:
        type: parsl
        parsl_type: DFK
```

If you see `type: parsl`, your `Pipeline` ran through QIIME 2's parallel computing support.

## Step 5: Scale up

The same configuration handles larger inputs.
Build a ten-sample table:

```shell
cat > sample-ids-medium.tsv <<'EOF'
sample-id
00b62637
00ce9aa6
016287d9
017d5b5e
01a38419
01e3a7b5
027ff912
0359c
03d12251
044403a4
EOF

qiime feature-table filter-samples \
    --i-table asv-table.qza \
    --m-metadata-file sample-ids-medium.tsv \
    --o-filtered-table asv-table-medium.qza
```

Then run with more resamples (`--p-n 5`):

```shell
qiime boots kmer-diversity \
    --i-table asv-table-medium.qza \
    --i-sequences asv-seqs.qza \
    --p-sampling-depth 10000 \
    --p-no-replacement \
    --m-metadata-file sample-metadata.tsv \
    --p-n 5 \
    --output-dir kmer-diversity-medium \
    --parallel \
    --parallel-config parsl-slurm.toml
```

When you are ready to run a real analysis, scale further by:

- raising `--p-n` so that more independent resamples can be dispatched,
- raising `max_blocks` so that Parsl can submit multiple worker blocks in parallel (each running its own subset of resamples),
- raising `mem_per_node` and `walltime` to match the size of your input data.

(parallel-on-slurm-troubleshooting)=
## Troubleshooting

### `Task failure due to loss of worker N on host ...`

This message means a Parsl worker process exited unexpectedly while QIIME 2 was waiting on a task it had dispatched to that worker.
The most common cause is that the worker was killed by the OS (out of memory) or by Slurm (block walltime exceeded, or job cancelled).

To diagnose:

1. **Check the failing block's stderr.** In `runinfo/<NNN>/submit_scripts/parsl.default.block-*.stderr`, look for messages like `slurmstepd: error: *** JOB N ON ... CANCELLED ...`. A cancellation right around the time of the failure points at Slurm killing the block.
2. **Check Slurm accounting if available.** If your site enables Slurm accounting, `sacct -j <jobid> --format=JobID,State,ExitCode,MaxRSS,ReqMem,Elapsed,TimeLimit` will show whether the job hit its memory or walltime cap.
3. **Re-run a serial baseline.** Drop `--parallel` (and `--parallel-config`) and run the same `Pipeline` once. If the serial run also fails with an out-of-memory error, the issue is the input size relative to the resources you've requested per block, not parallelism per se.

To fix:

- Increase `mem_per_node` and `walltime` in your TOML.
- Decrease `max_workers_per_node` (each worker holds one task in memory at a time, so fewer workers per block means more memory per task).
- Reduce the size of the input passed to each task (for example, fewer samples or a lower `--p-n`).

### Worker blocks never start running

If `squeue --me` shows your worker block in `PD` (pending) state for a long time, your `mem_per_node`, `cores_per_node`, or `walltime` may exceed what the partition allows.
Run `scontrol show partition <your-partition>` and compare its `MaxTime`, `MaxMemPerNode`, and `MaxCPUsPerNode` against your TOML.

### `Pipeline` never gets past "starting parallel execution"

Make sure your `worker_init` shell snippet actually activates a working QIIME 2 environment.
A quick check: copy the rendered `sbatch` script out of `runinfo/<NNN>/submit_scripts/` and submit it with `sbatch` directly.
The block must be able to `import qiime2` before Parsl can run any task on it.
