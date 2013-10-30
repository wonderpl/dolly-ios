//
//  SYNRoundButton.h
//  dolly
//
//  Created by Nick Banks on 30/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNSocialButton : UIButton

- (void) setTitle: (NSString *) title;

- (void) setTitle: (NSString *) title
         andCount: (NSInteger) count;

@property (nonatomic, weak) id dataItemLinked;

@end
