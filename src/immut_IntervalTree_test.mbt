///|
/// 测试创建空树
test "new_empty_immut_tree" {
  let tree : T[Int, String] = @immut_IntervalTree.new()
  assert_eq!(tree.size, 0)
  assert_eq!(tree.root, None)
}

///|
/// 测试插入节点
test "insert_immut" {
  let tree : T[Int, String] = @immut_IntervalTree.new()
  let tree2 = tree.insert(Interval::{ low: 10, high: 20 }, "A")
  let tree3 = tree2.insert(Interval::{ low: 15, high: 25 }, "B")
  let tree4 = tree3.insert(Interval::{ low: 5, high: 15 }, "C")

  // 验证每步的大小
  assert_eq!(tree.size, 0)
  assert_eq!(tree2.size, 1)
  assert_eq!(tree3.size, 2)
  assert_eq!(tree4.size, 3)

  // 验证原树未修改（不可变性）
  assert_eq!(tree.root, None)
}

///|
/// 测试查找精确匹配
test "find_exact_immut" {
  // 构建测试树
  let empty_tree : T[Int, String] = @immut_IntervalTree.new()
  let tree = empty_tree
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")

  // 测试查找
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
  assert_eq!(tree.find_exact(Interval::{ low: 15, high: 25 }), Some("B"))
  assert_eq!(tree.find_exact(Interval::{ low: 5, high: 15 }), Some("C"))
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 15 }), None)
  assert_eq!(empty_tree.find_exact(Interval::{ low: 10, high: 20 }), None)
}

///|
/// 测试删除节点
test "remove_immut" {
  // 构建测试树
  let tree : T[Int, String] = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")
  assert_eq!(tree.size, 3)

  // 测试删除
  let tree2 = tree.remove(Interval::{ low: 10, high: 20 })
  assert_eq!(tree2.size, 2)
  assert_eq!(tree2.find_exact(Interval::{ low: 10, high: 20 }), None)
  assert_eq!(tree2.find_exact(Interval::{ low: 15, high: 25 }), Some("B"))

  // 原树应保持不变
  assert_eq!(tree.size, 3)
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
}

///|
/// 测试替换数据
test "replace_exact_immut" {
  // 构建测试树
  let tree : T[Int, String] = @immut_IntervalTree.new().insert(
    Interval::{ low: 10, high: 20 },
    "A",
  )

  // 替换数据
  let tree2 = tree.replace_exact(Interval::{ low: 10, high: 20 }, "Updated A")

  // 验证更新
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
  assert_eq!(
    tree2.find_exact(Interval::{ low: 10, high: 20 }),
    Some("Updated A"),
  )
}

///|
/// 测试从数组创建树
test "from_array_immut" {
  let intervals : Array[(Interval[Int], String)] = [
    (Interval::{ low: 10, high: 20 }, "A"),
    (Interval::{ low: 15, high: 25 }, "B"),
    (Interval::{ low: 5, high: 15 }, "C"),
  ]
  let tree = @immut_IntervalTree.from_array(intervals)
  assert_eq!(tree.size, 3)
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
  assert_eq!(tree.find_exact(Interval::{ low: 15, high: 25 }), Some("B"))
  assert_eq!(tree.find_exact(Interval::{ low: 5, high: 15 }), Some("C"))
}

