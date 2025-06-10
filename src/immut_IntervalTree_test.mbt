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

///|
/// 测试单例创建
test "singleton_immut" {
  // 测试有效区间的单例创建
  let tree = @immut_IntervalTree.singleton(
    Interval::{ low: 10, high: 20 },
    "Singleton",
  )
  assert_eq!(tree.size, 1)
  assert_eq!(
    tree.find_exact(Interval::{ low: 10, high: 20 }),
    Some("Singleton"),
  )

  // 测试无效区间的单例创建（low > high）
  let invalid_tree = @immut_IntervalTree.singleton(
    Interval::{ low: 30, high: 20 },
    "Invalid",
  )
  assert_eq!(invalid_tree.size, 0)
  assert_eq!(invalid_tree.root, None)

  // 测试带选项的单例创建
  let options = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: true,
  }
  let tree_with_options = @immut_IntervalTree.singleton(
    Interval::{ low: 5, high: 15 },
    "WithOptions",
    options~,
  )
  assert_eq!(tree_with_options.size, 1)
  assert_eq!(tree_with_options.options.interval_type, IntervalType::Open)
}

///|
/// 测试大规模插入和删除操作
test "large_scale_operations_immut" {
  let mut tree = @immut_IntervalTree.new()

  // 插入大量区间
  for i = 1; i <= 100; i = i + 1 {
    tree = tree.insert(Interval::{ low: i * 10, high: i * 10 + 15 }, "Data\{i}")
  }
  assert_eq!(tree.size, 100)

  // 验证部分插入结果
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 25 }), Some("Data1"))
  assert_eq!(tree.find_exact(Interval::{ low: 500, high: 515 }), Some("Data50"))
  assert_eq!(
    tree.find_exact(Interval::{ low: 1000, high: 1015 }),
    Some("Data100"),
  )

  // 删除一半的区间
  for i = 1; i <= 50; i = i + 1 {
    tree = tree.remove(Interval::{ low: i * 10, high: i * 10 + 15 })
  }
  assert_eq!(tree.size, 50)

  // 验证删除后的状态
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 25 }), None)
  assert_eq!(tree.find_exact(Interval::{ low: 510, high: 525 }), Some("Data51"))
}

///|
/// 测试复杂的重叠查询
test "complex_overlap_queries_immut" {
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1, high: 5 }, "A")
    .insert(Interval::{ low: 3, high: 8 }, "B")
    .insert(Interval::{ low: 6, high: 10 }, "C")
    .insert(Interval::{ low: 12, high: 15 }, "D")
    .insert(Interval::{ low: 14, high: 18 }, "E")
    .insert(Interval::{ low: 20, high: 25 }, "F")

  // 测试多重重叠
  let overlaps1 = tree.find_overlaps(Interval::{ low: 4, high: 7 })
  assert_eq!(overlaps1.length(), 3) // A, B, C

  // 测试边界重叠 - 修正期望值
  let overlaps2 = tree.find_overlaps(Interval::{ low: 5, high: 6 })
  // A[1,5], B[3,8], C[6,10] 都应该与 [5,6] 重叠
  assert_eq!(overlaps2.length(), 3) // A, B, C 都应该重叠

  // 如果上面的测试仍然失败，使用更明确的边界测试
  let overlaps2_alt = tree.find_overlaps(Interval::{ low: 4, high: 7 })
  assert_eq!(overlaps2_alt.length(), 3) // 确保A, B, C都重叠

  // 测试单点查询
  let overlaps3 = tree.find_overlaps(Interval::{ low: 10, high: 10 })
  assert_eq!(overlaps3.length(), 1) // C

  // 测试跨越多个区间的查询
  let overlaps4 = tree.find_overlaps(Interval::{ low: 2, high: 16 })
  assert_eq!(overlaps4.length(), 5) // A, B, C, D, E

  // 测试无重叠查询
  let overlaps5 = tree.find_overlaps(Interval::{ low: 30, high: 35 })
  assert_eq!(overlaps5.length(), 0)
}

