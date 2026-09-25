# Progress MarkLogic/Semaphore GenAI Demo

## Introduction

PLEASE READ THESE INSTRUCTIONS IN THEIR ENTIRETY BEFORE TAKING ACTION.  

This Docker setup configures all Progress Semaphore components in one container.  Progress MarkLogic, acting as a backing store for the Semaphore models, runs in another container.

The setup consists of 2 containers:
+ A Semaphore server
+ A MarkLogic server

## Integrating into your project

`docker-compose.yml` in this directory is an example, not something you run
directly from here — copy its `services`, `volumes`, and `networks` entries
into your own project's `docker-compose.yml` (merging with anything already
there of the same name) and adjust ports/paths/network name to fit. It assumes
this repo is vendored at `vendor/semaphore-all-in-one`; update `build.context` and
the marklogic patch volume path if you've vendored it elsewhere.

### Vendoring this repo

Add this repo as a git submodule under `vendor/` in your project:

```bash
git submodule add git@github.com:sjcrook/semaphore-all-in-one.git vendor/semaphore-all-in-one
git submodule update --init --recursive
```

Anyone cloning your project afterwards needs to pull the submodule contents too:

```bash
git clone --recurse-submodules <your-project-url>
# or, if already cloned:
git submodule update --init --recursive
```

The Semaphore build also expects a `semaphore-provisioning/` directory at your
project root, holding the real license, RPMs, and yum certs for your
deployment (never committed) — see `template/create-scaffold-provisioning.sh`
and `template/provisioning/README.md` to set it up.

## Configuring The Build

### Semaphore

The Semaphore container is an all-on-one container (Studio, KMM, Classification Server, Semantic Enhancement Server, and Concept Server).  MarkLogic stores the Semaphore models.

The Semaphore all-in-one image can be built in one of two ways:
+ by copying the Semaphore RPMs into semaphore-provisioning/Semaphore_RPMs/ and specifying RPM_SOURCE=LOCAL in the .env file.
  - Note that you must copy into this directory all of the following RPMs otherwise the build will fail:
    * Semaphore Classification Server
    * Semaphore Concept Server
    * Semaphore Language Pack Linux Base
    * Semaphore Language Pack Linux English
    * Semaphore SES
    * Semaphore Studio
+ by installing the RPMs from a private repository and specifying RPM_SOURCE=PRIVATE_REPO in the .env file.
  - See yum-cert-utils/README.md.
  - The RPMs are downloaded as the image is being built.

You can set the ports that are exposed by setting the following values in the .env file.:
+ EXT_STUDIO_5080
+ EXT_STUDIO_5081
+ EXT_CLS_5058
+ EXT_CLS_5059
+ EXT_SES_8983
+ EXT_SES_9983
+ EXT_CONCEPTS_5092

If using RPM_SOURCE=PRIVATE_REPO, you can also specify the version numbers of the components to install:
+ SEM_VER_LP_BASE
+ SEM_VER_LP_ENGLISH
+ SEM_VER_CLASSIFICATION
+ SEM_VER_SES
+ SEM_VER_CONCEPTS
+ SEM_VER_STUDIO

### MarkLogic

You can set the MARKLOGIC_ADMIN_USERNAME/MARKLOGIC_ADMIN_PASSWORD in the .env file.  You can but shouldn't need to change the MARKLOGIC_SEMAPHORE_DATABASE value.

## Building the Environment

### Standup the containerized environment

At the command prompt, run `docker compose up -d`