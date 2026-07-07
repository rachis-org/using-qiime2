(types-of-parallel-support)=
# Types of Parallel Computing Support

## Parallel Pipeline execution

QIIME 2's formal parallel computing support uses [Parsl](https://parsl.readthedocs.io/en/stable/1-parsl-introduction.html>), and enables parallel execution of QIIME 2 [Pipeline](xref:rachis-news-target#term-pipeline) actions.
All QIIME 2 `Pipelines` will have parallel computing options, notably the `--parallel` parameter in [q2cli](xref:rachis-news-target#term-q2cli), though whether those actually induce parallel computing is up to the implementation of the `Pipeline`.
Actions using this formal parallel computing support can make use of high-performance computing hardware that doesn't necessarily have shared memory.

## Informal Parallel Support

Some [Method](xref:rachis-news-target#term-method) actions (e.g., `qiime dada2 denoise-*`) wrap multi-threaded applications and may define a parameter (like `--p-n`) that gives the user control over that.
The QIIME 2 parameter type associated with these parameters should always be `NTHREADS` or `NJOBS` (if you observe a parameter where this isn't the case, it was probably an error on the developers part - reach out on the forum to let us know).
Actions using this informal parallel computing support are generally restricted to running on systems with shared memory.

## Parallel Environment Variables Used by Dependencies

Many Python libraries, including prominent ones like [Pandas](https://pandas.pydata.org/) and [NumPy](https://numpy.org/), parallelize themselves. These libraries use shell environment variables to determine how many threads to create. If the variable they use isn't set, they will create as many threads as you have CPUs. If you want to control this, you must set these environment variables.

The most commonly used of these environment variables by QIIME 2 dependencies is `OMP_NUM_THREADS`. Some others include `MKL_NUM_THREADS` and `OPENBLAS_NUM_THREADS`. Dependencies using one or more of these environment variables are often to blame for unexplained additional threads created by QIIME 2. Generally, this is not an issue, but if you are running out of RAM or have other concerns due to these threads try setting these variables to the number of threads you want.
