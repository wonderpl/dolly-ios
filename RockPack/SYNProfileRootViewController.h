//
//  SYNYouRootViewController.h
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "ChannelOwner.h"

@protocol MoveTabDelegate <NSObject>
@optional
-(void)moveTab:(UIScrollView*)scrollView;
@end


@interface SYNProfileRootViewController : SYNAbstractViewController

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, assign) BOOL hideUserProfile;
@property (nonatomic,assign) id<MoveTabDelegate> moveTabDelegate;

- (void) deleteChannel;

@end
