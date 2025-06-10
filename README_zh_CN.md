# 不可变区间树 (Immutable IntervalTree)

[English](https://github.com/moonbit-community/immut_IntervalTree/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/immut_IntervalTree/blob/master/README_zh_CN.md)

不可变区间树是区间树的高效实现，支持各种区间查询操作，如查找重叠区间和包含区间。区间树是一种专门的自平衡二叉搜索树，专为快速处理区间查询而设计。与标准区间树不同，此实现保持完全不可变性，所有操作都返回新树而不是修改现有树。

## 🚀 核心特性
• 🛡️ **完全不可变** - 所有操作都返回新树，原始树保持不变  
• 🔄 **多种构造方法** - 支持空树、单区间树和从数组创建  
• ➕ **添加与查询** - 轻松插入区间并检查其存在  
• ❌ **删除** - 删除特定区间并获得新树  
• 🔍 **强大查询** - 支持查找符合特定条件的区间  
• 🧠 **泛型支持** - 可以使用任何实现 Compare trait 的类型作为区间端点  
• ⚡ **高效操作** - 针对时间和空间复杂度进行了优化
• 🔧 **区间类型支持** - 支持闭区间、开区间、左闭右开和左开右闭区间
• 🔄 **重复处理** - 可配置的重复区间支持

## 📥 安装
```bash
moon add kesmeey/immut_IntervalTree
```

## 🚀 使用指南

### 🔨 创建区间树
你可以使用 `new()`、`singleton()` 或 `from_array()` 方法创建不可变区间树。

```moonbit
// 空区间树 - O(1)
let tree : T[Int, String] = @immut_IntervalTree.new()

// 单区间树 - O(1)
let interval = Interval::{ low: 10, high: 20 }
let single_tree = @immut_IntervalTree.singleton(interval, "data")

// 从区间数组创建 - O(n log n)
let intervals = [
  (Interval::{ low: 10, high: 20 }, "A"),
  (Interval::{ low: 15, high: 25 }, "B"),
  (Interval::{ low: 5, high: 15 }, "C"),
]
let tree_from_array = @immut_IntervalTree.from_array(intervals)
```

### 🔧 区间类型与配置
库支持四种不同的区间类型和通过配置选项处理重复区间。

```moonbit
// 默认配置：闭区间，不允许重复
let default_tree = @immut_IntervalTree.new()

// 使用不同区间类型的自定义配置
let closed_options = IntervalOptions::{ 
  interval_type: IntervalType::Closed,     // [a, b] - 包含两个端点
  allow_duplicates: false 
}

let open_options = IntervalOptions::{ 
  interval_type: IntervalType::Open,       // (a, b) - 排除两个端点
  allow_duplicates: false 
}

let left_closed_options = IntervalOptions::{ 
  interval_type: IntervalType::LeftClosed, // [a, b) - 包含左端点，排除右端点
  allow_duplicates: false 
}

let right_closed_options = IntervalOptions::{ 
  interval_type: IntervalType::RightClosed, // (a, b] - 排除左端点，包含右端点
  allow_duplicates: false 
}

// 使用自定义选项创建树 - O(1)
let closed_tree = @immut_IntervalTree.new_with_options(closed_options)
let open_tree = @immut_IntervalTree.new_with_options(open_options)
```

### 🔄 重复处理
配置树如何处理具有相同边界的区间。

```moonbit
// 允许重复区间 - O(1)
let dup_options = IntervalOptions::{ 
  interval_type: IntervalType::Closed, 
  allow_duplicates: true 
}

let tree = @immut_IntervalTree.new_with_options(dup_options)
  .insert(Interval::{ low: 10, high: 20 }, "First")
  .insert(Interval::{ low: 10, high: 20 }, "Second")  // 两个区间都存储

assert_eq!(tree.size, 2)

// 不允许重复（默认）- 更新现有数据 - O(log n)
let no_dup_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "Original")
  .insert(Interval::{ low: 10, high: 20 }, "Updated")  // 替换原始数据

assert_eq!(no_dup_tree.size, 1)
assert_eq!(no_dup_tree.find_exact(Interval::{ low: 10, high: 20 }), Some("Updated"))
```

### 📦 批量操作
使用 `from_array()` 高效创建包含多个区间的树。

```moonbit
// 使用默认选项从数组创建 - O(n log n)
let intervals = [
  (Interval::{ low: 1, high: 10 }, "A"),
  (Interval::{ low: 5, high: 15 }, "B"),
  (Interval::{ low: 20, high: 30 }, "C"),
]
let tree = @immut_IntervalTree.from_array(intervals)

// 使用自定义选项从数组创建 - O(n log n)
let dup_options = IntervalOptions::{ 
  interval_type: IntervalType::Open, 
  allow_duplicates: true 
}
let dup_tree = @immut_IntervalTree.from_array(intervals, options~: dup_options)

// 无效区间（low > high）会自动过滤掉
let mixed_intervals = [
  (Interval::{ low: 10, high: 20 }, "Valid"),
  (Interval::{ low: 30, high: 25 }, "Invalid"), // 忽略
  (Interval::{ low: 40, high: 50 }, "Valid"),
]
let filtered_tree = @immut_IntervalTree.from_array(mixed_intervals)
assert_eq!(filtered_tree.size, 2) // 只插入有效区间
```

### ➕ 添加区间和数据
使用 `insert()` 方法向树中添加区间及其关联数据。这会返回包含添加区间的新树。

```moonbit
// 空树
let tree : T[Int, String] = @immut_IntervalTree.new()
// 插入区间，返回新树 - O(log n)
let tree2 = tree.insert(Interval::{ low: 10, high: 20 }, "A") 
// 原始树保持不变
assert_eq!(tree.size, 0)
assert_eq!(tree2.size, 1)
```

### 🔍 查询区间
使用 `find_exact()` 方法查找精确的区间匹配。

```moonbit
// 创建新树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
  .insert(Interval::{ low: 5, high: 15 }, "C")

// 精确匹配查找 - O(log n)
let data = tree.find_exact(Interval::{ low: 10, high: 20 })
assert_eq!(data, Some("A"))

// 查找重叠区间 - O(k + log n)，其中 k 是结果数量
let overlaps = tree.find_overlaps(Interval::{ low: 12, high: 18 })
```

### 🔍 不同区间类型的重叠检测
了解区间类型如何影响重叠检测行为。

```moonbit
// 闭区间 [10, 20] 和 [20, 30]
let closed_tree = @immut_IntervalTree.new_with_options(
  IntervalOptions::{ interval_type: IntervalType::Closed, allow_duplicates: false }
)
.insert(Interval::{ low: 10, high: 20 }, "A")
.insert(Interval::{ low: 20, high: 30 }, "B")

// 边界点查询 - O(k + log n)
let closed_overlaps = closed_tree.find_overlaps(Interval::{ low: 20, high: 20 })
// 在闭区间系统中，两个区间都在点 20 处重叠

// 开区间 (10, 20) 和 (20, 30)  
let open_tree = @immut_IntervalTree.new_with_options(
  IntervalOptions::{ interval_type: IntervalType::Open, allow_duplicates: false }
)
.insert(Interval::{ low: 10, high: 20 }, "A")
.insert(Interval::{ low: 20, high: 30 }, "B")

let open_overlaps = open_tree.find_overlaps(Interval::{ low: 20, high: 20 })
// 没有重叠，因为点 20 被两个区间排除
```

### ❌ 删除区间
使用 `remove()` 方法删除特定区间，返回新树。

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")

// 删除区间，返回新树 - O(log n)
let tree2 = tree.remove(Interval::{ low: 10, high: 20 })
assert_eq!(tree2.size, 1)
assert_eq!(tree2.find_exact(Interval::{ low: 10, high: 20 }), None)

// 原始树保持不变
assert_eq!(tree.size, 2)
assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
```

### 🔄 替换数据
使用 `replace_exact()` 方法替换特定区间的数据，返回新树。

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new().insert(
  Interval::{ low: 10, high: 20 },
  "A",
)

// 替换数据，返回新树 - O(log n)
let tree2 = tree.replace_exact(Interval::{ low: 10, high: 20 }, "Updated A")

// 验证更新
assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
assert_eq!(
  tree2.find_exact(Interval::{ low: 10, high: 20 }),
  Some("Updated A"),
)
```

### 🧹 清空树
使用 `clear()` 方法从树中删除所有区间，返回新的空树。

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")

// 清空树，返回新的空树 - O(1)
let empty_tree = tree.clear()
assert_eq!(empty_tree.size, 0)
assert_eq!(empty_tree.root, None)

// 原始树保持不变
assert_eq!(tree.size, 2)
```

### 🔍 高级查询

```moonbit
// 创建树并添加数据
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
// 查找包含在范围内的区间 - 最坏情况 O(n)
let contained = tree.find_contained(Interval::{ low: 0, high: 30 })

// 检查特定区间是否存在 - O(log n)
let exists = tree.contains(Interval::{ low: 10, high: 20 })

// 将所有区间转换为数组 - O(n)
let all_intervals = tree.to_array()
```

### 🧠 泛型支持
不可变区间树支持任何实现 Compare trait 的类型作为区间端点。

```moonbit
// 浮点类型区间
let float_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10.5, high: 20.5 }, "A")

