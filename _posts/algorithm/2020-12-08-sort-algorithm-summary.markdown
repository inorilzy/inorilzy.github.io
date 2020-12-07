---
layout: post
title: 排序算法总结
date:   2020-12-08 00:09:42 +0800
categories: algorithm
---

## Bubble-Sort
#### 基础版本：
```
def bubble_sort(arr):
    n = len(arr)
    for i in range(n-1): # 每次找出一个最大值，n个数需要n-1次。
        for j in range(n-i-1): # 当前次排序需要n-1次比较，再减去已经排好序的i个数，所以需要n-1-i
            if arr[j]>arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]

```
#### 改进版本：
```
def bubble_sort(arr):
    n = len(arr)
    for i in range(n-1): # 每次找出一个最大值，n个数需要n-1次。
        exchange = False # 设置一个发生交换的标志位
        for j in range(n-i-1): # 当前次排序需要n-1次比较，再减去已经排好序的i个数，所以需要n-1-i
            if arr[j]>arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
                exchange = True # 如果发生交换，修改标志位。默认有序不会发生交换。
        if not exchange: # 如果没有发生交换，说明数组默认有序。跳出循环
            break
```