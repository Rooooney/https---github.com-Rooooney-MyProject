//
//  BaseTableViewCell.h
//  HaoJiaZhang
//
//  Created by Xinfeng Du on 16/3/17.
//  Copyright © 2016年 hongli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView;

- (void)configureDataForCellWithModel:(id)model;

+ (CGFloat)rowHeightForCellWithModel:(id)model;

@end
