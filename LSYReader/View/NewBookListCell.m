//
//  NewBookListCell.m
//  LiteReader
//
//  Created by HD on 16/8/29.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "NewBookListCell.h"
#import "NewBookListModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static CGFloat kLeftX = 10;
static CGFloat kLeftY = 10;
static CGFloat kPadding = 5;

@implementation NewBookListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.accessoryType =UITableViewCellAccessoryDisclosureIndicator;//cell的右边有一个小箭头,距离右边有十几像素；
    
    return self;
}

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView
{
    
    NSString *kCellIdentifier = NSStringFromClass([self class]);
    NewBookListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[NewBookListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    return cell;
}

//cell.textLabel.text =itemModel.bookName;
//[cell.imageView sd_setImageWithURL:[NSURL URLWithString:itemModel.bookCoverLink]
//                  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图
//cell.imageView.frame = CGRectMake(5, 4, 60, 88-4-4);
//
//cell.imageView.clipsToBounds = YES;
//cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
//cell.detailTextLabel.text = itemModel.pubInfo;

- (void)configureDataForCellWithModel:(id)model
{
    NewBookListModel *listModel = model;
    self.textLabel.text = listModel.bookName;
    self.detailTextLabel.text = listModel.pubInfo;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:listModel.bookCoverLink]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];//placeholder是占位图
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(kLeftX, kLeftY, (self.bounds.size.height-2*kLeftX)*3/4, self.bounds.size.height-2*kLeftX);
    CGFloat nowW = self.imageView.frame.origin.x+self.imageView.frame.size.width;
    self.textLabel.frame = CGRectMake(nowW+kPadding, kLeftY, self.bounds.size.width-nowW-2*kPadding, self.imageView.bounds.size.height/2);
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.bounds.size.height/2, self.textLabel.bounds.size.width, self.imageView.bounds.size.height/2);
    
}


@end
