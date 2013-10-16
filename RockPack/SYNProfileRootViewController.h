//
//  SYNYouRootViewController.h
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "ChannelOwner.h"

@interface SYNProfileRootViewController : SYNAbstractViewController

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, assign) BOOL hideUserProfile;


- (void) deleteChannel;

@end
