//
//  SYNTimecodeLabel.h
//  dolly
//
//  Created by Sherman Lo on 6/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNTimecodeLabel : UILabel

@property (nonatomic, assign) NSTimeInterval timecode;
@property (nonatomic, assign) NSTimeInterval maxTimecode;

@end
