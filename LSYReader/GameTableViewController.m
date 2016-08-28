//
//  GameTableViewController.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "GameTableViewController.h"
#import "GameTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailsWebViewController.h"
#import "GameModel.h"
#import"AFNetworking.h"
static  NSString *cellId = @"cellIdentifier";
@interface GameTableViewController()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong)NSArray* dataArr;

@end
@implementation GameTableViewController
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
    NSString* url = @"http://o8wiem8yd.bkt.clouddn.com/game.json";
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSMutableArray* arr = [[NSMutableArray alloc]init];
    [mgr GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        for(NSDictionary *dict in responseObject){
            GameModel* item = [[GameModel alloc]initWithDict:dict];
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


-(GameTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[GameTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSInteger rowNo = indexPath.row;
    GameModel* itemModel =_dataArr[rowNo];
    
    cell.appNameLabel.text =itemModel.appName;
    cell.detailsLabel.text =itemModel.details;
    [cell.appIconImg sd_setImageWithURL:[NSURL URLWithString:itemModel.appCoverLink]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图
    [cell.screenShotImg sd_setImageWithURL:[NSURL URLWithString:itemModel.screenShotLink]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图

    cell.appIconImg.clipsToBounds = YES;
    cell.screenShotImg.clipsToBounds = YES;
    cell.appIconImg.contentMode = UIViewContentModeScaleAspectFill;
    cell.screenShotImg.contentMode = UIViewContentModeScaleAspectFill;
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
    GameModel* itemModel =_dataArr[indexPath.row];
    details.url = itemModel.appLink;
    [self presentViewController:details animated:YES completion:nil];
}

@end

