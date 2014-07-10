//
//  SYNEmailAlertView.m
//  dolly
//
//  Created by Cong on 09/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAddEmailAlertView.h"
#import "NSString+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"


static NSString *const kEmailReminderFirstUseDate = @"kEmailReminderFirstUseDate";
static NSString *const kEmailReminderUseCount = @"kEmailReminderUseCount";
static NSString *const kEmailReminderRequestDate = @"kEmailReminderRequestDate";

static NSInteger const kUseCount = 5;
static NSInteger const kNumberOfDays = 5;

@interface SYNAddEmailAlertView () <UIAlertViewDelegate>

@property (nonatomic, strong) NSDate *firstUseDate;
@property (nonatomic, strong) NSDate *endUseDate;
@property (nonatomic, assign) NSInteger useCount;
@end

@implementation SYNAddEmailAlertView


+ (instancetype) sharedInstance
{
    static dispatch_once_t onceQueue;
    static SYNAddEmailAlertView *emailReminder = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      emailReminder = [[self alloc] init];
                  });
    
    return emailReminder;
}


- (id)init {
	if (self = [super init]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if (![userDefaults valueForKey:kEmailReminderFirstUseDate]) {
            
            self.firstUseDate = [NSDate date];
			[userDefaults setObject:self.firstUseDate forKey:kEmailReminderFirstUseDate];
            [self calculateAndSetEndUseDate];
            [userDefaults setObject:self.endUseDate forKey:kEmailReminderRequestDate];

        } else {
        
            self.firstUseDate = [userDefaults valueForKey:kEmailReminderFirstUseDate];
            self.endUseDate = [userDefaults valueForKeyPath:kEmailReminderRequestDate];
            self.useCount = [[userDefaults valueForKeyPath:kEmailReminderUseCount] intValue];
        
        }
    }
    return self;
}

- (BOOL)alertViewConditionsMet{
	NSDate *currentDate = [NSDate date];
    
    NSDate *earlierDate = [currentDate earlierDate:self.endUseDate];

    if (self.endUseDate == earlierDate) {
        return YES;
    }
    
    if (self.useCount > kUseCount) {
        return YES;
    }
    return NO;
}

- (void)appBecameActive {
    self.useCount+=1;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.useCount) forKey:kEmailReminderUseCount];

    if (![self alertViewConditionsMet]) {
        return;
    }

    [self showAlertView];
    [self setInitialValues];

}

- (void) setInitialValues {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    self.firstUseDate = [NSDate date];
    [userDefaults setObject:self.firstUseDate forKey:kEmailReminderFirstUseDate];
    
    [self calculateAndSetEndUseDate];
    [userDefaults setObject:self.endUseDate forKey:kEmailReminderRequestDate];

    self.useCount = 0;
	[userDefaults setObject:@(self.useCount) forKey:kEmailReminderUseCount];
}

- (void)showAlertView {
    
    self.alertView = [[UIAlertView alloc]initWithTitle:@"Please Enter Your Email Address" message:@"Your email address will be used for newsletters, and notifications about your account" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Save", nil];
    self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.alertView show];
}

- (BOOL) alertViewShouldEnableFirstOtherButton: (UIAlertView *) alertView {
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    return [textfield.text isValidEmail];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex : %d", buttonIndex);
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (buttonIndex == 1) {
        [appDelegate.oAuthNetworkEngine changeUserField: @"email"
                                                     forUser: appDelegate.currentUser
                                                withNewValue: textfield.text
                                           completionHandler: ^(NSDictionary * dictionary){

                                               appDelegate.currentUser.emailAddress = textfield.text;
                                               
                                           } errorHandler: ^(id errorInfo) {
                                               
                                           }];
        return;
    }
    
    return;
}


- (void)calculateAndSetEndUseDate {
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = kNumberOfDays;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.endUseDate forKey:kEmailReminderRequestDate];
    _endUseDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                               toDate: _firstUseDate
                                                              options:0];
}



@end
