Standard Operating Procedures for automating development and maintenance.
Copy/paste, use issues, or [reach out](https://t.me/abitrolly) for
onboarding the experise into your own workflow.

#### Known Elements

* [x] GitHub (https://github.com/yakshaveinc/linux)
* [x] Travis CI (https://travis-ci.org/yakshaveinc/linux)
* [x] DockerHub (https://hub.docker.com/r/yakshaveinc)
* [x] Snap Store (https://snapcraft.io/yakshaveinc)
* [x] CirrusCI (https://cirrus-ci.com/github/yakshaveinc/linux)

 (automatic uploads are done with separate `yeesus` account)

#### Standard Operating Procedures (SOP)

Active automation.
    
* [x] Docker image builds with Cirrues CI [![CirrusCI](https://api.cirrus-ci.com/github/yakshaveinc/linux.svg)](https://cirrus-ci.com/github/yakshaveinc/linux)
  * [x] Including upload from Cirrus CI to DockerHub
     
Inactive automation.

* [x] Automatic builds, testing, `docker` and `snap` delivery with Travis CI [![Travis](https://img.shields.io/travis/yakshaveinc/linux.svg)](https://travis-ci.org/yakshaveinc/linux)
  * [x] Including deploy of Docker containers from Travis CI to DockerHub  
      ![github->travis->dockerhub](./docops/ops-travis-dockerhub.svg)
  * [x] Including build and publish from Travis CI to Snap Store  
      ![github->travis->dockerhub](./docops/ops-travis-snapcraft.svg)
    * https://snapcraft.io/yakshaveinc (@abitrolly)
    * https://snapcraft.io/gitless (@techtonik, @abitrolly)

### `snapcraft` Docker images for building snaps

This repo contains [automation](https://github.com/yakshaveinc/linux/blob/master/.cirrus.yml)
that builds and deploys docker images for
[`snapcraft`](https://snapcraft.io/docs/snapcraft) build tool.

https://hub.docker.com/r/yakshaveinc/snapcraft

---

(no copyright) Yak Shave Inc.
