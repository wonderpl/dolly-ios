//
//  SYNCommentingCollectionViewCell.h
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNCommentingCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* commentLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;

@end
