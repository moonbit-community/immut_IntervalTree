# Immutable IntervalTree

[English](https://github.com/moonbit-community/immut_IntervalTree/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/immut_IntervalTree/blob/master/README_zh_CN.md)

Immutable IntervalTree is an efficient implementation of interval trees that supports various interval query operations, such as finding overlapping intervals and contained intervals. An interval tree is a special self-balancing binary search tree designed for fast processing of interval queries. Unlike the standard IntervalTree, this implementation maintains complete immutability, with all operations returning new trees instead of modifying existing ones.

## 🚀 Key Features
• 🛡️ **Fully Immutable** - All operations return new trees while original trees remain unchanged  
• 🔄 **Multiple Construction Methods** - Support for empty trees, single interval trees, and creating from arrays  
• ➕ **Add & Query** - Easily insert intervals and check for their existence  
• ❌ **Remove** - Remove specific intervals and get new trees  
• 🔍 **Powerful Queries** - Support for finding intervals that match specific criteria  
• 🧠 **Generic Support** - Can use any type that implements the Compare trait as interval endpoints  
• ⚡ **Efficient Operations** - Optimized for both time and space complexity

## 📥 Installation
```bash
moon add kesmeey/immut_IntervalTree
```

## 🚀 Usage Guide

### 🔨 Creating an Interval Tree
You can create an immutable interval tree using the `new()`, `singleton()`, or `from_array()` methods.

```moonbit
// An empty interval tree - O(1)
let tree : T[Int, String] = @immut_IntervalTree.new()

// With a single interval - O(1)
let interval = Interval::{ low: 10, high: 20 }
let single_tree = @immut_IntervalTree.singleton(interval, "data")

// From an array of intervals - O(n log n)
let intervals = [
  (Interval::{ low: 10, high: 20 }, "A"),
  (Interval::{ low: 15, high: 25 }, "B"),
  (Interval::{ low: 5, high: 15 }, "C"),
]
let tree_from_array = @immut_IntervalTree.from_array(intervals)
```

### ➕ Adding Intervals and Data
Use the `insert()` method to add intervals and their associated data to the tree. This returns a new tree containing the added interval.

```moonbit
// Empty tree
let tree : T[Int, String] = @immut_IntervalTree.new()
// Insert interval, returns a new tree - O(log n)
let tree2 = tree.insert(Interval::{ low: 10, high: 20 }, "A") 
// Original tree remains unchanged
assert_eq!(tree.size, 0)
assert_eq!(tree2.size, 1)
```

### 🔍 Querying Intervals
Use the `find_exact()` method to find exact interval matches.

```moonbit
// Create new tree and add data
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
  .insert(Interval::{ low: 5, high: 15 }, "C")

// Exact match lookup - O(log n)
let data = tree.find_exact(Interval::{ low: 10, high: 20 })
assert_eq!(data, Some("A"))

// Find overlapping intervals - O(k + log n) where k is the number of results
let overlaps = tree.find_overlaps(Interval::{ low: 12, high: 18 })
```

### ❌ Removing Intervals
Use the `remove()` method to remove a specific interval, returning a new tree.

```moonbit
// Create tree and add data
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")

// Remove an interval, returns a new tree - O(log n)
let tree2 = tree.remove(Interval::{ low: 10, high: 20 })
assert_eq!(tree2.size, 1)
assert_eq!(tree2.find_exact(Interval::{ low: 10, high: 20 }), None)

// Original tree remains unchanged
assert_eq!(tree.size, 2)
assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
```

### 🔄 Replacing Data
Use the `replace_exact()` method to replace data for a specific interval, returning a new tree.

```moonbit
// Create tree and add data
let tree = @immut_IntervalTree.new().insert(
  Interval::{ low: 10, high: 20 },
  "A",
)

// Replace data, returns a new tree - O(log n)
let tree2 = tree.replace_exact(Interval::{ low: 10, high: 20 }, "Updated A")

// Verify update
assert_eq!(tree.find_exact(Interval::{ low: 10, high: 20 }), Some("A"))
assert_eq!(
  tree2.find_exact(Interval::{ low: 10, high: 20 }),
  Some("Updated A"),
)
```

### 🧹 Clearing the Tree
Use the `clear()` method to remove all intervals from the tree, returning a new empty tree.

```moonbit
// Create tree and add data
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")

// Clear the tree, returns a new empty tree - O(1)
let empty_tree = tree.clear()
assert_eq!(empty_tree.size, 0)
assert_eq!(empty_tree.root, None)

// Original tree remains unchanged
assert_eq!(tree.size, 2)
```

### 🔍 Advanced Queries

```moonbit
// Create tree and add data
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "A")
  .insert(Interval::{ low: 15, high: 25 }, "B")
// Find intervals contained within a range - O(n) in worst case
let contained = tree.find_contained(Interval::{ low: 0, high: 30 })

// Check if a specific interval exists - O(log n)
let exists = tree.contains(Interval::{ low: 10, high: 20 })

// Convert all intervals to an array - O(n)
let all_intervals = tree.to_array()
```

### 🧠 Generic Support
The immutable interval tree supports any type that implements the Compare trait as interval endpoints.

```moonbit
// Float type intervals
let float_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10.5, high: 20.5 }, "A")

// String type intervals
let string_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: "a", high: "z" }, 1)
```



## 🔄 Functional Programming Style
The immutable interval tree supports method chaining, making it well-suited for functional programming.

```moonbit
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
```

### ⏱️ Time Complexity Summary

| Operation | Time Complexity | Description |
|-----------|-----------------|-------------|
| `new()` | O(1) | Create an empty tree |
| `singleton()` | O(1) | Create a tree with one interval |
| `from_array()` | O(n log n) | Create from array of intervals |
| `insert()` | O(log n) | Insert a new interval |
| `remove()` | O(log n) | Remove an interval |
| `replace_exact()` | O(log n) | Replace data for an interval |
| `find_exact()` | O(log n) | Find an exact interval match |
| `find_overlaps()` | O(k + log n) | Find overlapping intervals (k = result count) |
| `find_contained()` | O(n) | Find intervals contained within a range |
| `contains()` | O(log n) | Check if an interval exists |
| `to_array()` | O(n) | Convert tree to array |
| `clear()` | O(1) | Clear all intervals |

## 📜 License
This project is licensed under the Apache-2.0 License. See LICENSE for details.

## 📢 Contact & Support
• Moonbit Community: moonbit-community  
• GitHub Issues: [Report an Issue](https://github.com/moonbit-community/immut_IntervalTree/issues)

👋 If you like this project, give it a ⭐! Happy coding! 🚀