---
title: MySQL 存储过程和 Event Scheduler
date: 2024-11-29 16:24:37 +0800
categories: [MySQL]
tags: [MySQL]
---



```mysql
CREATE PROCEDURE factory_data_annotation.archive_factory_affairs_records()
BEGIN
    -- 声明变量
    DECLARE archive_date DATE;
    DECLARE batch_size INT;
    DECLARE affected_rows INT;
    DECLARE max_retries INT;
    DECLARE current_retry INT;
    DECLARE error_occurred BOOLEAN DEFAULT FALSE;
    
    -- 初始化变量
    SET archive_date = DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH);
    SET batch_size = 10000;
    SET max_retries = 3;
    SET current_retry = 0;
    
    -- 创建归档表（如果不存在）
    CREATE TABLE IF NOT EXISTS factory_data_annotation.factory_affair_record_archive LIKE 
        factory_data_annotation.factory_affair_record;
    
    -- 创建归档日志表（如果不存在）
    CREATE TABLE IF NOT EXISTS factory_data_annotation.archive_log (
        `id` int NOT NULL AUTO_INCREMENT,
        `start_time` datetime DEFAULT NULL,
        `end_time` datetime DEFAULT NULL,
        `records_archived` int DEFAULT NULL,
        `status` varchar(50) DEFAULT NULL,
        `error_message` text,
        `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    );
    
    -- 记录开始时间
    INSERT INTO factory_data_annotation.archive_log 
        (start_time, status) 
    VALUES 
        (NOW(), 'STARTED');
    
    SET @log_id = LAST_INSERT_ID();
    
    archive_loop: LOOP
        SET current_retry = 0;
        SET error_occurred = FALSE;
        
        WHILE current_retry < max_retries AND NOT error_occurred DO
            BEGIN
                DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
                BEGIN
                    SET error_occurred = TRUE;
                    ROLLBACK;
                    SET current_retry = current_retry + 1;
                    
                    IF current_retry = max_retries THEN
                        UPDATE factory_data_annotation.archive_log 
                        SET status = 'FAILED',
                            error_message = 'Maximum retry attempts reached',
                            end_time = NOW()
                        WHERE id = @log_id;
                        
                        SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = '归档过程失败，已达到最大重试次数';
                    END IF;
                END;

                IF NOT error_occurred THEN
                    START TRANSACTION;
                    
                    -- 先创建临时表存储要归档的ID
                    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_archive_ids (
                        record_id int PRIMARY KEY
                    );
                    
                    -- 插入要归档的记录ID
                    INSERT INTO tmp_archive_ids (record_id)
                    SELECT id 
                    FROM factory_data_annotation.factory_affair_record 
                    WHERE time_stamp < archive_date
                    LIMIT batch_size;
                    
                    -- 使用临时表的ID来插入数据
                    INSERT INTO factory_data_annotation.factory_affair_record_archive
                    SELECT r.* 
                    FROM factory_data_annotation.factory_affair_record r
                    INNER JOIN tmp_archive_ids t ON r.id = t.record_id;
                    
                    SET affected_rows = ROW_COUNT();
                    
                    IF affected_rows > 0 THEN
                        -- 使用临时表的ID来删除数据
                        DELETE r FROM factory_data_annotation.factory_affair_record r
                        INNER JOIN tmp_archive_ids t ON r.id = t.record_id;
                        
                        UPDATE factory_data_annotation.archive_log 
                        SET records_archived = COALESCE(records_archived, 0) + affected_rows
                        WHERE id = @log_id;
                    END IF;
                    
                    -- 删除临时表
                    DROP TEMPORARY TABLE IF EXISTS tmp_archive_ids;
                    
                    COMMIT;
                    
                    -- 如果没有数据被处理，退出循环
                    IF affected_rows = 0 THEN
                        UPDATE factory_data_annotation.archive_log 
                        SET status = 'COMPLETED',
                            end_time = NOW()
                        WHERE id = @log_id;
                        
                        LEAVE archive_loop;
                    END IF;
                END IF;
            END;
        END WHILE;
        
        IF NOT error_occurred THEN
            LEAVE archive_loop;
        END IF;
        
    END LOOP archive_loop;
    
    -- 优化表
    OPTIMIZE TABLE factory_data_annotation.factory_affair_record;
    OPTIMIZE TABLE factory_data_annotation.factory_affair_record_archive;
    
END;
```



```mysql
-- 执行前先备份一些数据用于验证
CREATE TEMPORARY TABLE tmp_verify AS
SELECT * FROM factory_data_annotation.factory_affair_record
WHERE time_stamp < DATE_SUB(CURRENT_DATE(), INTERVAL 4 MONTH)
LIMIT 5;

