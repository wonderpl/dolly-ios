//
//  SYNWebViewController.m
//  dolly
//
//  Created by Cong on 13/01/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNWebViewController.h"
#import "SYNTrackingManager.h"

@interface SYNWebViewController () <UIWebViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeButton;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, copy) NSString *trackingName;

@end

@implementation SYNWebViewController

+ (UIViewController *)webViewControllerForURL:(NSURL *)URL {
	return [self webViewControllerForURL:URL withTrackingName:nil];
}

+ (UIViewController *)webViewControllerForURL:(NSURL *)URL withTrackingName:(NSString *)trackingName {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WebView" bundle:nil];
	UINavigationController *navController = [storyboard instantiateInitialViewController];
	SYNWebViewController *webViewController = (SYNWebViewController *)navController.topViewController;
	webViewController.URL = URL;
	webViewController.trackingName = trackingName;
	
	navController.delegate = webViewController;
	
	return navController;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// We want to increase the gap between the title and the cancel button by 30 pixels
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			target:nil
																			action:nil];
	spacer.width = 30.0;
	self.navigationItem.rightBarButtonItems = @[ self.closeButton, spacer ];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.trackingName) {
		[[SYNTrackingManager sharedManager] trackScreenViewWithName:self.trackingName];
	}
}

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
	return (IS_IPAD ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	self.navigationItem.title = title;
	
	BOOL canNavigateWebView = ([webView canGoBack] || [webView canGoForward]);
	if (canNavigateWebView) {
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
	
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
