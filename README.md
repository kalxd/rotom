# rotom-hs

不知道能干什么的服务。

# 安装

stack一把梭。目前来看`lts-13.29`兼容性最好，windows和debian上都没问题。

```bash
$ stack build
```

# 数据库

准备好postgresql数据库，导入表结构：

```bash
$ psql -d <你的数据库> < config/rotom.sql
```

# 填写配置

程序会加载`config/config.dhall`，各人配置都不一样，所以需要都要自己创建、自己填写。一般有两种方式快速写配置。

## 复制大法

`config/def.dhall`提供了全部配置，从此复制一份为`config/config.dhall`，从中更改对应项即可。

## import大法

dhall支持导入他人文件，所以我们可以导入`config/def.dhall`并修改默认值。

```dhall
let def = ./def.dhall

in    def
    ⫽ { appPort = 7000
      , appDB =
            def.appDB
          ⫽ { dbUser = "我的用户名"
            , dbPassword = "我的密码"
            , dbAddr = "192.168.1.1"
            , dbName = "我的数据库"
            }
      }

```

由于`stack lts`较低，不支持dhall的`with`语法，对应深层、多层次修改只能按照上述方式。

# 运行

build成功后会生成两个可执行文件。

## 查看API布局

```bash
$ stack exec rotom-layout

/
├─ 分组/
│  ├─ 列表/
│  │  └─•
│  ├─ 创建/
│  │  └─•
│  ┆
│  └─ <capture>/
│     ├─ 全部清除/
│     │  └─•
│     ├─ 更新/
│     │  └─•
│     ├─ 表情列表/
│     │  └─•
│     └─•
└─ 表情/
   ├─ 创建/
   │  └─•
   ┆
   └─ <capture>/
      ├─ 删除/
      │  └─•
      └─ 更新/
         └─•
```

## 运行网络服务

```bash
$ stack exec rotom-server
```

启动后没有任何提示。
