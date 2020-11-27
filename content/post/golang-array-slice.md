---
title: Go语言的array、slice，你需要知道的那些事儿
date: 2016-07-25T12:07:44+08:00
draft: false
tags: ["Golang"]
categories: ["Golang"]

autoCollapseToc: true

---

Go语言中的`array`、`slice`，你真的了解了吗？先看下段代码，如果你心中的结果都答对了，并且能说出具体原因（不是蒙对的:)）,那么你就可以不用在这里浪费时间了.
这段代码也让我反思自己，文档认真看了吗？看过文档后记住了吗？（不是过个几天就忘了）反复看过文档吗？我回答自己：认真看了，当时记住了，没有反复看过，来增强记忆。从现起改正自己吧。

**不啰嗦了，直接上代码:**
```go
//省略package 和 import
func slice() []int {
    s1 := []int{1, 2, 3, 4}
    s2 := []int{-1, -2, -3}
    return append(append(s1[:1], s2...), s1[1:]...)
}

func slice1() []int {
    s1 := []int{1, 2, 3, 4}
    s2 := []int{-1, -2, -3, -4}
    return append(append(s1[:1], s2...), s1[1:]...)
}

func main() {
    // output?
    fmt.Printf("func slice=%+v\n", slice())
    fmt.Printf("func slice1=%+v\n", slice1())
}
```
下边的内容，可能会对你有一些帮助。
先来回顾一下Go语言的`array`。

<!--more-->

## Array

### 用法:

```go
var a [2]int
a[0] = 1

s := [2]string{"a", "b"}
//or 
s := [...]string{"a", "b"}
```

### 内部结构：

![go-array-slices-array.png](/img/posts/go-array-slices-array.png)

### 总结:

1. 定义时必须指定长度和类型
2. 可以索引访问,不需要明确的初始化，数组中的 zero value 就是数组类型本身默认值
    例如:
    ```go
    var a [2]int
    a[0] = 1
    fmt.Println(a[1]) // output 0

    var b [2]bool
    fmt.Println(b[0]) // output false

    var s [2]string
    fmt.Println(s[0]) // output ""
    ```
3. **长度是固定的，是数组类型中的一部分，并且是非负数, [5]int与[10]int是不同的**     
4. **数组是值类型，分配或是传递一个数组时，是`copy` 数组所有内容，并不是指向原数组的指针；**如果想不复制数组的内容，可以传递指针，并这不是go的style，可以使用`slice`代替
5. 数组主要用于构造`slice`


## Slice

Slice切片是对底层数组Array的封装，提供了更广泛、功能强大、更方法的数据序列。在内存中的存储本质就是数组，体现为连续的内存块。

### 用法:

1. 从`array`创建
    ```go
    a := [5]int{1, 2, 3, 4, 5}
    s := a[1:3] //左闭右开
    fmt.Println(s) //output [2 3]
    ```
2. 类似创建数组一样，去掉长度，或使用`make` 内建方法来创建
    ```go
    s := []int{1, 2, 3, 4, 5}
    // or
    s := make([]int, 5, 5)
    ```


### 长度(length)与容量(capacity)

长度: 这个长度跟数组的长度是一个概念，即在内存中进行了初始化实际存在的元素的个数。
容量: 如果通过`make`函数创建`slice`的时候指定了容量参数，那内存管理器会根据指定的容量的值先划分一块内存空间，然后才在其中存放有数组元素，多余部分处于空闲状态，在Slice上追加元素的时候，首先会放到这块空闲的内存中，如果添加的参数个数超过了容量值，内存管理器会重新划分一块容量值为原容量值*2大小的内存空间，依次类推。这个机制的好处在能够提升运算性能，因为内存的重新划分会降低性能。
```go
len(s) //output 5
cap(s) //output 5
```
**注意: Slice的处理机制这样的**
>**当Slice的容量还有空闲的时候，append进来的元素会直接使用空闲的容量空间，但是一旦append进来的元素个数超过了原来指定容量值的时候，内存管理器就是重新开辟一个更大的内存空间，用于存储多出来的元素，并且会将原来的元素复制一份，放到这块新开辟的内存空间。是由append的实现机制导致的，是添加slice是尾部**

