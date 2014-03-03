//
//  SYNAccountSettingsDOB.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingsDOB.h"
#import "SYNAppDelegate.h"
#import "User.h"

@interface SYNAccountSettingsDOB ()

@property (nonatomic, strong) UIDatePicker* datePicker;

@end

@implementation SYNAccountSettingsDOB

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(0.0, (IS_IPHONE ? 60.0f : 0.0f), 280.0, 280.0);
    
    self.view.frame = frame;
    
    [self.view addSubview:self.datePicker];
    
    self.title = @"Choose a Date";
    
}

- (UIDatePicker *)datePicker {
	if (!_datePicker) {
		CGRect frame = CGRectMake(0.0, (IS_IPHONE ? 60.0f : 0.0f), 280.0, 280.0);
		UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame: frame];
		[datePicker setDatePickerMode: UIDatePickerModeDate];
		
		self.datePicker = datePicker;
	}
	return _datePicker;
}


@end
