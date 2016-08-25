//
//  DBManager.h
//  LSYReader
//
//  Created by HD on 16/8/10.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BookModel;

@interface DBManager : NSObject
//初始化数据库
+ (BOOL)initClientDB;

// 向数据库插入一条新新的收藏数据
+ (BOOL)insertBookToDB:(BookModel *)model;

//判断该条是否被收藏
+ (BOOL)isBookDown:(NSString *)bookid;
//删除数据，根据bookID
+ (BOOL)deleteBookFromDB:(NSString *)bookid;
//获取数据库并封装成modelarray
+ (NSArray *)fetchAllBook;
+(BookModel*)fetchBookByID:(NSString*)bookid;
@end
