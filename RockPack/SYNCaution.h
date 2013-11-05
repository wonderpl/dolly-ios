//
//  SYNCaution.h
//  rockpack
//
//  Created by Michael Michailidis on 25/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import Foundation;

@interface SYNCaution : NSObject

typedef void(^CautionCallbackBlock)(void);

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* actionButtonTitle;
@property (nonatomic, strong) NSString* skipButtonTitle;
@property (nonatomic, copy) CautionCallbackBlock action;
@property (nonatomic, copy) CautionCallbackBlock skip;

-(id)initWithTitle:(NSString*)_title andMessage:(NSString*)_message;
+(id)withTitle:(NSString*)_title andMessage:(NSString*)_message;

-(void)addButtonWithTitle:(NSString*)buttonTitle andCallbackBlock:(CautionCallbackBlock)actionBlock;

-(void)addSkipButtonTitle:(NSString*)buttonTitle andCallbackBlock:(CautionCallbackBlock)skipBlock;

+(id)withMessage:(NSString*)_message actionTitle:(NSString*)_actionTitle andCallback:(CautionCallbackBlock)_callbackBlock;

@end
