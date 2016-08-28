//
//  MovieModel.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject
@property(nonatomic,copy)NSString* movieName;
@property(nonatomic,copy)NSString* movieLink;
@property(nonatomic,copy)NSString* movieCoverLink;
@property(nonatomic,copy)NSString* actorsStr;
@property(nonatomic,copy)NSString* starStr;
-(id)initWithDict:(NSDictionary*)dict;
@end
