# BaoKanIOS

## 项目介绍

这个一款使用Swift3.0编写的资讯新闻类app，数据来自 [爆侃网文](http://www.baokan.name) 。

项目首页使用使用网易首页选项卡方式切换控制器，文章详情使用 `UIWebView` 展示文章内容，并使用js与原始iOS交互，展示图片轮播。尝试过 `WKWebView` ，但是不能读取本地的缓存图片，不过内存占用会减少很多，如果不需要做缓存，或者用原生 `UIImageView` 覆盖 `img` 标签内容也能使用更好的 `WKWebView` 。

图库详情使用传统新闻客户端的图片浏览器，可以隐藏/显示UI，缩放图片，保存图片，多种手势操作。

集成推送、第三方分享、第三方登录等SDK，项目代码注释清晰，适合swift新手参考。

## AppStore

<a target='_blank' href='https://itunes.apple.com/app/id1115587250'>
<img src='http://ww2.sinaimg.cn/large/0060lm7Tgw1f1hgrs1ebwj308102q0sp.jpg' width='144' height='49' />
</a>

## 相关链接

+ [BaoKanAndroid 本项目Android端](https://github.com/6ag/BaoKanAndroid)
+ [使用NSKeyedArchiver缓存app用户账号数据](https://blog.6ag.cn/1545.html)
+ [使用SQLite缓存数据分析与实现](https://blog.6ag.cn/1551.html)
+ [网易新闻app内容页实现分析与代码实现 完成图片缓存和交互](https://blog.6ag.cn/1514.html)

## 使用介绍

**开发环境：** *Xcode8.1* + *Swift3.0* ，如果编译失败，请检查环境是否满足。
   
**特别注意：** clone工程后，首先需要自己使用 `cocoapods` 更新第三方库，并且需要手动修改图片加载第三方库中 `Pods/YYCache/YYDiskCache.m` 第171行代码，这是设置磁盘缓存文件的最小尺寸，如果设置为20kb，新闻正文的小图将不能缓存到磁盘。

```objc
// 原来的
return [self initWithPath:path inlineThreshold:1024 * 20];

// 修改后的
return [self initWithPath:path inlineThreshold:0];
```

## 项目结构

![image](https://github.com/6ag/BaoKanIOS/blob/master/project.png)

## 各种截图

### 网文资讯

![image](https://github.com/6ag/BaoKanIOS/blob/master/1.gif)

### 栏目定制

![image](https://github.com/6ag/BaoKanIOS/blob/master/2.gif)

### 网文图库

![image](https://github.com/6ag/BaoKanIOS/blob/master/3.gif)

### 个人中心

![image](https://github.com/6ag/BaoKanIOS/blob/master/4.gif)

## 许可

[MIT](https://raw.githubusercontent.com/6ag/BaoKanIOS/master/LICENSE) © [六阿哥](https://github.com/6ag)

