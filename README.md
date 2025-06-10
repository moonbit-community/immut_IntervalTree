
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
• 🔧 **Interval Type Support** - Support for Closed, Open, LeftClosed, and RightClosed intervals
• 🔄 **Duplicate Handling** - Configurable support for duplicate intervals

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

### 🔧 Interval Types & Configuration
The library supports four different interval types and duplicate handling through configuration options.

```moonbit
// Default configuration: Closed intervals, no duplicates
let default_tree = @immut_IntervalTree.new()

// Custom configuration with different interval types
let closed_options = IntervalOptions::{ 
  interval_type: IntervalType::Closed,     // [a, b] - includes both endpoints
  allow_duplicates: false 
}

let open_options = IntervalOptions::{ 
  interval_type: IntervalType::Open,       // (a, b) - excludes both endpoints
  allow_duplicates: false 
}

let left_closed_options = IntervalOptions::{ 
  interval_type: IntervalType::LeftClosed, // [a, b) - includes left, excludes right
  allow_duplicates: false 
}

let right_closed_options = IntervalOptions::{ 
  interval_type: IntervalType::RightClosed, // (a, b] - excludes left, includes right
  allow_duplicates: false 
}

// Create trees with custom options - O(1)
let closed_tree = @immut_IntervalTree.new_with_options(closed_options)
let open_tree = @immut_IntervalTree.new_with_options(open_options)
```

### 🔄 Duplicate Handling
Configure how the tree handles intervals with identical boundaries.

```moonbit
// Allow duplicate intervals - O(1)
let dup_options = IntervalOptions::{ 
  interval_type: IntervalType::Closed, 
  allow_duplicates: true 
}

let tree = @immut_IntervalTree.new_with_options(dup_options)
  .insert(Interval::{ low: 10, high: 20 }, "First")
  .insert(Interval::{ low: 10, high: 20 }, "Second")  // Both intervals stored

assert_eq!(tree.size, 2)

// Disallow duplicates (default) - updates existing data - O(log n)
let no_dup_tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "Original")
  .insert(Interval::{ low: 10, high: 20 }, "Updated")  // Replaces original

assert_eq!(no_dup_tree.size, 1)
assert_eq!(no_dup_tree.find_exact(Interval::{ low: 10, high: 20 }), Some("Updated"))
```

### 📦 Bulk Operations
Efficiently create trees from multiple intervals using `from_array()`.

```moonbit
// Create from array with default options - O(n log n)
let intervals = [
  (Interval::{ low: 1, high: 10 }, "A"),
  (Interval::{ low: 5, high: 15 }, "B"),
  (Interval::{ low: 20, high: 30 }, "C"),
]
let tree = @immut_IntervalTree.from_array(intervals)

// Create from array with custom options - O(n log n)
let dup_options = IntervalOptions::{ 
  interval_type: IntervalType::Open, 
  allow_duplicates: true 
}
let dup_tree = @immut_IntervalTree.from_array(intervals, options dup_options)

// Invalid intervals (low > high) are automatically filtered out
let mixed_intervals = [
  (Interval::{ low: 10, high: 20 }, "Valid"),
  (Interval::{ low: 30, high: 25 }, "Invalid"), // Ignored
  (Interval::{ low: 40, high: 50 }, "Valid"),
]
let filtered_tree = @immut_IntervalTree.from_array(mixed_intervals)
assert_eq!(filtered_tree.size, 2) // Only valid intervals inserted
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

### 🔍 Overlap Detection with Different Interval Types
Understand how interval types affect overlap detection behavior.

```moonbit
// Closed intervals [10, 20] and [20, 30]
let closed_tree = @immut_IntervalTree.new_with_options(
  IntervalOptions::{ interval_type: IntervalType::Closed, allow_duplicates: false }
)
.insert(Interval::{ low: 10, high: 20 }, "A")
.insert(Interval::{ low: 20, high: 30 }, "B")

// Point query at boundary - O(k + log n)
let closed_overlaps = closed_tree.find_overlaps(Interval::{ low: 20, high: 20 })
// Both intervals overlap at point 20 in closed interval system

// Open intervals (10, 20) and (20, 30)  
let open_tree = @immut_IntervalTree.new_with_options(
  IntervalOptions::{ interval_type: IntervalType::Open, allow_duplicates: false }
)
.insert(Interval::{ low: 10, high: 20 }, "A")
.insert(Interval::{ low: 20, high: 30 }, "B")

let open_overlaps = open_tree.find_overlaps(Interval::{ low: 20, high: 20 })
// No overlaps since point 20 is excluded from both intervals
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

### 🕰️ Version Control & Immutability Benefits
Leverage immutability for version control, undo/redo operations, and safe concurrent access.

