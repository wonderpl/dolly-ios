//
//  SYNCommentingCollectionViewCell.h
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYNCommentingViewController;
#import "NSDictionary+Validation.h"


#define kCommentTextSizeWidth 200.0f

@interface SYNCommentingCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIButton* avatarButton;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UITextView* commentTextView;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loader;

@property (nonatomic, weak) NSDate* datePosted;

@property (nonatomic, strong) NSArray* mainElements; // to dim when loading

@property (nonatomic) BOOL loading;

@property (nonatomic, weak) NSDictionary* comment;

@property (nonatomic) BOOL deletable; // only for user generated comments


@property (nonatomic) BOOL deleting;

@property (nonatomic, weak) SYNCommentingViewController* delegate;


+(UIFont*)commentFieldFont;
+(CGRect)commentFieldFrame;
+ (NSParagraphStyle *)paragraphStyle;


@end
