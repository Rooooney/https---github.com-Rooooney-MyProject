//
//  BookModel.m
//  UICollectionVIewDemo
//
//  Created by HD on 16/7/12.
//  Copyright © 2016年 hongli. All rights reserved.
//

#import "BookModel.h"
#import "LSYReadUtilites.h"
@implementation BookModel

-(id)initWithDict:(NSDictionary*) dict{
    self.bookID  = [dict valueForKey:@"id" ];
    self.bookName = [dict valueForKey:@"name" ];
    self.authorName = [dict valueForKey:@"author"];
    //NSNumber* num = [dict valueForKey:@"size"];
    self.bookSize = [dict valueForKey:@"size"];
    self.downloadURL = [dict valueForKey:@"url"];

    self.isSelected = NO;
    //书籍下载的链接
     self.downloadURL = [dict valueForKey:@"url" ];
     //self.downloadURL = @"https://manuals.info.apple.com/MANUALS/1000/MA1595/en_US/ipad_user_guide.pdf";
     //self.downloadURL = @"http://package.minghui.org/mh/2016/7/19/9ping.epub";
   // self.downloadURL =@"http://o8wiem8yd.bkt.clouddn.com/22378.txt";
    NSString* bookExtension =[[self.downloadURL lastPathComponent]pathExtension];
    if([bookExtension isEqualToString:@"txt"]){
        self.bookType = BookTypeTXT;
    
    }else if([bookExtension isEqualToString:@"pdf"]){
        self.bookType = BookTypePDF;
    }//默认是epub
    
    if([[LSYReadUtilites getBookIDDone] containsString:self.bookName]){
        self.downloadState = @"done";
    }else if ([[LSYReadUtilites getBookIDContinue] containsString:self.bookName]){
        self.downloadState = @"continue";
    }else {
        self.downloadState = @"start";

    }
    return self;
}

@end
