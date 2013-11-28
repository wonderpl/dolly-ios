//
//  SYNChannelCreateNewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNChannelCreateNewCelllDelegate <NSObject>

- (void) createCellTapped;
- (void) followButtonTapped: (UICollectionViewCell *) cell;
@end

@interface SYNChannelCreateNewCell : UICollectionViewCell <UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *bottomBarView;
@property (strong, nonatomic) IBOutlet UIView *boarderView;
@property (strong, nonatomic) IBOutlet UITextField *createTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *createCellButton;
@property (nonatomic, weak) id<SYNChannelCreateNewCelllDelegate> viewControllerDelegate;

@end
