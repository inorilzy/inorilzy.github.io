---
title: apscheduler 简单使用
date: 2024-06-21 12:08:25 +0800
categories: [python, apscheduler]
tags: []
---



```
from apscheduler.schedulers.background import BackgroundScheduler
import time

# 定义任务
def cron_job():
    pass


if __name__ == "__main__":
    scheduler = BackgroundScheduler()  # 创建调度器
    scheduler.add_job(cron_job, "cron", hour=8, minute=0, id="job1")
    scheduler.add_job(cron_job, "cron", hour=12, minute=0, id="job2")
    try:
        scheduler.start()
        print("调度器已启动")
        while True:
            time.sleep(1)  # 保持主线程运行
    except Exception as e:
        print(f"调度器发生异常: {e}")
        scheduler.shutdown()
        print("调度器已关闭")
```