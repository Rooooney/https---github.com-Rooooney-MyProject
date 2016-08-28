//
//  DetailsWebViewController.h
//  LiteReader
//
//  Created by 张红利 on 16/8/28.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
@interface DetailsWebViewController : UIViewController<UIWebViewDelegate,NJKWebViewProgressDelegate>
@property(nonatomic,strong)UIWebView* webView;
@property(nonatomic,strong)NSString* url;
@end
