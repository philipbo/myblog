---
title: Go语言的defer那点事
date: 2016-07-21T13:50:22+08:00
draft: false
tags: ["Golang"]
categories: ["Golang"]

autoCollapseToc: true

---

Go语言的`defer`语句提供了强大的机制，通常用于简化执行各种清理操作，释放锁等操作，例如能够保证打开的文件，肯定被关闭，那你真的理解`defer`了吗？

我们先看下边一段代码。先自己在心里运行一遍结果，然后在去验证。如果都对了，恭喜你不用看了，该干嘛干嘛去吧，不要浪费时间。

<!--more-->

```go
package main
import "log"

func main() {
    log.Printf("f %v", f())
    log.Printf("f1 %v", f1())
    log.Printf("f2 %v", f2())
    log.Printf("f3 %v", f3())
    log.Printf("f4 %v", f4())
    log.Printf("f5 %v", f5())
}

func f() (i int) {
    defer func() {
        i++
    }()

    return 0
}

func f1() int {
    i := 0
    defer func() {
        i++
    }()

    return i
}

func f2() int {
    i := 5
    defer func() {
        i = i + 5
    }()

    return i
}

func f3() (i int) {
    i = 5
    defer func() {
        i = i + 5
    }()

    return i
}

func f4() (i int) {
    t := 5
    defer func() {
        t = t + 5
    }()
    return t
}

func f5() (i int) {
    defer func(i int) {
        i = i + 5
    }(i)

    return 1
}
```
答案在结尾处，着急验证的直接翻到底就看到了：）


## defer 的规则

《官方文档》[^fn:1]中有明确的说明。
以下是我个人的理解，英文水平有限。
1. `defer` 语句push 到一个list中，这个list是后进先出(LIFO)
2. `defer` 语句是在 return 前执行
3. `defer` 语句在执行时，函数值和参数是及时评估（确定）
    例如:
    ```go
    func f6() int {
        i := 0
        defer log.Printf("in defer i %d", i) //output 0
        i++
        return i
    }
    ```
4. 在一个有命名返回值的`function`中，定义了内嵌的`defer function`，这个`defer function` 在 父`function` 返回前，可以访问并且修改命名返回值。比如上边的f(),f3()。而`defer function`中有返回值的话，会被丢弃。
5. `defer` 语句配合 `panic` 和 `recover` 使用。

在《Defer, Panic, and Recover》[^fn:2]的Blog中，也给出了几个简单规则。
1. A deferred function's arguments are evaluated when the defer statement is evaluated.
2. Deferred function calls are executed in Last In First Out order after the surrounding function returns.
3. Deferred functions may read and assign to the returning function's named return values.

在了解`defer`的规则之后，接下来看看`defer`实现机制。

## defer 实现机制

以下引用《Go语言的defer，你真的懂了吗？》文章[^fn:3]
>大致就是在defer出现的地方，插入指令CALL runtime.deferproc，然后在函数返回之前的地方，插入指令CALL runtime.deferreturn。再就是明确go返回值的方式跟C是不一样的，为了支持多值返回，go是用栈返回值的，而C是用寄存器。

**最最重要的一点就是：**
**return xxx这一条语句并不是一条原子指令!**

>整个return过程，没有defer之前，先在栈中写一个值，这个值会被当作返回值，然后再调用RET指令返回。return xxx语句汇编后是先给返回值赋值，再做一个空的return，( 赋值指令 ＋ RET指令)。defer的执行是被插入到return指令之前的，有了defer之后，就变成了(赋值指令 + CALL defer指令 + RET指令)。而在CALL defer函数中，有可能将最终的返回值改写了...也有可能没改写。总之，如果改写了，那么看上去就像defer是在return xxx之后执行的。

以上就是`defer`的基本知识，了解了这些，就在也不迷糊了。

**这里有一个简单的转换规则，改写规则是将return语句分开成两句写，return xxx会被改写成:**
```
返回值 = xxx
调用defer函数
空的return
```
来两个例子，还记得上边的代码f()和f2()吗?
f()可以改写成这样:
```go
func f() (i int) {
    i = 0 //return语句不是一条原子调用，return xxx其实是赋值＋RET指令
    func() {
        i++ //defer被插入到return之前执行，也就是赋返回值和RET指令之间
    }
    return 
}
```
输出 f() = 1

f2() 改成这样:
```
func f2() int {
    i := 5
    result = 5 //返回值赋值
    func() {
        i = i + 5
    }
    return 
}
```
输出 f2() = 5

这回小伙伴们应该对`defer`有了更深的了解了吧。

## 答案

```
$ go run main.go 
f 1
f1 0
f2 5
f3 10
f4 5
f5 1
```

## 最后

`defer` 强大的机制给gopher带来方便，但也是性能杀手，追求极致性能时，慎用之。

[^fn:1]: <https://golang.org/ref/spec#Defer_statements/>
[^fn:2]: <https://blog.golang.org/defer-panic-and-recover/>
[^fn:3]: <http://www.zenlife.tk/golang-defer.md/>