```moonbit
// Create snapshots at different points in time
let v1 = @immut_IntervalTree.new()
  .insert(Interval::{ low: 10, high: 20 }, "Initial") // Version 1 - O(log n)

let v2 = v1.insert(Interval::{ low: 15, high: 25 }, "Added") // Version 2 - O(log n)

let v3 = v2.remove(Interval::{ low: 10, high: 20 }) // Version 3 - O(log n)

let v4 = v2.replace_exact(Interval::{ low: 15, high: 25 }, "Modified") // Branch from v2 - O(log n)

// All versions remain accessible and unchanged
assert_eq!(v1.size, 1)  // Original version
assert_eq!(v2.size, 2)  // With addition  
assert_eq!(v3.size, 1)  // After removal from v2
assert_eq!(v4.size, 2)  // Modified branch from v2

// Perfect for implementing undo/redo systems
let history = [v1, v2, v3, v4]
let current_version = history[2] // Can jump to any version
```

### ⚠️ Error Handling & Edge Cases
The library gracefully handles various edge cases and invalid inputs.

```moonbit
// Invalid intervals are automatically rejected - O(1)
let tree = @immut_IntervalTree.new()
  .insert(Interval::{ low: 20, high: 10 }, "Invalid") // Ignored: low > high
  .insert(Interval::{ low: 10, high: 10 }, "Point")   // Valid: point interval
  .insert(Interval::{ low: 15, high: 25 }, "Valid")   // Valid: normal interval

assert_eq!(tree.size, 2) // Only valid intervals inserted

// Empty queries return empty results - O(k + log n)
let empty_results = tree.find_overlaps(Interval::{ low: 100, high: 200 })
assert_eq!(empty_results.length(), 0)

// Operations on non-existent intervals are safe - O(log n)
let unchanged = tree.remove(Interval::{ low: 50, high: 60 }) // No change
assert_eq!(unchanged.size, tree.size)

// Singleton with invalid interval creates empty tree - O(1)
let empty_singleton = @immut_IntervalTree.singleton(
  Interval::{ low: 30, high: 20 }, // Invalid
  "data"
)
assert_eq!(empty_singleton.size, 0)
```

### 🚀 Performance Tips & Best Practices
Optimize your usage for better performance and memory efficiency.

```moonbit
// ✅ Good: Use from_array() for bulk insertions - O(n log n)
let intervals = generate_many_intervals() // Your interval generation
let efficient_tree = @immut_IntervalTree.from_array(intervals)

// ❌ Avoid: Multiple individual inserts for bulk data - O(n log n) but slower constants
let mut slow_tree = @immut_IntervalTree.new()
for interval_data in intervals {
  slow_tree = slow_tree.insert(interval_data.0, interval_data.1)
}

// ✅ Good: Choose restrictive interval types when appropriate
let precise_options = IntervalOptions::{ 
  interval_type: IntervalType::Open,      // More restrictive overlap detection
  allow_duplicates: false 
}

// ✅ Good: Use method chaining for multiple operations - maintains efficiency
let result = tree
  .insert(Interval::{ low: 5, high: 10 }, "New")
  .replace_exact(Interval::{ low: 15, high: 25 }, "Updated")
  .remove(Interval::{ low: 20, high: 30 })

// ✅ Good: Store commonly used trees to avoid recomputation
let base_tree = @immut_IntervalTree.from_array(common_intervals)
let variant1 = base_tree.insert(special_interval1, data1)
let variant2 = base_tree.insert(special_interval2, data2)
// base_tree structure is shared between variants
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

## 📋 Complete API Reference

### Construction Methods
| Method | Time Complexity | Description |
|--------|-----------------|-------------|
| `new()` | O(1) | Create empty tree with default options |
| `new_with_options(options)` | O(1) | Create empty tree with custom options |
| `singleton(interval, data, options~)` | O(1) | Create tree with single interval |
| `from_array(intervals, options~)` | O(n log n) | Create tree from array of intervals |

### Core Operations
| Method | Time Complexity | Description |
|--------|-----------------|-------------|
| `insert(interval, data)` | O(log n) | Insert interval, returns new tree |
| `remove(interval)` | O(log n) | Remove interval, returns new tree |
| `replace_exact(interval, data)` | O(log n) | Replace data for exact interval match |
| `clear()` | O(1) | Remove all intervals, returns empty tree |

### Query Operations
| Method | Time Complexity | Description |
|--------|-----------------|-------------|
| `find_exact(interval)` | O(log n) | Find exact interval match |
| `find_overlaps(interval)` | O(k + log n) | Find all overlapping intervals |
| `find_contained(interval)` | O(n) | Find intervals contained within range |
| `contains(interval)` | O(log n) | Check if specific interval exists |
| `to_array()` | O(n) | Convert all intervals to array |

### Properties & Types
| Property/Type | Description |
|---------------|-------------|
| `size` | Number of intervals in tree |
| `root` | Internal tree structure (optional) |
| `options` | Tree configuration (IntervalOptions) |
| `IntervalType` | Closed, Open, LeftClosed, RightClosed |
| `IntervalMatch[V, D]` | Result type containing interval and data |

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
