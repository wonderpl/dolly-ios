//
//  SYNHomeTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNAggregateCellDelegate.h"

@interface SYNFeedRootViewController : SYNAbstractViewController <SYNAggregateCellDelegate>


- (void) removeEmptyGenreMessage;

- (void) displayEmptyGenreMessage: (NSString*) messageKey
                        andLoader: (BOOL) isLoader;

@end