///|
/// 测试包含关系的复杂情况
test "complex_containment_queries_immut" {
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1, high: 20 }, "Container")
    .insert(Interval::{ low: 5, high: 10 }, "Small1")
    .insert(Interval::{ low: 12, high: 15 }, "Small2")
    .insert(Interval::{ low: 3, high: 25 }, "Larger")
    .insert(Interval::{ low: 30, high: 40 }, "Separate")

  // 测试大容器查询
  let contained1 = tree.find_contained(Interval::{ low: 0, high: 30 })
  assert_eq!(contained1.length(), 4) // 除了Separate

  // 测试中等容器查询
  let contained2 = tree.find_contained(Interval::{ low: 2, high: 18 })
  assert_eq!(contained2.length(), 2) // Small1, Small2

  // 测试精确匹配容器
  let contained3 = tree.find_contained(Interval::{ low: 5, high: 10 })
  assert_eq!(contained3.length(), 1) // Small1自身

  // 测试不包含任何区间的查询
  let contained4 = tree.find_contained(Interval::{ low: 50, high: 60 })
  assert_eq!(contained4.length(), 0)
}

///|
/// 测试树的平衡性和旋转操作
test "tree_balance_and_rotations_immut" {
  // 构建严重右偏的树
  let mut right_heavy = @immut_IntervalTree.new()
  for i = 1; i <= 10; i = i + 1 {
    right_heavy = right_heavy.insert(
      Interval::{ low: i * 10, high: i * 10 + 5 },
      "R\{i}",
    )
  }

  // 构建严重左偏的树
  let mut left_heavy = @immut_IntervalTree.new()
  for i = 10; i >= 1; i = i - 1 {
    left_heavy = left_heavy.insert(
      Interval::{ low: i * 10, high: i * 10 + 5 },
      "L\{i}",
    )
  }

  // 验证平衡后的树仍然保持功能正确性
  assert_eq!(right_heavy.size, 10)
  assert_eq!(left_heavy.size, 10)

  // 验证所有元素都能找到
  for i = 1; i <= 10; i = i + 1 {
    assert_eq!(
      right_heavy.find_exact(Interval::{ low: i * 10, high: i * 10 + 5 }),
      Some("R\{i}"),
    )
    assert_eq!(
      left_heavy.find_exact(Interval::{ low: i * 10, high: i * 10 + 5 }),
      Some("L\{i}"),
    )
  }

  // 测试混合插入模式
  let mut mixed = @immut_IntervalTree.new()
  let sequence = [5, 3, 7, 1, 9, 2, 8, 4, 6]
  for i = 0; i < sequence.length(); i = i + 1 {
    let val = sequence[i]
    mixed = mixed.insert(
      Interval::{ low: val * 10, high: val * 10 + 5 },
      "M\{val}",
    )
  }
  assert_eq!(mixed.size, 9)
}

///|
/// 测试不同数据类型作为值
test "different_data_types_immut" {
  // 测试整数数据
  let int_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, 42)
    .insert(Interval::{ low: 15, high: 25 }, 84)
  assert_eq!(int_tree.find_exact(Interval::{ low: 10, high: 20 }), Some(42))

  // 测试浮点数数据
  let float_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1, high: 5 }, 3.14)
    .insert(Interval::{ low: 6, high: 10 }, 2.71)
  assert_eq!(float_tree.find_exact(Interval::{ low: 1, high: 5 }), Some(3.14))

  // 测试布尔数据
  let bool_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1, high: 5 }, true)
    .insert(Interval::{ low: 6, high: 10 }, false)
  assert_eq!(bool_tree.find_exact(Interval::{ low: 1, high: 5 }), Some(true))

  // 测试数组数据
  let array_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1, high: 5 }, [1, 2, 3])
    .insert(Interval::{ low: 6, high: 10 }, [4, 5, 6])
  assert_eq!(
    array_tree.find_exact(Interval::{ low: 1, high: 5 }),
    Some([1, 2, 3]),
  )
}

///|
/// 测试区间端点的边界情况
test "interval_endpoint_edge_cases_immut" {
  // 测试相同端点的区间
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 10 }, "Point")
    .insert(Interval::{ low: 5, high: 15 }, "Range")
  assert_eq!(tree.find_exact(Interval::{ low: 10, high: 10 }), Some("Point"))

  // 测试重叠查询点区间
  let overlaps = tree.find_overlaps(Interval::{ low: 10, high: 10 })
  assert_eq!(overlaps.length(), 2) // Point 和 Range

  // 测试相邻区间
  let adjacent_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1, high: 5 }, "First")
    .insert(Interval::{ low: 5, high: 10 }, "Second")
    .insert(Interval::{ low: 10, high: 15 }, "Third")

  // 测试边界点重叠
  let boundary_overlaps = adjacent_tree.find_overlaps(Interval::{
    low: 5,
    high: 5,
  })
  assert_eq!(boundary_overlaps.length(), 2) // First 和 Second (闭区间)
}

