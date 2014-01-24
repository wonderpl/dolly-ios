//
//  SYNTimestampView.h
//  dolly
//
//  Created by Sherman Lo on 23/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNTimestampView : UIView

@property (nonatomic, assign) NSTimeInterval timestamp;

+ (instancetype)viewWithMaxDuration:(NSTimeInterval)maxDuration;

@end
