///|
pub fn[V : Compare, D] new() -> T[V, D] {
  { root: None, size: 0, options: default_options() }
}

///|
/// Creates a new interval tree with options.
pub fn[V : Compare, D] new_with_options(options : IntervalOptions) -> T[V, D] {
  { root: None, size: 0, options }
}

///|
/// Creates a new interval tree with a single interval.
pub fn[V : Compare, D] singleton(
  interval : Interval[V],
  data : D,
  options~ : IntervalOptions = default_options(),
) -> T[V, D] {
  // 直接创建包含一个节点的树，而不是修改现有树
  if is_valid_interval(interval) == false {
    return new_with_options(options)
  }
  let root_node = Some({
    interval,
    data,
    max_high: interval.high,
    left: None,
    right: None,
    height: 1,
  })
  { root: root_node, size: 1, options }
}

///|
/// Creates a new interval tree from an array of intervals and data.
pub fn[V : Compare, D] from_array(
  intervals : Array[(Interval[V], D)],
  options~ : IntervalOptions = default_options(),
) -> T[V, D] {
  // 使用折叠操作构建不可变树，而不是通过修改来构建
  intervals.fold(init=new_with_options(options), fn(tree, pair) {
    let (interval, data) = pair
    tree.insert(interval, data)
  })
}

///|
/// Inserts an interval with associated data into the tree.
/// Returns a new tree with the interval inserted.
pub fn[V : Compare, D] insert(
  self : T[V, D],
  interval : Interval[V],
  data : D,
) -> T[V, D] {
  // 验证区间
  if is_valid_interval(interval) == false {
    println("Invalid interval: low > high")
    return self
  }

  // 如果不允许重复且相同区间存在，则更新数据
  if self.options.allow_duplicates == false {
    // 检查是否有完全匹配的区间
    match self.find_exact(interval) {
      Some(_) =>
        // 在不可变实现中，我们需要创建一个新树，更新匹配节点的数据
        return self.replace_exact(interval, data)
      None => ignore(None)
    }
  }
  let new_node = {
    interval,
    data,
    max_high: interval.high,
    left: None,
    right: None,
    height: 1,
  }

  // 插入新节点
  // 修改insert函数中的代码片段
  match self.root {
    None =>
      // 创建一个只有根节点的新树
      return { root: Some(new_node), size: 1, options: self.options }
    Some(root) => {
      // 创建包含新节点的新树
      let insert_result = insert_node_immut(
        root,
        new_node,
        allow_duplicates=self.options.allow_duplicates,
      )
      if insert_result.inserted {
        return {
          root: Some(insert_result.node),
          size: self.size + 1,
          options: self.options,
        }
      } else {
        return {
          root: Some(insert_result.node),
          size: self.size,
          options: self.options,
        }
      }
    }
  }
}

///|
/// Represents the result of an immutable insert operation
pub struct InsertResult[V, D] {
  node : Node[V, D]
  inserted : Bool
}

///|
/// Immutable version of insert_node

