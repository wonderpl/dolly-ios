//
//  SYNInstructionsToShareControllerViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 12/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNInstructionsToShareControllerViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNAbstractViewController.h"

typedef enum InstructionsShareState {

    InstructionsShareStateInit = 0,
    InstructionsShareStatePressAndHold,
    InstructionsShareStateChooseAction,
    InstructionsShareStateGoodJob,
    InstructionsShareStateShared

} InstructionsShareState;
@interface SYNInstructionsToShareControllerViewController () {
    
}

#define STD_FADE_TEXT 0.2f

@property (strong, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *subLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIView* backgroundView;
@property (weak, nonatomic) SYNAbstractViewController* delegate;
@property (nonatomic) InstructionsShareState state;

@end

@implementation SYNInstructionsToShareControllerViewController

-(id)initWithDelegate:(SYNAbstractViewController*)delegate
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])
    {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.state = 0; // init state, should already be set so will ignored
    
    
    
    self.subLabel.font = [UIFont rockpackFontOfSize:self.subLabel.font.pointSize];
    self.instructionsLabel.font = [UIFont rockpackFontOfSize:self.instructionsLabel.font.pointSize];
    
    UITapGestureRecognizer* tapToCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToClose:)];
    [self.backgroundView addGestureRecognizer:tapToCloseGesture];
    
    self.videoImageView.alpha = 0.0f;
    self.videoImageView.userInteractionEnabled = NO;
    UILongPressGestureRecognizer* videoLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOverVideoImagePerformed:)];
    [self.videoImageView addGestureRecognizer:videoLongPress];
    
    self.videoImageView.backgroundColor = [UIColor redColor];
    
}

-(void)longPressOverVideoImagePerformed:(UILongPressGestureRecognizer*)recogniser
{
    [self.delegate arcMenuUpdateState:recogniser];
}

-(void)tapToClose:(UIGestureRecognizer*)recogniser
{
    [self.backgroundView removeGestureRecognizer:self.backgroundView.gestureRecognizers[0]]; // remove the tap gesture for house keeping
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewStackManager removeCoverPopoverViewController]; // hide self
    
}

-(IBAction)okayButtonPressed:(id)sender
{
    self.okButton.enabled = NO;
    self.state += 1;
}

-(void)setState:(InstructionsShareState)state
{
    if(_state == state)
        return;
    
    _state = state;
    
    switch (_state)
    {
        case InstructionsShareStateInit:
            self.instructionsLabel.text = NSLocalizedString(@"instruction_initial", nil);
            self.subLabel.text = NSLocalizedString(@"instruction_initial_subtext", nil);
            self.subLabel.hidden = NO;
            break;
            
        case InstructionsShareStatePressAndHold:
        {
            [UIView animateWithDuration:STD_FADE_TEXT animations:^{
                
                self.instructionsLabel.alpha = 0.0f;
                self.subLabel.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                
                self.instructionsLabel.text = NSLocalizedString(@"instruction_press_hold", nil);
                self.subLabel.text = @"";
                
                self.videoImageView.userInteractionEnabled = YES;
                
                [UIView animateWithDuration:STD_FADE_TEXT animations:^{
                    self.videoImageView.alpha = 1.0;
                    self.instructionsLabel.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    
                    self.okButton.enabled = YES;
                    
                }];
            }];
            
            self.subLabel.hidden = YES;
        }
            break;
            
        case InstructionsShareStateChooseAction:
        {
            
            [UIView animateWithDuration:STD_FADE_TEXT animations:^{
                
                self.instructionsLabel.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                
                self.instructionsLabel.text = NSLocalizedString(@"instruction_choose_action", nil);
                
                [UIView animateWithDuration:STD_FADE_TEXT animations:^{
                    
                    self.instructionsLabel.alpha = 1.0f;
                    
                } completion:^(BOOL finished) {
                    
                    self.okButton.enabled = YES;
                    
                }];
                
            }];
            
        }
            
            break;
            
        case InstructionsShareStateGoodJob:
        {
            [UIView animateWithDuration:STD_FADE_TEXT animations:^{
                
                self.instructionsLabel.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                
                self.instructionsLabel.text = NSLocalizedString(@"instruction_good_job", nil);
                
                [UIView animateWithDuration:STD_FADE_TEXT animations:^{
                    
                    self.instructionsLabel.alpha = 1.0f;
                    
                } completion:^(BOOL finished) {
                    
                    self.okButton.enabled = YES;
                    
                }];
                
            }];
        }
            
            break;
            
        case InstructionsShareStateShared:
        {
            self.instructionsLabel.text = NSLocalizedString(@"channels_screen_loading_categories", nil);
        }
            
            break;
            
            
    }
    
}


@end