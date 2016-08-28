//
//  GameModel.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameModel : NSObject
@property(nonatomic,copy)NSString* appName;
@property(nonatomic,copy)NSString* appLink;
@property(nonatomic,copy)NSString* appCoverLink;
@property(nonatomic,copy)NSString* details;
@property(nonatomic,copy)NSString* screenShotLink;
-(id)initWithDict:(NSDictionary*)dict;
@end