///|
/// Immutable version of insert_node
pub fn[V : Compare, D] insert_node_immut(
  node : Node[V, D],
  new_node : Node[V, D],
  allow_duplicates~ : Bool = false,
) -> InsertResult[V, D] {
  // 使用低端点作为BST键
  let comp = new_node.interval.low.compare(node.interval.low)

  // 插入到左子树
  if comp < 0 {
    match node.left {
      None => {
        // 创建新节点，左子树设置为new_node
        let updated_node = {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: Some(new_node),
          right: node.right,
          height: node.height,
        }
        let result_node = update_height_and_max_high_immut(updated_node)
        { node: result_node, inserted: true }
      }
      Some(left) => {
        let insert_result = insert_node_immut(left, new_node, allow_duplicates~)
        let updated_node = {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: Some(insert_result.node),
          right: node.right,
          height: node.height,
        }
        if insert_result.inserted {
          let height_updated = update_height_and_max_high_immut(updated_node)
          let balanced = balance_immut(height_updated)
          { node: balanced, inserted: true }
        } else {
          { node: updated_node, inserted: false }
        }
      }
    }
    // 插入到右子树
  } else if comp > 0 {
    match node.right {
      None => {
        let updated_node = {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: node.left,
          right: Some(new_node),
          height: node.height,
        }
        let result_node = update_height_and_max_high_immut(updated_node)
        { node: result_node, inserted: true }
      }
      Some(right) => {
        let insert_result = insert_node_immut(
          right,
          new_node,
          allow_duplicates~,
        )
        let updated_node = {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: node.left,
          right: Some(insert_result.node),
          height: node.height,
        }
        if insert_result.inserted {
          let height_updated = update_height_and_max_high_immut(updated_node)
          let balanced = balance_immut(height_updated)
          { node: balanced, inserted: true }
        } else {
          { node: updated_node, inserted: false }
        }
      }
    }
    // 区间完全相同，根据allow_duplicates决定更新还是添加
  } else if new_node.interval.high == node.interval.high {
    if allow_duplicates {
      // 如果允许重复，将新节点添加到右子树，视为"大于"当前节点
      match node.right {
        None => {
          let updated_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: node.left,
            right: Some(new_node),
            height: node.height,
          }
          let result_node = update_height_and_max_high_immut(updated_node)
          { node: result_node, inserted: true }
        }
        Some(right) => {
          let insert_result = insert_node_immut(
            right,
            new_node,
            allow_duplicates~,
          )
          let updated_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: node.left,
            right: Some(insert_result.node),
            height: node.height,
          }
          if insert_result.inserted {
            let height_updated = update_height_and_max_high_immut(updated_node)
            let balanced = balance_immut(height_updated)
            { node: balanced, inserted: true }
          } else {
            { node: updated_node, inserted: false }
          }
        }
      }
    } else {
      // 不允许重复，只更新数据
      let updated_node = {
        interval: node.interval,
        data: new_node.data, // 更新数据
        max_high: node.max_high,
        left: node.left,
        right: node.right,
        height: node.height,
      }
      { node: updated_node, inserted: false }
    }
  } else {
    // 相同低端点但不同高端点，应该插入到右子树
    match node.right {
      None => {
        let updated_node = {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: node.left,
          right: Some(new_node),
          height: node.height,
        }
        let result_node = update_height_and_max_high_immut(updated_node)
        { node: result_node, inserted: true }
      }
      Some(right) => {
        let insert_result = insert_node_immut(
          right,
          new_node,
          allow_duplicates~,
        )
        let updated_node = {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: node.left,
          right: Some(insert_result.node),
          height: node.height,
        }
        if insert_result.inserted {
          let height_updated = update_height_and_max_high_immut(updated_node)
          let balanced = balance_immut(height_updated)
          { node: balanced, inserted: true }
        } else {
          { node: updated_node, inserted: false }
        }
      }
    }
  }
}

///|
/// Update height and max_high for a node (immutable version)
pub fn[V : Compare, D] update_height_and_max_high_immut(
  node : Node[V, D],
) -> Node[V, D] {
  // 计算新的高度
  let new_height = 1 +
    @math.maximum(
      match node.left {
        Some(left) => left.height
        None => 0
      },
      match node.right {
        Some(right) => right.height
        None => 0
      },
    )

  // 计算新的max_high
  let mut new_max_high = node.interval.high
  match node.left {
    Some(left) =>
      if left.max_high.compare(new_max_high) > 0 {
        new_max_high = left.max_high
      }
    None => ignore(None)
  }
  match node.right {
    Some(right) =>
      if right.max_high.compare(new_max_high) > 0 {
        new_max_high = right.max_high
      }
    None => ignore(None)
  }

  // 创建并返回新节点
  {
    interval: node.interval,
    data: node.data,
    max_high: new_max_high, // 更新max_high
    left: node.left,
    right: node.right,
    height: new_height, // 更新height
  }
}

///|
/// Helper function to clone a node
pub fn[V, D] clone_node(node : Node[V, D]) -> Node[V, D] {
  {
    interval: node.interval,
    data: node.data,
    max_high: node.max_high,
    left: node.left,
    right: node.right,
    height: node.height,
  }
}

///|
/// Right rotation (immutable version)
pub fn[V : Compare, D] right_rotate_immut(y : Node[V, D]) -> Node[V, D] {
  match y.left {
    Some(x) => {
      let t2 = x.right

      // 创建新节点，使用记录更新语法替代字段修改
      let new_y = {
        interval: y.interval,
        data: y.data,
        max_high: y.max_high,
        left: t2,
        right: y.right,
        height: y.height,
      }

      // 更新高度和max_high
      let updated_y = update_height_and_max_high_immut(new_y)

      // 创建新的x节点，右子树指向更新后的y
      let new_x = {
        interval: x.interval,
        data: x.data,
        max_high: x.max_high,
        left: x.left,
        right: Some(updated_y),
        height: x.height,
      }

      // 更新x的高度和max_high
      update_height_and_max_high_immut(new_x)
    }
    None =>
      // 理论上不应该发生
      y
  }
}

