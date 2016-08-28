//
//  NewsModel.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel
-(id)initWithDict:(NSDictionary*)dict{
    self.newsName = [dict valueForKey:@"newsName"];
    self.newsLink = [dict valueForKey:@"newsLink"];
    return self;
}
@end
