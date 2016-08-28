//
//  MovieModel.m
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel
-(id)initWithDict:(NSDictionary*)dict{
    self.movieName = [dict valueForKey:@"movieName"];
    self.movieLink = [dict valueForKey:@"movieLink"];
    self.movieCoverLink = [dict valueForKey:@"movieCoverLink"];
    self.actorsStr = [dict valueForKey:@"actors"];
    self.starStr = [dict valueForKey:@"star"];
    return self;
}
@end