///|
/// Left rotation (immutable version)
pub fn[V : Compare, D] left_rotate_immut(x : Node[V, D]) -> Node[V, D] {
  match x.right {
    Some(y) => {
      let t2 = y.left

      // 创建新节点，使用记录更新语法替代字段修改
      let new_x = {
        interval: x.interval,
        data: x.data,
        max_high: x.max_high,
        left: x.left,
        right: t2,
        height: x.height,
      }

      // 更新高度和max_high
      let updated_x = update_height_and_max_high_immut(new_x)

      // 创建新的y节点，左子树指向更新后的x
      let new_y = {
        interval: y.interval,
        data: y.data,
        max_high: y.max_high,
        left: Some(updated_x),
        right: y.right,
        height: y.height,
      }

      // 更新y的高度和max_high
      update_height_and_max_high_immut(new_y)
    }
    None =>
      // 理论上不应该发生
      x
  }
}

///|
/// Removes an interval from the tree.
/// Returns a new tree with the interval removed.
pub fn[V : Compare, D] remove(
  self : T[V, D],
  interval : Interval[V],
) -> T[V, D] {
  match self.root {
    None => self
    Some(root) => {
      let result = remove_node_immut(root, interval)
      if result.removed {
        return { root: result.node, size: self.size - 1, options: self.options }
      } else {
        return self
      }
    }
  }
}

///|
/// Result of removing a node
pub struct RemoveResult[V, D] {
  node : Node[V, D]?
  removed : Bool
}

///|

///|
/// Immutable version of remove_node
pub fn[V : Compare, D] remove_node_immut(
  node : Node[V, D],
  interval : Interval[V],
) -> RemoveResult[V, D] {
  let comp = interval.low.compare(node.interval.low)

  // 在左子树中搜索
  if comp < 0 {
    match node.left {
      None => { node: Some(node), removed: false }
      Some(left) => {
        let result = remove_node_immut(left, interval)
        if result.removed {
          // 创建带有更新左子树的新节点
          let updated_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: result.node, // 更新左子树
            right: node.right,
            height: node.height,
          }
          let height_updated = update_height_and_max_high_immut(updated_node)
          let balanced_node = balance_immut(height_updated)
          { node: Some(balanced_node), removed: true }
        } else {
          { node: Some(node), removed: false }
        }
      }
    }
    // 在右子树中搜索
  } else if comp > 0 {
    match node.right {
      None => { node: Some(node), removed: false }
      Some(right) => {
        let result = remove_node_immut(right, interval)
        if result.removed {
          // 创建带有更新右子树的新节点
          let updated_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: node.left,
            right: result.node, // 更新右子树
            height: node.height,
          }
          let height_updated = update_height_and_max_high_immut(updated_node)
          let balanced_node = balance_immut(height_updated)
          { node: Some(balanced_node), removed: true }
        } else {
          { node: Some(node), removed: false }
        }
      }
    }
    // 找到了相同低端点的节点，检查高端点
  } else if node.interval.high != interval.high {
    // 相同的低端点但不同的高端点，可能在子树中
    match node.right {
      None => { node: Some(node), removed: false }
      Some(right) => {
        let result = remove_node_immut(right, interval)
        if result.removed {
          // 创建带有更新右子树的新节点
          let updated_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: node.left,
            right: result.node, // 更新右子树
            height: node.height,
          }
          let height_updated = update_height_and_max_high_immut(updated_node)
          let balanced_node = balance_immut(height_updated)
          { node: Some(balanced_node), removed: true }
        } else {
          { node: Some(node), removed: false }
        }
      }
    }
  } else {
    // 找到要删除的节点
    match (node.left, node.right) {
      // 情况1：叶子节点
      (None, None) => { node: None, removed: true }
      // 情况2a：只有右子节点
      (None, Some(_)) => { node: node.right, removed: true }
      // 情况2b：只有左子节点
      (Some(_), None) => { node: node.left, removed: true }
      // 情况3：有两个子节点
      (Some(_), Some(right)) => {
        // 找到右子树中的最小节点
        let successor = find_min_immut(right)

        // 创建一个新节点，使用后继节点的值
        let new_node = {
          interval: successor.interval, // 使用后继节点的区间
          data: successor.data, // 使用后继节点的数据
          max_high: node.max_high,
          left: node.left,
          right: node.right,
          height: node.height,
        }

        // 从右子树中删除后继节点
        let result = remove_node_immut(right, successor.interval)

        // 创建更新了右子树的新节点
        let node_with_right_updated = {
          interval: new_node.interval,
          data: new_node.data,
          max_high: new_node.max_high,
          left: new_node.left,
          right: result.node, // 更新后的右子树
          height: new_node.height,
        }

        // 更新高度和max_high，然后平衡
        let updated_node = update_height_and_max_high_immut(
          node_with_right_updated,
        )
        let balanced_node = balance_immut(updated_node)
        { node: Some(balanced_node), removed: true }
      }
    }
  }
}

