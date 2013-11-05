//
//  SYNImplicitSharingController.h
//  rockpack
//
//  Created by Michael Michailidis on 06/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

typedef void (^ImplicitSharingCompletionBlock) (BOOL);

@interface SYNImplicitSharingController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *notNowButton;
@property (strong, nonatomic) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (copy, readwrite) ImplicitSharingCompletionBlock completionBlock;

+(id)controllerWithBlock:(ImplicitSharingCompletionBlock)block;
-(void)dismiss;
@end
