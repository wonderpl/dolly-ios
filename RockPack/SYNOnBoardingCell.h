//
//  SYNOnBoardingCell.h
//  dolly
//
//  Created by Michael Michailidis on 25/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialActionsDelegate.h"
#import "SYNAvatarButton.h"
#import "SYNSocialButton.h"

@interface SYNOnBoardingCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet SYNAvatarButton* avatarButton;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* descriptionLabel;

@property (nonatomic, strong) IBOutlet SYNSocialButton* followButton;


@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;

@end
