---
title: Ubuntu 安装 MySQL 和初始化设置
date: 2024-10-09 10:58:20 +0800
categories: [MySQL]
tags: [Ubuntu, MySQL]
---

# Ubuntu 安装 MySQL 和初始化设置



### 更新软件包列表

在开始安装之前，先更新一下系统的软件包列表：

```bash
sudo apt update
```

### 安装MySQL服务器

使用`apt`来安装MySQL服务器：

```bash
sudo apt install mysql-server
```

### 启动并检查MySQL服务

安装完成后，MySQL服务应该会自动启动。可以使用以下命令检查MySQL是否在运行：

```bash
sudo systemctl status mysql
```

如果没有启动，可以手动启动：

```bash
sudo systemctl start mysql
```

### 配置安全性

安装完成后，运行以下命令来配置MySQL的安全性：

```bash
sudo mysql_secure_installation
```

该命令会引导你设置MySQL的root用户密码，并进行其他安全相关的配置，如禁用远程登录、移除测试数据库等。

### 登录MySQL

可以通过以下命令登录到MySQL：

```bash
sudo mysql
```

或者使用MySQL root账户和密码登录：

```bash
mysql -u root -p
```

### 创建一个新用户

创建一个可以远程登录并具有读写权限的用户。假设新用户的用户名是 `newuser`，密码是 `password123`，并且允许从任意IP地址（即 `%`）连接：

```sql
CREATE USER 'newuser'@'%' IDENTIFIED BY 'password123';
create user 'newuser'@'%' identified by 'password123';
```

这里的 `%` 表示该用户可以从任何远程主机进行连接。你也可以指定特定的 IP 地址或主机名，例如 `192.168.1.100`，从而限制这个用户只能从某个 IP 地址连接。

###  赋予读写权限

给新用户赋予所有数据库的读写权限：

```sql
GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'%';
grant all privileges on *.* to 'newuser'@'%';
```

- `*.*` 表示该用户对所有数据库和所有表具有权限。如果你想限制该用户对某个特定数据库的读写权限，可以改为类似 `your_database.*`。

### 4. 刷新权限

完成后，执行以下命令刷新 MySQL 的权限缓存，以使更改立即生效：

```sql
FLUSH PRIVILEGES;
flush privileges;
```

### 

### 6. 验证安装

可以通过以下命令检查MySQL版本，确保它已经成功安装：

```bash
mysql --version
```

至此，MySQL已经成功安装并配置好了。









### 5. 配置 MySQL 允许远程连接

在 MySQL 默认配置中，MySQL 服务器只允许本地连接。如果需要远程访问 MySQL，需要修改 MySQL 配置文件：

编辑 `/etc/mysql/mysql.conf.d/mysqld.cnf` 文件：

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

找到以下行：

```bash
bind-address = 127.0.0.1
```

将它修改为：

```bash
bind-address = 0.0.0.0
```

这样 MySQL 将接受来自所有网络接口的连接。

### 6. 重启 MySQL 服务

修改配置文件后，重启 MySQL 服务以使更改生效：

```bash
sudo systemctl restart mysql
```

### 7. 测试远程连接

你可以在另一台机器上通过以下命令测试远程连接（替换 `your_mysql_server_ip` 为 MySQL 服务器的 IP 地址）：

```bash
mysql -u newuser -p -h your_mysql_server_ip
```

这样，新用户 `newuser` 就可以从远程主机连接到 MySQL 服务器，并具有读写权限了。



### 远程无法访问可能的问题

### 1. 防火墙阻止连接
防火墙可能会阻止 MySQL 的默认端口（通常是 `3306`）的外部访问。

#### 解决方案：
检查并配置防火墙允许 MySQL 端口 `3306` 的外部连接。

- **使用 UFW (Uncomplicated Firewall) 管理防火墙**：

  首先，查看防火墙状态：

  ```bash
  sudo ufw status
  ```

  如果防火墙启用且 MySQL 端口未开放，运行以下命令开放 `3306` 端口：

  ```bash
  sudo ufw allow 3306/tcp
  ```

  然后重新加载 UFW：

  ```bash
  sudo ufw reload
  ```

  你还可以直接开放 MySQL 允许远程访问的服务：

  ```bash
  sudo ufw allow mysql
  ```

- **检查其他防火墙（如云服务器的防火墙规则）**：
  如果你使用的是云服务器（如 AWS、阿里云等），还需检查云平台的防火墙规则（安全组）是否允许从外部访问端口 `3306`。

### 2. MySQL 配置文件限制外部访问
默认情况下，MySQL 服务器只允许本地连接（绑定到 `127.0.0.1`），这会阻止远程连接。

#### 解决方案：
检查并修改 MySQL 配置文件，使其允许远程连接。

1. 编辑 MySQL 配置文件：

   ```bash
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   ```

2. 找到以下行：

   ```bash
   bind-address = 127.0.0.1
   ```

3. 将它修改为：

   ```bash
   bind-address = 0.0.0.0
   ```

   这样 MySQL 将监听所有网络接口，允许远程访问。

4. 保存文件后，重启 MySQL 服务：

   ```bash
   sudo systemctl restart mysql
   ```

### 3. 用户权限配置不正确
如果你为远程用户配置了权限，但仍无法访问，可能是用户权限没有正确设置。

#### 解决方案：
确保远程用户拥有正确的权限，并且授权完成后刷新了权限。

1. 以 `root` 身份登录 MySQL：

   ```bash
   sudo mysql
   ```

2. 确认用户 `newuser` 的授权设置，确保它可以从 `%`（任何主机）连接：

   ```sql
   SELECT user, host FROM mysql.user WHERE user = 'newuser';
   ```

   如果没有发现类似 `newuser@%` 的记录，创建一个远程用户或调整现有用户的权限：

   ```sql
   GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'%' IDENTIFIED BY 'password123';
   FLUSH PRIVILEGES;
   ```

### 4. 网络问题
确保远程机器和 MySQL 服务器之间没有网络阻碍。

#### 解决方案：
1. 检查网络连接：

   ```bash
   ping your_mysql_server_ip
   ```

2. 使用 telnet 检查端口是否开放：

   ```bash
   telnet your_mysql_server_ip 3306
   ```

   如果连接失败，说明可能是网络或防火墙问题。
   
   如果是云服务器，需要在对应网站（阿里云、腾讯云等）打开连接端口。

### 总结
- 检查防火墙是否允许 MySQL 端口 3306 访问。
- 确保 MySQL 配置文件中的 `bind-address` 设置为 `0.0.0.0`。
- 确保用户权限正确配置，并允许从远程连接。
- 确认网络连接正常，没有阻碍。



### MySQL 配置文件位置：

使用apt安装的位置如下

**配置文件**：

- 主配置文件路径：`/etc/mysql/my.cnf`
- 其他配置文件路径：`/etc/mysql/mysql.conf.d/` 和 `/etc/mysql/conf.d/`

**数据库文件**：

- 默认数据库存储路径：`/var/lib/mysql/`
- MySQL的数据库数据会存储在这个目录下。

**日志文件**：

- 一般的日志路径：`/var/log/mysql/`
- 错误日志、慢查询日志等都可以在这个目录找到。

**可执行文件**：

- MySQL服务的可执行文件路径：`/usr/sbin/mysqld`
- 客户端命令如`mysql`命令的路径：`/usr/bin/mysql`

**服务管理**：

- 服务启动脚本：`/etc/init.d/mysql`
- 使用`systemctl`管理服务：`sudo systemctl start mysql`、`sudo systemctl status mysql`等。