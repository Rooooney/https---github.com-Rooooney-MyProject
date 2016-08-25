//
//  DBManager.m
//  LSYReader
//
//  Created by HD on 16/8/10.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "DBManager.h"
#import "BookModel.h"
#import "FMDB.h"

#define kPath_FMDB [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/BOOK.sqlite"]
static NSString *kBookTable = @"BOOKTABLE";

@interface DBManager ()
@property(nonatomic,strong) FMDatabaseQueue *queue;
@end

@implementation DBManager

-(FMDatabaseQueue *)queue
{
    if (!_queue) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];
    }
    return _queue;
}

+ (NSString *)SQL:(NSString *)sql inTable:(NSString *)tableName{
    return [NSString stringWithFormat:sql,tableName];
}


+ (BOOL)initClientDB
{
    __block BOOL result = NO;

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        
        NSString *sql = [DBManager SQL:@"CREATE TABLE IF NOT EXISTS %@ (bookid INTEGER,bookname TEXT,author TEXT,size TEXT,type INTEGER)" inTable:kBookTable];
        
        result = [db executeUpdate:sql];

        
    }];
    
    return result;

}

+ (BOOL)insertBookToDB:(BookModel *)model
{
    __block BOOL result = NO;

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];

    NSString *sql= [DBManager SQL:@"INSERT INTO %@ (bookid,bookname,author,size,type) VALUES (?,?,?,?,?)" inTable:kBookTable];
    
    [queue inDatabase:^(FMDatabase *db) {
//     NSInteger type = [LSYReadModel judgeTheFileType:[NSURL URLWithString:[model.filePath
//                                                                                          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];//TXT不这样处理会返回nil];

     NSString* bookType = [NSString stringWithFormat:@"%ld",model.bookType];
        result = [db executeUpdate:sql,model.bookID,model.bookName,model.authorName,[NSString stringWithFormat:@"%@",model.bookSize],bookType];
    }];
    
    return result;

}

+ (BOOL)deleteBookFromDB:(NSString *)bookid{

    __block BOOL result = NO;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];
    
    NSString *sql= [NSString stringWithFormat:@"DELETE FROM %@ WHERE bookid = '%@'",kBookTable,bookid];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        result = [db executeUpdate:sql];
    }];
     
     return result;
}

+ (BOOL)isBookDown:(NSString *)bookid
{
    __block BOOL result = NO;
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];
    
    NSString *sql= [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookid = '%@'",kBookTable,bookid];
    
    [queue inDatabase:^(FMDatabase *db) {

       FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            result = YES;
            break;
        }
        [rs close];
       
    }];
    
    
    
    return result;
}

+ (NSArray *)fetchAllBook
{
    
    NSMutableArray *mutablearray = [[NSMutableArray alloc] initWithCapacity:0];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];
    
    NSString *sql= [NSString stringWithFormat:@"SELECT * FROM %@",kBookTable];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];

        while ([rs next]) {
            
            BookModel *model = [[BookModel alloc] init];
            model.bookID = [NSString stringWithFormat:@"%zd",[rs intForColumn:@"bookid"]];
            model.bookName = [rs stringForColumn:@"bookname"];
            model.authorName = [rs stringForColumn:@"author"];
            model.bookSize = [f numberFromString:[rs stringForColumn:@"size"]];
            model.bookType = [rs intForColumn:@"type"];
            if(model.bookType==BookTypeEPUB){
               model.cover =[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cover_%@.png",model.bookName]];
            }
            model.filePath = [[documentsPath stringByAppendingPathComponent:@"/files" ]stringByAppendingString:[NSString stringWithFormat:@"/%@.dat",model.bookName]];
            [mutablearray addObject:model];
        }
        [rs close];
        
    }];
    return [NSArray arrayWithArray:mutablearray];
}

+(BookModel*)fetchBookByID:(NSString*)bookid{
    __block BookModel *model = [[BookModel alloc] init];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kPath_FMDB];
    
    NSString *sql= [NSString stringWithFormat:@"SELECT * FROM %@ WHERE bookid = '%@'",kBookTable,bookid];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];

        while ([rs next]) {
            model.bookID = [NSString stringWithFormat:@"%zd",[rs intForColumn:@"bookid"]];
            model.bookName = [rs stringForColumn:@"bookname"];
            model.authorName = [rs stringForColumn:@"author"];
            model.bookSize = [f numberFromString:[rs stringForColumn:@"size"]];
            model.bookType = [rs intForColumn:@"type"];
            if(model.bookType==BookTypeEPUB){
                model.cover =[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cover_%@.png",model.bookName]];
            }
            model.filePath = [[documentsPath stringByAppendingPathComponent:@"/files" ]stringByAppendingString:[NSString stringWithFormat:@"/%@.dat",model.bookName]];
            break;

        }
        [rs close];
        
    }];
    
    
    
    return model;


}

@end