///|
/// Finds the node with the minimum value in the subtree (immutable version)
pub fn[V, D] find_min_immut(node : Node[V, D]) -> Node[V, D] {
  match node.left {
    None => node
    Some(left) => find_min_immut(left)
  }
}

///|
/// Replace data for an exactly matching interval
pub fn[V : Compare, D] replace_exact(
  self : T[V, D],
  interval : Interval[V],
  new_data : D,
) -> T[V, D] {
  match self.root {
    None => self
    Some(root) => {
      let updated_root = replace_exact_helper(root, interval, new_data)
      return {
        root: Some(updated_root),
        size: self.size,
        options: self.options,
      }
    }
  }
}

///|
/// Finds an exact match for an interval in the tree
pub fn[V : Compare, D] find_exact(self : T[V, D], interval : Interval[V]) -> D? {
  match self.root {
    None => None
    Some(root) => find_exact_in_node(root, interval)
  }
}

///|
/// Helper function to find an exact interval match in a node
pub fn[V : Compare, D] find_exact_in_node(
  node : Node[V, D],
  query : Interval[V],
) -> D? {
  let low_comp = query.low.compare(node.interval.low)
  if low_comp == 0 && query.high == node.interval.high {
    // Found an exact match
    return Some(node.data)
  } else if low_comp < 0 {
    // Try left subtree
    match node.left {
      Some(left) => find_exact_in_node(left, query)
      None => None
    }
  } else {
    // Try right subtree
    match node.right {
      Some(right) => find_exact_in_node(right, query)
      None => None
    }
  }
}

///|
/// Helper for replace_exact

///|
/// Helper for replace_exact
pub fn[V : Compare, D] replace_exact_helper(
  node : Node[V, D],
  query : Interval[V],
  new_data : D,
) -> Node[V, D] {
  let low_comp = query.low.compare(node.interval.low)

  // 找到完全匹配的节点，创建新节点并更新数据
  if low_comp == 0 && query.high == node.interval.high {
    return {
      interval: node.interval,
      data: new_data, // 只更新数据字段
      max_high: node.max_high,
      left: node.left,
      right: node.right,
      height: node.height,
    }
  }

  // 没找到匹配节点，继续在适当的子树中搜索并更新
  if low_comp < 0 {
    match node.left {
      Some(left) => {
        let updated_left = replace_exact_helper(left, query, new_data)
        // 创建新节点，更新左子树
        return {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: Some(updated_left), // 更新左子树
          right: node.right,
          height: node.height,
        }
      }
      None => return node // 没有左子树，无需更新
    }
  } else {
    match node.right {
      Some(right) => {
        let updated_right = replace_exact_helper(right, query, new_data)
        // 创建新节点，更新右子树
        return {
          interval: node.interval,
          data: node.data,
          max_high: node.max_high,
          left: node.left,
          right: Some(updated_right), // 更新右子树
          height: node.height,
        }
      }
      None => return node // 没有右子树，无需更新
    }
  }
}

///|
/// Clears all intervals from the tree.
/// Returns a new empty tree with the same options.
pub fn[V : Compare, D] clear(self : T[V, D]) -> T[V, D] {
  new_with_options(self.options)
}

///|
/// Checks if the interval is valid (low <= high)
pub fn[V : Compare] is_valid_interval(interval : Interval[V]) -> Bool {
  // 检查区间的低端点是否不大于高端点
  interval.low.compare(interval.high) <= 0
}

