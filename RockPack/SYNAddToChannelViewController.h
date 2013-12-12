//
//  SYNExistingChannelsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNPopoverable.h"

@class VideoInstance;

@interface SYNAddToChannelViewController : SYNAbstractViewController <SYNPopoverable>

@property (nonatomic, strong) VideoInstance *videoInstance;

- (IBAction) confirmButtonPressed: (id) sender;

@end
