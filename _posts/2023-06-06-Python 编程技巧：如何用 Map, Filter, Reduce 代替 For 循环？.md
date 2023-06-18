你是否有过这样的经历，你查看自己写的代码并看到满眼的 for 循环？你发现你必须斜着你的眼睛，并将脑袋前倾到你的显示器，以看得更清楚。

for 循环就像是一把瑞士军刀，它可以解决很多问题，但是，当你需要扫视代码，快速搞清楚代码所做的事情时，它们可能会让人不知所措。

`map`、`filter` 和 `reduce` 这三种技术可以提供描述迭代原因的函数替代方案，以便避免过多的 `for` 循环。我之前在 JavaScript 中写过这些技术的入门文章，但是它们在 Python 中的实现略有不同。

我们将简要介绍这三种技术，主要介绍它们在 JavaScript 和 Python 中的语法差异，然后给出如何转换 for 循环的示例。

**什么是 Map、Filter 和 Reduce？**

回顾我以前编写的代码，我意识到 95% 的时间都花在遍历字符串或数组上。在这种情况下，我会执行以下操作之一：将一系列语句映射到每个值，筛选满足特定条件的值，或将数据集减少为单个聚合值。

有了这种洞察力，你就可以识别和实现这三种方法，即循环遍历通常属于这三种功能类别之一：

- Map：对每个项应用相同的步骤集，存储结果
- Filter：应用验证条件，存储计算结果为 True 的项
- Reduce：返回一个从元素传递到元素的值

**为什么 Python Map/Filter/Reduce 会不一样？**

在 Python 中，这三种技术作为函数存在，而不是数组或字符串类的方法。这意味着，你将编写 map (function, my_list)，而不是编写 my_array.map（function）。

此外，每个技术都需要传递一个函数，该函数将执行每个项目。通常，该函数是作为匿名函数（在 JavaScript 中称为 arrow 头函数）编写的。但是，在 Python 中，你经常看到被使用的是 lambda 表达式。

lambda 表达式和 arrow 函数之间的语法实际上非常相似。将 => 替换为 ： 并确保使用关键字 lambda，其余的几乎相同。

```text
// JavaScript Arrow Function
const square = number => number * number;

// Python Lambda Expression
square = lambda number: number * number
```

arrow 函数和 lambda 表达式之间的一个关键区别是，arrow 函数能够通过多个语句扩展成完整的函数，而 lambda 表达式仅限于返回的单个表达式。因此，在使用 map（）、filter（）或 reduce（）时，如果需要对每个项执行多个操作，请先定义函数，然后再包含它。

```text
def inefficientSquare(number):
   result = number * number
   return result

map(inefficientSquare, my_list)
```

**替换 for 循环**

好了，下面来点好东西。下面是三个常见的 for 循环示例，它们将被 map、filter 和 reduce 替换。我们的编程目标：计算列表中奇数平方和。

首先，使用 基本的 for 循环示例。注意：下面的代码纯粹是为了演示，即使没有 map/filter/reduce 也有改进空间。

```text
numbers = [1,2,3,4,5,6]
odd_numbers = []
squared_odd_numbers = []
total = 0

# filter for odd numbers
for number in numbers:
  if number % 2 == 1:
     odd_numbers.append(number)

# square all odd numbers
for number in odd_numbers:
  squared_odd_numbers.append(number * number)

# calculate total
for number in squared_odd_numbers:
  total += number

# calculate average
```

让我们将每个步骤转换为这三个函数的其中之一：

```text
from functools import reduce
numbers = [1,2,3,4,5,6]
odd_numbers = filter(lambda n: n % 2 == 1, numbers)
squared_odd_numbers = map(lambda n: n * n, odd_numbers)
total = reduce(lambda acc, n: acc + n, squared_odd_numbers)
```

有几个重要的语法要点要强调。

- map（）和 filter（）本机可用。但是，reduce（）必须从 Python 3 以上版本中的函数库导入
- lambda 表达式是所有三个函数中的第一个参数，iterable 是第二个参数
- reduce（）的 lambda 表达式需要两个参数：累加器（传递给每个元素的值）和单个元素本身

记住，for 循环在代码中确实是很重要的，但是扩展工具包从来都不是坏事。