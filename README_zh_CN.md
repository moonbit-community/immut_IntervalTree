# 不可变区间树 (Immutable IntervalTree)

[English](https://github.com/moonbit-community/immut_IntervalTree/blob/master/README.md) | 
[简体中文](https://github.com/moonbit-community/immut_IntervalTree/blob/master/README_zh_CN.md)

不可变区间树是一种高效的区间树实现，支持多种区间查询操作，如查找重叠区间和包含区间等。与标准区间树不同，此实现保持完全不可变性，所有操作都返回新树而不是修改现有树。

## 🚀 核心特性
• 🛡️ **完全不可变** - 所有操作返回新树，原树保持不变  
• 🔄 **多种构建方式** - 支持创建空树、单区间树和从数组构建  
• ➕ **添加与查询** - 轻松插入区间并检查存在性  
• ❌ **删除操作** - 移除特定区间并获取新树  
• 🔍 **强大查询** - 支持查找符合特定条件的区间  
• 🧠 **泛型支持** - 可使用任何实现Compare特性的类型作为区间端点  
• ⚡ **高效操作** - 时间和空间复杂度均经过优化  

## 📥 安装
```bash
moon add kesmeey/immut_IntervalTree
```

## 🚀 使用指南

### 🔨 创建区间树
使用`new()`、`singleton()`或`from_array()`方法创建不可变区间树。

```moonbit
// 创建空区间树 - O(1)
let tree : T[Int, String] = @immut_IntervalTree.new()

// 创建单区间树 - O(1)
let interval = Interval::{ low: 10, high: 20 }
let single_tree = @immut_IntervalTree.singleton(interval, "数据")

// 从数组创建 - O(n log n)
let intervals = [
  (Interval::{ low: 10, high: 20 }, "A"),
  (Interval::{ low: 15, high: 25 }, "B"),
  (Interval::{ low: 5, high: 15 }, "C"),
]
let tree_from_array = @immut_IntervalTree.from_array(intervals)
```

### ➕ 添加区间和数据
使用`insert()`方法添加区间及其关联数据，返回包含新区间的新树。

```moonbit
// 空树
let tree : T[Int, String] = @immut_IntervalTree.new()
// 插入区间，返回新树 - O(log n)
let tree2 = tree.insert(Interval::{ low: 10, high: 20 }, "A") 
// 原树保持不变
assert_eq!(tree.size, 0)
assert_eq!(tree2.size, 1)
```

### 🔍 查询区间
使用`find_exact()`方法查找精确匹配的区间。

```moonbit
// 创建新树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
  .insert(Interval::{ low: 5, high: 15 }, "C")

// 精确匹配查询 - O(log n)
let data = tree.find_exact(Interval::{ low: 10, high: 20 })
assert_eq!(data, Some("A"))

// 查找重叠区间 - O(k + log n)，k为结果数量
let overlaps = tree.find_overlaps(Interval::{ low: 12, high: 18 })
```

### ❌ 删除区间
使用`remove()`方法删除特定区间，返回新树。

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")

// 删除区间，返回新树 - O(log n)
let tree2 = tree.remove(Interval::{ low: 10, high: 20 })
assert_eq!(tree2.size, 1)
assert_eq!(tree2.find_exact(Interval::{ low: 10, high: 20 }), None)

// 原树保持不变
assert_eq!(tree.size, 2)
assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
```

### 🔄 替换数据
使用`replace_exact()`方法替换特定区间的数据，返回新树。

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new().insert(
  Interval::{ low: 10, high: 20 },
  "A",
)

// 替换数据，返回新树 - O(log n)
let tree2 = tree.replace_exact(Interval::{ low: 10, high: 20 }, "更新后的A")

// 验证更新
assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
assert_eq!(
  tree2.find_exact(Interval::{ low: 10, high: 20 }),
  Some("更新后的A"),
)
```

### 🧹 清空树
使用`clear()`方法移除所有区间，返回新的空树。

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")

// 清空树，返回新空树 - O(1)
let empty_tree = tree.clear()
assert_eq!(empty_tree.size, 0)
assert_eq!(empty_tree.root, None)

// 原树保持不变
assert_eq!(tree.size, 2)
```

### 🔍 高级查询

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
// 查找范围内的区间 - 最坏情况O(n)
let contained = tree.find_contained(Interval::{ low: 0, high: 30 })

// 检查区间是否存在 - O(log n)
let exists = tree.contains(Interval::{ low: 10, high: 20 })

// 转换所有区间为数组 - O(n)
let all_intervals = tree.to_array()
```

### 🧠 泛型支持
不可变区间树支持任何实现Compare特性的类型作为区间端点。

```moonbit
// 浮点型区间
let float_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10.5, high: 20.5 }, "A")

// 字符串型区间
let string_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: "a", high: "z" }, 1)
```

## 🔄 函数式编程风格
不可变区间树支持方法链式调用，非常适合函数式编程。

```moonbit
// 使用方法链构建树
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
  .insert(Interval::{ low: 5, high: 15 }, "C")

// 组合查询、修改和删除操作
let result = tree
  .replace_exact(Interval::{ low: 10, high: 20 }, "更新后的A")
  .remove(Interval::{ low: 15, high: 25 })

// 原树不变，结果包含所有更改
assert_eq!(tree.size, 3)
assert_eq!(result.size, 2)
```

### ⏱️ 时间复杂度总结

| 操作 | 时间复杂度 | 描述 |
|-----------|-----------------|-------------|
| `new()` | O(1) | 创建空树 |
| `singleton()` | O(1) | 创建单区间树 |
| `from_array()` | O(n log n) | 从数组创建 |
| `insert()` | O(log n) | 插入新区间 |
| `remove()` | O(log n) | 删除区间 |
| `replace_exact()` | O(log n) | 替换区间数据 |
| `find_exact()` | O(log n) | 精确匹配查询 |
| `find_overlaps()` | O(k + log n) | 查找重叠区间(k为结果数) |
| `find_contained()` | O(n) | 查找范围内的区间 |
| `contains()` | O(log n) | 检查区间是否存在 |
| `to_array()` | O(n) | 转换为数组 |
| `clear()` | O(1) | 清空所有区间 |

## 📜 许可证
本项目采用Apache-2.0许可证，详见LICENSE文件。

## 📢 联系与支持
• Moonbit社区: moonbit-community  
• GitHub问题: [报告问题](https://github.com/moonbit-community/immut_IntervalTree/issues)

👋 如果喜欢本项目，请给它点个⭐！祝编程愉快！🚀