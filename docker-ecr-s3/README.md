# PREP

Preprocessing docker image with s3 and ECR

- Dockerfile: used for building the docker image and installing dependencies, setting up env
- scrape.py: script that executes when a container is run, will download a file from stpubdata and upload to s3 bucket
- config.sh: editable configuration settings that tells docker and aws things like the image name, tag, ECR repo etc
- build.sh: builds the image
- push.sh: pushes image to ECR

## config settings

Once you've created a repo in ECR (for now can do so in the AWS console), edit the config.sh file to whatever you named that repo (e.g. "rkein-pixel")

## build docker image

```bash
$ sh build.sh
```

### run the container (testing the scrape.py script)

try running the container from EC2:

1. interactively (go into the running container, run the py script):

```bash
$ docker run -it $DOCKERIMAGE 
$ python scrape.py

downloading from s3: stpubdata : hst/public/ien4/ien406d3q/ien406d3q_flc.fits
uploading to s3:uvisqepixel
Uploaded: preptest/ien406d3q_flc.fits
```

2. noninteractively (just have the container run py script in background)

```bash
$ docker run $DOCKERIMAGE python scrape.py
```

check the s3 folder and voila the file is now in your bucket!


## push image to ECR

Once you've created a repo in ECR (for now can do so in the AWS console), edit the config.sh file to whatever you named that repo (e.g. "rkein-pixel")

```bash
$ sh push.sh
```
