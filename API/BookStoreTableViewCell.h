//
//  BookStoreTableViewCell.h
//  LSYReader
//
//  Created by hongli on 16/7/29.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"BookModel.h"
#import "TWRDownloadObject.h"
#import "TWRDownloadManager.h"
#import "DBManager.h"

@protocol StartReadAfterDownloadDelegate<NSObject>

-(void)StartReadingWithBookModel:(BookModel*)model;

- (void)statDownBookWithBookModel:(BookModel*)model withIndexPath:(NSIndexPath *)indexPath;
@end

@interface BookStoreTableViewCell : UITableViewCell
@property(nonatomic,copy)UILabel* bookTitle;
@property(nonatomic,copy)UILabel* authorName ;
@property(nonatomic,copy)UIButton* downloadBtn;
@property(nonatomic,copy)UIProgressView* progressBar;

//@property (strong, nonatomic)NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSData *resumeData;//保留下载进度
@property(nonatomic,strong)BookModel* model;
@property (nonatomic,weak)id<StartReadAfterDownloadDelegate> delegate;
-(void)cellBindingwithBookModel:(BookModel*)model withIndexPath:(NSIndexPath *)indexPath;

@property(nonatomic,strong) NSIndexPath *indexPath;
@property (strong, nonatomic) TWRDownloadProgressBlock progressBlock;
@property (strong, nonatomic) TWRDownloadCompletionBlock completionBlock;

@end
