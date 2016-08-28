//
//  GameTableViewCell.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "GameTableViewCell.h"
#define WIDTH  [UIScreen mainScreen].applicationFrame.size.width
#define HEIGHT [UIScreen mainScreen].applicationFrame.size.height

@implementation GameTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _appNameLabel = [[UILabel alloc]init];;
        _detailsLabel= [[UILabel alloc]init];;;
        _appIconImg = [[UIImageView alloc ]init];
        _screenShotImg = [[UIImageView alloc ]init];
        _appIconImg.clipsToBounds = YES;
        _screenShotImg.clipsToBounds = YES;
        _appIconImg.contentMode = UIViewContentModeScaleAspectFill;
        _screenShotImg.contentMode = UIViewContentModeScaleAspectFill;

        [self addSubview:_appNameLabel];
        [self addSubview:_detailsLabel];
        [self addSubview:_appIconImg];
        [self addSubview:_screenShotImg];
    }
    return self;
}

- (void)layoutSubviews
{
    self.appIconImg.frame = CGRectMake(0, 0, 50, 50);
    self.appNameLabel.frame = CGRectMake(CGRectGetMaxX(self.appIconImg.frame)+10, 0,WIDTH-60 , 20);
    self.screenShotImg.frame = CGRectMake(0, 60, WIDTH/2, HEIGHT-60);
    self.detailsLabel.frame = CGRectMake(CGRectGetMaxX(self.screenShotImg.frame)+10, 60,WIDTH/2-10,HEIGHT-60);
}

@end
