(workshop-container)=
# How to use the QIIME 2 workshop container

````{margin}
```{admonition} Video
:class: tip
The first ~15 minutes of [this video](https://www.youtube.com/watch?v=-NrzA8BcQxQ) illustrate interacting with our workshop container from a recent QIIME 2 workshop.
The specific quay.io URLs referenced in the video should work, but referring to the URLs referenced below will ensure that you're using the most recent workshop containers.
```
````

```{warning}
This document covers use of the QIIME 2 workshops containers, which were released for the first time with QIIME 2 2024.10.
Because this is relatively new functionality (as of October 2024) be sure to test your container before relying on it for a workshop.
Reach out on the [QIIME 2 Forum](https://forum.qiime2.org) if you run into questions or issues.
```

Using a QIIME 2 workshop container will enable you (or your students) to use QIIME 2 on the command line or through Jupyter Lab in a containerized environment that should be consistent across different host operating systems (i.e., whether you're running on macOS, Linux, or Windows).

We recommend using either [Podman](https://podman.io) or [Docker](https://docker.com).
Before you jump in with QIIME 2, follow the "Get Started" (i.e., install) instructions for one or the other on the project's website, and confirm that it's working according to the Podman's or Docker's instructions.
(We don't link to their instructions here so that we don't send you to an outdated link.)

```{admonition} Podman versus Docker
:class: dropdown, question
We don't take much of a stance on whether Podman or Docker is a better tool for using QIIME 2 - teaching with either is still pretty new to us.

Podman seems to have some interesting benefits though, including ease of transition to paid cloud environments (via [Kubernetes](https://www.digitalocean.com/products/kubernetes)) if you need more computational resources than you have access to.
Podman also doesn't require that you have root/admin access on the computer where you're using it, so may work better if you're using computer hardware that is administered by others (such as a laptop computer owned and maintained by your employer).

You can find a perspective on the differences between the two from the developers of Podman [here](https://www.redhat.com/en/topics/containers/what-is-podman#podman-vs-docker).
```

(pull-workshop-image)=
## Pull the container image

After installing Docker or Podman, we next need to pull (i.e., download) the image that contains our QIIME 2 environment.
Copy/paste the relevant commands.

`````{tab-set}
````{tab-item} Docker instructions

First, open Docker Desktop.

Then, in a command terminal, run:

```shell
docker \
 image \
 pull quay.io/qiime2/<distribution>-workshop:<epoch>
```
````

````{tab-item} Podman instructions

The first time you start podman, you'll need to run the following command:

```shell
podman machine init
```

Then, each time you restart your computer, you'll need to run:

```shell
podman machine start
```

Then, run:

```shell
podman \
 image \
 pull quay.io/qiime2/<distribution>-workshop:<epoch>
```
````
`````

The above commands will require modification to replace `<distribution>` with the QIIME 2 [distribution](xref:rachis-news-target#term-distribution) that you'd like to install, and to replace `<epoch>` with the QIIME 2 [epoch](xref:rachis-news-target#term-epoch) that you'd like to install.
For example, if you'd like to install the metagenome distribution from the 2024.10 epoch, your quay.io URL would look like:

```
quay.io/qiime2/metagenome-workshop:2024.10
```

You can browse our container collection on quay.io at https://quay.io/organization/qiime2.

```{tip}
If you're teaching a QIIME 2 workshop and want to provide specific instructions to your students on how to download a container without requiring them to adapt commands (e.g., replace `<distribution>` with `metagenome`), you can feel free to download and modify the contents of this file.
You can download the Markdown source (`.md` file) for this page above (click the ⬇ button toward the top of the page).
```

(create-volume)=
## Create a data storage volume

Next, we create a volume that will be used to store any data we generate during our analysis.
Data that you create in your container will persist and be available the next time you start the container.

`````{tab-set}
````{tab-item} Docker
```shell
docker volume create qiime2-workshop
```
````
````{tab-item} Podman
```shell
podman volume create qiime2-workshop
```
````
`````

(start-container)=
## Start the container

Next, we'll start the container.

`````{tab-set}

````{tab-item} Docker
```shell
docker container run \
  -itd \
  --rm \
  -v qiime2-workshop:/home/qiime2 \
  --name qiime2-workshop \
  -p 8889:8888 \
  quay.io/qiime2/<distribution>-workshop:<epoch>
```
````

````{tab-item} Docker on Apple M-series
```shell
docker container run \
  -itd \
  --rm \
  -v qiime2-workshop:/home/qiime2 \
  --name qiime2-workshop \
  -p 8889:8888 \
  --platform "linux/amd64" \
  quay.io/qiime2/<distribution>-workshop:<epoch>
```
````

````{tab-item} Podman
```shell
podman container run \
  -itd \
  --rm \
  -v qiime2-workshop:/home/qiime2 \
  --name qiime2-workshop \
  -p 8889:8888 \
  quay.io/qiime2/<distribution>-workshop:<epoch>
```
````

````{tab-item} Podman on Apple M-series
```shell
podman container run \
  -itd \
  --rm \
  -v qiime2-workshop:/home/qiime2 \
  --name qiime2-workshop \
  -p 8889:8888 \
  --platform "linux/amd64" \
  quay.io/qiime2/<distribution>-workshop:<epoch>
```
````
`````

Again, you'll need to update `<distribution>` and `<epoch>` as described above.

## Interact with Jupyter Lab and QIIME 2

Once the container is running, you can interact with it by opening the following link: http://localhost:8889
This will open a Jupyter Lab window in your web browser.

### Using QIIME 2 through the command line

In the Jupyter Lab window, click the *Terminal* button toward the bottom right.
(Look for a block box with a `$` symbol in it.)

You'll then have command line access to QIIME 2.

In the terminal environment, run the following command:

```shell
qiime info
```

This provides information on your QIIME 2 environment, including the versions of the QIIME 2 framework, Python, and the installed plugins.

To get a start getting a feel for what you can do with your QIIME 2 deployment, run:

```shell
qiime --help
```

This provides a list of the available QIIME 2 plugins.
To learn more about what you can do with one of them (for example, the `feature-table` plugin), call:

```shell
qiime feature-table --help
```

This will display a list of actions (i.e., commands) that are available in that plugin.
To learn how to use one, for example `filter-samples`, call:

```shell
qiime feature-table filter-samples --help
```

That will provide help text and a list of examples that illustrate how to use the command to achieve different goals.

You can return to this document when you need to start, stop, or update your container.

## Stopping the container

When you're no longer using the container, you can stop it as follows:

`````{tab-set}
````{tab-item} Docker
```shell
docker container stop qiime2-workshop
```
````

````{tab-item} Podman
```shell
podman container stop qiime2-workshop
```
````
`````

If using Docker, once you're done using your container and don't have any other containers running, it's a good idea to quit Docker so it's not using resources unnecessarily.

(build-the-workshop-image)=
## Building the image locally (optional; experts only ♦♦)

**Expert users** may ultimately be interested in modifying the image used here.
This can be done with `docker` as follows.
[Pulling the image](#pull-workshop-image) will be quicker and easier.

First, download the Dockerfile for the workshop container.
```shell
wget https://raw.githubusercontent.com/qiime2/distributions/refs/heads/dev/Dockerfile.workshop
```

Then, edit the file to specify the epoch (e.g., 2024.10) and distribution (e.g., `amplicon`) that you want to build your container for.

Next, make sure that the Docker daemon is running (e.g. by launching Docker Desktop).

Finally, build the image.

`````{tab-set}
````{tab-item} Standard Instructions
```shell
docker image build -t my-image-name .
```
````
````{tab-item} M-series Mac Instructions
```shell
docker image build -t my-image-name --platform "linux/amd64" .
```
````
`````
