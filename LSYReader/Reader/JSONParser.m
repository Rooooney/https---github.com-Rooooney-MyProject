//
//  JSONParser.m
//  LSYReader
//
//  Created by hongli on 16/7/29.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "JSONParser.h"
#import"BookModel.h"

@implementation JSONParser

+ (void)fetchBookModelWithURL:(NSString *)dataURL completeBlock:(void(^)(NSArray *dataarray,NSError *error))block{
    __block NSMutableArray* bookModelArr = [[NSMutableArray alloc] init]; // 可变数组使用前必须进行初始化
    __block NSError *error;
    NSURL *url = [[NSURL alloc] initWithString: dataURL];
    NSURLRequest* requst = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dic;
        if(data==nil){//网络问题
           [LSYReadUtilites showAlertTitle:nil content:@"请检查网络设置..."];
        }else{
           dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        }
        
       
    if(dic==nil){//如果没有返回数据
           NSString *domain = @"com.tencent.BookReader.ErrorDomain";
           NSString *desc = @"No data returned";
           NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
           
           error = [NSError errorWithDomain:domain
                                                code:-1
                                            userInfo:userInfo];
           
     }
       //保存版本号：version，数据总长度：datanum？
       [[NSUserDefaults standardUserDefaults] setObject:[dic valueForKey:@"version" ]forKey:@"version"];

        NSNumber  *num = [dic valueForKey:@"datanum" ];
        long totalDataNum = [num floatValue];
        bookModelArr = [[NSMutableArray alloc]initWithCapacity:totalDataNum];
        NSMutableArray* dictArr =[dic valueForKey:@"data"];
        for(NSDictionary *dict in dictArr){
            BookModel* item = [[BookModel alloc]initWithDict:dict];
            [bookModelArr addObject:item];
        }
        
        if (bookModelArr.count) {
            block([NSArray arrayWithArray:bookModelArr],nil);
        }else{
            block([NSArray array],error);
        }
    }];
}



@end
