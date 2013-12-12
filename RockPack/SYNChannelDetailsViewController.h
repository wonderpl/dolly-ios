//
//  SYNChannelDetailsViewController.h
//  dolly
//
//  Created by Cong on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"
#import "SYNSocialActionsDelegate.h"


@interface SYNChannelDetailsViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout, UIPopoverControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
SYNSocialActionsDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) kChannelDetailsMode mode;

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;




- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode;

@end
