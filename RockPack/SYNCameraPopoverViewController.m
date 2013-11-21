//
//  SYNCameraPopoverViewController.m
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNCameraPopoverViewController.h"

@interface SYNCameraPopoverViewController ()

@end

@implementation SYNCameraPopoverViewController



-(void)viewDidLoad
{
    if (IS_IPAD) {
        [self.takePhotoButton.titleLabel setFont:[UIFont regularCustomFontOfSize:12.0f]];
        [self.chooseExistingPhotoButton.titleLabel setFont:[UIFont regularCustomFontOfSize:12.0f]];
    }
    
    
}

- (IBAction) userTouchedTakePhotoButton: (id) sender
{
    if ([self.delegate respondsToSelector: @selector(userTouchedTakePhotoButton)])
    {
        [self.delegate userTouchedTakePhotoButton];
    }
}


- (IBAction) userTouchedChooseExistingPhotoButton: (id) sender
{
    if ([self.delegate respondsToSelector: @selector(userTouchedChooseExistingPhotoButton)])
    {
        [self.delegate userTouchedChooseExistingPhotoButton];
    }
}

@end