// 字符串类型区间
let string_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: "a", high: "z" }, 1)
```

### 🕰️ 版本控制与不可变性优势
利用不可变性进行版本控制、撤销/重做操作和安全的并发访问。

```moonbit
// 在不同时间点创建快照
let v1 = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "Initial") // 版本 1 - O(log n)

let v2 = v1.insert(Interval::{ low: 15, high: 25 }, "Added") // 版本 2 - O(log n)

let v3 = v2.remove(Interval::{ low: 10, high: 20 }) // 版本 3 - O(log n)

let v4 = v2.replace_exact(Interval::{ low: 15, high: 25 }, "Modified") // 从 v2 分支 - O(log n)

// 所有版本都保持可访问且不变
assert_eq!(v1.size, 1)  // 原始版本
assert_eq!(v2.size, 2)  // 添加后  
assert_eq!(v3.size, 1)  // 从 v2 删除后
assert_eq!(v4.size, 2)  // 从 v2 修改的分支

// 完美适用于实现撤销/重做系统
let history = [v1, v2, v3, v4]
let current_version = history[2] // 可以跳转到任何版本
```

### ⚠️ 错误处理和边界情况
库优雅地处理各种边界情况和无效输入。

```moonbit
// 无效区间会自动拒绝 - O(1)
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 20, high: 10 }, "Invalid") // 忽略：low > high
  .insert(Interval::{ low: 10, high: 10 }, "Point")   // 有效：点区间
  .insert(Interval::{ low: 15, high: 25 }, "Valid")   // 有效：正常区间

