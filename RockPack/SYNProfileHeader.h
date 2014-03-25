//
//  SYNProfileHeader.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelOwner.h"
#import "AppConstants.h"
#import "SYNProfileDelegate.h"

@interface SYNProfileHeader : UICollectionReusableView

@property (nonatomic, strong) ChannelOwner *channelOwner;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *coverImageTop;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *coverImageBottom;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic, strong, readonly) UIImageView *coverImage;
@property (nonatomic, strong, readonly) UIView *outerViewFullNameLabel;
@property (nonatomic, readonly) UILabel *fullNameLabel;
@property (nonatomic, weak) id<SYNProfileDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedController;


-(void) setCoverphotoImage: (NSString*) thumbnailURL;
-(void) setProfileImage : (NSString*) thumbnailURL;
-(void) setDescriptionText : (NSString*) text; 

@end
