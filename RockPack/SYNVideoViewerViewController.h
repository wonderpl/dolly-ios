//
//  SYNVideoViewerViewController.h
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class SYNMasterViewController;

@interface SYNVideoViewerViewController : SYNAbstractViewController

- (id) initWithVideoInstanceArray: (NSArray *) videoInstanceArray
                    selectedIndex: (int) selectedIndex;

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) SYNMasterViewController *overlayParent;
@property (nonatomic, assign) BOOL shownFromChannelScreen;
@property (nonatomic, strong) IBOutlet UIImageView *iPhonePanelImageView;


- (void) playIfVideoActive;
- (void) pauseIfVideoActive;

- (void) prepareForAppearAnimation;
- (void) runAppearAnimation;

- (void)userTouchedMaxMinButton;

@end