下边的代码很好的解释了slice的处理机制
```go
s := []int{1, 2, 3, 4, 5}
fmt.Printf("s len - %v, cap - %v, pointer -  %p, val - %v\n", len(s), cap(s), s, s)

s1 := s[1:3] //左闭右开
fmt.Printf("before append s1 len - %v cap - %v pointer - %p val - %v\n", len(s1), cap(s1), s1, s1)

//未超出容量
s1 = append(s1, 10, 11)
fmt.Printf("afert append s1 len - %v cap - %v pointer - %p val - %v\n", len(s1), cap(s1), s1, s1)

//超出容量
s1 = append(s1, 12, 13, 14)
fmt.Printf("afert append s1 len - %v cap - %v pointer - %p val - %v\n", len(s1), cap(s1), s1, s1)

// output 
s len - 5, cap - 5, pointer -  0xc820014120, val - [1 2 3 4 5]
before append s1 len - 2 cap - 4 pointer - 0xc820014128 val - [2 3]
afert 1 append s1 len - 4 cap - 4 pointer - 0xc820014128 val - [2 3 10 11]
afert 2 append s1 len - 7 cap - 8 pointer - 0xc820010280 val - [2 3 10 11 12 13 14]

```

看到这里，我们看一下开篇的代码输入的是什么？
**答案**
```
func slice=[1 -1 -2 -3 -1 -2 -3]
func slice1=[1 -1 -2 -3 -4 2 3 4]
```

接下来看一下slice内部结构是什么样子的。

### 内部结构

一个`slice`结构是一个指向数组的指针，一个长度（len）和容量（cap）字段
![slice struct](/img/posts/go-array-slices-internals_slice-struct.png)

创建 `s := make([]byte, 5)`， 结构是这样的:
![slice struct](/img/posts/go-array-slices-internals_slice-1.png)

使用切片`s = s[2:4]`， 结构是这样的:
![slice struct](/img/posts/go-array-slices-internals_slice-2.png)
Slicing不会复制数据。只是创建了一个新的切片值，指向原始数组。新切片的操作对原始数组有效。也就是说修改了切片的值，同样修改了之前的数组的值(英文水平有限:P)，上例子:
```go
fmt.Println("修改前")
sl := []int{1, 2, 3, 4}
fmt.Println("sl: ", sl)
sl1 := sl[1:3]
fmt.Println("sl1: ", sl1)
sl1[1] = 10
fmt.Println("修改后")
fmt.Println("sl: ", sl)
fmt.Println("sl1: ", sl1)

//output
修改前
sl:  [1 2 3 4]
sl1:  [2 3]
修改后
sl:  [1 2 10 4]
sl1:  [2 10]
```

### 总结

1. slice是可变长的, **当没有超过容量时，指针不变，当超过容量时，重新分配一块内存，并把数据copy过来，指针改变**
2. slice是一个指针而不是值
3. The zero value of a slice is nil. The len and cap functions will both return 0 for a nil slice.
4. 长度不能超容量，否则会runtime panic。

## array vs slice
最后这个性能对比，我只是想告诉读者，有的时候，array是有性能优势的。在编码的时候，是使用array还是slice根据当时需求去做一下权衡，仅此而已。老习惯上代码：
```
package main

import (
    "testing"
)

const capacity = 1024

func array_init()[capacity]int{
    var a [capacity]int
    for i := 0; i < len(a); i++{
        a[i] = 1
    }
    return a
}

func slice_init() []int{
    sl := make([]int, capacity)
    for i := 0; i < len(sl); i++{
        sl[i] = 1
    }
    return sl
}

func BenchmarkArray(b *testing.B){
    for i := 0; i < b.N; i++{
        _ = array_init()
    }
}

func BenchmarkSlice(b *testing.B){
    for i := 0; i < b.N; i++{
        _ = slice_init()
    }
}
```
运行测试:
```
$ go test -v -bench . -benchmem
testing: warning: no tests to run
PASS
BenchmarkArray-4         1000000              1686 ns/op               0 B/op          0 allocs/op
BenchmarkSlice-4          500000              2341 ns/op            8192 B/op          1 allocs/op
```
看到运行结果，array 不但拥有更好的性能，还避免了堆内存分配，也就是说减轻了 GC 压力。为什么会这样？
以下摘自`雨痕学堂`公众号的分享，结尾出有链接。
>函数 array_init 返回值的复制只需用 "CX + REP" 指令就可完成。整个 array_init 函数完全在栈上完成，而 slice_init 函数则需执行 makeslice，继而在堆上分配内存，这就是问题所在。对于一些短小的对象，复制成本远小于在堆上分配和回收操作。

## 参考资料
* Go Blog [Go Slices: usage and internals](https://blog.golang.org/go-slices-usage-and-internals)
* Effective Go [Arrays](https://golang.org/doc/effective_go.html#arrays) [Slices](https://golang.org/doc/effective_go.html#slices)
* Go Specification [Array_types](https://golang.org/ref/spec#Array_types) [Slice_types](https://golang.org/ref/spec#Slice_types)
* 雨痕学堂 [Go 性能优化技巧 2/10](http://mp.weixin.qq.com/s?__biz=MzI4ODI2NzkzNg==&mid=2247483654&idx=1&sn=e77f5432634470fcd9ee74bcbd37bf3e&scene=4#wechat_redirect)




 