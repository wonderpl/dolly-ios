//
//  SYNWebViewController.h
//  dolly
//
//  Created by Cong on 13/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNWebViewController : UIViewController <UIWebViewDelegate>

+ (UIViewController *)webViewControllerForURL:(NSURL *)URL;

@property (nonatomic, strong, readonly) UIWebView *webView;

@end
