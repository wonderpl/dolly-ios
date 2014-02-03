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

@interface SYNMoodRootViewController : SYNAbstractViewController <UIPickerViewDelegate,  UIPickerViewDataSource,SYNSocialActionsDelegate, SYNVideoCellDelegate>
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, weak) id<SYNSocialActionsDelegate, SYNVideoCellDelegate> delegate;

@end
