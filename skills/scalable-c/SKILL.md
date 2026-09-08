---
name: scalable-c
description: 本项目 Scalable C 编码风格的 skill
---

# Scalable C（可规模化的 C）

本项目的 C 代码风格源自 Pieter Hintjens 的 *Scalable C* 一书。
核心思想是：**让 C 代码在人数、项目数、时间三个维度上都能线性扩展，不会随规模增长而失控。**

## 核心哲学

**一切皆是 class。**
C 中写面向对象不是形式上的模仿，而是在思想上用 OOP 来组织代码：
每个模块就是一个 class，有自己的职责和 API。
当一个功能需要独立的职责边界时，就抽出一个 class（如 `xexe_t`），
而不是把函数分散在各处。

**API 即合约，实现是细节。**
`.h` 定义了不可随意破坏的合约——变了就要改所有调用者。
`.c` 是实现空间，可以任意重构而不影响调用者。
这条边界越清晰，模块就越可以在不改动其他模块的前提下独立演进。

**从调用者视角设计 API。**
先用调用者的眼光设计 interface，再写实现。
调用方怎么写最自然、最不易出错、最少需要记忆，就怎么设计。

**一致性是规模化的前提。**
所有 class 遵循同一个编码模板，用户学会一个 class 的 API 模式就知道所有 class 的用法。
多样性在 API 设计中是 bug，不是 feature。

**快速失败，明确边界。**
内部错误（我自己的 bug）用 `assert` 终止——在受损状态上继续运行只会让问题更难排查。
外部输入（用户数据、网络数据、文件）不做 assert，而是正常处理或返回错误。
这是一条分界线，让调试成本随规模增长保持线性。

**廉价实验。**
结构统一意味着新建模块/项目的边际成本趋近于零。
鼓励把小功能拆成独立模块，而不是把代码堆进一个文件里。

## 何时该创建一个 class

当一组操作共享同一批状态数据时，这些操作和状态就构成了一个 class。
判断标准很简单：**回答"这个东西是什么"，答案就是 class 名。**

例如处理 `.xexe` 文件格式时，序列化/反序列化/验证等操作都需要访问同一批内部
数据结构（definitions、values、fixups）。这些操作散落在各处会造成职责混乱。
正确做法是抽取 `xexe_t`，让它承接所有 xexe 相关的 API。

具体来说，出现以下信号就应当创建 class：

- **有一批需要一起传递的状态** — 如果在多个函数间传来传去的参数总是同一组变量，这组变量就该封装成 class
- **有明确的生命周期边界** — 如果存在"初始化 → 使用 → 释放"的流程，就是 class 的构造/析构
- **概念上是一个独立的实体** — 用自然语言描述时它是一个名词（如"模块"、"帧"、"分配器"），而不是一个动作

**反例：** 如果只有一两个纯函数、没有共享状态，就不需要 class。工具函数（如 `char_isspace`、`int_max`）保持为独立函数即可。

## class 的基本结构

一个 class 由一组固定的文件构成：

- `types.h` — 前置声明、类型别名、函数指针 typedef
- `{class}.h` — 公开 API（外部调用者依赖的合约）
- `{class}.c` — 实现（内部可自由变化的细节）
- `index.h` — 聚合入口（调用者只需 include 这个文件，不需要知道模块内部有哪些文件）

## 接口可见性

根据是否需要隐藏内部实现来决定 struct 的放置位置：

**隐藏内部细节的容器** —— struct 定义在 `.c`，`types.h` 只写前置声明：

```c
// types.h
typedef struct hash_t hash_t;

// hash.c —— 只有 .c 文件知道 struct 内部有什么
struct hash_t {
  size_t prime_index;
  size_t used_indexes_size;
  size_t length;
  hash_entry_t **entries;
  // ...
};
```

这样做的好处：内部结构随时可以改，不影响任何调用者。

**公开数据载体和迭代器** —— struct 定义在 `.h`：

