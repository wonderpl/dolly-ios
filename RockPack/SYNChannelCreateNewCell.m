//
//  SYNChannelCreateNewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelCreateNewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNChannelCreateNewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
	[self.createTextField setFont:[UIFont regularCustomFontOfSize:self.createTextField.font.pointSize]];
    [self setBorder];
    //May not be a good idea to do this
    [self.createTextField setValue:[UIColor lightGrayColor]
                    forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.createTextField setFont:[UIFont lightCustomFontOfSize:self.createTextField.font.pointSize]];
    [self.descriptionTextView setFont:[UIFont lightCustomFontOfSize:self.descriptionTextView.font.pointSize]];
    [self.createCellButton.titleLabel setFont:[UIFont boldCustomFontOfSize:self.createCellButton.titleLabel.font.pointSize]];
    [self.descriptionPlaceholderLabel setFont:[UIFont lightCustomFontOfSize:self.descriptionPlaceholderLabel.font.pointSize]];
    [self.createCellButton setBackgroundColor:[UIColor whiteColor]];

}

- (void) setBorder {
    [self.descriptionTextView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    
    [self.createTextField.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    
    [self.boarderView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    
    if (IS_RETINA)
    {
        [self.descriptionTextView.layer setBorderWidth:0.5f];
        [self.createTextField.layer setBorderWidth:0.5f];
        [self.boarderView.layer setBorderWidth:0.5f];
    }
    else
    {
        [self.descriptionTextView.layer setBorderWidth:1.0f];
        [self.createTextField.layer setBorderWidth:1.0f];
        [self.boarderView.layer setBorderWidth:1.0f];
    }

    
    
}

- (void) setViewControllerDelegate: (id<SYNChannelCreateNewCelllDelegate>)  viewControllerDelegate
{
    
    _viewControllerDelegate = viewControllerDelegate;
    
    if(!_viewControllerDelegate)
        return;
    
    [self.createCellButton addTarget:_viewControllerDelegate
                                action:@selector(createNewButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];

    self.descriptionTextView.delegate = _viewControllerDelegate;
    self.createTextField.delegate = _viewControllerDelegate;

}

-(void)setState:(CreateNewChannelCellState)state
{
    
    _state = state;
    switch (_state)
    {
        case CreateNewChannelCellStateHidden:
            
            self.descriptionTextView.text = @"";
            self.createTextField.text = @"";
            self.descriptionTextView.hidden = YES;
            self.createTextField.hidden = YES;
            self.createCellButton.hidden = NO;
            self.descriptionPlaceholderLabel.hidden = YES;

            if (IS_IPAD) {
                CGRect tmpFrame = self.boarderView.frame;
                tmpFrame.size.height = 90;
                self.boarderView.frame = tmpFrame;
                [self setBorder];
			}
            
            break;
            
        case CreateNewChannelCellStateEditing:
            self.descriptionTextView.text = @"";
            self.createTextField.text = @"";
            self.descriptionTextView.hidden = NO;
            self.descriptionPlaceholderLabel.hidden = NO;
            self.createTextField.hidden = NO;
            self.createCellButton.hidden = YES;
            [self.createTextField becomeFirstResponder];

            
            if (IS_IPAD) {
                
                CGRect tmpFrame = self.boarderView.frame;
                tmpFrame.size.height = 174;
                self.boarderView.frame = tmpFrame;
                
                [self setBorder];
            }
            break;
            
        case CreateNewChannelCellStateFinilizing:
            
            break;
    }

}

@end