///|
/// Balances a node in the AVL tree (immutable version)
pub fn[V : Compare, D] balance_immut(node : Node[V, D]) -> Node[V, D] {
  // 计算平衡因子
  let balance = get_balance(node)

  // 左子树高 - 需要右旋或左右旋
  if balance > 1 {
    match node.left {
      Some(left) =>
        // 左-左情况：直接右旋
        if get_balance(left) >= 0 {
          return right_rotate_immut(node)
          // 左-右情况：先左旋左子树，再右旋节点
        } else {
          let new_left = left_rotate_immut(left)
          // 创建新节点，左子树设为new_left
          let new_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: Some(new_left), // 使用记录创建语法
            right: node.right,
            height: node.height,
          }
          return right_rotate_immut(new_node)
        }
      None => ignore(node) // 理论上不应该发生
    }
    // 右子树高 - 需要左旋或右左旋
  } else if balance < -1 {
    match node.right {
      Some(right) =>
        // 右-右情况：直接左旋
        if get_balance(right) <= 0 {
          return left_rotate_immut(node)
          // 右-左情况：先右旋右子树，再左旋节点
        } else {
          let new_right = right_rotate_immut(right)
          // 创建新节点，右子树设为new_right
          let new_node = {
            interval: node.interval,
            data: node.data,
            max_high: node.max_high,
            left: node.left,
            right: Some(new_right), // 使用记录创建语法
            height: node.height,
          }
          return left_rotate_immut(new_node)
        }
      None => ignore(node) // 理论上不应该发生
    }
  }

  // 节点已经平衡
  return node
}

///|
/// Gets the balance factor of a node
pub fn[V, D] get_balance(node : Node[V, D]) -> Int {
  let left_height = match node.left {
    Some(left) => left.height
    None => 0
  }
  let right_height = match node.right {
    Some(right) => right.height
    None => 0
  }
  left_height - right_height
}

///|
/// 将树中的所有区间及其数据转换为数组
pub fn[V : Compare, D] to_array(self : T[V, D]) -> Array[IntervalMatch[V, D]] {
  let results = []

  // 使用中序遍历收集所有节点
  fn traverse(node : Node[V, D]?) -> Unit {
    match node {
      None => ()
      Some(n) => {
        // 先遍历左子树
        traverse(n.left)

        // 处理当前节点
        results.push({ interval: n.interval, data: n.data })

        // 再遍历右子树
        traverse(n.right)
      }
    }
  }

  traverse(self.root)
  results
}

///|
/// 检查树中是否存在指定的区间
pub fn[V : Compare, D] contains(self : T[V, D], interval : Interval[V]) -> Bool {
  match self.find_exact(interval) {
    Some(_) => true
    None => false
  }
}

///|
/// 查找被给定区间完全包含的所有区间
/// 返回包含匹配区间和数据的数组
pub fn[V : Compare, D] find_contained(
  self : T[V, D],
  container : Interval[V],
) -> Array[IntervalMatch[V, D]] {
  let results = []
  match self.root {
    None => results
    Some(root) => {
      find_contained_helper(
        root,
        container,
        results,
        self.options.interval_type,
      )
      results
    }
  }
}

///|
/// Helper function for find_contained
fn[V : Compare, D] find_contained_helper(
  node : Node[V, D],
  container : Interval[V],
  results : Array[IntervalMatch[V, D]],
  interval_type : IntervalType,
) -> Unit {
  // 检查当前节点的区间是否被container完全包含
  if interval_contains(container, node.interval, interval_type~) {
    // 创建匹配对象并添加到结果中
    let match_obj = { interval: node.interval, data: node.data }
    results.push(match_obj)
  }

  // 检查左子树 - 不剪枝，遍历所有节点
  match node.left {
    Some(left) => find_contained_helper(left, container, results, interval_type)
    None => ()
  }

  // 检查右子树 - 不剪枝，遍历所有节点
  match node.right {
    Some(right) =>
      find_contained_helper(right, container, results, interval_type)
    None => ()
  }
}

///|
/// 查找与给定区间重叠的所有区间
/// 返回包含匹配区间和数据的数组
pub fn[V : Compare, D] find_overlaps(
  self : T[V, D],
  interval : Interval[V],
) -> Array[IntervalMatch[V, D]] {
  let results = []
  match self.root {
    None => results
    Some(root) => {
      find_overlaps_helper(root, interval, results, self.options.interval_type)
      results
    }
  }
}