assert_eq!(tree.size, 2) // 只插入有效区间

// 空查询返回空结果 - O(k + log n)
let empty_results = tree.find_overlaps(Interval::{ low: 100, high: 200 })
assert_eq!(empty_results.length(), 0)

// 对不存在区间的操作是安全的 - O(log n)
let unchanged = tree.remove(Interval::{ low: 50, high: 60 }) // 无变化
assert_eq!(unchanged.size, tree.size)

// 使用无效区间的单例创建空树 - O(1)
let empty_singleton = @immut_IntervalTree.singleton(
  Interval::{ low: 30, high: 20 }, // 无效
  "data"
)
assert_eq!(empty_singleton.size, 0)
```

### 🚀 性能提示与最佳实践
优化使用以获得更好的性能和内存效率。

```moonbit
// ✅ 好：使用 from_array() 进行批量插入 - O(n log n)
let intervals = generate_many_intervals() // 你的区间生成
let efficient_tree = @immut_IntervalTree.from_array(intervals)

// ❌ 避免：对批量数据进行多次单独插入 - O(n log n) 但常数较慢
let mut slow_tree = @immut_IntervalTree.new()
for interval_data in intervals {
  slow_tree = slow_tree.insert(interval_data.0, interval_data.1)
}

// ✅ 好：在适当时选择限制性区间类型
let precise_options = IntervalOptions::{ 
  interval_type: IntervalType::Open,      // 更严格的重叠检测
  allow_duplicates: false 
}

