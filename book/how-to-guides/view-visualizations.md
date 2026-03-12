(view-visualizations)=
# How to view Visualizations

## QIIME 2 View

QIIME 2 visualizations can be loaded at [QIIME 2 View](https://view.qiime2.org).

```{admonition} Video
[This video](https://t.co/eJbm03cnSa) on the QIIME 2 YouTube channel illustrates how to use QIIME 2 View.
```

## q2cli

If you're using {term}`q2cli` on a computer with an active display (i.e., not one that you're connected to over ssh), you should be able to view your visualization by calling `qiime tools view`.

## Jupyter Notebooks: Experimental

QIIME 2 Visualizations can be viewed and interacted with inline in Jupyter Notebooks.
Before starting your Jupyter server, run the following command:

```shell
jupyter server extension enable --py qiime2 --sys-prefix
```

Then, after starting your Jupyter server (e.g., by running `jupyter notebook` or `jupyter lab`), you can view a visualization by referring to it (i.e., its `repr` will be the interactive view) as follows:

```python
import qiime2
v = qiime2.Visualization.load('./taxa-bar-plots.qzv')
v
```