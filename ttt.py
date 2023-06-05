def quick_sort(arr):
  if len(arr) <= 1:
    return arr
  pivot = arr[len(arr) // 2]
  left = [x for x in arr if x < pivot]
  middle = [x for x in arr if x == pivot]
  right = [x for x in arr if x > pivot]
  return quick_sort(left) + middle + quick_sort(right)

# 生成一个 python 函数，功能是从长字符串中找到子字符串，使用kmp算法

def bubble_sort(arr):
  n = len(arr)

  for i in range(n):

    for j in range(0, n - i - 1):

      if arr[j] > arr[j + 1]:
        arr[j], arr[j + 1] = arr[j + 1], arr[j]

  return arr


if __name__ == '__main__':
  arr = [3, 6, 1, 7, 2, 8, 5, 4]
  print(quick_sort(arr))  # 输出  [1,  2,  3,  4,  5,  6,  7,  8]




