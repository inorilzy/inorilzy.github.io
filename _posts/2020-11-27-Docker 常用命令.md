---
title: "Docker 常用命令"
date: 2020-11-27 21:44:42 +0800
categories: [docker]
---

工作中 `docker` 常用的一些命令。

## docker:

* ps: 查看所有容器

* rm:
    * -f 强制删除没有关闭的容器
    * eg: docker rm -f  容器id/容器name

* images： 查看镜像

* rmi： 删除镜像

* run： 根据镜像启动容器
    * -i: 交互式
    * -t: 重新分配伪终端
    * -d: 后台运行
    * -p: 端口映射，可以写多个
    * -v: 挂在容器外目录，可以写多个
    * eg: docker run -itd -p 0.0.0.0:6061:6061 -p 0.0.0.0:6062:6062 -v /path:/path dockerimage:version
* exec:
    * -i: 交互式
    * -t: 伪终端
    * eg: docker exec -it 容器id/容器name /bin/bash

