//
//  SYNAbstractViewController.h
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers


#import "MKNetworkOperation.h"
#import "SYNAppDelegate.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNPopupMessageView.h"

@import CoreData;
@import UIKit;

@class VideoInstance, Channel, ChannelOwner;
@class SYNOneToOneSharingController;

@interface SYNAbstractViewController : UIViewController <UICollectionViewDelegate, SYNSocialActionsDelegate>
{
@protected
    SYNAppDelegate *appDelegate;
    NSString *viewId;
    NSString *abstractTitle;
}

@property (nonatomic) NSInteger dataItemsAvailable;
@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic) int offsetValue;
@property (nonatomic, assign, getter = isLoadingMoreContent) BOOL loadingMoreContent;
@property (nonatomic, readonly) NSString *viewId;
@property (nonatomic, strong) SYNChannelFooterMoreView *footerView;

- (id) initWithViewId: (NSString *) vid;

- (void) resetDataRequestRange;

- (void) incrementRangeForNextRequest;
- (BOOL) moreItemsToLoad;

// Share
- (void) requestShareLinkWithObjectType: (NSString *) objectType
                               objectId: (NSString *) objectId;

- (void) shareVideoInstance: (VideoInstance *) videoInstance;

- (void)shareChannel:(Channel *)channel;


- (SYNOneToOneSharingController *)createSharingViewControllerForShareObject:(id) shareObject
                                                                      image:(UIImage *)image;

- (SYNPopupMessageView*) displayPopupMessage: (NSString*) messageKey
                                  withLoader: (BOOL) isLoader;

- (void) removePopupMessage;

- (void)viewProfileDetails:(ChannelOwner *)channelOwner;
- (void)viewChannelDetails:(Channel *)channel withAnimation:(BOOL)animated;
- (void)viewVideoInstanceInChannel:(Channel*) channel withVideoId:videoId;

- (NSString *)trackingScreenName;

- (void)favouriteButtonPressed:(UIButton *)button videoInstance:(VideoInstance *)videoInstance;

- (void) applicationWillEnterForeground: (UIApplication *) application;

- (CGSize) footerSize;

- (void)followControlPressed:(UIButton *)button withChannelOwner:(ChannelOwner *)channelOwner completion :(void (^)(void))callbackBlock;
- (void)followButtonPressed:(UIButton *)button withChannel:(Channel *)channel completion :(void (^)(void))callbackBlock;



@end
