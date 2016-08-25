//
//  MainViewController.m
//  UICollectionVIewDemo
//
//  Created by HD on 16/7/12.
//  Copyright © 2016年 hongli. All rights reserved.
//

#import "MainViewController.h"
#import "ReadCollectionCell.h"
#import "BookModel.h"
#import <QuartzCore/QuartzCore.h>
#import "LSYReadViewController.h"
#import "LSYReadPageViewController.h"
#import "LSYReadUtilites.h"
#import "LSYReadModel.h"
#import "DBManager.h"
#define DF_WIDTH [UIScreen mainScreen].applicationFrame.size.width
#define DF_HEIGHT [UIScreen mainScreen].applicationFrame.size.height

static NSInteger padding = 10;
static NSInteger count = 3; // 每行三个
static NSString *kCollectionCellIdentifier = @"CollectionCellIdentifier";

NS_ENUM(NSInteger,CellState){
    
    //右上角编辑按钮的两种状态；
    //正常的状态，按钮显示“编辑”;
    NormalState,
    //正在删除时候的状态，按钮显示“完成”；
    DeleteState
    
};

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>{
    BookModel *bookModelEpub;
    BookModel *bookModelTXT;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,assign) enum CellState;
@property(retain,nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation MainViewController

-(NSMutableArray*)dataArray{
    if(_dataArray==nil){
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[DBManager fetchAllBook]mutableCopy];
    [self addTheDefaultBook:@"北京折叠（试读版）" withPathExtension:@".epub"];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editBookShelf:)];
    
    self.navigationItem.rightBarButtonItem = editButton;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBookDownloaded:) name: @"NewBookDownloaded" object:nil];
    // collectionView 布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 50;//行距
    flowLayout.minimumInteritemSpacing = 1;
    
    //一开始是正常状态；
    CellState = NormalState;
    // collectionView 初始化
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.frame = CGRectMake(0, 0, DF_WIDTH, DF_HEIGHT);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[ReadCollectionCell class] forCellWithReuseIdentifier:kCollectionCellIdentifier];
    [self.view addSubview:self.collectionView];
    
//    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    _activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);//只能设置中心，不能设置大小
//    [self.view addSubview:self.activityIndicator];
//    _activityIndicator.color = [UIColor blackColor]; // 改变圈圈的颜色为红色； iOS5引入

    
    [self.collectionView reloadData];

    
}


-(void)viewWillLayoutSubviews{//　这个在collectionview画每一个cell 前调用
    
    [super viewWillLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, DF_WIDTH, DF_HEIGHT);//重置布局的时候一定要注意布局的frame！
    UIDeviceOrientation interfaceOrientation = [UIDevice currentDevice].orientation;
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        //翻转为竖屏时
        count = 3;
        [self.collectionView reloadData];
        
    }else if (interfaceOrientation==UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        //翻转为横屏时
        count = 5;
        [self.collectionView reloadData];
    }
}


//更新书架的通知
-(void)newBookDownloaded:(NSNotification *)no{
    NSString* result = no.object;
    if([result isEqualToString:@"success"]){
        //异步执行
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[self loadData];
            [self.dataArray removeAllObjects];
            self.dataArray = [[DBManager fetchAllBook]mutableCopy];
            [self addTheDefaultBook:@"北京折叠（试读版）" withPathExtension:@".epub"];
            [self.collectionView reloadData];
        
        });

        
    }
}


