//
//  NewBookTableViewCell.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//
#define WIDTH  [UIScreen mainScreen].applicationFrame.size.width
#define HEIGHT [UIScreen mainScreen].applicationFrame.size.height
#import "MovieTableViewCell.h"

@implementation MovieTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _movieNameLabel = [[UILabel alloc]init];;
        _starLabel= [[UILabel alloc]init];;;
        _actorsLabel= [[UILabel alloc]init];;;
        _movieCoverImg = [[UIImageView alloc ]init];
        _movieCoverImg.clipsToBounds = YES;
        _movieCoverImg.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_movieNameLabel];
        [self addSubview:_starLabel];
        [self addSubview:_actorsLabel];
        [self addSubview:_movieCoverImg];
    }
    return self;
}

- (void)layoutSubviews
{
    self.movieCoverImg.frame = CGRectMake(0, 0, WIDTH/3, CGRectGetHeight(self.frame));
    self.movieNameLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame)+10, 0,WIDTH/3-50 , 20);
    self.starLabel.frame = CGRectMake(WIDTH-10, 0, 10, 20);
    self.actorsLabel.frame = CGRectMake(self.movieNameLabel.frame.origin.x, HEIGHT-30,WIDTH*2/3-10,20);
}
@end
