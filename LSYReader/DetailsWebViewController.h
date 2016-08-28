//
//  DetailsWebViewController.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailsWebViewController : UIViewController<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView* webView;
@property(nonatomic,strong)NSString* url;
@end
