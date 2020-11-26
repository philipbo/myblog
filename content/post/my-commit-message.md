---
title: "我的Git提交信息规范"
date: 2016-06-28T14:41:49+08:00
draft: false
tags: ["Git"]
categories: ["Git", "搬砖"]

autoCollapseToc: true

---

Git 每次提交代码，都要写 commit message（提交说明，写啥都可以），否则就不允许提交。
但是对commit message的提交信息格式一直是个头疼的问题。在协作人数比较少的情况尊守口头规范还可以，在协作人数比较多的情况，如果没有规范，就是个头疼的问题，比如在作code review时，没办法很快的找到相关的commit.

最近看了一些关提交规范的文章，特别是阮一峰老师的`Commit message 和 Change log 编写指南`文章，才有了更清晰的认识。commit message 应该清晰明了，说明本次提交的目的。

**格式化的提交信息有诸多好处，整理一套自己用的提交信息格式，并在团队中试运行一段时间，感觉还不错，这是有这篇文章的原因。**

<!--more-->

## Commit message 的作用

格式化的Commit message，有几个好处：
* 提供更多的历史信息，方便快速浏览。
* 可以过滤某些commit（比如文档、构建），便于快速查找信息。
* 可以直接从commit生成Change log。

## Commit message 的格式

**提交信息包括三个部分：Header，Body 和 Footer。**
```
<Header>
//空一行
<Body>
//空一行
<Footer>
```
**其中，Header 是必需的，Body 和 Footer 可以省略**
不管是哪一个部分，任何一行尽量不要超过72个字符（或100个字符）。

### Header

格式：`<type>(<scope>): <subject>`
只有一行，包括三个字段：type（必需）、scope（可选）和subject（必需）。

#### type

`typt` 用于说明 commit 的类别，只允许使用下面7个标识。

* feat：新功能（feature）
* fix：修补bug
* docs：文档（documentation）
* style： 格式（不影响代码运行的变动）
* refactor：重构（即不是新增功能，也不是修改bug的代码变动）
* test：增加测试
* chore：构建过程或辅助工具的变动

#### scope

`scope`用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同。

#### subject

`subject`是 commit 目的的简短描述，尽量不超过50个字符。

要求:
* 以动词开头，使用第一人称现在时，比如change，而不是changed或changes
* 第一个字母小写
* 结尾不加句号（.）

### Body

`Body` 部分是对本次 commit 的详细描述，可以分成多行。下面是一个范例。

```
More detailed explanatory text, if necessary.  Wrap it to 
about 72 characters or so. 

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Use a hanging indent
```

有两个注意点。
（1）使用第一人称现在时，比如使用change而不是changed或changes。
（2）应该说明代码变动的动机，以及与以前行为的对比。

### Footer

`Footer` 部分只用于两种情况：
* 关闭 Issue
* 关联 Issue

#### 关闭 Issue

如果当前提交信息解决了某个issue，那么可以在 Footer 部分关闭这个 issue，关闭的格式如下：
```
Close #1, #2, #3
```

#### 关联 Issue

本次提交如果和摸个issue有关系则需要写上这个，格式如下：
```
Issue #1, #2, #3
```

### Revert

还有一种特殊情况（笔者很少用，项目比较小），如果当前 commit 用于撤销以前的 commit，则必须以revert:开头，后面跟着被撤销 Commit 的 Header。

`Body` 部分的格式是固定的，必须写成This reverts commit hash，其中的hash是被撤销 commit 的 SHA 标识符。

## 例子

```
 feat: 增加用户渠道来源和APP来源
    
    - 用户正常注册
    - 微信用户注册
    - 其他第三方引流

 chore: auto build versioning

```

## 总结

这些基本规范足够自己和团队使用了，以后会根据自己或者团队的需要在进行扩展。

### 写在最后
 
 目前，社区有多种 Commit message 的[写法规范](https://github.com/conventional-changelog/conventional-changelog)。[Angular 规范](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#heading=h.greljkmo14y0)，这是目前使用最广的写法，比较合理和系统化，并且有配套的工具。有兴趣的朋友可以自己去查看。

### 参考
* 阮一峰 [[Commit message 和 Change log 编写指南]](http://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html)
* 颜海镜 [[我的提交信息规范]](http://yanhaijing.com/git/2016/02/17/my-commit-message/)