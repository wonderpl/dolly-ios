//
//  SYNSignupViewController.m
//  dolly
//
//  Created by Sherman Lo on 31/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNSignupViewController.h"
#import	"SYNTextFieldLogin.h"
#import "NSString+Validation.h"

static const NSInteger NameMaxLength = 32;
static const NSInteger UsernameMaxLength = 20;

@interface SYNSignupViewController ()

@end

@implementation SYNSignupViewController

- (BOOL)validateFirstNameField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel {
	if (![textField.text length]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_first_name_error_empty", nil);
		
        [textField becomeFirstResponder];
		
		return NO;
	}
	
    if ([textField.text length] > NameMaxLength) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_first_name_error_too_long", nil);
		
        [textField becomeFirstResponder];
        
        return NO;
    }
	
	return YES;
}

- (BOOL)validateLastNameField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel {
	if (![textField.text length]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_last_name_error_empty", nil);
		
        [textField becomeFirstResponder];
		
		return NO;
	}
	
    if ([textField.text length] > NameMaxLength) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_last_name_error_too_long", nil);
		
        [textField becomeFirstResponder];
        
        return NO;
    }
	
	return YES;
}

- (BOOL)validateUsernameField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel {
    if (![textField.text length]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_username_error_empty", nil);
        
        [textField becomeFirstResponder];
        
        return NO;
    }
    
    if (![textField.text isValidUsername]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_username_error_invalid", nil);
        
        [textField becomeFirstResponder];
        
        return NO;
    }
    
    if (textField.text.length > UsernameMaxLength) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_username_error_too_long", nil);
		
        [textField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)validateDateField:(SYNTextFieldLogin *)dateField
			   monthField:(SYNTextFieldLogin *)monthField
				yearField:(SYNTextFieldLogin *)yearField
				 errorLabel:(UILabel *)errorLabel {
	
    NSArray *dobTextFields = @[ dateField, monthField, yearField];
    
    // == Check wether the DOB fields contain numbers == //
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    for (SYNTextFieldLogin *dobField in dobTextFields) {
        if (dobField.text.length == 0) {
			dobField.errorMode = YES;
			errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
            
            [dateField becomeFirstResponder];
            
            return NO;
        }
        
        if (dobField.text.length == 1) {
            dobField.text = [NSString stringWithFormat: @"0%@", dobField.text]; // add a trailing 0
        }
        
        if (![numberFormatter numberFromString: dobField.text]) {
			dobField.errorMode = YES;
			errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
			
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    
    if (yearField.text.length < 4) {
		yearField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
		
        return NO;
    }
	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
	NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@", yearField.text, [self zeroPadIfOneCharacter:monthField.text], [self zeroPadIfOneCharacter:dateField.text]];
    NSDate *potentialDate = [dateFormatter dateFromString:dateString];
    
    // == Not a real date == //
    
    if (!potentialDate) {
		dateField.errorMode = YES;
		monthField.errorMode = YES;
		yearField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_error_invalid_date", nil);
		
        return NO;
    }
	
    NSDate *nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare: potentialDate] == NSOrderedAscending) {
		yearField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_error_future", nil);
		
        return NO;
    }
    
    // == Younger than 13 == //
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *nowDateComponents = [gregorian components: (NSYearCalendarUnit)
                                                       fromDate: nowDate];
    nowDateComponents.year -= 13;
    
    NSDate *tooYoungDate = [gregorian dateFromComponents: nowDateComponents];
    
    if ([tooYoungDate compare: potentialDate] == NSOrderedAscending) {
		yearField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_error_under_13", nil);
		
        return NO;
    }
    
    return YES;
}

- (BOOL)validateEmailField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel {
    if (![textField.text length]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_email_error_empty", nil);
		
        [textField becomeFirstResponder];
        
        return NO;
    }
    
    if (![textField.text isValidEmail]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_email_error_empty", nil);
		
        [textField becomeFirstResponder];
        
        return NO;
    }
	
	return YES;
}

- (BOOL)validatePasswordField:(SYNTextFieldLogin *)textField errorLabel:(UILabel *)errorLabel {
	if (![textField.text length]) {
		textField.errorMode = YES;
		errorLabel.text = NSLocalizedString(@"register_screen_form_field_password_error_empty", nil);
		
		[textField becomeFirstResponder];
		
		return NO;
	}
	
	return YES;
}

- (NSString *)zeroPadIfOneCharacter:(NSString *)inputString {
    if ([inputString length] == 1) {
        return [NSString stringWithFormat: @"0%@", inputString];
    }
    
    return inputString;
}

@end