///|
/// 测试负数区间
test "negative_intervals_immut" {
  let tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: -20, high: -10 }, "Negative1")
    .insert(Interval::{ low: -15, high: -5 }, "Negative2")
    .insert(Interval::{ low: -5, high: 5 }, "CrossZero")
    .insert(Interval::{ low: 10, high: 20 }, "Positive")
  assert_eq!(tree.size, 4)

  // 测试负数区间查找
  assert_eq!(
    tree.find_exact(Interval::{ low: -20, high: -10 }),
    Some("Negative1"),
  )

  // 测试跨零点的重叠查询
  let zero_overlaps = tree.find_overlaps(Interval::{ low: -2, high: 2 })
  assert_eq!(zero_overlaps.length(), 1) // CrossZero

  // 测试负数范围的包含查询
  let negative_contained = tree.find_contained(Interval::{ low: -25, high: 0 })
  assert_eq!(negative_contained.length(), 2) // Negative1, Negative2
}

///|
/// 测试树的不可变性验证
test "immutability_verification_immut" {
  let original = @immut_IntervalTree.new().insert(
    Interval::{ low: 10, high: 20 },
    "Original",
  )

  // 创建多个修改版本
  let version1 = original.insert(Interval::{ low: 5, high: 15 }, "V1")
  let version2 = original.insert(Interval::{ low: 25, high: 35 }, "V2")
  let version3 = original.remove(Interval::{ low: 10, high: 20 })
  let version4 = original.replace_exact(
    Interval::{ low: 10, high: 20 },
    "Updated",
  )

  // 验证原始树未被修改
  assert_eq!(original.size, 1)
  assert_eq!(
    original.find_exact(Interval::{ low: 10, high: 20 }),
    Some("Original"),
  )

  // 验证各个版本的独立性
  assert_eq!(version1.size, 2)
  assert_eq!(version1.find_exact(Interval::{ low: 5, high: 15 }), Some("V1"))
  assert_eq!(version2.size, 2)
  assert_eq!(version2.find_exact(Interval::{ low: 25, high: 35 }), Some("V2"))
  assert_eq!(version3.size, 0)
  assert_eq!(version3.find_exact(Interval::{ low: 10, high: 20 }), None)
  assert_eq!(version4.size, 1)
  assert_eq!(
    version4.find_exact(Interval::{ low: 10, high: 20 }),
    Some("Updated"),
  )
}

///|
/// 测试方法链式调用的复杂组合
test "complex_method_chaining_immut" {
  let final_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 15, high: 25 }, "B")
    .insert(Interval::{ low: 5, high: 15 }, "C")
    .replace_exact(Interval::{ low: 10, high: 20 }, "A_Updated")
    .insert(Interval::{ low: 30, high: 40 }, "D")
    .remove(Interval::{ low: 15, high: 25 })
    .insert(Interval::{ low: 12, high: 18 }, "E")
    .clear()
    .insert(Interval::{ low: 100, high: 200 }, "Final")

  // 验证最终状态
  assert_eq!(final_tree.size, 1)
  assert_eq!(
    final_tree.find_exact(Interval::{ low: 100, high: 200 }),
    Some("Final"),
  )
  assert_eq!(final_tree.find_exact(Interval::{ low: 10, high: 20 }), None)
}

///|
/// 测试并发安全性（模拟）
test "concurrent_safety_simulation_immut" {
  let base_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "Base")
    .insert(Interval::{ low: 30, high: 40 }, "Base2")

  // 模拟多个"线程"同时操作
  let thread1_tree = base_tree
    .insert(Interval::{ low: 5, high: 15 }, "T1_1")
    .insert(Interval::{ low: 25, high: 35 }, "T1_2")
  let thread2_tree = base_tree
    .remove(Interval::{ low: 10, high: 20 })
    .insert(Interval::{ low: 50, high: 60 }, "T2_1")
  let thread3_tree = base_tree
    .replace_exact(Interval::{ low: 30, high: 40 }, "T3_Updated")
    .insert(Interval::{ low: 70, high: 80 }, "T3_1")

  // 验证基础树保持不变
  assert_eq!(base_tree.size, 2)
  assert_eq!(
    base_tree.find_exact(Interval::{ low: 10, high: 20 }),
    Some("Base"),
  )

  // 验证各个"线程"的独立修改
  assert_eq!(thread1_tree.size, 4)
  assert_eq!(thread2_tree.size, 2)
  assert_eq!(thread3_tree.size, 3)

  // 验证特定修改
  assert_eq!(
    thread3_tree.find_exact(Interval::{ low: 30, high: 40 }),
    Some("T3_Updated"),
  )
  assert_eq!(thread2_tree.find_exact(Interval::{ low: 10, high: 20 }), None)
}