///|
/// 测试平衡操作
test "balance_immut" {
  // 构建需要平衡的树 (右重)
  let right_heavy = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 20, high: 30 }, "B")
    .insert(Interval::{ low: 30, high: 40 }, "C")

  // 验证所有数据依然可以找到
  assert_eq!(right_heavy.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
  assert_eq!(right_heavy.find_exact(Interval::{ low: 20, high: 30 }), Some("B"))
  assert_eq!(right_heavy.find_exact(Interval::{ low: 30, high: 40 }), Some("C"))

  // 构建左重的树
  let left_heavy = @immut_IntervalTree.new()
    .insert(Interval::{ low: 30, high: 40 }, "C")
    .insert(Interval::{ low: 20, high: 30 }, "B")
    .insert(Interval::{ low: 10, high: 20 }, "A")

  // 验证所有数据依然可以找到
  assert_eq!(left_heavy.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
  assert_eq!(left_heavy.find_exact(Interval::{ low: 20, high: 30 }), Some("B"))
  assert_eq!(left_heavy.find_exact(Interval::{ low: 30, high: 40 }), Some("C"))
}

///|
/// 测试清空树
test "clear_immut" {
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
  assert_eq!(tree.size, 2)
  let cleared = tree.clear()
  assert_eq!(cleared.size, 0)
  assert_eq!(cleared.root, None)

  // 原树不变
  assert_eq!(tree.size, 2)
}

///|
test {
  // Build a tree using method chaining
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")

  // Combine query, modification, and removal operations
  let result = tree
    .replace_exact(Interval::{ low: 10, high: 20 }, "Updated A")
    .remove(Interval::{ low: 15, high: 25 })

  // Original tree unchanged, result contains all changes
  assert_eq!(tree.size, 3)
  assert_eq!(result.size, 2)
}

///|
/// 测试查找重叠区间
test "find_overlaps_immut" {
  // 构建测试树
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")
    .insert(Interval::{ low: 30, high: 40 }, "D")

  // 测试闭区间重叠 [12,18]
  let overlaps = tree.find_overlaps(Interval::{ low: 12, high: 18 })
  println(tree.size)
  // 应该找到A B C 3个区间
  assert_eq!(overlaps.length(), 3)

  // 验证找到的区间数据和范围
  let mut found_a = false
  let mut found_b = false
  for i = 0; i < overlaps.length(); i = i + 1 {
    let item = overlaps[i]
    if item.data == "A" {
      assert_eq!(item.interval.low, 10)
      assert_eq!(item.interval.high, 20)
      found_a = true
    }
    if item.data == "B" {
      assert_eq!(item.interval.low, 15)
      assert_eq!(item.interval.high, 25)
      found_b = true
    }
  }
  assert_eq!(found_a, true)
  assert_eq!(found_b, true)

  // 测试开区间重叠
  let options = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: false,
  }
  let open_tree = @immut_IntervalTree.new_with_options(options)
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
  let open_overlaps = open_tree.find_overlaps(Interval::{ low: 20, high: 30 })
  assert_eq!(open_overlaps.length(), 1)

  // 测试左闭右开区间
  let left_closed_options = IntervalOptions::{
    interval_type: IntervalType::LeftClosed,
    allow_duplicates: false,
  }
  let left_closed_tree = @immut_IntervalTree.new_with_options(
    left_closed_options,
  ).insert(Interval::{ low: 10, high: 20 }, "A")
  let left_closed_overlaps = left_closed_tree.find_overlaps(Interval::{
    low: 20,
    high: 30,
  })
  // 因为是左闭右开区间[10,20)，所以不应该与[20,30)重叠
  assert_eq!(left_closed_overlaps.length(), 0)

  // 测试不重叠的查询
  let no_overlaps = tree.find_overlaps(Interval::{ low: 26, high: 28 })
  assert_eq!(no_overlaps.length(), 0)

  // 测试边界情况
  let edge_case_tree = @immut_IntervalTree.new().insert(
    Interval::{ low: 10, high: 20 },
    "A",
  )

  // 测试空查询区间
  let empty_interval = Interval::{ low: 15, high: 15 }
  let empty_overlaps = edge_case_tree.find_overlaps(empty_interval)
  assert_eq!(empty_overlaps.length(), 1)

  // 测试重合边界点
  let boundary = tree.find_overlaps(Interval::{ low: 20, high: 25 })
  assert_eq!(boundary.length(), 2) // 应该有2个结果(A和B)
  assert_eq!(boundary[0].data, "A")
}

///|
/// 测试查找被包含的区间
test "find_contained_immut" {
  // 构建测试树
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 18 }, "B") // 包含于[10,20]
    .insert(Interval::{ low: 5, high: 25 }, "C")
    .insert(Interval::{ low: 30, high: 40 }, "D")

  // 查找被区间[5,25]完全包含的区间
  let container = Interval::{ low: 5, high: 25 }
  let contained = tree.find_contained(container)
  assert_eq!(contained.length(), 3)

  // 验证找到的区间数据
  let mut has_a = false
  let mut has_b = false
  for i = 0; i < contained.length(); i = i + 1 {
    if contained[i].data == "A" {
      has_a = true
    }
    if contained[i].data == "B" {
      has_b = true
    }
  }
  assert_true!(has_a)
  assert_true!(has_b)

  // 更小的容器，只包含B
  let small_container = Interval::{ low: 12, high: 22 }
  let small_contained = tree.find_contained(small_container)
  assert_eq!(small_contained.length(), 1)
  assert_eq!(small_contained[0].data, "B")

  // 不包含任何区间的查询
  let no_contained = tree.find_contained(Interval::{ low: 31, high: 35 })
  assert_eq!(no_contained.length(), 0)
}

