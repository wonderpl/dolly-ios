//
//  SYNInstructionsToShareControllerViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 12/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYNAbstractViewController;

typedef enum InstructionsShareState : NSInteger {
    InstructionsShareStateNone = 0,
    InstructionsShareStatePressAndHold,
    InstructionsShareStateChooseAction,
    InstructionsShareStateGoodJob,
    InstructionsShareStatePacks
    
} InstructionsShareState;

@interface SYNInstructionsToShareControllerViewController : UIViewController

-(id)initWithDelegate:(SYNAbstractViewController*)delegate andState:(InstructionsShareState)iState;

@end
