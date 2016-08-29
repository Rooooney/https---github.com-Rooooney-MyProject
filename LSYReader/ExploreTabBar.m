//
//  ExploreTabBar.m
//  LiteReader
//
//  Created by mobyzhang on 16/8/23.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "ExploreTabBar.h"
#import"NewsTableViewController.h"
#import"NewBookListTableViewController.h"
#import"MovieTableViewController.h"
#import"GameTableViewController.h"
#import "DiscoveryModel.h"
#import "DiscoveryCell.h"

static  NSString *exploreCell = @"exploreCell";
@interface ExploreTabBar()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong)NSMutableArray* dataArr;
@property(nonatomic,strong)NSArray* iconArr;
@property(nonatomic,strong)NSArray* detailsArr;
@end

@implementation ExploreTabBar

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
    NSArray *titlearray = @[@"新书来啦",@"独家秘闻",@"极客游戏",@"科幻光影"];
    NSArray *iconarray = @[@"new_book.png",@"exclusive_news.png",@"geek_game.png",@"fun_movie.png"];
    NSArray *detailsarray = @[@"精品新书，独家首发！",@"无穷未解之谜，尽在这里！",@"这些烧脑游戏，是否敢来尝试？",@"精品科幻电影，一定别错过！"];
    
    self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<titlearray.count; i++) {
        DiscoveryModel *model = [[DiscoveryModel alloc] init];
        model.title = titlearray[i];
        model.icon = iconarray[i];
        model.detailText = detailsarray[i];
        
        [self.dataArr addObject:model];
    }
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
    
    DiscoveryCell *cell = [DiscoveryCell dequeueReusableCellWithTableView:tableView];
    [cell configureDataForCellWithModel:self.dataArr[indexPath.row]];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:exploreCell];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:exploreCell];
//    }
//    NSInteger rowNo = indexPath.row;
//    cell.textLabel.text = _dataArr[rowNo];
//    cell.imageView.image = [UIImage imageNamed:_iconArr[rowNo]];
//    cell.imageView.frame = CGRectMake(5, 4, 60, 88-4-4);
//    cell.imageView.contentMode = UIViewContentModeScaleToFill;
//    cell.imageView.clipsToBounds = YES;
//    cell.detailTextLabel.text = _detailsArr[rowNo];
//    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;//cell的右边有一个小箭头,距离右边有十几像素；
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
    UIViewController*  controller;
    switch (indexPath.row){
        case 0:{
             controller = [[NewBookListTableViewController alloc]init];
             break;
        }
        case 1:{
            controller = [[NewsTableViewController alloc]init];
            break;
        }
            
        case 2:{
            controller = [[GameTableViewController alloc]init];
            break;
        }
        case 3:{
            controller = [[MovieTableViewController alloc]init];
            break;
        }
    
    }

    
    [self.navigationController pushViewController:controller animated:YES];
    
}








@end
