//
//  SYNProfileViewController.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

/* 
 
 Profile has 3 different collectionviews, Each one has its own VC.
 SYNProfileViewController is a container for all the VC and using SYNProfileHeaderDelegate.h it switches VC's in and out.
 They all reuse the same SYNProfileHeader.
 	
 The initial idea was to have a single header but to get the same functionality without making it apart of the collectionview
 was to complicated to recreate using scrollview delegates. The simpler solution was to reuse the header views.
 
 Ideally a single header would be better.
 
 */

#import "SYNAbstractViewController.h"
#import "SYNProfileHeaderDelegate.h"
#import "SYNProfileEditDelegate.h"
#import "SYNProfileHeader.h"

@interface SYNProfileViewController : SYNAbstractViewController <SYNProfileHeaderDelegate,SYNProfileEditDelegate>

@property (nonatomic, strong) ChannelOwner* channelOwner;

+ (UINavigationController *)navigationControllerWithChannelOwner:(ChannelOwner*) channelOwner;
+ (UIViewController *)viewControllerWithChannelOwner:(ChannelOwner*) channelOwner;


@end
