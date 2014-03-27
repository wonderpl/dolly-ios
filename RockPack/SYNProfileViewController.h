//
//  SYNProfileViewController.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNProfileDelegate.h"
#import "SYNProfileEditDelegate.h"
#import "SYNProfileHeader.h"

@interface SYNProfileViewController : SYNAbstractViewController <SYNProfileDelegate,SYNProfileEditDelegate>

@property (nonatomic, strong) ChannelOwner* channelOwner;


@end
