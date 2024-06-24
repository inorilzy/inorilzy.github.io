---
title: 排序算法总结
date: 2020-12-08 00:09:42 +0800
categories: [数据结构和算法]
---

一些排序，方便随时查看！

![sort_algorithm](https://cdn.jsdelivr.net/gh/inorilzy/blog-img/sort202305091836213.png)

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
## Insert-Sort
思路：将序列看成两部分 前面有序，再从后面去一个插入到前面有序队列的对应位置
参考：https://www.bilibili.com/video/BV1Ly4y1B7fy?from=search&seid=5866228426019660095

```
def insert_sort(arr):
    for i in range(1,len(arr)):
        key = arr[i]
        j = i-1
        while j>=0 and arr[j]>key:
            arr[j+1] = arr[j]
            j -= 1
        arr[j+1] = key
```
## selectionSort
```
def selectionSort(arr):
    for i in range(len(arr) - 1):
        # 记录最小数的索引
        minIndex = i
        for j in range(i + 1, len(arr)):
            if arr[j] < arr[minIndex]:
                minIndex = j
        # i 不是最小数时，将 i 和最小数进行交换
        if i != minIndex:
            arr[i], arr[minIndex] = arr[minIndex], arr[i]
```
## Quick-Sort
```
def quick_sort(arr, left, right):
    if left < right:
        p = partition(arr, left, right)
        quick_sort(arr, left, p - 1)
        quick_sort(arr, p+1, right)


def partition(arr, left, right):
    key = arr[left]
    while left < right:
        while left < right and arr[right] >= key:
            right -= 1
        arr[left] = arr[right]
        while left < right and arr[left] <= key:
            left += 1
        arr[right] = arr[left]
    arr[left] = key
    return left


if __name__ == '__main__':
    L = [5, 9, 1, 11, 6, 7, 2, 4]
    quick_sort(L, 0, len(L)-1)
    print(L)


```