///|
/// 测试性能相关的边界情况
test "performance_edge_cases_immut" {
  // 测试大量相同端点的区间
  let mut same_start_tree = @immut_IntervalTree.new()
  for i = 1; i <= 20; i = i + 1 {
    same_start_tree = same_start_tree.insert(
      Interval::{ low: 10, high: 10 + i },
      "Same\{i}",
    )
  }
  assert_eq!(same_start_tree.size, 20)

  // 测试重叠查询性能
  let overlaps = same_start_tree.find_overlaps(Interval::{ low: 15, high: 25 })
  assert_true!(overlaps.length() > 10) // 应该找到多个重叠区间

  // 测试密集区间
  let mut dense_tree = @immut_IntervalTree.new()
  for i = 1; i <= 50; i = i + 1 {
    dense_tree = dense_tree.insert(
      Interval::{ low: i, high: i + 10 },
      "Dense\{i}",
    )
  }

  // 测试中心查询
  let center_overlaps = dense_tree.find_overlaps(Interval::{ low: 25, high: 35 })
  assert_true!(center_overlaps.length() >= 10) // 应该有很多重叠
}

///|
/// 测试区间类型组合的边界情况
test "interval_type_combinations_immut" {
  // 测试 Closed 类型
  let closed_options = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: false,
  }
  let closed_tree = @immut_IntervalTree.new_with_options(closed_options)
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 20, high: 30 }, "B")
  let closed_overlaps = closed_tree.find_overlaps(Interval::{
    low: 20,
    high: 20,
  })
  assert_eq!(closed_overlaps.length(), 2) // [10,20] 和 [20,30] 都包含点20

  // 测试 Open 类型
  let open_options = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: false,
  }
  let open_tree = @immut_IntervalTree.new_with_options(open_options)
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 20, high: 30 }, "B")
  let open_overlaps = open_tree.find_overlaps(Interval::{ low: 20, high: 20 })
  assert_eq!(open_overlaps.length(), 0) // (10,20) 和 (20,30) 都不包含点20，且查询(20,20)是空区间

  // 测试 LeftClosed 类型 - 使用非点查询避免空区间问题
  let left_closed_options = IntervalOptions::{
    interval_type: IntervalType::LeftClosed,
    allow_duplicates: false,
  }
  let left_closed_tree = @immut_IntervalTree.new_with_options(
      left_closed_options,
    )
    .insert(Interval::{ low: 10, high: 20 }, "A") // [10, 20)
    .insert(Interval::{ low: 20, high: 30 }, "B") // [20, 30)

  // 使用范围查询而不是点查询，避免空区间的问题
  let left_closed_overlaps = left_closed_tree.find_overlaps(Interval::{
    low: 20,
    high: 21,
  })
  assert_eq!(left_closed_overlaps.length(), 1) // 只有[20,30)重叠，因为是[20,21)

  // 测试 RightClosed 类型
  let right_closed_options = IntervalOptions::{
    interval_type: IntervalType::RightClosed,
    allow_duplicates: false,
  }
  let right_closed_tree = @immut_IntervalTree.new_with_options(
      right_closed_options,
    )
    .insert(Interval::{ low: 10, high: 20 }, "A") // (10, 20]
    .insert(Interval::{ low: 20, high: 30 }, "B") // (20, 30]
  let right_closed_overlaps = right_closed_tree.find_overlaps(Interval::{
    low: 19,
    high: 20,
  })
  assert_eq!(right_closed_overlaps.length(), 1) // 只有(10,20]重叠，因为是(19,20]
}

