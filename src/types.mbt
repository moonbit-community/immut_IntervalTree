// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This module implements the immutable interval tree data structure.
// The interval endpoints need to implement the Compare trait.
// All operations return new trees rather than modifying existing ones.

///|
/// Represents an interval with low and high endpoints
pub(all) struct Interval[T] {
  low : T // 区间低端点
  high : T // 区间高端点
} derive(Eq, Show)

///|
/// The main immutable interval tree container
pub(all) struct T[V, D] {
  root : Node[V, D]? // 根节点
  size : Int // 区间数量
  options : IntervalOptions // 区间操作选项
}

///|
/// Internal node structure for the immutable interval tree
pub(all) struct Node[V, D] {
  interval : Interval[V] // 存储的区间
  data : D // 与区间关联的数据
  max_high : V // 以该节点为根的子树中所有区间的最大高端点
  left : Node[V, D]? // 左子树
  right : Node[V, D]? // 右子树
  height : Int // 节点高度，用于平衡
} derive(Eq, Show)

///|
/// Represents the type of interval: closed [a,b], open (a,b), or half-open [a,b) or (a,b]
pub(all) enum IntervalType {
  Closed // [a,b] - 包含两个端点
  Open // (a,b) - 不包含任何端点
  LeftClosed // [a,b) - 包含左端点，不包含右端点
  RightClosed // (a,b] - 不包含左端点，包含右端点
} derive(Eq, Show)

///|
/// Result of an interval query, containing the interval and associated data
pub(all) struct IntervalMatch[T, D] {
  interval : Interval[T] // 匹配的区间
  data : D // 关联的数据
} derive(Eq, Show)

///|
/// Options for interval operations
pub(all) struct IntervalOptions {
  interval_type : IntervalType // 区间类型，默认为闭区间
  allow_duplicates : Bool // 是否允许重复区间，默认为false
} derive(Eq, Show)

///|
/// Default interval options: closed intervals with no duplicates allowed
pub fn default_options() -> IntervalOptions {
  IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: false,
  }
}
