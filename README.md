# docker-spark

 > Spark Docker Image based on Alpine Linux which is optimized for containers and light-weight.

## Introduction

> Please use corresponding branches from this repo to play with code.

- __2.2.9 = latest__
- __2.1.1__

## Build

```bash
docker build --build-arg VCS_REF=`git rev-parse --short HEAD` \
--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
--rm \
-t lonly/docker-spark:2.0.0 .
```

## License

![License](https://img.shields.io/github/license/lonly197/docker-alpine-python.svg)

## Contact me

- Email: <lonly197@qq.com>