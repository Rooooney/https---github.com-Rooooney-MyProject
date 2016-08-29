//
//  NewBookTableViewCell.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//
#define WIDTH  [UIScreen mainScreen].applicationFrame.size.width
#define HEIGHT [UIScreen mainScreen].applicationFrame.size.height

//计算当前高度、宽度
#define DF_NowHeight(a) (a.frame.origin.y + a.frame.size.height)
#define DF_NowWidth(a) (a.frame.origin.x + a.frame.size.width)


#import "MovieTableViewCell.h"
#import "MovieModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static CGFloat kLeftX = 10;
static CGFloat kLeftY = 10;
static CGFloat kPadding = 5;

@interface MovieTableViewCell ()
@property(nonatomic,strong)UILabel* movieNameLabel;
@property(nonatomic,strong)UILabel* starLabel;
@property(nonatomic,strong)UILabel* actorsLabel;
@property(nonatomic,strong)UIImageView* movieCoverImg;
@property(nonatomic,strong)UIView* line;

@end

@implementation MovieTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _movieNameLabel = [[UILabel alloc]init];;
        _starLabel= [[UILabel alloc]init];
        _starLabel.textAlignment = NSTextAlignmentRight;
        _actorsLabel= [[UILabel alloc]init];;;
        _movieCoverImg = [[UIImageView alloc ]init];
        _movieCoverImg.clipsToBounds = YES;
        _movieCoverImg.contentMode = UIViewContentModeScaleAspectFill;
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor grayColor];
        
        [self addSubview:_movieNameLabel];
        [self addSubview:_starLabel];
        [self addSubview:_actorsLabel];
        [self addSubview:_movieCoverImg];
        [self addSubview:_line];
    }
    return self;
}

- (void)configureDataForCellWithModel:(id)model
{
    MovieModel *movieModel = model;
    
    self.movieNameLabel.text =movieModel.movieName;
    self.starLabel.text = [NSString stringWithFormat:@"评分:%@",movieModel.starStr];
    self.actorsLabel.text =movieModel.actorsStr;
    [self.movieCoverImg sd_setImageWithURL:[NSURL URLWithString:movieModel.movieCoverLink]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图
    
    self.movieCoverImg.clipsToBounds = YES;
    self.movieCoverImg.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (void)layoutSubviews
{
    self.movieCoverImg.frame = CGRectMake(kLeftX, kLeftY, (CGRectGetHeight(self.frame)-2*kLeftY)*3/4, CGRectGetHeight(self.frame)-2*kLeftY);// 按照一个三笔的比例来算
    self.movieNameLabel.frame = CGRectMake(DF_NowWidth(self.movieCoverImg)+kPadding, kLeftY,WIDTH-DF_NowWidth(self.movieCoverImg)-2*kPadding , 20);
    self.starLabel.frame = CGRectMake(WIDTH-kLeftX-100, self.movieCoverImg.center.y-20, 100, 20);
    self.actorsLabel.frame = CGRectMake(self.movieNameLabel.frame.origin.x, self.movieCoverImg.center.y,self.movieNameLabel.frame.size.width,self.movieCoverImg.frame.size.height/2);
    self.line.frame = CGRectMake(0,self.bounds.size.height-0.5,WIDTH,0.5);
}

@end
