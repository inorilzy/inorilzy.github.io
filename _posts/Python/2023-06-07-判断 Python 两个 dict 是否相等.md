---
title: 判断 Python 两个 dict 是否相等.md
date: 2023-06-07 02:28:26 +0800
categories: [Python]
tags: []
---

## 1. 使用 `==` 进行比较
```python
a = {'name':'lzy', 'num':[1,2,3]}
b = { 'num':[1,2,3],'name':'lzy'}
a == b
True
```

## 2. 利用函数进行比较

```python
a = {'name':'lzy', 'num':[1,2,3]}
b = { 'num':[1,2,3,4],'name':'lzy'}
import operator
operator.eq(a,b)
False
```
