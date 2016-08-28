//
//  NewsModel.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject
@property(nonatomic,copy)NSString* newsName;
@property(nonatomic,copy)NSString* newsLink;
-(id)initWithDict:(NSDictionary*)dict;
@end
