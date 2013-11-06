//
//  SYNRoundButton.h
//  dolly
//
//  Created by Nick Banks on 30/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

@interface SYNSocialButton : UIButton

@property (nonatomic, strong) NSString* title;

@property (nonatomic, weak) id dataItemLinked;

- (void) setTitle: (NSString *) title
         andCount: (NSInteger) count;

- (UIColor *) defaultColor;
- (UIColor *) selectedColor;
@end