-(void)addTheDefaultBook:(NSString*) fileName withPathExtension:(NSString*)extension{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    BookModel *model = [[BookModel alloc] init];
    //model.bookID = ;
    model.bookName = fileName;
    //model.authorName = @"";
    //model.bookSize = [f numberFromString:[rs stringForColumn:@"size"]];
    model.bookType = bookModelEpub;
    if(model.bookType==BookTypeEPUB){
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        model.cover =[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cover_%@.png",@"OEBPS"]];
    }
    model.filePath = filePath;
    [_dataArray addObject:model];

}


#pragma mark UICollectionView data source.

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReadCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCellIdentifier forIndexPath:indexPath];
    BookModel *bookModel =  self.dataArray[indexPath.row];
    [cell configBookCellModel:bookModel];//设置bookmodel的封面
    [cell.deleteBtn addTarget:self action:@selector(deleteCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

#pragma mark- 点击每个cell的删除按钮
- (void)deleteCellButtonPressed: (id)sender{
    ReadCollectionCell *cell = (ReadCollectionCell *)[sender superview];//获取cell
    
    NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];//获取cell对应的indexpath;
    BookModel* model =[self.dataArray objectAtIndex:indexpath.row];
    NSString* bookIDToDelete =model.bookID;
    [LSYReadUtilites deleteFileWithFilePath:model.filePath];//删除压缩包
    NSString* unZipFile =[NSString stringWithFormat:@"%@/%@",[[model.filePath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent],model.bookName];
    [LSYReadUtilites deleteFileWithFilePath:unZipFile];//删除解压包

    [DBManager deleteBookFromDB:bookIDToDelete];
    [self.dataArray removeObjectAtIndex:indexpath.row];
    [self.collectionView reloadData];
    
}



//点击每本书事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookModel *bookModel = [self.dataArray objectAtIndex:indexPath.row];
    if(bookModel.isSelected==NO){
        [self beginReading:bookModel];
    }
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (IBAction)editBookShelf:(id)sender {
    if(CellState==NormalState){//    //从正常状态变为可删除状态；
        CellState = DeleteState;
        self.navigationItem.rightBarButtonItem.title = @"完成";
        for(BookModel* item in self.dataArray){
            item.isSelected = YES;
        }
        
    }else{
        CellState = NormalState;
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        for(BookModel* item in self.dataArray){
            
            item.isSelected = NO;
        }
        
    }
    
    [self.collectionView reloadData];
    
}



#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellW = (DF_WIDTH-20*(count+2))/count; // 计算一个cell 的宽度 (屏幕宽度 - 间距之间空白)/每行个数
    CGFloat cellH = cellW*4/3 +20; // 随便设置的一个高度 封面比例4:3 20 表示标题高度
    
    return CGSizeMake(cellW, cellH);
}

////定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(padding, 25, padding, 25); // 整个CollectionView 到边界的间距 顺序 上、左、下、右
}

//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return padding;
}


-(void) beginReading:(BookModel*)bookModel {
    UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"请稍等..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil]; //display without any btns
        alert.frame = CGRectMake(DF_WIDTH/3, DF_HEIGHT/3, DF_WIDTH/3/3, DF_HEIGHT/3);
        // alert = [[UIAlertView alloc] initWithTitle:@"\n\nConfiguring Preferences\nPlease Wait..." message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil]; //to display with cancel btn
        
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        // Adjust the indicator so it is up a few pixels from the bottom of the alert
        indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height/2);
        [indicator startAnimating];
        [alert addSubview:indicator];
        [alert show];
        [self.activityIndicator startAnimating];
        LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
        pageView.resourceURL  = [NSURL URLWithString:[bookModel.filePath
                                                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//TXT不这样处理会返回nil
    
        if(bookModel.bookType!=BookTypePDF){
            pageView.isPDF = NO;
        }else{
            pageView.isPDF = YES;
            pageView.fileName = bookModel.bookName;
        }
        NSLog(@"PATH is %@",bookModel.filePath);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //pageView.model = [LSYReadModel getLocalModelWithURL: pageView.resourceURL];
            pageView.model = [LSYReadModel getLocalModelWithBookModel: bookModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
               // [self.activityIndicator stopAnimating];
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                [self presentViewController:pageView animated:YES completion:nil];
            });
        });

    
}

-(BOOL)copyFileToDocuments:(NSString*) fileName{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *resourcePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"/files"];
    NSError*  error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:resourcePath withIntermediateDirectories:NO attributes:nil error:&error];
    NSString *DestPath=[resourcePath stringByAppendingString:[@"/" stringByAppendingString:fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:DestPath];
    if(!fileExists){
        [fm copyItemAtPath:filePath toPath:DestPath error:&error];
        
    }
    if(error==nil)return YES;
    else return NO;
}

//获得沙盒Documents文件夹URL
-(NSURL*)getURLInDocunments:(NSString* )fileName{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return  [url URLByAppendingPathComponent:@"fileName"];
    
    
}
@end