// ✅ 好：对多个操作使用方法链 - 保持效率
let result = tree
  .insert(Interval::{ low: 5, high: 10 }, "New")
  .replace_exact(Interval::{ low: 15, high: 25 }, "Updated")
  .remove(Interval::{ low: 20, high: 30 })

// ✅ 好：存储常用树以避免重新计算
let base_tree = @immut_IntervalTree.from_array(common_intervals)
let variant1 = base_tree.insert(special_interval1, data1)
let variant2 = base_tree.insert(special_interval2, data2)
// base_tree 结构在变体之间共享
```

## 🔄 函数式编程风格
不可变区间树支持方法链，非常适合函数式编程。

```moonbit
// 使用方法链构建树
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
  .insert(Interval::{ low: 5, high: 15 }, "C")

// 组合查询、修改和删除操作
let result = tree
  .replace_exact(Interval::{ low: 10, high: 20 }, "Updated A")
  .remove(Interval::{ low: 15, high: 25 })

// 原始树不变，结果包含所有更改
assert_eq!(tree.size, 3)
assert_eq!(result.size, 2)
```

## 📋 完整 API 参考

### 构造方法
| 方法 | 时间复杂度 | 描述 |
|--------|-----------------|-------------|
| `new()` | O(1) | 使用默认选项创建空树 |
| `new_with_options(options)` | O(1) | 使用自定义选项创建空树 |
| `singleton(interval, data, options~)` | O(1) | 创建单区间树 |
| `from_array(intervals, options~)` | O(n log n) | 从区间数组创建树 |

### 核心操作
| 方法 | 时间复杂度 | 描述 |
|--------|-----------------|-------------|
| `insert(interval, data)` | O(log n) | 插入区间，返回新树 |
| `remove(interval)` | O(log n) | 删除区间，返回新树 |
| `replace_exact(interval, data)` | O(log n) | 替换精确区间匹配的数据 |
| `clear()` | O(1) | 删除所有区间，返回空树 |

### 查询操作
| 方法 | 时间复杂度 | 描述 |
|--------|-----------------|-------------|
| `find_exact(interval)` | O(log n) | 查找精确区间匹配 |
| `find_overlaps(interval)` | O(k + log n) | 查找所有重叠区间 |
| `find_contained(interval)` | O(n) | 查找范围内包含的区间 |
| `contains(interval)` | O(log n) | 检查特定区间是否存在 |
| `to_array()` | O(n) | 将所有区间转换为数组 |

### 属性与类型
| 属性/类型 | 描述 |
|---------------|-------------|
| `size` | 树中区间的数量 |
| `root` | 内部树结构（可选） |
| `options` | 树配置（IntervalOptions） |
| `IntervalType` | Closed、Open、LeftClosed、RightClosed |
| `IntervalMatch[V, D]` | 包含区间和数据的结果类型 |

### ⏱️ 时间复杂度总结

| 操作 | 时间复杂度 | 描述 |
|-----------|-----------------|-------------|
| `new()` | O(1) | 创建空树 |
| `singleton()` | O(1) | 创建单区间树 |
| `from_array()` | O(n log n) | 从区间数组创建 |
| `insert()` | O(log n) | 插入新区间 |
| `remove()` | O(log n) | 删除区间 |
| `replace_exact()` | O(log n) | 替换区间数据 |
| `find_exact()` | O(log n) | 查找精确区间匹配 |
| `find_overlaps()` | O(k + log n) | 查找重叠区间（k = 结果数量） |
| `find_contained()` | O(n) | 查找范围内包含的区间 |
| `contains()` | O(log n) | 检查区间是否存在 |
| `to_array()` | O(n) | 将树转换为数组 |
| `clear()` | O(1) | 清空所有区间 |

## 📜 许可证
本项目采用 Apache-2.0 许可证。详情请参阅 LICENSE。

## 📢 联系与支持
• MoonBit 社区：moonbit-community  
• GitHub Issues：[报告问题](https://github.com/moonbit-community/immut_IntervalTree/issues)

👋 如果你喜欢这个项目，请给它一个 ⭐！编程愉快！🚀