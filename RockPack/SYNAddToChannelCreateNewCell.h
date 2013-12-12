//
//  SYNChannelCreateNewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

#import "AppConstants.h"
@class SYNAddToChannelViewController;


@interface SYNAddToChannelCreateNewCell : UICollectionViewCell <UITextFieldDelegate, UITextViewDelegate>
{
    UIView* separatorTop;
}

@property (strong, nonatomic) UIView* separatorBottom;
@property (strong, nonatomic) IBOutlet UIButton *createNewButton;
@property (strong, nonatomic) IBOutlet UITextView* descriptionTextView;

@property (strong, nonatomic) IBOutlet UITextField* nameInputTextField;

@property (nonatomic, assign, readonly) BOOL editedDescription;

@property (nonatomic) CreateNewChannelCellState state;
@property (nonatomic, weak) SYNAddToChannelViewController* delegate;

-(BOOL)isEditing;

@end
