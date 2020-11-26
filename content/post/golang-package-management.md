---
title: Golang的包管理实践
date: 2016-06-17T17:41:57+08:00
draft: false
tags: ["Golang"]
categories: ["Golang"]
---

## Golang包管理带来的问题

Golang包管理，在团队成员比较少的情况下，Golang自带的包管理工具 `go get` 足已满足使用，但是由于服务端团队在急速扩张，同学越来越多，对于Golang包管理就会带来以下问题：

> 1. 所有项目共同使用GOPATH中的第三方库, 缺乏明确显示的版本。团队开发容易导入不一样的版本。
> 2. 第三方包没有内容安全审计，很容易引入代码 Bug
> 3. 每位同学都需要 `go get` 所有包。
> 4. 如果换台电脑，又需要重新`go get`下载。 

**解决办法就是使用包管理工具，让项目引用的第三方库，列入到项目里面，进行版本管理，即可解决。**

<!--more-->

## 官方对包管理依赖的建议

* 当使用开源类库时，尽量的少用第三方库，学会使用标准库。发布的类库，也请使用版本服务，类如gopkg.in来管理版本。
*  对于包管理，使用[官方推荐](https://github.com/golang/go/wiki/PackageManagementTools)的工具来管理。

由于官方对于包管理暂时没有明确的指导意见，所以，作为社区驱动的一门语言，不缺乏各路优秀开发者推出的自己的最佳实践工具。请参考官方推荐 [[PackageManagementTools]](https://github.com/golang/go/wiki/PackageManagementTools)

## 包管理工具实践

笔者只对以下几个包管理工具进行了实践，找到满足自己需求的那款。

测试环境:
**go version go1.6.2 darwin/amd64**
**main.go**
```go
package main

import "github.com/gin-gonic/gin"

func main() {
  r := gin.Default()
  r.GET("/ping", func(c *gin.Context) {
    c.JSON(200, gin.H{
      "message": "pong",
    })
  })
  r.Run() // listen and server on 0.0.0.0:8080
}

```

### godep

1. **详情请查看 [官方文档](https://github.com/tools/godep)**

2. **安装**

    ```bash
    $ go get -u github.com/tools/godep
    
    $ godep help
    Godep is a tool for managing Go package dependencies.
    
    Usage:
    
      godep command [arguments]
    
    The commands are:
    
        save     list and copy dependencies into Godeps
        go       run the go tool with saved dependencies
        get      download and install packages with specified dependencies
        path     print GOPATH for dependency code
        restore  check out listed dependency versions in GOPATH
        update   update selected packages or the go version
        diff     shows the diff between current and previously saved set of dependencies
        version  show version info
    
    Use "godep help [command]" for more information about a command.
    ```
3. **用法**

    ```
    # add package
    $ go get -u <package name> #视具体情况而定
    $ godep save
    
    $ tree -d
    .
    ├── Godeps
    └── vendor
        ├── github.com
        │   ├── gin-gonic
        │   │   └── gin
        │   │       ├── binding
        │   │       └── render
        │   ├── golang
        │   │   └── protobuf
        │   │       └── proto
        │   └── manucorporat
        │       └── sse
        ├── golang.org
        │   └── x
        │       └── net
        │           └── context
        └── gopkg.in
            └── go-playground
                └── validator.v8
    
    # update package
    $ go get -u <package name>
    $ godep update <package name>
    
    ```

    生成Godeps/Godeps.json文件, 不要修改。
    ```
    {
      "ImportPath": "me.com/testpkg",
      "GoVersion": "go1.6",
      "GodepVersion": "v74",
      "Deps": [
        {
          "ImportPath": "github.com/gin-gonic/gin",
          "Comment": "v1.0rc1-219-g3d002e3",
          "Rev": "3d002e382355cafc15d706b92899b1961d5b79e9"
        },
        {
          "ImportPath": "github.com/gin-gonic/gin/binding",
          "Comment": "v1.0rc1-219-g3d002e3",
          "Rev": "3d002e382355cafc15d706b92899b1961d5b79e9"
        },
        ......
      ]
    }
    ```

    执行 `go restore`时，会按照Godeps/Godeps.json内列表，依次执行go get -d -v 来下载对应依赖包到GOPATH路径下。

4. **总结**

    - `godep save` 前提所有依赖包已使用`go get`安装到GOPATH下，依赖包必须使用了某个代码管理工具（git等）,这是因为godep需要记录revision。
    - 只是对依赖包的一个copy, 把依赖包从GOPATH复制到项目中。
    - godep 是在go tool上包装了个壳，在使用`go build`等命令时，请使用`godep go build`等，在go前面加上godep。

### gvt
 
1. **详情请查看 [官方文档](https://github.com/FiloSottile/gvt)**

2. **安装**
    ```bash
    $ go get -u github.com/FiloSottile/gvt
    
    # 安装完成后，运行`gvt help`，如下安装成功
    $ gvt help
    gvt, a simple go vendoring tool based on gb-vendor.
    
    Usage:
            gvt command [arguments]
    
    The commands are:
    
            fetch       fetch a remote dependency
            restore     restore dependencies from manifest
            update      update a local dependency
            list        list dependencies one per line
            delete      delete a local dependency
    
    Use "gvt help [command]" for more information about a command.
    
    ```

3. **用法**
    
    在想使用`go get`时，使用`gvt fetch`代替
    ```bash
    $ gvt fetch github.com/gin-gonic/gin
    2016/06/17 18:42:25 Fetching: github.com/gin-gonic/gin
    2016/06/17 18:42:33 · Fetching recursive dependency: golang.org/x/net/context
    ....
    
    
    $ tree -d
    .
    └── vendor
        ├── github.com
        │   ├── dustin
        │   │   └── go-broadcast
        │   ├── gin-gonic
        │   │   └── gin
        │   │       ├── binding
        │   │       │   └── example
        │   │       ├── examples
        │   │       │   ├── app-engine
        │   │       │   ├── basic
        │   │       │   ├── realtime-advanced
        │   │       │   └── realtime-chat
        │   │       ├── ginS
        │   │       └── render
        │   ├── golang
        │   │   └── protobuf
        │   │       ├── proto
        │   │       │   └── proto3_proto
        │   │       └── ptypes
        │   │           └── any
    ```
    **manifest文件**
    `gvt restore` 以此manifest为准,下面部分源码：
    ```
    {
        "version": 0,
        "dependencies": [
            {
                "importpath": "github.com/dustin/go-broadcast",
                "repository": "https://github.com/dustin/go-broadcast",
                "vcs": "git",
                "revision": "3bdf6d4a7164a50bc19d5f230e2981d87d2584f1",
                "branch": "master",
                "notests": true
            },
            {
                "importpath": "github.com/gin-gonic/gin",
                "repository": "https://github.com/gin-gonic/gin",
                "vcs": "git",
                "revision": "f931d1ea80ae95a6fc739213cdd9399bd2967fb6",
                "branch": "develop",
                "notests": true
            },
            ....
        ]    
    }
    ```
   
4. **总结**

    - 在想使用`go get`时，使用`gvt fetch`代替，使用其他`go tools`命令与以前是一样的，如：`go fmt`、`go build`、`go run`等等。
    - `gvt fetch` 可以获取特定的提交或分支，并且可以是私有的镜像。
    - 不需要改变你创建项目的方式。
    - 不需要手动添加，复制，清理依赖。

### glide

1. **详情请查看 [官方文档](https://github.com/Masterminds/glide)**

2. **安装**

    [查看文档](https://github.com/Masterminds/glide#install)

3. **用法**

    ```
    $ glide create
    [INFO] Generating a YAML configuration file and guessing the dependencies
    [INFO] Attempting to import from other package managers (use --skip-import to skip)
    [INFO] Found reference to github.com/gin-gonic/gin
    
    $ glide install
    [INFO] Lock file (glide.lock) does not exist. Performing update.
    [INFO] Downloading dependencies. Please wait...
    [INFO] Fetching updates for github.com/gin-gonic/gin.
    [INFO] Resolving imports
    [INFO] Found Godeps.json file in vendor/github.com/gin-gonic/gin
    [INFO] Fetching github.com/manucorporat/sse into /Users/zbo/go/src/me.com/testpkg/vendor
    ........
    [INFO] Project relies on 6 dependencies.
    
    ```
    glide.yaml  [详细说明](http://glide.readthedocs.io/en/latest/glide.yaml/)
    ```
    package: me.com/testpkg
    import:
    - package: github.com/gin-gonic/gin
    
    ```
    
    glide.lock 
    ```
    hash: 7772f906f51de7fa50761d0ed254e12e83429979a6621bef4fb164b9051df88d
    updated: 2016-06-20T11:42:35.002094371+08:00
    imports:
    - name: github.com/gin-gonic/gin
      version: f931d1ea80ae95a6fc739213cdd9399bd2967fb6
      subpackages:
      - binding
      - render
    - name: github.com/golang/protobuf
      version: 2402d76f3d41f928c7902a765dfc872356dd3aad
      subpackages:
      - proto
    - name: github.com/manucorporat/sse
      version: ee05b128a739a0fb76c7ebd3ae4810c1de808d6d
    - name: golang.org/x/net
      version: f315505cf3349909cdf013ea56690da34e96a451
      subpackages:
      - context
    - name: gopkg.in/go-playground/validator.v8
      version: c193cecd124b5cc722d7ee5538e945bdb3348435
    - name: gopkg.in/yaml.v2
      version: a83829b6f1293c91addabc89d0571c246397bbf4
    devImports: []
    ```

4. **总结**

    - 简单方便，查看glide.yaml，一目了然项目中的所有依赖。
    - 可以从其他第三方工具的配置文件中导入，如：godep,gom,gpm等。
    - 可以指定第三包的版本，commit, repo等。支持vcs。如: git, hg, svn等。
    - 可以在所有go tools上工作。
    
5. **注意**
    测试时的版本是0.10.2, glide rm -d <package name>时，glide.yaml、glide.lock中对应的包都删除了，但是在vendor文件夹下的包没有删除。

### gom

1. **详情请查看 [官方文档](https://github.com/mattn/gom)**

2. **安装**
    ```
    $ go get github.com/mattn/gom
    
    # 安装成功
    $ gom help
    Usage of gom:
     Tasks:
       gom build   [options]   : Build with _vendor packages
       gom install [options]   : Install bundled packages into _vendor directory, by default.
                                  GOM_VENDOR_NAME=. gom install [options], for regular src folder.
       gom test    [options]   : Run tests with bundles
       gom run     [options]   : Run go file with bundles
       gom doc     [options]   : Run godoc for bundles
       gom exec    [arguments] : Execute command with bundle environment
       gom tool    [options]   : Run go tool with bundles
       gom env     [arguments] : Run go env
       gom fmt     [arguments] : Run go fmt
       gom list    [arguments] : Run go list
       gom vet     [arguments] : Run go vet
       gom update              : Update all dependencies (Experiment)
       gom gen travis-yml      : Generate .travis.yml which uses "gom test"
       gom gen gomfile         : Scan packages from current directory as root
                                  recursively, and generate Gomfile
       gom lock                : Generate Gomfile.lock
    
    ```

3. **用法**

    ```
    $ gom gen gomfile
    
    $ cat Gomfile
    gom 'github.com/gin-gonic/gin', :commit => '3d002e382355cafc15d706b92899b1961d5b79e9'
    gom 'github.com/golang/protobuf', :commit => '9e6977f30c91c78396e719e164e57f9287fff42c'
    gom 'github.com/manucorporat/sse', :commit => 'ee05b128a739a0fb76c7ebd3ae4810c1de808d6d'
    gom 'golang.org/x/net', :commit => 'e7da8edaa52631091740908acaf2c2d4c9b3ce90'
    gom 'gopkg.in/go-playground/validator.v8', :commit => '014792cf3e266caff1e916876be12282b33059e0'
    
    $ gom install
    downloading github.com/gin-gonic/gin
    downloading github.com/golang/protobuf
    downloading github.com/manucorporat/sse
    downloading golang.org/x/net
    downloading gopkg.in/go-playground/validator.v8
    ```

    `gom install`完成后，生成vendor目录，把第三方包放到此目录下。

4. **总结**
    - gom 是在go tools上包装的壳，允许指定commit, branch, tag。
    - gom 可以从不同的组group，安装第三方包。
    - 大部分go tools上的命令都需要使用gom。如: `gom run`、 `gom build`等。

## 总结

以上几个工具，都可以实现第三方包纳入项目的版本管理中，各有自己的特点。

1. godep 是把第三方包从GOPAHT中copy到项目中，生成vendor目录和配置文件，不需要重新下载，更新时，需要先更新GOPATH的第三方包，然后在使用`godep update`进行更新。
2. gvt 是必须使用 `gvt fetch` 重新安装一次。允许指定commit 或 branch 或 private repos。
3. glide 允许指定commit, version等，支持vcs,如git,svn等。可以从第三方工具库导入，如godep,gpm等。可以go tools上工作。但是每次`glide get` 都会检查已存的包，这个可以指定flag。
4. gom， 使用`gom install`重新安装一次 可以指group安装第三包，允许指定commit,branch, tag.

**最后**

按照笔者的需求，只是把项目中的第三方包列入项目管理中，
没有其他额外的需求。所以笔者选择是godep, 只要GOPATH安装，
要做的事只copy到项目vendor下即可, 使用简单，作者更新频繁，
当有其他需求时，在更新到glide上也不迟。
如果有其他同学的需求有必须使用国内镜像
（像大公司开发的类库、不开源）、指定commit、version等需求，可以选择glide、gvt。


**参考资料**
1. [Golang的包管理之道](http://www.infoq.com/cn/articles/golang-package-management)
2. [Go 语言的包依赖管理](https://io-meter.com/2014/07/30/go%27s-package-management/)



