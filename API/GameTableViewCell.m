//
//  GameTableViewCell.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "GameTableViewCell.h"
#import "GameModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define WIDTH  [UIScreen mainScreen].applicationFrame.size.width
#define HEIGHT [UIScreen mainScreen].applicationFrame.size.height
//计算当前高度、宽度
#define DF_NowHeight(a) (a.frame.origin.y + a.frame.size.height)
#define DF_NowWidth(a) (a.frame.origin.x + a.frame.size.width)


static CGFloat kLeftX = 10;
static CGFloat kLeftY = 10;
static CGFloat kPadding = 5;

@interface GameTableViewCell ()
@property(nonatomic,strong)UILabel* appNameLabel;
@property(nonatomic,strong)UILabel* detailsLabel;
@property(nonatomic,strong)UIImageView* appIconImg;
@property(nonatomic,strong)UIImageView* screenShotImg;
@property(nonatomic,strong)UIView* line;

@end

@implementation GameTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        _appNameLabel = [[UILabel alloc]init];
        _detailsLabel= [[UILabel alloc]init];
        _detailsLabel.numberOfLines = 0;
        _detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _appIconImg = [[UIImageView alloc ]init];
        _screenShotImg = [[UIImageView alloc ]init];
        _appIconImg.clipsToBounds = YES;
        _screenShotImg.clipsToBounds = YES;
        _appIconImg.contentMode = UIViewContentModeScaleAspectFill;
        _screenShotImg.contentMode = UIViewContentModeScaleAspectFill;
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor grayColor];
        
        [self addSubview:_appNameLabel];
        [self addSubview:_detailsLabel];
        [self addSubview:_appIconImg];
        [self addSubview:_screenShotImg];
        [self addSubview:_line];

    }
    return self;
}

- (void)configureDataForCellWithModel:(id)model
{
    GameModel *gameModel = model;
    
    self.appNameLabel.text =gameModel.appName;
    self.detailsLabel.text =gameModel.details;
    [self.appIconImg sd_setImageWithURL:[NSURL URLWithString:gameModel.appCoverLink]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图
    [self.screenShotImg sd_setImageWithURL:[NSURL URLWithString:gameModel.screenShotLink]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图
    
    
}
- (void)layoutSubviews
{
    self.appIconImg.frame = CGRectMake(kLeftX/2, kLeftY/2, 50, 50);
    self.appNameLabel.frame = CGRectMake(DF_NowWidth(self.appIconImg)+kPadding, 0,WIDTH-60 , 30);
    self.screenShotImg.frame = CGRectMake(kLeftX/2, DF_NowHeight(self.appIconImg)+kLeftX/2, 80, 120);
    self.detailsLabel.frame = CGRectMake(DF_NowWidth(self.screenShotImg)+kPadding, self.screenShotImg.frame.origin.y,WIDTH- kLeftX/2- DF_NowWidth(self.screenShotImg)-kPadding*2,self.screenShotImg.frame.size.height);
    self.line.frame = CGRectMake(0,self.bounds.size.height-0.5,WIDTH,0.5);

}

@end
