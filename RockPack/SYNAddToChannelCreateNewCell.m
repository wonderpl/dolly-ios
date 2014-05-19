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
#import "SYNAddToChannelViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface SYNAddToChannelCreateNewCell ()

@property (nonatomic, assign) BOOL editedDescription;

@end

@implementation SYNAddToChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self.createNewButton.titleLabel setFont:[UIFont boldCustomFontOfSize:self.createNewButton.titleLabel.font.pointSize]];

    self.descriptionTextView.font = [UIFont regularCustomFontOfSize:self.descriptionTextView.font.pointSize];
    self.descriptionTextView.hidden = NO;
    self.descriptionTextView.alpha = 0.0f;
	self.descriptionTextView.textColor = [UIColor lightGrayColor];
    self.descriptionTextView.layer.borderColor = [[UIColor colorWithWhite:172/255.0 alpha:1.0] CGColor];
    self.descriptionTextView.layer.borderWidth = (IS_RETINA ? 0.5 : 1.0f);
    
    self.nameInputTextField.font = [UIFont regularCustomFontOfSize:self.nameInputTextField.font.pointSize];
    self.nameInputTextField.layer.borderColor = [[UIColor colorWithWhite:172/255.0 alpha:1.0] CGColor];
    self.nameInputTextField.layer.borderWidth = (IS_RETINA ? 0.5 : 1.0f);
    
    if(IS_IPAD)
    {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = (IS_RETINA ? 0.5 : 1.0f);
    }
    else // IS_IPHONE
    {
        // == Add two lines, one top one bottom
        
        
        
        CGRect lineFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, IS_RETINA ? 0.5 : 1.0);
        separatorTop = [[UIView alloc] initWithFrame:lineFrame];
        
        self.separatorBottom = [[UIView alloc] initWithFrame:lineFrame];
        
        separatorTop.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        self.separatorBottom.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        
        [self addSubview:separatorTop];
        [self addSubview:self.separatorBottom];
    }
    
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
    if(self.state == CreateNewChannelCellStateFinilizing) // has been into the description text view first
    {
        if(self.delegate)
            [self.delegate confirmButtonPressed:nil];
    }
     else if(self.state == CreateNewChannelCellStateEditing)
        self.state = CreateNewChannelCellStateFinilizing;
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    
    if ([text isEqualToString:@"\n"]) {
        
        [self.delegate confirmButtonPressed:nil];
        return NO;
    }  
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
	self.editedDescription = YES;
	self.descriptionTextView.textColor = [UIColor blackColor];
    self.descriptionTextView.text = @"";
}

-(void)setDelegate:(SYNAddToChannelViewController*)delegate
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
            
            // hack to get the cursor at the start rather than on the second line as it appears without this method.
            [self.descriptionTextView performSelector:@selector(setText:) withObject:@"" afterDelay:0.1f];
            break;
    }
}



// returns either of the two editing states
-(BOOL)isEditing
{
    return (self.state == CreateNewChannelCellStateEditing || self.state == CreateNewChannelCellStateFinilizing);
}

@end