///|
/// 测试contains方法
test "contains_immut" {
  // 构建测试树
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")

  // 测试存在的区间
  assert_true!(tree.contains(Interval::{ low: 10, high: 20 }))
  assert_true!(tree.contains(Interval::{ low: 15, high: 25 }))

  // 测试不存在的区间
  assert_false!(tree.contains(Interval::{ low: 10, high: 15 }))
  assert_false!(tree.contains(Interval::{ low: 30, high: 40 }))

  // 空树测试
  let empty_tree = @immut_IntervalTree.new()
  assert_false!(empty_tree.contains(Interval::{ low: 10, high: 20 }))
}

///|
/// 测试to_array方法
test "to_array_immut" {
  // 构建测试树
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")

  // 转换为数组
  let array = tree.to_array()

  // 验证数组长度
  assert_eq!(array.length(), 3)

  // 验证所有数据都在数组中
  let mut has_a = false
  let mut has_b = false
  let mut has_c = false
  for i = 0; i < array.length(); i = i + 1 {
    let item = array[i]
    if item.interval.low == 10 && item.interval.high == 20 && item.data == "A" {
      has_a = true
    }
    if item.interval.low == 15 && item.interval.high == 25 && item.data == "B" {
      has_b = true
    }
    if item.interval.low == 5 && item.interval.high == 15 && item.data == "C" {
      has_c = true
    }
  }
  assert_true!(has_a)
  assert_true!(has_b)
  assert_true!(has_c)

  // 空树测试
  let empty_tree = @immut_IntervalTree.new()
  assert_eq!(empty_tree.to_array().length(), 0)
}

///|
/// 测试不同区间类型
test "interval_types_immut" {
  // 创建不同类型的区间树选项
  let closed_options = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: false,
  }
  let open_options = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: false,
  }
  let left_closed_options = IntervalOptions::{
    interval_type: IntervalType::LeftClosed,
    allow_duplicates: false,
  }
  let right_closed_options = IntervalOptions::{
    interval_type: IntervalType::RightClosed,
    allow_duplicates: false,
  }

  // 创建不同类型的树
  let closed_tree = @immut_IntervalTree.new_with_options(closed_options).insert(
    Interval::{ low: 10, high: 20 },
    "A",
  )
  let open_tree = @immut_IntervalTree.new_with_options(open_options).insert(
    Interval::{ low: 10, high: 20 },
    "B",
  )
  let left_closed_tree = @immut_IntervalTree.new_with_options(
    left_closed_options,
  ).insert(Interval::{ low: 10, high: 20 }, "C")
  let right_closed_tree = @immut_IntervalTree.new_with_options(
    right_closed_options,
  ).insert(Interval::{ low: 10, high: 20 }, "D")

  // 闭区间测试 [10, 20]
  let closed_overlaps = closed_tree.find_overlaps(Interval::{
    low: 20,
    high: 30,
  })
  assert_eq!(closed_overlaps.length(), 1) // 边界点20重叠

  // 开区间测试 (10, 20)
  let open_overlaps = open_tree.find_overlaps(Interval::{ low: 20, high: 30 })
  assert_eq!(open_overlaps.length(), 0) // 边界点20不重叠

  // 左闭右开区间测试 [10, 20)
  let left_closed_overlaps = left_closed_tree.find_overlaps(Interval::{
    low: 20,
    high: 30,
  })
  assert_eq!(left_closed_overlaps.length(), 0) // 边界点20不重叠

  // 左开右闭区间测试 (10, 20]
  let right_closed_overlaps = right_closed_tree.find_overlaps(Interval::{
    low: 20,
    high: 30,
  })
  assert_eq!(right_closed_overlaps.length(), 1) // 边界点20重叠
}