///|
/// Helper function for find_overlaps
fn[V : Compare, D] find_overlaps_helper(
  node : Node[V, D],
  query : Interval[V],
  results : Array[IntervalMatch[V, D]],
  interval_type : IntervalType,
) -> Unit {
  // 检查当前节点的区间是否与查询区间重叠
  if intervals_overlap(node.interval, query, interval_type~) {
    // 创建匹配对象并添加到结果中
    let match_obj = { interval: node.interval, data: node.data }
    results.push(match_obj)
  }

  // 如果左子树不为空且可能包含重叠区间，则递归搜索
  match node.left {
    Some(left) =>
      // 如果左子树的最大高端点大于或等于查询的低端点，可能存在重叠
      if endpoints_geq(left.max_high, query.low, interval_type~) {
        find_overlaps_helper(left, query, results, interval_type)
      }
    None => ()
  }

  // 如果右子树不为空且当前节点的低端点小于等于查询的高端点，则递归搜索右子树
  match node.right {
    Some(right) =>
      if endpoints_leq(node.interval.low, query.high, interval_type~) {
        find_overlaps_helper(right, query, results, interval_type)
      }
    None => ()
  }
}

///|
/// Checks if two intervals overlap

///|
/// Checks if two intervals overlap
pub fn[V : Compare] intervals_overlap(
  a : Interval[V],
  b : Interval[V],
  interval_type~ : IntervalType = IntervalType::Closed,
) -> Bool {
  match interval_type {
    IntervalType::Closed =>
      // [a, b] 与 [c, d] 重叠：b >= c && d >= a
      a.high.compare(b.low) >= 0 && b.high.compare(a.low) >= 0
    IntervalType::Open =>
      // (a, b) 与 (c, d) 重叠：b > c && d > a
      a.high.compare(b.low) > 0 && b.high.compare(a.low) > 0
    IntervalType::LeftClosed =>
      // [a, b) 与 [c, d) 重叠：b > c && d > a
      a.high.compare(b.low) > 0 && b.high.compare(a.low) > 0
    IntervalType::RightClosed =>
      // (a, b] 与 (c, d] 重叠：b >= c && d > a（注意这里 d > a，不是 d >= a）
      a.high.compare(b.low) >= 0 && b.high.compare(a.low) > 0
  }
}

///|
/// Checks if interval a completely contains interval b///|
pub fn[V : Compare] interval_contains(
  a : Interval[V],
  b : Interval[V],
  interval_type~ : IntervalType = IntervalType::Closed,
) -> Bool {
  match interval_type {
    IntervalType::Closed =>
      // [a, b] 包含 [c, d] 当且仅当 a <= c 且 b >= d
      a.low.compare(b.low) <= 0 && a.high.compare(b.high) >= 0
    IntervalType::Open =>
      // (a, b) 包含 (c, d) 当且仅当 a < c 且 b > d
      a.low.compare(b.low) < 0 && a.high.compare(b.high) > 0
    IntervalType::LeftClosed =>
      // [a, b) 包含 [c, d) 当且仅当 a <= c 且 b >= d，并且如果 b == d，则 d 不能等于 b（因为 b 是开的）
      a.low.compare(b.low) <= 0 &&
      (
        a.high.compare(b.high) > 0 ||
        (a.high.compare(b.high) == 0 && b.high.compare(a.high) != 0)
      )
    IntervalType::RightClosed =>
      // (a, b] 包含 (c, d] 当且仅当 a < c 且 b >= d，并且如果 a == c，则 c 不能等于 a（因为 a 是开的）
      a.low.compare(b.low) < 0 && a.high.compare(b.high) >= 0
  }
}

///|
/// Helper: Checks if a <= b accounting for interval type
pub fn[V : Compare] endpoints_leq(
  a : V,
  b : V,
  interval_type~ : IntervalType = IntervalType::Closed,
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) <= 0
    IntervalType::Open => a.compare(b) < 0
    IntervalType::LeftClosed => a.compare(b) <= 0
    IntervalType::RightClosed => a.compare(b) < 0
  }
}

///|
/// Helper: Checks if a >= b accounting for interval type
pub fn[V : Compare] endpoints_geq(
  a : V,
  b : V,
  interval_type~ : IntervalType = IntervalType::Closed,
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) >= 0
    IntervalType::Open => a.compare(b) > 0
    IntervalType::LeftClosed => a.compare(b) >= 0
    IntervalType::RightClosed => a.compare(b) > 0
  }
}
