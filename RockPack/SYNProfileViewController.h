//
//  SYNProfileViewController.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNProfileHeaderDelegate.h"
#import "SYNProfileEditDelegate.h"
#import "SYNProfileHeader.h"

@interface SYNProfileViewController : SYNAbstractViewController <SYNProfileHeaderDelegate,SYNProfileEditDelegate>

@property (nonatomic, strong) ChannelOwner* channelOwner;

+ (UINavigationController *)navigationControllerWithChannelOwner:(ChannelOwner*) channelOwner;
+ (UIViewController *)viewControllerWithChannelOwner:(ChannelOwner*) channelOwner;


@end
