//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNDeviceManager.h"
#import "SYNSearchBoxViewController.h"
#import "SYNSearchChannelsViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchUsersViewController.h"
#import "SYNSearchVideosViewController.h"

@interface SYNSearchRootViewController ()

@property (nonatomic) NSInteger tabSelected;
@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) NSString *currentSelectionId;
@property (nonatomic, strong) NSString *lastSearchTerm;
@property (nonatomic, strong) SYNSearchChannelsViewController *searchChannelsController;
@property (nonatomic, strong) SYNSearchTabView *channelsSearchTabView;
@property (nonatomic, strong) SYNSearchTabView *usersSearchTabView;
@property (nonatomic, strong) SYNSearchTabView *videoSearchTabView;
@property (nonatomic, strong) SYNSearchUsersViewController *searchUsersController;
@property (nonatomic, strong) SYNSearchVideosViewController *searchVideosController;
@property (nonatomic, strong) UIView *tabsContainer;
@property (nonatomic, weak) SYNAbstractViewController *currentController;
@property (nonatomic, weak) UIView *currentOverlayView;

@end


@implementation SYNSearchRootViewController

#pragma mark - Object lifcyle

- (void) dealloc
{
    viewIsOnScreen = NO;
    
    searchTerm = nil;
    
    self.videoSearchTabView.selected = NO;
    self.channelsSearchTabView.selected = NO;
    
    [self.currentController.view removeFromSuperview];
    
    self.currentController = nil;
    
    self.searchVideosController = nil;
    self.searchChannelsController = nil;
}


#pragma mark - View lifecyle

- (void) loadView
{
    
    if (IS_IOS_7_OR_GREATER)
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    CGRect frame = CGRectMake(0.0, 0.0, [SYNDeviceManager.sharedInstance currentScreenWidth],
                              [SYNDeviceManager.sharedInstance currentScreenHeight]);
    
    self.view = [[UIView alloc] initWithFrame: frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.videoSearchTabView = [SYNSearchTabView tabViewWithSearchType: SearchTabTypeVideos];
    self.channelsSearchTabView = [SYNSearchTabView tabViewWithSearchType: SearchTabTypeChannels];
    self.usersSearchTabView = [SYNSearchTabView tabViewWithSearchType: SearchTabTypeUsers];
    
    NSArray *tabsArray = @[self.videoSearchTabView, self.channelsSearchTabView, self.usersSearchTabView];
    
    self.tabsContainer = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0f, // set below
                                                                   self.channelsSearchTabView.frame.size.width * tabsArray.count,
                                                                   self.channelsSearchTabView.frame.size.height)];
    
    self.tabsContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    // position tabs correctly
    CGFloat offsetX = 0.0;
    CGRect tabRect;
    SYNSearchTabView *searchTab;
    
    for (int t = 0; t < tabsArray.count; t++)
    {
        searchTab = (SYNSearchTabView *) tabsArray[t];
        
        tabRect = searchTab.frame;
        tabRect.origin.x += offsetX;
        searchTab.frame = tabRect;
        offsetX += tabRect.size.width;
        
        [searchTab addTarget: self
                      action: @selector(searchTabPressed:)
            forControlEvents: UIControlEventTouchUpInside];
        
        [self.tabsContainer addSubview: searchTab];
    }
    
    CGFloat correctTabsY = IS_IPAD ? 104.0 : self.channelsSearchTabView.frame.size.height / 2 + 65.0f;
    if(IS_IOS_7_OR_GREATER)
        correctTabsY += 10.0f;
    self.tabsContainer.center = CGPointMake(self.view.center.x, correctTabsY);
    self.tabsContainer.frame = CGRectIntegral(self.tabsContainer.frame);
    
    [self.view addSubview: self.tabsContainer];
    
    // == Adding the main subviews == //
    self.searchVideosController = [[SYNSearchVideosViewController alloc] initWithViewId: viewId];
    self.searchVideosController.itemToUpdate = self.videoSearchTabView;
    self.searchVideosController.parent = self;
    [self addChildViewController: self.searchVideosController];
    
    [self.view insertSubview: self.searchVideosController.view
                belowSubview: self.tabsContainer];
    
    self.searchVideosController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (IS_IPHONE)
    {
        CGRect collectionViewFrame = CGRectMake(0, 108.0f, 320.0f, self.view.frame.size.height - 108.0f);
        self.searchVideosController.videoThumbnailCollectionView.frame = collectionViewFrame;
        self.searchVideosController.videoThumbnailCollectionView.backgroundColor = [UIColor colorWithWhite: 0.97f
                                                                                                     alpha: 1.0f];
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.currentController.videoThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets = layout.sectionInset;
        insets.top = 2.0f;
        insets.bottom = 10.0f;
        layout.sectionInset = insets;
    }
    else
    {
        CGRect collectionViewFrame = self.searchVideosController.view.frame;
        collectionViewFrame.size = self.view.frame.size;
        self.searchVideosController.view.frame = collectionViewFrame;
    }
    
    self.searchChannelsController = [[SYNSearchChannelsViewController alloc] initWithViewId: viewId]; // this is "Search"
    self.searchChannelsController.itemToUpdate = self.channelsSearchTabView;
    self.searchChannelsController.parent = self;
    [self addChildViewController: self.searchChannelsController];
    
    [self.view insertSubview: self.searchChannelsController.view
                belowSubview: self.tabsContainer];
    
    self.searchChannelsController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (IS_IPHONE)
    {
        // FIXME: This magic number layout is not so good. self.view needs to be setup with the correct frame, and then we can start doing a relative layout.
        CGRect collectionViewFrame = CGRectMake(0, 48.0f, 320.0f, self.view.frame.size.height - 103.0f);
        self.searchChannelsController.channelThumbnailCollectionView.frame = collectionViewFrame;
        self.searchChannelsController.channelThumbnailCollectionView.backgroundColor = [UIColor colorWithWhite: 0.97f
                                                                                                         alpha: 1.0f];
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.searchChannelsController.channelThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets = layout.sectionInset;
        insets.top = 5.0f;
        insets.bottom = 10.0f;
        layout.sectionInset = insets;
    }
    
    self.searchUsersController = [[SYNSearchUsersViewController alloc] initWithViewId: viewId];
    self.searchUsersController.itemToUpdate = self.usersSearchTabView;
    self.searchUsersController.parent = self;
    [self addChildViewController: self.searchUsersController];
    
    [self.view insertSubview: self.searchUsersController.view
                belowSubview: self.tabsContainer];
    
    self.controllers = @[self.searchVideosController,
                         self.searchChannelsController,
                         self.searchUsersController];
}


