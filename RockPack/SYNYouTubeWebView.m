//
//  SYNYouTubeWebView.m
//  dolly
//
//  Created by Sherman Lo on 17/03/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNYouTubeWebView.h"

static const CGFloat VideoAspectRatio = 16.0 / 9.0;

static const NSInteger InitialWebViewCount = 3;

@interface SYNYouTubeWebView ()

@end

@implementation SYNYouTubeWebView

#pragma mark - Public class

+ (instancetype)webView {
	NSMutableArray *reusableWebViews = [self reusableWebViews];
	
	SYNYouTubeWebView *webView = [reusableWebViews firstObject];
	[reusableWebViews removeObject:webView];
	
	if (!webView) {
		webView = [self createWebView];
	}
	
	return webView;
}

+ (void)setup {
	for (NSInteger i = 0; i < InitialWebViewCount; i++) {
		[[self reusableWebViews] addObject:[self createWebView]];
	}
}

#pragma mark - Private class

+ (instancetype)createWebView {
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	CGSize size = CGSizeMake(round(CGRectGetHeight(screenBounds)),
							 round(CGRectGetHeight(screenBounds) / VideoAspectRatio));
	
	CGRect frame = CGRectMake(0, 0, size.width, size.height);
	
	return [[self alloc] initWithFrame:frame];
}

+ (NSMutableArray *)reusableWebViews {
	static dispatch_once_t onceToken;
	static NSMutableArray *reusableWebViews;
	dispatch_once(&onceToken, ^{
		reusableWebViews = [NSMutableArray array];
	});
	return reusableWebViews;
}

#pragma mark - Init / Dealloc

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.scrollView.scrollEnabled = NO;
		self.allowsInlineMediaPlayback = YES;
		self.mediaPlaybackRequiresUserAction = NO;
		
		NSURL *url = [self URLForPlayerHTML];
		NSString *templateHTMLString = [NSString stringWithContentsOfURL:url
																encoding:NSUTF8StringEncoding
																   error:nil];
		
		NSString *iFrameHTML = [NSString stringWithFormat:templateHTMLString,
								(int)CGRectGetWidth(self.frame),
								(int)CGRectGetHeight(self.frame)];
		
		[self loadHTMLString:iFrameHTML baseURL:[NSURL URLWithString: @"http://www.youtube.com"]];
	}
	return self;
}

#pragma mark - UIView

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[[[self class] reusableWebViews] addObject:self];
	}
}

#pragma mark - Private

- (NSURL *)URLForPlayerHTML {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSURL *documentsURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
	NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"YouTubeIFramePlayer.html"];
	
	if ([fileManager fileExistsAtPath:[fileURL path]]) {
		return fileURL;
	}
	
	return [[NSBundle mainBundle] URLForResource:@"YouTubeIFramePlayer" withExtension:@"html"];
}

@end
