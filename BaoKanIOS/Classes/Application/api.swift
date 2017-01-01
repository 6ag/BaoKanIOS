//
//  api.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/19.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import Foundation

/// 基础url
let BASE_URL = "http://www.baokan.tv/"

// 接口路径
let API_URL = "\(BASE_URL)e/bpi/"

/// 分类
let GET_CLASS = "\(API_URL)getNewsClass.php"

/// 文章列表
let ARTICLE_LIST = "\(API_URL)getNewsList.php"

/// 文章详情
let ARTICLE_DETAIL = "\(API_URL)getNewsContent.php"

/// 获取评论信息
let GET_COMMENT = "\(API_URL)getNewsComment.php"

/// 提交评论
let SUBMIT_COMMENT = "\(API_URL)subPlPost.php"

/// 顶贴踩贴
let TOP_DOWN = "\(API_URL)DoForPl.php"

/// 注册
let REGISTER = "\(API_URL)Register.php"

/// 登录
let LOGIN = "\(API_URL)loginReq.php"

/// 获取用户信息
let GET_USERINFO = "\(API_URL)checkLoginStamp.php"

/// 获取用户收藏夹
let GET_USER_FAVA = "\(API_URL)getUserFava.php"

/// 删除好友、收藏夹
let DEL_ACTIONS = "\(API_URL)dellActions.php"

/// 增加删除收藏
let ADD_DEL_FAVA = "\(API_URL)addFava.php"

/// 修改账号资料/找回密码
let MODIFY_ACCOUNT_INFO = "\(API_URL)publicActions.php"

/// 获取用户评论列表
let GET_USER_COMMENT = "\(API_URL)getUserComment.php"

/// 搜索
let SEARCH = "\(API_URL)search.php"

/// 搜索关键词列表
let SEARCH_KEY_LIST = "\(API_URL)searchKeyboard.php"

/// 更新搜索关键词列表的开关
let UPDATE_SEARCH_KEY_LIST = "\(API_URL)updateKeyboard.php"

