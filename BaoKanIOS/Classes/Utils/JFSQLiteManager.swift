//
//  JFSQLiteManager.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import FMDB

let NEWS_LIST_HOME_TOP = "jf_newslist_hometop"     // 首页 列表页 的 幻灯片 数据表
let NEWS_LIST_HOME_LIST = "jf_newslist_homelist"   // 首页 列表页 的 列表 数据表
let NEWS_LIST_OTHER_TOP = "jf_newslist_othertop"   // 其他分类 列表页 的 幻灯片 数据表
let NEWS_LIST_OTHER_LIST = "jf_newslist_otherlist" // 其他分类 列表页 的 列表 数据表
let NEWS_CONTENT = "jf_news_content"               // 资讯/图库 正文 数据表
let SEARCH_KEYBOARD = "jf_search_keyboard"         // 搜索关键词数据表

class JFSQLiteManager: NSObject {
    
    /// FMDB单例
    static let shareManager = JFSQLiteManager()
    
    /// sqlite数据库名
    fileprivate let newsDBName = "news.db"
    
    let dbQueue: FMDatabaseQueue
    
    override init() {
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        let dbPath = "\(documentPath)/\(newsDBName)"
        print(dbPath)
        
        // 根据路径创建并打开数据库，开启一个串行队列
        dbQueue = FMDatabaseQueue(path: dbPath)
        super.init()
        
        // 创建数据表
        createNewsListTable(NEWS_LIST_HOME_TOP)
        createNewsListTable(NEWS_LIST_HOME_LIST)
        createNewsListTable(NEWS_LIST_OTHER_TOP)
        createNewsListTable(NEWS_LIST_OTHER_LIST)
        createNewsContentTable()
        createSearchKeyboardTable()
    }
    
    /**
     创建新闻列表的数据表
     
     - parameter tbname: 表名
     */
    fileprivate func createNewsListTable(_ tbname: String) {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(tbname) ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
            "classid INTEGER, \n" +
            "news TEXT, \n" +
            "createTime VARCHAR(30) DEFAULT (datetime('now', 'localtime')) \n" +
        ");"
        
        dbQueue.inDatabase { (db) in
            if (db?.executeStatements(sql))! {
                print("创建 \(tbname) 表成功")
            } else {
                print("创建 \(tbname) 表失败")
            }
        }
    }
    
    /**
     创建资讯内容数据表
     */
    fileprivate func createNewsContentTable() {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(NEWS_CONTENT) ( \n" +
            "id INTEGER, \n" +
            "classid INTEGER, \n" +
            "news TEXT, \n" +
            "createTime VARCHAR(30) DEFAULT (datetime('now', 'localtime')) \n" +
        ");"
        
        dbQueue.inDatabase { (db) in
            if (db?.executeStatements(sql))! {
                print("创建 \(NEWS_CONTENT) 表成功")
            } else {
                print("创建 \(NEWS_CONTENT) 表失败")
            }
        }
    }
    
    /**
     创建搜索关键词数据表
     */
    fileprivate func createSearchKeyboardTable() {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(SEARCH_KEYBOARD) ( \n" +
            "id INTEGER, \n" +
            "keyboard VARCHAR(30), \n" +
            "pinyin VARCHAR(30), \n" +
            "num INTEGER, \n" +
            "createTime VARCHAR(30) DEFAULT (datetime('now', 'localtime')) \n" +
        ");"
        
        dbQueue.inDatabase { (db) in
            if (db?.executeStatements(sql))! {
                print("创建 \(SEARCH_KEYBOARD) 表成功")
            } else {
                print("创建 \(SEARCH_KEYBOARD) 表失败")
            }
        }
    }
}