- (void) viewWillAppear: (BOOL) animated
{
    // TODO: Check why we have to invert
    
    [super viewWillAppear: animated];
    
    // FIXME: Replace with something more elegant (i.e. anything else)
    if (appDelegate.searchRefreshDisabled == YES)
    {
        return;
    }
    
    viewIsOnScreen = YES;
    
    if (searchTerm)
    {
        [self performSearchForCurrentSearchTerm];
    }
    
    if (!self.currentController)
    {
        [self searchTabPressed: nil];
    }
    
    if (IS_IPHONE)
    {
        [self.searchBoxViewController.searchBoxView revealCloseButton];
    }
}


- (void) viewWillDisappear: (BOOL) animated
{
    self.lastSearchTerm = searchTerm;
    
    [super viewWillDisappear: animated];
    
    // FIXME: Replace with something more elegant (i.e. anything else)
    if (appDelegate.searchRefreshDisabled == TRUE)
    {
        return;
    }
    
    if (IS_IPHONE)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAllNavControlsShow
                                                            object: self];
    }
}


- (void) searchTabPressed: (UIButton *) control
{
    // nil means select the first
    
    if (!control)
    {
        self.videoSearchTabView.selected = YES;
        self.channelsSearchTabView.selected = NO;
        self.usersSearchTabView.selected = NO;
        
        self.currentController = self.searchVideosController;
        [self logViewInGA: self.currentController];
        
        return;
    }
    
    // already selected
    
    if (control.selected)
    {
        return;
    }
    
    [self.controllers enumerateObjectsUsingBlock: ^(SYNAbstractViewController *controller, NSUInteger idx, BOOL *stop) {
        
        SYNSearchTabView *tabView = (SYNSearchTabView *) [controller valueForKey: @"itemToUpdate"];
         
         if ([tabView isClicked: control]) // return tabView.overButton == control
         {
             tabView.selected = YES;
             self.currentController = controller;
             [self logViewInGA: self.currentController];
         }
         else
         {
             tabView.selected = NO; // turn off the rest
             controller.view.hidden = YES;
         }
     }];
}


- (void) showSearchResultsForTerm: (NSString *) newSearchTerm
{
    if (searchTerm && [searchTerm isEqualToString: newSearchTerm])
    {
        return;
    }
    
    searchTerm = newSearchTerm;
    
    if (!searchTerm)
    {
        return;
    }
    
    if (!viewIsOnScreen)
    {
        return;
    }
    
    [self performSearchForCurrentSearchTerm];
}


#pragma mark - GA support

// Google analytics view logging
- (void) logViewInGA: (UIViewController *) currentViewController
{
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (currentViewController == self.searchVideosController)
    {
        // Video tab
        [tracker set: kGAIScreenName
               value: @"Search - Videos"];
    }
    else if (currentViewController == self.searchChannelsController)
    {
        // Channels tab
        [tracker set: kGAIScreenName
               value: @"Search - Channels"];
    }
    else
    {
        // Users tab
        [tracker set: kGAIScreenName
               value: @"Search - Users"];
    }
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
}


#pragma mark - Main Search Call

- (void) performSearchForCurrentSearchTerm
{
    BOOL success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"Channel"];
    
    if (!success)
    {
        DebugLog(@"Could not clean Channel from search context");
    }
    
    success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"VideoInstance"];
    
    if (!success)
    {
        DebugLog(@"Could not clean VideoInstances from search context");
    }
    
    success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"ChannelOwner"];
    
    if (!success)
    {
        DebugLog(@"Could not clean ChannelOwner from search context");
    }
    
    [self.searchVideosController performNewSearchWithTerm: searchTerm];
    [self.searchChannelsController performNewSearchWithTerm: searchTerm];
    [self.searchUsersController performNewSearchWithTerm: searchTerm];
}


- (void) setCurrentController: (SYNAbstractViewController *) currentController
{
    _currentController = currentController;
    
    [self.controllers enumerateObjectsUsingBlock: ^(SYNAbstractViewController *controller, NSUInteger idx, BOOL *stop) {
        controller.view.hidden = YES;
    }];
    
    _currentController.view.hidden = NO;
    
    // set the value for the entity to search
    
    appDelegate.searchEntity = _currentController.associatedEntity;
}


#pragma mark - Accessor

- (BOOL) alwaysDisplaysSearchBox
{
    return YES;
}


@end
