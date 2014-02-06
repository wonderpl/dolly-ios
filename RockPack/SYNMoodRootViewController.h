//
//  SYNMoodViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNVideoCellDelegate.h"
#import "SYNVideoPlayerAnimator.h"

@interface SYNMoodRootViewController : SYNAbstractViewController <SYNSocialActionsDelegate, SYNVideoCellDelegate,SYNVideoPlayerAnimatorDelegate>
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;

@end
