//
//  GameModel.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel
-(id)initWithDict:(NSDictionary*)dict{
    self.appName = [dict valueForKey:@"appName"];
    self.appLink = [dict valueForKey:@"appLink"];
    self.appCoverLink = [dict valueForKey:@"appCoverLink"];
    self.screenShotLink = [dict valueForKey:@"screenShotLink"];
    self.details = [dict valueForKey:@"details"];
    return self;
}
@end
