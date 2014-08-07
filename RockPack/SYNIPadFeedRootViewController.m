//
//  SYNIPadFeedRootViewController.m
//  dolly
//
//  Created by Sherman Lo on 24/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNIPadFeedRootViewController.h"
#import "SYNFeedVideoLargeCell.h"
#import "SYNFeedVideoSmallCell.h"
#import "SYNFeedChannelLargeCell.h"
#import "SYNFeedChannelSmallCell.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNFeedModel.h"
#import "FeedItem.h"
#import "VideoInstance.h"
#import "SYNIPadFeedLayout.h"
#import "UINavigationBar+Appearance.h"
#import "Video.h"

static NSString *const HTMLTemplateFilename = @"VideoDescriptionTemplate";

@interface SYNIPadFeedRootViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightConstant;

@property (nonatomic, assign) float firstX;
@property (strong, nonatomic) IBOutlet UIWebView *infoView;
@property (strong, nonatomic) IBOutlet UIView *infoViewContainer;

@end

@implementation SYNIPadFeedRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	SYNIPadFeedLayout *layout = (SYNIPadFeedLayout *)self.feedCollectionView.collectionViewLayout;
//	layout.model = self.model;
	
	[self.feedCollectionView registerNib:[SYNFeedVideoLargeCell nib]
			  forCellWithReuseIdentifier:[SYNFeedVideoLargeCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedVideoSmallCell nib]
			  forCellWithReuseIdentifier:[SYNFeedVideoSmallCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedChannelLargeCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelLargeCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedChannelSmallCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelSmallCell reuseIdentifier]];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveInfoBar:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.infoView addGestureRecognizer:panRecognizer];

    [self.infoViewContainer addGestureRecognizer:panRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.feedCollectionView reloadData];
	[self.navigationController.navigationBar setBackgroundTransparent:NO];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[super scrollViewDidScroll:scrollView];
}

#pragma mark - Overridden

- (SYNFeedChannelCell *)channelCellForIndexPath:(NSIndexPath *)indexPath
								 collectionView:(UICollectionView *)collectionView {
	
	NSString *reuseIdentifier = [SYNFeedChannelLargeCell reuseIdentifier];
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
																forIndexPath:indexPath];
}

- (SYNFeedVideoCell *)videoCellForIndexPath:(NSIndexPath *)indexPath
							 collectionView:(UICollectionView *)collectionView {
	
	NSString *reuseIdentifier = [SYNFeedVideoLargeCell reuseIdentifier];
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(768, 1024);
    } else {
        NSLog(@"left constant : %f", self.rightConstant.constant);
        return CGSizeMake(self.rightConstant.constant, 768);
    }
    
	return CGSizeZero;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    [self setWebViewHTML];
}

- (void)setWebViewHTML {
    FeedItem *feedItem = [self.model feedItemAtindex:[self currentPage]];
	
	if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo) {
        VideoInstance *videoInstance = [self.model resourceForFeedItem:feedItem];
        NSURL *templateURL = [[NSBundle mainBundle] URLForResource:HTMLTemplateFilename withExtension:@"html"];
        NSString *templateString = [NSString stringWithContentsOfURL:templateURL encoding:NSUTF8StringEncoding error:nil];
        NSString *HTMLString = [templateString stringByReplacingOccurrencesOfString:@"%{DESCRIPTION}" withString:videoInstance.video.videoDescription];
        [self.infoView loadHTMLString:HTMLString baseURL:nil];
	}
}

#pragma mark - Private

- (BOOL)isLargeCellAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger blockNumber = (indexPath.item / 3);
	NSInteger blockOffset = (indexPath.item % 3);
	
	BOOL isEvenBlock = (blockNumber % 2 == 0);
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		return (blockOffset == 0);
	} else {
		return (isEvenBlock ? (blockOffset == 0) : (blockOffset == 2));
	}
}

#pragma mark - Pan Gesture
- (void)moveInfoBar:(UIPanGestureRecognizer *)recognizer {
    
    [self.view bringSubviewToFront:[(UIPanGestureRecognizer*)recognizer view]];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
    
    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateBegan) {
        self.firstX = self.rightConstant.constant;
    }

    if (self.firstX+translatedPoint.x > 415 &&  self.firstX+translatedPoint.x < 1000) {
        [self.rightConstant setConstant:(self.firstX+translatedPoint.x)];
        [self.feedCollectionView.collectionViewLayout invalidateLayout];
    }
    
    
    if (self.firstX+translatedPoint.x < 415) {
        [self.rightConstant setConstant:415];
        [self.feedCollectionView.collectionViewLayout invalidateLayout];

    }
}

- (NSInteger)currentPage {
    CGPoint contentOffset = self.feedCollectionView.contentOffset;
    CGSize viewSize = self.feedCollectionView.bounds.size;
    
    NSInteger verticalPage = MAX(0.0, contentOffset.y / viewSize.height);
    
    return verticalPage;
}

- (void)clickToMore:(UIButton *)button withURL:(NSURL *)url {
    
	[self.infoView loadRequest:[NSURLRequest requestWithURL:url]];
}


@end
