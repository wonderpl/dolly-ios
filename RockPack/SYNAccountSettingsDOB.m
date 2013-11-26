//
//  SYNAccountSettingsDOB.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAccountSettingsDOB.h"
#import "SYNAppDelegate.h"
#import "User.h"

@interface SYNAccountSettingsDOB ()


@end

@implementation SYNAccountSettingsDOB

@synthesize datePicker;


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"accountPropertyChanged"
                                                            label: @"Date of birth"
                                                            value: nil] build]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(0.0, (IS_IPHONE ? 60.0f : 0.0f), 280.0, 280.0);
    
    self.view.frame = frame;
    
    datePicker = [[UIDatePicker alloc] initWithFrame: frame];
    [datePicker setDatePickerMode: UIDatePickerModeDate];
    [self.view addSubview: datePicker];
    
    self.title = @"Choose a Date";
    
}





@end
