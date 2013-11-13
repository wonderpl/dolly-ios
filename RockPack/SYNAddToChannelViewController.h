//
//  SYNExistingChannelsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNPopoverable.h"

@interface SYNAddToChannelViewController : SYNAbstractViewController <SYNPopoverable>

- (IBAction) confirmButtonPressed: (id) sender;

@end
