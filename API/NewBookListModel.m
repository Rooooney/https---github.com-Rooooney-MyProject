//
//  NewBookListModel.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "NewBookListModel.h"

@implementation NewBookListModel
-(id)initWithDict:(NSDictionary*)dict{
    self.bookName = [dict valueForKey:@"bookName"];
    self.bookLink = [dict valueForKey:@"bookLink"];
    self.bookCoverLink = [dict valueForKey:@"bookCoverLink"];
    self.pubInfo = [dict valueForKey:@"pubInfo"];
    return self;
}
@end
