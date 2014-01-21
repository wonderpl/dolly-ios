//
//  SYNWebViewController.m
//  dolly
//
//  Created by Cong on 13/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNWebViewController.h"

@interface SYNWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSURL *URL;

@end

@implementation SYNWebViewController

+ (UIViewController *)webViewControllerForURL:(NSURL *)URL {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebView" bundle:nil];
	UINavigationController *navController = [storyboard instantiateInitialViewController];
	SYNWebViewController *webViewController = (SYNWebViewController *)navController.topViewController;
	webViewController.URL = URL;
	
	return navController;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	self.navigationItem.title = title;
	
	self.backButton.enabled = [webView canGoBack];
	self.forwardButton.enabled = [webView canGoForward];
}

#pragma mark - IBActions

- (IBAction)closeButtonPressed:(UIBarButtonItem *)barButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButtonPressed:(UIBarButtonItem *)barButton {
    [self.webView goBack];
}

- (IBAction)forwardButtonPressed:(UIBarButtonItem *)barButton {
    [self.webView goForward];
}

@end
