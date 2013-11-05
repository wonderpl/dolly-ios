//
//  SYNAccountSettingsModalContainer.h
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

typedef void(^DoneButtonBlock)(void);

@interface SYNAccountSettingsModalContainer : UIViewController <UINavigationControllerDelegate> {
    UINavigationController* childNavigationController;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;

-(id)initWithNavigationController:(UINavigationController*)navigationController andCompletionBlock:(DoneButtonBlock)block;

-(void)setModalViewFrame:(CGRect)newFrame;

@end
