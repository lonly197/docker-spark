# docker-spark

> Spark Docker Image based on Alpine Linux which is optimized for containers and light-weight.

## Build

```bash
docker build --build-arg VCS_REF=`git rev-parse --short HEAD` \
--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
--rm \
-t lonly/docker-spark:2.3.2-slim .
```

## License

![License](https://img.shields.io/github/license/lonly197/docker-spark.svg)

## Contact me

- Email: <lonly197@qq.com>
