//
//  SYNEmailAlertView.h
//  dolly
//
//  Created by Cong on 09/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAddEmailAlertView : NSObject

@property (nonatomic, strong) UIAlertView *alertView;


+ (instancetype) sharedInstance;
- (void)appBecameActive;
- (void)showAlertView;

@end
