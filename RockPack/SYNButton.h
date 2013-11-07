//
//  SYNButton.h
//  dolly
//
//  Created by Nick Banks on 07/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

@interface SYNButton : UIButton

@property (nonatomic, strong) NSString* title;
@property (nonatomic, weak) id dataItemLinked;

- (void) setTitle: (NSString *) title
         andCount: (NSInteger) count;

@end
