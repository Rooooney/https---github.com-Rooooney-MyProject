//
//  DiscoveryCell.m
//  LiteReader
//
//  Created by HD on 16/8/29.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "DiscoveryCell.h"
#import "DiscoveryModel.h"

static CGFloat kLeftX = 10;
static CGFloat kLeftY = 10;
static CGFloat kPadding = 5;

@implementation DiscoveryCell

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
    DiscoveryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[DiscoveryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    return cell;
}

- (void)configureDataForCellWithModel:(id)model
{
    DiscoveryModel *discoveryModel = model;
    self.textLabel.text = discoveryModel.title;
    self.detailTextLabel.text = discoveryModel.detailText;
    self.imageView.image = [UIImage imageNamed:discoveryModel.icon];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(kLeftX, kLeftY, self.bounds.size.height-2*kLeftX, self.bounds.size.height-2*kLeftX);
    CGFloat nowW = self.imageView.frame.origin.x+self.imageView.frame.size.width;
    self.textLabel.frame = CGRectMake(nowW+kPadding, kLeftY, self.bounds.size.width-nowW-2*kPadding, self.imageView.bounds.size.height/2);
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.bounds.size.height/2, self.textLabel.bounds.size.width, self.imageView.bounds.size.height/2);

}


@end
