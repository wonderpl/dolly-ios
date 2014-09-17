//
//  SYNWebViewCell.m
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNWebViewCell.h"

static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNWebViewCell () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation SYNWebViewCell

- (void)awakeFromNib {
	[super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

	self.webView.scrollView.scrollEnabled = NO;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	self.delegate = nil;
}

- (CGFloat)contentHeight {
    
    //Hack to get the content size accurate
    //The contentsize never decreased based on content, as it increased it would keep the larger value and never go down.
    //Other hack would have been to re init the webview.
    CGRect frame = self.webView.frame;
    frame.size.height = 10;
    self.webView.frame = frame;
    frame.size.height = self.webView.scrollView.contentSize.height;
    self.webView.frame = frame;

	return self.webView.frame.size.height;
}

- (void)setContentHTML:(NSString *)contentHTML {
	_contentHTML = contentHTML;
	
	NSURL *templateURL = [[NSBundle mainBundle] URLForResource:HTMLTemplateFilename withExtension:@"html"];
	NSString *templateString = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:nil];
	NSString *HTMLString = [templateString stringByReplacingOccurrencesOfString:@"%{DESCRIPTION}" withString:contentHTML];	
	[self.webView loadHTMLString:HTMLString baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.delegate webViewCellContentLoaded:self];
}

@end
