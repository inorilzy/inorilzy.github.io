---
title: (翻译)如何在__init__中使用 await 设置类属性
date: 2023-06-07 01:55:54 +0800
categories: [Python]
tags: [asyncio]

---

# [如何在 \_\_init__ 中使用  await  设置类属性](https://stackoverflow.com/questions/33128325/how-to-set-class-attribute-with-await-in-init)

例如我想要的：

```python
import asyncio

# some code

class Foo(object):

    async def __init__(self, settings):
        self.settings = settings
        self.pool = await create_pool(dsn)

foo = Foo(settings)
# it raises:
# TypeError: __init__() should return None, not 'coroutine'
```
或具有类体属性的示例：

```python
class Foo(object):

    self.pool = await create_pool(dsn)  # Sure it raises syntax Error

    def __init__(self, settings):
        self.settings = settings

foo = Foo(settings)
```

我的解决方案（但我希望看到一种更优雅的方式）

```python
class Foo(object):

    def __init__(self, settings):
        self.settings = settings

    async def init(self):
        self.pool = await create_pool(dsn)

foo = Foo(settings)
await foo.init()
```

------

大多数魔术方法不是为使用 `async def` / `await` 而设计的 - 一般来说，您应该只在专用的异步魔术方法 - `__aiter__` 、 `__anext__` 、 `__aenter__` 和 `__aexit__` 中使用 `await` 。在其他魔术方法中使用它要么根本不起作用，就像 `__init__` 的情况一样（除非你使用这里其他答案中描述的一些技巧），要么会强制你总是在异步上下文中使用任何触发魔术方法调用的触发器。

现有的 `asyncio` 库倾向于以两种方式之一处理此问题：首先，我看到了使用的工厂模式（例如 `asyncio-redis` ）：

```python
import asyncio

dsn = "..."

class Foo(object):
    @classmethod
    async def create(cls, settings):
        self = Foo()
        self.settings = settings
        self.pool = await create_pool(dsn)
        return self

async def main(settings):
    settings = "..."
    foo = await Foo.create(settings)
```

其他库使用创建对象的顶级协同函数，而不是工厂方法：

```python
import asyncio

dsn = "..."


class Foo(object):
    def __init__(self, settings):
        self.settings = settings

    async def _init(self):
        self.pool = await create_pool(dsn)

async def create_foo(settings):
    foo = Foo(settings)
    await foo._init()
    return foo

async def main():
    settings = "..."
    foo = await create_foo(settings)
```

你想在 `__init__` 中调用的 `aiopg` 中的 `create_pool` 函数实际上使用了这种确切的模式。

这至少解决了 `__init__` 问题。我还没有看到我可以回忆起的在野外进行异步调用的类变量，所以我不知道是否出现了任何成熟的模式。

------

另一种有趣的方法：

```python
class aobject(object):
    """Inheriting this class allows you to define an async __init__.

    So you can create objects by doing something like `await MyClass(params)`
    """
    async def __new__(cls, *a, **kw):
        instance = super().__new__(cls)
        await instance.__init__(*a, **kw)
        return instance

    async def __init__(self):
        pass

#With non async super classes

class A:
    def __init__(self):
        self.a = 1

class B(A):
    def __init__(self):
        self.b = 2
        super().__init__()

class C(B, aobject):
    async def __init__(self):
        super().__init__()
        self.c=3

#With async super classes

class D(aobject):
    async def __init__(self, a):
        self.a = a

class E(D):
    async def __init__(self):
        self.b = 2
        await super().__init__(1)

# Overriding __new__

class F(aobject):
    async def __new__(cls):
        print(cls)
        return await super().__new__(cls)

    async def __init__(self):
        await asyncio.sleep(1)
        self.f = 6

async def main():
    e = await E()
    print(e.b) # 2
    print(e.a) # 1

    c = await C()
    print(c.a) # 1
    print(c.b) # 2
    print(c.c) # 3

    f = await F() # Prints F class
    print(f.f) # 6

import asyncio
loop = asyncio.get_event_loop()
loop.run_until_complete(main())
```

------

更好的是，你可以做这样的事情，这很容易：

```python
import asyncio

class Foo:
    def __init__(self, settings):
        self.settings = settings
        print(1)

    async def async_init(self):
        await asyncio.sleep(1)
        print(3)


    def __await__(self):
        print(2)
        return self.async_init().__await__()

async def main():
    foo = await Foo(1)


if __name__ == '__main__':
    asyncio.run(main())
```

基本上这里发生的事情是像往常一样首先调用 `__init__()` 。然后调用 `__await__()` ，然后等待 `async_init()` 。



------

我会推荐一种单独的工厂方法。它既安全又简单。但是，如果您坚持使用 `async` 版本的 `__init__()` ，下面是一个示例：

```python
def asyncinit(cls):
    __new__ = cls.__new__

    async def init(obj, *arg, **kwarg):
        await obj.__init__(*arg, **kwarg)
        return obj

    def new(cls, *arg, **kwarg):
        obj = __new__(cls, *arg, **kwarg)
        coro = init(obj, *arg, **kwarg)
        #coro.__init__ = lambda *_1, **_2: None
        return coro

    cls.__new__ = new
    return cls
```

**用法：**

```py
@asyncinit
class Foo(object):
    def __new__(cls):
        '''Do nothing. Just for test purpose.'''
        print(cls)
        return super().__new__(cls)

    async def __init__(self):
        self.initialized = True
```





```py
async def f():
    print((await Foo()).initialized)

loop = asyncio.get_event_loop()
loop.run_until_complete(f())
```

 **输出：**

```py
<class '__main__.Foo'>
True
```

 **解释：**

类构造必须返回 `coroutine` 对象而不是其自己的实例。
