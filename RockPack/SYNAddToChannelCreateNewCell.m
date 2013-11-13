//
//  SYNChannelCreateNewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAddToChannelCreateNewCell.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

#import <QuartzCore/QuartzCore.h>

@implementation SYNAddToChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.createNewButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.createNewButton.titleLabel.font.pointSize];
    
    self.descriptionTextView.hidden = NO;
    self.descriptionTextView.alpha = 0.0f;
    
    self.createNewButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.createNewButton.layer.borderWidth = 0.5f;
    
    self.nameInputTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.nameInputTextField.layer.borderWidth = 0.5f;
    
    if(IS_IPAD)
    {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
    }
    else // IS_IPHONE
    {
        // == Add two lines, one top one bottom
        
        CGRect lineFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
        separatorTop = [[UIView alloc] initWithFrame:lineFrame];
        
        self.separatorBottom = [[UIView alloc] initWithFrame:lineFrame];
        
        separatorTop.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        self.separatorBottom.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        
        [self addSubview:separatorTop];
        [self addSubview:self.separatorBottom];
        
    }
    
    self.descriptionTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.descriptionTextView.layer.borderWidth = 0.5f;
    
    self.state = CreateNewChannelCellStateHidden;
    
}

// set the bottom line's frame here so that it marches the variable size as it expands
-(void)layoutSubviews
{
    CGRect bottomLineFrame = self.separatorBottom.frame;
    bottomLineFrame.origin.y = self.frame.size.height - 1.0f;
    self.separatorBottom.frame = bottomLineFrame;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.state == CreateNewChannelCellStateFinilizing)
        NSLog(@"");
     else if(self.state == CreateNewChannelCellStateEditing)
        self.state = CreateNewChannelCellStateFinilizing;
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.descriptionTextView.text = @"";
}

-(void)setDelegate:(id)delegate
{
    if(_delegate)
    {
        [self.createNewButton removeTarget:_delegate
                                    action:@selector(createNewButtonPressed)
                          forControlEvents:UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [self.createNewButton addTarget:_delegate
                             action:@selector(createNewButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - State Management

-(void)setState:(CreateNewChannelCellState)state
{
    _state = state;
    switch (_state)
    {
        case CreateNewChannelCellStateHidden:
            self.nameInputTextField.hidden = YES;
            self.createNewButton.hidden = NO;
            break;
            
        case CreateNewChannelCellStateEditing:
            
            self.nameInputTextField.hidden = NO;
            self.createNewButton.hidden = YES;
            self.nameInputTextField.returnKeyType = UIReturnKeyNext;
            
            [self.nameInputTextField becomeFirstResponder];
            
            break;
            
        case CreateNewChannelCellStateFinilizing:
            
            
            self.nameInputTextField.returnKeyType = UIReturnKeyGo;
            
            [self.descriptionTextView becomeFirstResponder];
            break;
    }
}

// returns either of the two editing states
-(BOOL)isEditing
{
    return (self.state == CreateNewChannelCellStateEditing || self.state == CreateNewChannelCellStateFinilizing);
}

@end
