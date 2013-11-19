//
//  SYNCollectionVideoCell.h
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNSocialButton.h"
#import "SYNSocialAddButton.h"
#import "VideoInstance.h"
#import "SYNSocialActionsDelegate.h"

@interface SYNCollectionVideoCell : UICollectionViewCell
 
@property (strong, nonatomic) IBOutlet SYNSocialButton *likeControl;
@property (strong, nonatomic) IBOutlet SYNSocialAddButton *addControl;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareControl;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tap;


@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;
@property (nonatomic, weak) VideoInstance* videoInstance;


-(void) setUpVideoTap;

@end
