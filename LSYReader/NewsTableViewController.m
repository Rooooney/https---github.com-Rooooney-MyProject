//
//  NewsTableViewController.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//
#import"NewsModel.h"
#import "NewsTableViewController.h"
#import "DetailsWebViewController.h"
#import"AFNetworking.h"
static  NSString *cellId = @"cellIdentifier";
@interface NewsTableViewController()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong)NSArray* dataArr;

@end

@implementation NewsTableViewController

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    [_tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];//删除多余的分割线
    return _tableView;
}

//分割线左对齐
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    //_dataArr = @[@"新书来啦",@"独家秘闻",@"极客游戏",@"科幻光影"];
    //AFNetworking 下载数据
    NSString* url = @"http://o8wiem8yd.bkt.clouddn.com/news.json";
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    [mgr GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        for(NSDictionary *dict in responseObject){
            NewsModel* item = [[NewsModel alloc]initWithDict:dict];
            [arr addObject:item];
        }
        self.dataArr = [arr copy];
        [self.tableView reloadData];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    [self.view addSubview:self.tableView];
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tableView.frame = CGRectMake(0, 0, ViewSize(self.view).width, ViewSize(self.view).height);
}


#pragma mark - UITableView Delagete DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSInteger rowNo = indexPath.row;
    NewsModel* itemModel =_dataArr[rowNo];
    cell.textLabel.text =itemModel.newsName;
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;//cell的右边有一个小箭头,距离右边有十几像素；
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  88.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当手指离开某行时，就让某行的选中状态消失
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailsWebViewController* details = [[DetailsWebViewController alloc]init];
    NewsModel* itemModel =_dataArr[indexPath.row];
    details.url = itemModel.newsLink;
    [self.navigationController pushViewController:details animated:YES];
}


@end