-- 执行存储过程
CALL factory_data_annotation.archive_factory_affairs_records();

-- 验证数据
SELECT * FROM tmp_verify t
LEFT JOIN factory_data_annotation.factory_affair_record_archive a ON t.id = a.id;
```





## 存储过程定时执行：

MySQL 提供了两种方式来定时执行存储过程：

### 1. 使用 MySQL Event Scheduler（推荐）

首先检查并启用 Event Scheduler：

```sql
-- 检查 Event Scheduler 状态
SHOW VARIABLES LIKE 'event_scheduler';

-- 如果未启用，可以启用它
SET GLOBAL event_scheduler = ON;
```

然后创建定时事件：

```sql
-- 创建每天凌晨2点执行的事件
CREATE EVENT archive_factory_affairs_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 2 HOUR
DO CALL factory_data_annotation.archive_factory_affairs_records();

-- 或者创建每周日凌晨2点执行的事件
CREATE EVENT archive_factory_affairs_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL (7 - WEEKDAY(CURRENT_DATE)) DAY) + INTERVAL 2 HOUR
DO CALL factory_data_annotation.archive_factory_affairs_records();
```

事件管理命令：

```sql
-- 查看所有事件
SHOW EVENTS;

-- 临时禁用事件
ALTER EVENT archive_factory_affairs_daily DISABLE;

-- 启用事件
ALTER EVENT archive_factory_affairs_daily ENABLE;

-- 删除事件
DROP EVENT IF EXISTS archive_factory_affairs_daily;
```

### 2. 使用 Linux Crontab（如果有服务器权限）

1. 创建执行脚本 `archive_factory_affairs.sh`：

```bash
#!/bin/bash
mysql -u username -p'password' factory_data_annotation -e "CALL archive_factory_affairs_records();"
```

2. 添加执行权限：

```bash
chmod +x archive_factory_affairs.sh
```

3. 编辑 crontab：

```bash
crontab -e
```

4. 添加定时任务：

```bash
# 每天凌晨2点执行
0 2 * * * /path/to/archive_factory_affairs.sh

# 或每周日凌晨2点执行
0 2 * * 0 /path/to/archive_factory_affairs.sh
```

### 建议和注意事项：

1. **日志记录**：修改存储过程添加更详细的日志

```sql
CREATE PROCEDURE factory_data_annotation.archive_factory_affairs_records()
BEGIN
    -- ... 其他代码 ...
    
    -- 添加更详细的日志记录
    INSERT INTO factory_data_annotation.archive_log 
        (start_time, status, error_message) 
    VALUES 
        (NOW(), 'STARTED', CONCAT('Scheduled run at ', NOW()));
    
    -- ... 其他代码 ...
END;
```

2. **错误通知**：可以添加邮件通知

```sql
CREATE PROCEDURE factory_data_annotation.send_error_notification(IN p_message TEXT)
BEGIN
    -- 这里添加发送邮件的逻辑
    -- 可以调用外部脚本或使用MySQL的sys_exec
END;

-- 在主存储过程中使用
IF error_occurred THEN
    CALL send_error_notification(CONCAT('Archive failed at ', NOW()));
END IF;
```

3. **监控查询**：

```sql
-- 检查最近的归档状态
SELECT 
    DATE(start_time) as archive_date,
    status,
    records_archived,
    TIMEDIFF(end_time, start_time) as duration,
    error_message
FROM factory_data_annotation.archive_log
ORDER BY start_time DESC
LIMIT 10;
```

4. **性能考虑**：

```sql
-- 在事件定义中添加并发控制
CREATE EVENT archive_factory_affairs_daily
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE) + INTERVAL 2 HOUR
DO
BEGIN
    -- 检查是否有其他归档正在运行
    IF NOT EXISTS (
        SELECT 1 
        FROM factory_data_annotation.archive_log 
        WHERE status = 'STARTED' 
        AND start_time > DATE_SUB(NOW(), INTERVAL 1 HOUR)
    ) THEN
        CALL factory_data_annotation.archive_factory_affairs_records();
    END IF;
END;
```

5. **备份建议**：

在定时任务执行前自动备份：

```bash
#!/bin/bash
# 备份当前数据
mysqldump -u username -p'password' factory_data_annotation factory_affair_record > backup_$(date +%Y%m%d).sql

# 执行归档
mysql -u username -p'password' factory_data_annotation -e "CALL archive_factory_affairs_records();"
```

选择哪种方式主要取决于：
1. 服务器权限
2. 维护便利性
3. 监控需求
4. 系统架构

通常推荐使用 MySQL Event Scheduler，因为：
- 更容易管理和监控
- 不需要额外的系统权限
- 可以直接在数据库层面控制
