//
//  SYNWonderMailActivity.m
//  dolly
//
//  Created by Sherman Lo on 17/02/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNWonderMailActivity.h"
#import "OWActivityViewController.h"
#import "SYNOneToOneSharingController.h"

@implementation SYNWonderMailActivity

- (id)init {
    self = [super initWithTitle: NSLocalizedStringFromTable(@"activity.Mail.title", @"OWActivityViewController", @"Mail")
                          image: [UIImage imageNamed: @"ShareMailButton"]
                    actionBlock: nil];
    
    if (!self) {
        return nil;
    }
	
    self.actionBlock = ^(OWActivity *activity, OWActivityViewController *activityViewController) {
		SYNOneToOneSharingController *shareViewController = (SYNOneToOneSharingController *)activityViewController.presentingController;
		[shareViewController.searchBar becomeFirstResponder];
    };
    
    return self;
}

@end
