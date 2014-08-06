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
@property (nonatomic, assign) float firstY;
@property (strong, nonatomic) IBOutlet UIWebView *infoView;

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

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.feedCollectionView reloadData];

	[self.navigationController.navigationBar setBackgroundTransparent:NO];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[super scrollViewDidScroll:scrollView];
	
//	layout.blockLocation = (scrollView.contentOffset.y + scrollView.contentInset.top) / scrollView.bounds.size.height;
}

#pragma mark - Overridden

- (SYNFeedChannelCell *)channelCellForIndexPath:(NSIndexPath *)indexPath
								 collectionView:(UICollectionView *)collectionView {
	
	BOOL isLargeCell = [self isLargeCellAtIndexPath:indexPath];
	NSString *reuseIdentifier = [SYNFeedChannelLargeCell reuseIdentifier];
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
																forIndexPath:indexPath];
}

- (SYNFeedVideoCell *)videoCellForIndexPath:(NSIndexPath *)indexPath
							 collectionView:(UICollectionView *)collectionView {
	
	BOOL isLargeCell = [self isLargeCellAtIndexPath:indexPath];
	NSString *reuseIdentifier = [SYNFeedVideoLargeCell reuseIdentifier];
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FeedItem *feedItem = [self.model feedItemAtindex:indexPath.item];
	
	CGFloat collectionViewWidth = CGRectGetWidth(collectionView.bounds);
	BOOL isVideo = (feedItem.resourceTypeValue == FeedItemResourceTypeVideo);
	
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(768, 1024);
    } else {
        
        NSLog(@"%@", NSStringFromCGSize(CGSizeMake(964-self.leftConstant.constant, 768)));
        NSLog(@"left constant : %f", self.leftConstant.constant);
        return CGSizeMake(1024, 768);
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
        self.firstX = self.leftConstant.constant;
        self.firstY = [[recognizer view] center].y;
    }
    
    if (self.firstX-translatedPoint.x > -480 && self.firstX-translatedPoint.x < 0) {
        NSLog(@"translatedPoint : %f", self.firstX-translatedPoint.x);
        [self.leftConstant setConstant:(self.firstX-translatedPoint.x)];
    }
    
    if (self.firstX-translatedPoint.x > 0) {
        [self.leftConstant setConstant:0];
    }
    
    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
        
        if (self.firstX-translatedPoint.x > 0) {
            [self.leftConstant setConstant:0];
        }
    
        if (self.firstX-translatedPoint.x <= -480) {
            [self.leftConstant setConstant:-480];
        }
        
        

    }
    
}

- (NSInteger)currentPage {
    CGPoint contentOffset = self.feedCollectionView.contentOffset;
    CGSize viewSize = self.feedCollectionView.bounds.size;
    
    NSInteger verticalPage = MAX(0.0, contentOffset.y / viewSize.height);
    
    return verticalPage;
}



@end