```c
// frame.h
struct frame_t {
  const function_t *function;
  uint8_t *pc;
  uint16_t local_count;
  size_t prev_frame_offset;
};
```

这样做的好处：调用者可以直接访问字段，不需要不必要的 getter/setter 开销。

判断标准很简单：**非 class 的使用者需要直接访问这个 struct 的字段吗？需要就公开，不需要就隐藏。**

## 命名约定

所有函数和类型名使用 class 名作为前缀。这既提供命名空间隔离，也让调用者一眼知道这个函数属于谁。（实际上 class 名不一定等于模块名，比如 `cli_make_ctx` 中的 `cli_ctx_t` 是 class 名，但其所在模块是 `cli`。）

**构造与析构：**

| 模式 | 含义 | 何时使用 |
|------|------|----------|
| `make_hash()` | 分配 + 零初始化，无参数 | 最简单的构造，不需要外部数据 |
| `make_list_with(free_fn)` | 构造 + 设置回调/配置 | 需要可选的行为定制 |
| `make_xstring_take(text_t *)` | 构造 + 获取调用方数据的所有权 | 外部已分配好数据，转交给 class 管理 |
| `make_xstring_copy(const char *)` | 构造 + 复制一份自己的副本 | 外部数据仍由调用方管理，class 需要独立副本 |
| `make_static_xstring(const char *)` | 构造不可释放的静态对象 | 生命周期与进程一致，不参与 GC/释放 |
| `hash_free(self)` | 析构：释放对象及所有子资源 | |
| `hash_purge(self)` | 清理：清空子资源，保留结构体可复用 | 对象要重用但需要清空内部状态 |

构造函数后缀体现了**所有权语义**——调用者通过函数名就能知道数据是被接管（`_take`）、被复制（`_copy`）、还是保持独立。

**属性访问：**

| 模式 | 含义 |
|------|------|
| `hash_length(h)` | getter |
| `hash_put_hash_fn(h, fn)` | setter |
| `hash_is_empty(h)` | 布尔断言 |
| `hash_has(h, key)` | 成员检查 |
| `hash_get(h, key)` | 按 key 查找 |
| `hash_insert_or_fail()` | 失败即 assert 的变体（用于"不可能失败"的调用场景） |

**所有权约定体现在 API 注释中，而不是在函数名上：**

```c
// - return true if success.
// - will own the key if success.
// - will not update the key if the entry exists (fail).
bool hash_insert(hash_t *self, void *key, void *value);
```

## self 参数约定

每个方法第一个参数始终命名为 `self`：

```c
// 可变方法
void list_push(list_t *self, void *value);

// 只读方法
size_t hash_length(const hash_t *self);
```

## 内存分配

构造时使用本项目封装的分配函数，而不是直接调 `malloc`/`calloc`：

```c
void *allocate(size_t size);           // calloc + assert + 8字节对齐验证
void *allocate_pointers(size_t count); // 指针数组
void *allocate_page_aligned(size_t);   // 页对齐（避免伪共享）

#define new(type) allocate(sizeof(type))
```

核心特征：
- `allocate()` **始终**零初始化——这意味着构造出的对象中所有属性默认为零值（`NULL`/`0`/`false`）
- 分配失败立刻 `assert` 终止——不在 OOM 状态上继续运行
- 构造函数只需设置非零值的属性，不作冗余初始化

```c
allocator_t *make_allocator(size_t cache_size) {
  allocator_t *self = new_page_aligned(allocator_t);
  self->mutex = make_mutex();
  self->stack = make_stack();
  self->cache_size = cache_size;
  return self;
}
```

析构模式：`_free()` 先依次释放子资源，再 `free(self)`。

```c
void cli_ctx_free(cli_ctx_t *self) {
  array_free(self->args);
  record_free(self->options);
  array_free(self->passthrough);
  free(self);
}
```

标准回调类型：

```c
typedef void (free_fn_t)(void *value);
typedef bool (equal_fn_t)(const void *value1, const void *value2);
typedef void *(copy_fn_t)(void *value);
```

