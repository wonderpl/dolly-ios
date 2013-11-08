//
//  SYNAbstractVideoPlaybacViewController.h
//  dolly
//
//  Created by Nick Banks on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
@import Foundation;

@interface SYNAbstractVideoPlaybackViewController : GAITrackedViewController

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong) UIButton *shuttleBarMaxMinButton;
@property (nonatomic, strong) UIView *shuttleBarView;
@property (nonatomic, strong) VideoInstance *currentVideoInstance;

// Player control
- (void) playVideoAtIndex: (int) index;

@end
