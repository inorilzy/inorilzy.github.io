---
title: python dotenv 测试
date: 2025-01-22 13:57:05 +0800
categories: []
tags: []
---











config.py:

```python


```

launch.json	

```json
{
  // 使用 IntelliSense 了解相关属性。
  // 悬停以查看现有属性的描述。
  // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python 调试程序: 当前文件",
      "type": "debugpy",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "env": {
        "Env": "dev"
      }
    }
  ]
}

```

这样就可以通过环境变量来控制测试环境和生产环境 ，

同时需要提供 .env.example 文件

如何使用:

```
from config import config


def main():
    print(config.get("name"))
    print(config.get("sex"))


if __name__ == "__main__":
    main()

```

# Python-dotenv 环境配置最佳实践

## 1. 项目结构
```
project/
├── .env.dev         # 开发环境配置
├── .env.product     # 生产环境配置
├── .env.example     # 配置模板
├── config.py        # 配置类
└── main.py         # 主程序
```

## 2. 配置类实现
我们实现了一个优雅的配置管理类：

```python:config.py
from dotenv import dotenv_values
import os
from typing import Dict, Any


class Config:
    def __init__(self):
        self.env = os.environ.get("Env")
        self.config: Dict[str, Any] = self._load_config()

    def _load_config(self) -> Dict[str, Any]:
        if self.env == "dev":
            return dotenv_values(".env.dev")
        else:
            return dotenv_values(".env.product")

    def get(self, key: str, default: Any = None) -> Any:
        """获取配置值"""
        return self.config.get(key, default)

    @property
    def environment(self) -> str:
        """获取当前环境"""
        return self.env


# 创建全局配置实例
config = Config()
```

## 3. 环境变量文件示例

```ini:.env.example
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=user
DB_PASSWORD=password

# API配置
API_KEY=your_api_key
API_URL=https://api.example.com

# 应用配置
DEBUG=false
LOG_LEVEL=info
```

## 4. VSCode 调试配置

```json:.vscode/launch.json
{
  "configurations": [
    {
      "name": "Python: 开发环境",
      "type": "debugpy",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "env": {
        "Env": "dev"
      }
    },
    {
      "name": "Python: 生产环境",
      "type": "debugpy",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "env": {
        "Env": "prod"
      }
    }
  ]
}
```

## 5. 使用示例

```python:main.py
from config import config

def main():
    # 获取配置值，支持默认值
    db_host = config.get("DB_HOST", "localhost")
    api_key = config.get("API_KEY")
    
    # 获取当前环境
    current_env = config.environment
    print(f"当前环境: {current_env}")

if __name__ == "__main__":
    main()
```

## 6. 安全性建议

1. **版本控制**
```gitignore
.env
.env.*
!.env.example
```

2. **敏感信息处理**
- 不要在代码中硬编码敏感信息
- 生产环境的密钥应通过安全渠道分发
- 使用环境变量传递敏感配置

## 7. 最佳实践

1. **环境区分**
- 开发环境：`.env.dev`
- 测试环境：`.env.test`
- 生产环境：`.env.product`
