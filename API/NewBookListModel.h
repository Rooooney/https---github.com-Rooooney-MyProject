//
//  NewBookListModel.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewBookListModel : NSObject
@property(nonatomic,copy)NSString* bookName;
@property(nonatomic,copy)NSString* bookLink;
@property(nonatomic,copy)NSString* bookCoverLink;
@property(nonatomic,copy)NSString* pubInfo;
-(id)initWithDict:(NSDictionary*)dict;
@end
