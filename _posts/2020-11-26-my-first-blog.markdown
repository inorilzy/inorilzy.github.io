---
layout: post
title:  "配置Linux命令行提示符颜色"
date:   2020-11-26 15:40:42 +0800
categories: jekyll update
---


# 配置Linux命令行提示符颜色

终端输入： 
  `PS1="\[\e[0m\][\[\e[32m\]\u\[\e[35m\]@\h \[\e[36m\]\w\[\e[0m\]]\\$ "`

但现在是一次性的，每次重启或新建窗口就会消失。

永久获得：
  `vim ~/.bashrc`
讲上面的代码复制到 .bashrc 中并重新加载 `source ~/.bashrc` 。

修改完成！！！