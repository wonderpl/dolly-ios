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
    
    if (IS_IPHONE)
    {
        [self.createTextField setFont:[UIFont lightCustomFontOfSize:15]];
    }else{
        [self.createTextField setFont:[UIFont lightCustomFontOfSize:18]];
    }
    [self.boarderView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];
    
    
    [self.descriptionTextView.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];

    [self.createTextField.layer setBorderColor:[[UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f]CGColor]];

    self.descriptionTextView.alpha = 0.0f;

    if (IS_RETINA) {
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

@end
