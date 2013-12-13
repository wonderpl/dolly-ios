//
//  SYNCommentingCollectionViewCell.h
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

#define kCommentTextSizeWidth 200.0f

@interface SYNCommentingCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton* avatarButton;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UITextView* commentTextView;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loader;

@property (nonatomic, weak) NSDate* datePosted;

@property (nonatomic, strong) NSArray* mainElements; // to dim when loading

@property (nonatomic) BOOL loading;

@property (nonatomic, weak) Comment* comment;

+(UIFont*)commentFieldFont;
+(CGRect)commentFieldFrame;

@end
