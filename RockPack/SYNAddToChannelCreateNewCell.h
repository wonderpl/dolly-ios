//
//  SYNChannelCreateNewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;
@class SYNAddToChannelViewController;

typedef enum {
    
    CreateNewChannelCellStateHidden = 0,
    CreateNewChannelCellStateEditing = 1,
    CreateNewChannelCellStateFinilizing = 2

} CreateNewChannelCellState;

@interface SYNAddToChannelCreateNewCell : UICollectionViewCell <UITextFieldDelegate, UITextViewDelegate>
{
    UIView* separatorTop;
}

@property (strong, nonatomic) UIView* separatorBottom;
@property (strong, nonatomic) IBOutlet UIButton *createNewButton;
@property (strong, nonatomic) IBOutlet UITextView* descriptionTextView;

@property (strong, nonatomic) IBOutlet UITextField* nameInputTextField;

@property (nonatomic) CreateNewChannelCellState state;
@property (nonatomic, weak) SYNAddToChannelViewController* delegate;

-(BOOL)isEditing;

@end
