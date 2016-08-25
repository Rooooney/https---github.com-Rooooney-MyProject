//
//  BookStoreTabBar.m
//  LSYReader
//
//  Created by hongli on 16/7/8.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "BookStoreTabBar.h"
#import "BookStoreTableViewCell.h"
#import "JSONParser.h"
#import "BookModel.h"
#import "MJRefresh.h"
#import "LSYReadPageViewController.h"
#import "TWRDownloadManager.h"
#import "TWRDownloadObject.h"

static  NSString* bookIDDoneStr;
static  NSString* bookIDContinueStr;
#define REFRESH_URL @"http://stdl.qq.com/stdl/ipad/liteapp/novel1/list/"


@interface BookStoreTabBar ()
{
    int pageCount;
}
@property(retain,nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation BookStoreTabBar



- (id) initBookStore{
    if(self = [super init]){
        self.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"书城" image:nil tag:2];
        self.title = @"书城";
    }
    return self;
}

-(NSMutableArray*)dataArr{
    if(!_dataArr){
        _dataArr = [[NSMutableArray alloc]init];
    }
    return _dataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-113);
    pageCount = 1;
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);//只能设置中心，不能设置大小
    _activityIndicator.color = [UIColor blackColor]; // 改变圈圈的颜色为红色； iOS5引入
   [self.view addSubview:self.activityIndicator];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    //第一步：
    //UITableView去掉自带系统的分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Hide the time
    //self.tableView.header.lastUpdatedTimeKey.hidden = YES;
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
   
}

-(void)viewWillLayoutSubviews{

    _activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);//只能设置中心，不能设置大小

}

-(void)loadNewData{
    //联网下载书城数据
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
    pageCount = 1;
    NSString* pageStr = [NSString stringWithFormat:@"%d.txt", pageCount];
    NSString* dataURL = [REFRESH_URL stringByAppendingString: pageStr];
   // NSString* url =@"http://o8wiem8yd.bkt.clouddn.com/books.json";
    [JSONParser fetchBookModelWithURL:dataURL completeBlock:^(NSArray *dataarray,NSError *error){
        if(!error){
            [self.dataArr removeAllObjects];//书籍列表清空 加载第一页
            [self.dataArr addObjectsFromArray:dataarray];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        
    }];
    //});
}

-(void)loadMoreData{
    //联网下载书城数据
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSString* pageStr = [NSString stringWithFormat:@"%d.txt", ++pageCount];
    NSString* dataURL = [REFRESH_URL stringByAppendingString:pageStr];
    [JSONParser fetchBookModelWithURL:dataURL completeBlock:^(NSArray *dataarray,NSError *error){
        if(!error){
            [self.dataArr addObjectsFromArray:dataarray];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        }else if([error.localizedDescription isEqualToString:@"No data returned"]){
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    }];
    //});
}

//用来指定表视图的分区个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //分区设置为1
    return 1;
}

//用来指定特定分区有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //设置为20行
    return _dataArr.count;
}

//配置特定行中的单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
   
    BookStoreTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        //单元格样式设置为UITableViewCellStyleDefault
        cell = [[BookStoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    BookModel* item=_dataArr[indexPath.row];
    cell.bookTitle.text = item.bookName;
    if(![item.bookName containsString:@"《"]){
        cell.bookTitle.text = [[@"《" stringByAppendingString:item.bookName]stringByAppendingString:@"》"];
        
    }
    [cell cellBindingwithBookModel:item withIndexPath:indexPath];
//    [cell.progressBar setHidden:YES];
    cell.delegate = self;
    
    if ([[TWRDownloadManager sharedManager] isFileDownloadingForUrl:item.downloadURL withProgressBlock:cell.progressBlock completionBlock:cell.completionBlock]) {
        cell.progressBar.hidden = NO;

    }else{
        cell.progressBar.hidden = YES;

    }
    
    return cell;
}

//设置单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    //这里设置成150
    return 100;
}

//实现cell里点击开始阅读的代理方法
-(void)StartReadingWithBookModel:(BookModel*)model{
    
    [self.activityIndicator startAnimating];
    LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
    //pageView.resourceURL = [NSURL URLWithString:model.filePath];    //文件位置
    pageView.resourceURL = [NSURL URLWithString:[model.filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]];    //文件位置
    pageView.fileName = model.bookName;
    if(model.bookType==BookTypePDF){
        pageView.isPDF = YES;
        pageView.fileName = model.bookName;
    }else{
        pageView.isPDF = NO;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        pageView.model = [LSYReadModel getLocalModelWithBookModel:model];//这个model存储了归档的阅读参数：进度（chapter、page），笔记，背景主题，字体大小
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self presentViewController:pageView animated:YES completion:nil];
        });
    });
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //当手指离开某行时，就让某行的选中状态消失
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //（这种是没有点击后的阴影效果)

}






- (void)statDownBookWithBookModel:(BookModel *)model withIndexPath:(NSIndexPath *)indexPath
{
    BookStoreTableViewCell  *cell = (BookStoreTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    NSString *suffname;
//    if ([model.downloadURL containsString:@".pdf"]) {
//        suffname = @".pdf";
//    }else if ([model.downloadURL containsString:@".epub"]){
//        suffname = @".epub";
//
//    }else{
//        suffname = @".txt";
//
//    }
     suffname = @".dat";

     [[TWRDownloadManager sharedManager] downloadFileForURL:model.downloadURL  withName:[NSString stringWithFormat:@"%@%@",model.bookName,suffname] inDirectoryNamed:@"files" progressBlock:cell.progressBlock completionBlock:cell.completionBlock enableBackgroundMode:YES];
   
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