## 错误处理

Sclaable C 把错误分成两类，用不同策略对待：

| 场景 | 策略 | 理由 |
|------|------|------|
| 内部逻辑矛盾（代码 bug） | `assert(condition)` | 不应继续运行，快速暴露问题 |
| 可预期的失败（key 不存在等） | `bool` 返回 false | 正常业务逻辑 |
| 未找到 | 返回 `NULL` | 调用方自行判断 |
| 不可恢复的致命错误 | `exit(1)` | 如资源耗尽 |
| 调试/日志信息 | `who_printf("fmt", ...)` | 自动带 `[函数名]` 前缀 |
| 调试/日志信息 | `where_printf("fmt", ...)` | 自动带 `文件:行号` 前缀 |
| 未实现功能的占位 | `TODO()` | 等价 `assert(false)` 带 "TODO" 消息 |

关键分界线：**只对内部错误 assert，对外部输入不做 assert**。
如果某个条件一旦发生就说明"我的代码有 bug"，用 assert。
如果某个条件可能因为用户输入或环境变化而发生，用返回值。

## 迭代器

两种分配方式对应两种生命周期：

```c
// 栈分配 —— 函数内短迭代，零 malloc 开销
list_iter_t iter;
list_iter_init(&iter, list);
void *value = list_iter_next(&iter);
while (value) {
  // ...
  value = list_iter_next(&iter);
}
// 无需释放

// 堆分配 —— 需要保存迭代器或传递出去
list_iter_t *iter = make_list_iter(list);
// ...
list_iter_free(iter);
```

迭代器 struct 布局简单（通常只是指针字段），就是为了支持栈分配的高效用法。

## 模块组织

模块级 `index.h` 是模块的单一入口——按依赖顺序聚合本模块的所有头文件：

```c
// hash/index.h
#pragma once

#include "deps.h"
#include "types.h"
#include "hash.h"
#include "hash_entry.h"
#include "hash_iter.h"
```

所有 `.c` 文件只 include 自己模块的 `"index.h"`，不直接 include 其他头文件。
这让模块内部的子文件拆分对调用者完全透明。

### deps.h 的链式结构

`deps.h` 是模块声明"我依赖什么"的地方，形成三层链式结构：

```
模块级 deps.h  →  项目级 deps.h  →  上游项目 src/index.h
```

**模块级 deps.h**（如 `xvm/deps.h`）——声明本模块需要的标准库头文件 + 本项目内其他模块的依赖：

```c
// xvm/deps.h
#pragma once
#include "../deps.h"           // 项目级 deps.h
#include "../value/index.h"    // 本项目的 value 模块
#include "../gc/index.h"       // 本项目的 gc 模块
```

**项目级 deps.h**（如 `xvm.c/src/deps.h`）——声明本项目的上游项目依赖：

```c
// xvm.c/src/deps.h
#pragma once
#include "../../std.c/src/index.h"  // 上游项目
#include "../../cli.c/src/index.h"      // 上游项目
#include "config.h"                     // 项目级配置
```

**根项目**（如 std.c）没有项目级 `deps.h`——它的 `src/index.h` 直接聚合所有模块。

原则：每个模块只声明自己**直接**需要的依赖，不传递。调用某模块时，include 该模块的 `index.h` 即可，不需要手动 include 其上游。

## 测试

测试文件命名为 `{class}.test.c`，只用 `assert()` 做断言，不引入测试框架：

```c
#include "index.h"

int main(void) {
  test_start();

  {
    hash_t *hash = make_hash();
    assert(hash_is_empty(hash));
    assert(hash_insert(hash, key, value));
    assert(hash_length(hash) == 1);
    hash_free(hash);
  }

  test_end();
}
```

## 代码风格

- 头文件保护：`#pragma once`
- 注释：`//`
- 积极使用 `const`
- 类型名全小写 + `_t` 后缀：`hash_t`, `xvm_t`, `allocator_t`
