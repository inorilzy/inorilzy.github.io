---
title: uv 安装本地 python ，uv sync 使用国内 pip 源
date: 2024-12-05 12:52:30 +0800
categories: [uv]
tags: [uv]
---



### 如何在 Linux 上快速安装 python 新版本

如果 `apt` 没有提供你需要的最新版本的 Python，你可以通过添加 PPA（Personal Package Archive）来安装。以下是使用 PPA 安装最新 Python 版本的步骤：

1. **更新包列表**：

   首先，确保你的包列表是最新的：

   ```bash
   sudo apt update
   ```

2. **安装 `software-properties-common`**：

   这个包提供了 `add-apt-repository` 命令，用于添加 PPA：

   ```bash
   sudo apt install software-properties-common
   ```

3. **添加 Python PPA**：

   你可以使用 `deadsnakes` PPA，它通常提供最新的 Python 版本：

   ```bash
   sudo add-apt-repository ppa:deadsnakes/ppa
   ```

   然后再次更新包列表：

   ```bash
   sudo apt update
   ```

4. **安装最新的 Python 版本**：

   现在你可以安装最新的 Python 版本。例如，要安装 Python 3.12：

   ```bash
   sudo apt search python3.12.*
   sudo apt install python3.12
   ```

5. **验证安装**：

   安装完成后，验证 Python 版本：

   ```bash
   python3.12 --version
   ```

通过以上步骤，你就可以使用 PPA 安装最新版本的 Python。请注意，使用 PPA 可能会引入不稳定的版本，因此在生产环境中使用时要谨慎。

1.  使用 uv 安装
   1. 使用自带的 python 安装 uv
      - uv 会从 uv 开发者维护的 github 仓库拉取 python 编译后的安装包，如果服务器没有使用代理，会拉取失败
      - 从拉取失败中给的 url 下载 python 
      - 使用 sftp 移动到服务器
      - 找个文件夹放 ，如： /root/20241016/cpython-3.13.0+20241016-x86_64-unknown-linux-gnu-freethreaded+pgo+lto-full.tar.zst , 后面这个20241016 是 下载失败 url 中的路径
      - uv python install cpython-3.13.0+freethreaded-linux-x86_64-gnu --mirror file:///root

### uv sync 如何使用国内源

- 使用国内源 `uv sync -i url`
- url:
  - 清华大学：URL: https://pypi.tuna.tsinghua.edu.cn/simple
  - 阿里云：URL: https://mirrors.aliyun.com/pypi/simple/
  - 中国科技大学：URL: https://pypi.mirrors.ustc.edu.cn/simple/
  - 豆瓣：URL: https://pypi.douban.com/simple/



