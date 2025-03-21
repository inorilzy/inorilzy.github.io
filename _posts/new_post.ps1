# 设置输出编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 获取文章标题
if ($args.Count -eq 0) {
    $title = Read-Host "请输入文章标题"
} else {
    $title = $args[0]
}

# 获取当前日期和时间
$date_str = Get-Date -Format "yyyy-MM-dd"
$datetime_str = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 创建文件名（移除标题中的特殊字符）
$filename = "$date_str-$($title -replace '["\?/\\]','-').md"

# 创建文章内容
$content = @"
---
layout: post
title: "$title"
date: $datetime_str +0800
categories: blog
tags: []
description: 
---

"@

# 写入文件
$content | Out-File -FilePath $filename -Encoding utf8
Write-Host "已创建文章：$filename"
