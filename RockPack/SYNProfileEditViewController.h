//
//  SYNProfileEditViewController.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNProfileEditDelegate.h"
#import "UIPlaceHolderTextView.h"

@interface SYNProfileEditViewController : SYNAbstractViewController
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *descriptionTextView;
@property (strong, nonatomic) NSString *descriptionString;
@property (nonatomic, weak) id<SYNProfileEditDelegate> delegate;

@end
