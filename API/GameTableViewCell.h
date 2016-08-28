//
//  GameTableViewCell.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel* appNameLabel;
@property(nonatomic,strong)UILabel* detailsLabel;
@property(nonatomic,strong)UIImageView* appIconImg;
@property(nonatomic,strong)UIImageView* screenShotImg;
@end