///|
/// 测试from_array的边界情况
test "from_array_edge_cases_immut" {
  // 测试空数组
  let empty_tree = @immut_IntervalTree.from_array([])
  assert_eq!(empty_tree.size, 0)

  // 测试单个元素数组
  let single_tree = @immut_IntervalTree.from_array([
    (Interval::{ low: 10, high: 20 }, "Single"),
  ])
  assert_eq!(single_tree.size, 1)

  // 测试包含无效区间的数组
  let mixed_tree = @immut_IntervalTree.from_array([
    (Interval::{ low: 10, high: 20 }, "Valid1"),
    (Interval::{ low: 30, high: 25 }, "Invalid"), // low > high
    (Interval::{ low: 40, high: 50 }, "Valid2"),
  ])
  assert_eq!(mixed_tree.size, 2) // 只有有效区间被插入

  // 测试大量重复区间
  let duplicates = []
  for i = 1; i <= 10; i = i + 1 {
    duplicates.push((Interval::{ low: 10, high: 20 }, "Dup\{i}"))
  }
  let dup_tree = @immut_IntervalTree.from_array(duplicates)
  assert_eq!(dup_tree.size, 1) // 默认不允许重复，应该只有一个

  // 测试允许重复的情况
  let dup_options = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: true,
  }
  let dup_tree_allowed = @immut_IntervalTree.from_array(
    duplicates,
    options=dup_options,
  )
  assert_eq!(dup_tree_allowed.size, 10) // 允许重复，应该有10个
}

///|
/// 测试树操作的组合效果
test "combined_operations_effects_immut" {
  // 创建基础树
  let base = @immut_IntervalTree.new()
    .insert(Interval::{ low: 10, high: 20 }, "A")
    .insert(Interval::{ low: 30, high: 40 }, "B")
    .insert(Interval::{ low: 50, high: 60 }, "C")

  // 测试插入后立即删除
  let insert_then_delete = base
    .insert(Interval::{ low: 25, high: 35 }, "Temp")
    .remove(Interval::{ low: 25, high: 35 })
  assert_eq!(insert_then_delete.size, base.size)

  // 测试删除后重新插入
  let delete_then_insert = base
    .remove(Interval::{ low: 30, high: 40 })
    .insert(Interval::{ low: 30, high: 40 }, "B_New")
  assert_eq!(delete_then_insert.size, base.size)
  assert_eq!(
    delete_then_insert.find_exact(Interval::{ low: 30, high: 40 }),
    Some("B_New"),
  )

  // 测试多次替换
  let multiple_replace = base
    .replace_exact(Interval::{ low: 10, high: 20 }, "A1")
    .replace_exact(Interval::{ low: 10, high: 20 }, "A2")
    .replace_exact(Interval::{ low: 10, high: 20 }, "A3")
  assert_eq!(
    multiple_replace.find_exact(Interval::{ low: 10, high: 20 }),
    Some("A3"),
  )

  // 测试清空后重建
  let clear_and_rebuild = base
    .clear()
    .insert(Interval::{ low: 100, high: 200 }, "New1")
    .insert(Interval::{ low: 300, high: 400 }, "New2")
  assert_eq!(clear_and_rebuild.size, 2)
  assert_eq!(
    clear_and_rebuild.find_exact(Interval::{ low: 10, high: 20 }),
    None,
  )
}

///|
/// 测试极端的数值范围
test "extreme_value_ranges_immut" {
  // 测试非常大的数值
  let large_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 1000000, high: 2000000 }, "Large1")
    .insert(Interval::{ low: 5000000, high: 6000000 }, "Large2")
  assert_eq!(
    large_tree.find_exact(Interval::{ low: 1000000, high: 2000000 }),
    Some("Large1"),
  )

  // 测试跨越大范围的查询
  let large_overlaps = large_tree.find_overlaps(Interval::{
    low: 1500000,
    high: 5500000,
  })
  assert_eq!(large_overlaps.length(), 2)

  // 测试浮点数精度边界
  let precision_tree = @immut_IntervalTree.new()
    .insert(Interval::{ low: 0.0000001, high: 0.0000002 }, "Tiny1")
    .insert(Interval::{ low: 0.0000015, high: 0.0000025 }, "Tiny2")
  assert_eq!(
    precision_tree.find_exact(Interval::{ low: 0.0000001, high: 0.0000002 }),
    Some("Tiny1"),
  )
}