///|
/// 测试非整数类型的区间端点
test "non_integer_keys_immut" {
  // 测试浮点数作为区间端点
  let float_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10.5, high: 20.5 }, "A")
    .insert(Interval::{ low: 15.5, high: 25.5 }, "B")
    .insert(Interval::{ low: 5.5, high: 15.5 }, "C")

  // 测试查找
  assert_eq!(
    float_tree.find_exact(Interval::{ low: 10.5, high: 20.5 }),
    Some("A"),
  )
  assert_eq!(float_tree.find_exact(Interval::{ low: 10.0, high: 20.0 }), None)

  // 测试重叠查询
  let float_overlaps = float_tree.find_overlaps(Interval::{
    low: 12.0,
    high: 18.0,
  })
  assert_eq!(float_overlaps.length(), 3) // A、B和C都重叠

  // 测试字符串作为区间端点 - 修正字符串长度问题
  // 使用相同长度的字符串作为区间端点，避免因字符串长度比较导致的问题
  let string_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: "apple", high: "zebra" }, 1) // 都是5个字符
    .insert(Interval::{ low: "hello", high: "world" }, 2) // 都是5个字符
    .insert(Interval::{ low: "cat", high: "dog" }, 3) // 都是3个字符
  println(string_tree.to_array())

  // 测试查找
  assert_eq!(
    string_tree.find_exact(Interval::{ low: "apple", high: "zebra" }),
    Some(1),
  )

  // 测试包含查询 - 使用能够包含所有测试区间的短字符串
  let string_contained = string_tree.find_contained(Interval::{
    low: "a",
    high: "zzzzz", // 确保长度为5，能够"大于"所有5字符的高端点
  })
  assert_eq!(string_contained.length(), 3) // 所有区间
}

///|
/// 测试极端情况
test "edge_cases_immut" {
  // 创建初始树
  let tree = @immut_IntervalTree.new().insert(
    Interval::{ low: 10, high: 20 },
    "A",
  )

  // 测试相同区间插入
  let tree_with_duplicate = tree.insert(
    Interval::{ low: 10, high: 20 },
    "New A",
  )
  assert_eq!(
    tree_with_duplicate.find_exact(Interval::{ low: 10, high: 20 }),
    Some("New A"),
  )

  // 测试无效区间 (low > high)
  let tree_with_invalid = tree.insert(
    Interval::{ low: 30, high: 20 },
    "Invalid",
  )
  assert_eq!(tree_with_invalid.size, 1) // 应保持不变
  assert_eq!(
    tree_with_invalid.find_exact(Interval::{ low: 30, high: 20 }),
    None,
  )

  // 测试删除不存在的区间
  let tree_after_delete = tree.remove(Interval::{ low: 30, high: 40 })
  assert_eq!(tree_after_delete.size, 1) // 应保持不变

  // 测试在空树上执行操作
  let empty_tree = @immut_IntervalTree.new()
  assert_eq!(
    empty_tree.find_overlaps(Interval::{ low: 10, high: 20 }).length(),
    0,
  )
  assert_eq!(
    empty_tree.find_contained(Interval::{ low: 10, high: 20 }).length(),
    0,
  )
}

///|
/// 测试允许重复区间
test "allow_duplicates_immut" {
  // 创建允许重复的树
  let options = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: true,
  }
  let tree = @immut_IntervalTree.new_with_options(options)
    .insert(Interval::{ low: 10, high: 20 }, "A1")
    .insert(Interval::{ low: 10, high: 20 }, "A2") // 完全相同的区间
  println(tree.size)
  // 检查树的大小
  assert_eq!(tree.size, 2)

  // 查找重叠区间
  let overlaps = tree.find_overlaps(Interval::{ low: 10, high: 20 })
  assert_eq!(overlaps.length(), 2)
  println(tree.to_array())
  // 查找精确匹配

  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A1"))

  // 测试删除操作
  // 注意：remove通常只删除一个匹配项（取决于实现）
  let tree_after_delete = tree.remove(Interval::{ low: 10, high: 20 })
  assert_eq!(tree_after_delete.size, 1)
}

///|
test {
  // Build tree using method chaining
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")

  // Combine query, modification, and removal operations
  let result = tree
    .replace_exact(Interval::{ low: 10, high: 20 }, "Updated A")
    .remove(Interval::{ low: 15, high: 25 })

  // Original tree unchanged, result contains all changes
  assert_eq!(tree.size, 3)
  assert_eq!(result.size, 2)
}
