//
//  SYNAccountSettingsModalContainer.m
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingsModalContainer.h"
#import "SYNAccountSettingsTextInputController.h"
#import "UIFont+SYNFont.h"



@interface SYNAccountSettingsModalContainer ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (copy) DoneButtonBlock doneBlock;

@end

@implementation SYNAccountSettingsModalContainer

#pragma mark - Object lifecycle

- (id) initWithNavigationController: (UINavigationController*) navigationController
                 andCompletionBlock: (DoneButtonBlock) block
{
    if (self = [super initWithNibName: @"SYNAccountSettingsModalContainer"
                              bundle: [NSBundle mainBundle]])
    {
        childNavigationController = navigationController;
        childNavigationController.delegate = self;
        [self addChildViewController:childNavigationController];
        _doneBlock = block;
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
    childNavigationController.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0.0, 0.0, 320.0, 600.0);
    
    [self.contentView addSubview:childNavigationController.view];
    
    self.backgroundImage.image = [[UIImage imageNamed: @"PanelMenuSecondLevel"] resizableImageWithCapInsets: UIEdgeInsetsMake(65, 0, 1, 0)];
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
    self.titleLabel.text = NSLocalizedString(@"SETTINGS",nil);
	
}


- (IBAction) backButtonTapped: (id) sender
{
    [childNavigationController popViewControllerAnimated:YES];
}


- (IBAction) doneButtonTapped: (id) sender
{
    UIViewController* viewController = [childNavigationController topViewController];
    
    if (viewController == childNavigationController.viewControllers[0])
    {
        self.doneBlock();
    }
    else
    {
        if ([viewController isKindOfClass: [SYNAccountSettingsTextInputController class]])
        {
            SYNAccountSettingsTextInputController* controller = (SYNAccountSettingsTextInputController*)viewController;
            [controller saveButtonPressed: nil];
        }
    }
}


- (void) setModalViewFrame: (CGRect) newFrame
{
    self.view.frame = newFrame;
    childNavigationController.view.frame = self.contentView.bounds;
}


#pragma mark - navigation controller delegate

- (void) navigationController: (UINavigationController *)navigationController
       willShowViewController: (UIViewController *) viewController
                     animated: (BOOL) animated
{
   if (viewController == navigationController.viewControllers[0])
   {
       self.doneButton.hidden = NO;
       self.backButton.hidden = NO;
       
       [self.doneButton setImage: [UIImage imageNamed: @"ButtonSettingsDone"]
                        forState: UIControlStateNormal];
       
       [self.doneButton setImage: [UIImage imageNamed: @"ButtonSettingsDoneHighlighted"]
                        forState: UIControlStateHighlighted];
       
       [UIView animateWithDuration: 0.3f
                             delay: 0.0f
                           options: UIViewAnimationOptionCurveEaseInOut
                        animations: ^{
                            self.doneButton.alpha = 1.0f;
                            self.backButton.alpha = 0.0f;
                        }
                        completion:^(BOOL finished) {
                            self.doneButton.hidden = NO;
                            self.backButton.hidden = YES;
                        }];
   }
    else
    {
        BOOL hideDoneButton = YES;
        if ([viewController isKindOfClass: [SYNAccountSettingsTextInputController class]])
        {
            hideDoneButton = NO;
            SYNAccountSettingsTextInputController* controller = (SYNAccountSettingsTextInputController*)viewController;
            //On iPhone we want to use our donebutton
            [controller.saveButton removeFromSuperview];
            //Reassign the save button to our done button
            controller.saveButton = self.doneButton;
            
            [self.view addSubview:controller.spinner];
            controller.spinner.center = self.doneButton.center;
            
            [self.doneButton setImage: [UIImage imageNamed: @"ButtonSettingsSave"]
                             forState: UIControlStateNormal];
            
            [self.doneButton setImage: [UIImage imageNamed: @"ButtonSettingsSaveHighlighted"]
                             forState: UIControlStateHighlighted];
        }
        
        self.doneButton.hidden = NO;
        self.backButton.hidden = NO;
        
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             self.doneButton.alpha = hideDoneButton? 0.0f : 1.0f;
                             self.backButton.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             self.doneButton.hidden = hideDoneButton;
                             self.backButton.hidden = NO;
                             
                         }];
    }
}


@end
