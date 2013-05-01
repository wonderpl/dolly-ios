//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchRootViewController.h"

#import "SYNSearchVideosViewController.h"
#import "SYNSearchChannelsViewController.h"
#import "AppConstants.h"
#import "SYNDeviceManager.h"
#import "SYNSearchTabView.h"

@interface SYNSearchRootViewController ()

@property (nonatomic) NSInteger tabSelected;

@property (nonatomic, strong) SYNSearchVideosViewController* searchVideosController;
@property (nonatomic, strong) SYNSearchChannelsViewController* searchChannelsController;

@property (nonatomic, weak) SYNAbstractViewController* currentController;

@property (nonatomic, weak) UIView* currentOverlayView;

@property (nonatomic, strong) NSString* currentSelectionId;

@property (nonatomic, strong) SYNSearchTabView* videoSearchTabView;
@property (nonatomic, strong) SYNSearchTabView* channelsSearchTabView;
@property (nonatomic, strong) UIView* tabsContainer;


@end

@implementation SYNSearchRootViewController
@synthesize tabsContainer;
@synthesize videoSearchTabView, channelsSearchTabView;

-(id)initWithViewId:(NSString *)vid
{
    if (self = [super initWithViewId:vid]) {
        self.title = kSearchTitle;
    }
    return self;
}

-(void)loadView
{
    
    CGRect frame = CGRectMake(0.0, 0.0,[[SYNDeviceManager sharedInstance] currentScreenWidth],
                               [[SYNDeviceManager sharedInstance] currentScreenHeight]);
    
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [[SYNDeviceManager sharedInstance] isIPad]?[UIColor clearColor]:[UIColor colorWithWhite:0.97f alpha:1.0f];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.videoSearchTabView = [SYNSearchTabView tabViewWithSearchType:SearchTabTypeVideos];
    self.channelsSearchTabView = [SYNSearchTabView tabViewWithSearchType:SearchTabTypeChannels];
    
    CGRect channelTabRect = self.channelsSearchTabView.frame;
    channelTabRect.origin.x = self.videoSearchTabView.frame.size.width;
    self.channelsSearchTabView.frame = channelTabRect;
    
    tabsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                            self.channelsSearchTabView.frame.size.width * 2.0,
                                                            self.channelsSearchTabView.frame.size.height)];
    
    
    
    [tabsContainer addSubview:self.channelsSearchTabView];
    [tabsContainer addSubview:self.videoSearchTabView];
    
    [self.videoSearchTabView addTarget:self action:@selector(videoTabPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.channelsSearchTabView addTarget:self action:@selector(channelTabPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    tabsContainer.center = CGPointMake(self.view.center.x, self.channelsSearchTabView.frame.size.height/2 + 65.0f);
    tabsContainer.frame = CGRectIntegral(tabsContainer.frame);
    
    
    [self.view addSubview:tabsContainer];
    
    // Google Analytics support
    self.trackedViewName = @"Search - Root";
}

-(void)videoTabPressed:(UIControl*)control
{
    
    
   if(self.videoSearchTabView.selected)
       return;
    
    self.videoSearchTabView.selected = YES;
    self.channelsSearchTabView.selected = NO;
    
    
    [self showVideoSearchResults];
    
}

-(void)channelTabPressed:(UIControl*)control
{
    
    
    if(self.channelsSearchTabView.selected)
        return;
    
    self.channelsSearchTabView.selected = YES;
    self.videoSearchTabView.selected = NO;
    
    [self showChannelsSearchResult];
}

-(void)showVideoSearchResults
{
    SYNAbstractViewController* newController;
    [self.view insertSubview:self.searchVideosController.view belowSubview:tabsContainer];
    newController = self.searchVideosController;
    
    
    if(self.currentController)
        [self.currentController.view removeFromSuperview];
    
    self.currentController = newController;
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        CGRect collectionViewFrame = CGRectMake(0,108.0f,320.0f,self.view.frame.size.height - 108.0f);
        self.currentController.videoThumbnailCollectionView.frame = collectionViewFrame;
    }
    
}
-(void)showChannelsSearchResult
{
    SYNAbstractViewController* newController;
    [self.view insertSubview:self.searchChannelsController.view belowSubview:tabsContainer];
    newController = self.searchChannelsController;
    
    if(self.currentController)
        [self.currentController.view removeFromSuperview];
    
    self.currentController = newController;
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        CGRect collectionViewFrame = CGRectMake(0,108.0f,320.0f,self.view.frame.size.height - 108.0f);
        self.currentController.videoThumbnailCollectionView.frame = collectionViewFrame;
    }
}




-(void)showSearchResultsForTerm:(NSString*)newSearchTerm
{
    
    if(searchTerm && [searchTerm isEqualToString:newSearchTerm])
        return;
    
    
    searchTerm = newSearchTerm;
    
    if(!searchTerm)
        return;
    
    if(!viewIsOnScreen)
        return;
    
    
    [self performSearchForCurrentSearchTerm];
    
    
}




-(void)viewWillAppear:(BOOL)animated
{
    
    // TODO: Check why we have to invert
    
    self.searchVideosController = [[SYNSearchVideosViewController alloc] initWithViewId:viewId];
    self.searchVideosController.itemToUpdate = self.videoSearchTabView;
    self.searchVideosController.parent = self;
    [self addChildViewController:self.searchVideosController];
    
    self.searchChannelsController = [[SYNSearchChannelsViewController alloc] initWithViewId:viewId];
    self.searchChannelsController.itemToUpdate = self.channelsSearchTabView;
    self.searchChannelsController.parent = self;
    [self addChildViewController:self.searchChannelsController];
    
    viewIsOnScreen = YES;
    
    if(searchTerm)
        [self performSearchForCurrentSearchTerm];
    
    
}

-(void)performSearchForCurrentSearchTerm
{
    
    [self clearOldSearchData];
    
    if(!self.currentController)
        [self videoTabPressed:nil];
    
    
    [self.searchVideosController performSearchWithTerm:searchTerm];
    [self.searchChannelsController performSearchWithTerm:searchTerm];
}

-(void)clearOldSearchData
{
    
    [appDelegate.searchRegistry clearImportContextFromEntityName:@"VideoInstance"];
    
    [appDelegate.searchRegistry clearImportContextFromEntityName:@"Channel"];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self clearController];
    
}

-(void)clearController
{
    
    //searchTerm = nil;
    
    viewIsOnScreen = NO;
    
    searchTerm = nil;
    
    self.videoSearchTabView.selected = NO;
    self.channelsSearchTabView.selected = NO;
    
    
    [self.currentController.view removeFromSuperview];
    
    self.currentController = nil;
    
    
    self.searchVideosController = nil;
    self.searchChannelsController = nil;
}




-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    CGFloat newWidth = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 1024.0 : 768.0;
    tabsContainer.center = CGPointMake(newWidth * 0.5, tabsContainer.center.y);
    [self.searchChannelsController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchVideosController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchVideosController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchChannelsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.searchVideosController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.searchChannelsController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
