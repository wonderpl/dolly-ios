//
//  SYNAccountSettingsOnOffField.h
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNAccountSettingsOnOffField : UIView {
    id target;
    SEL action;
}

@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, strong) UISwitch* onOffSwitch;

-(void)addTarget:(id)target action:(SEL)action;
- (id)initWithFrame:(CGRect)frame andString:(NSString*)value;
@end
