//
//  SYNHomeTopTabViewController.h
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNSocialActionsDelegate.h"

@interface SYNFeedRootViewController : SYNAbstractViewController <SYNSocialActionsDelegate>


- (void) removeEmptyGenreMessage;

- (void) displayEmptyGenreMessage: (NSString*) messageKey
                        andLoader: (BOOL) isLoader;

@end
