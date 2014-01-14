//
//  SYNTextFieldLogin.m
//  rockpack
//
//  Created by Nick Banks on 15/11/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTextFieldLogin.h"
#import "UIFont+SYNFont.h"

@implementation SYNTextFieldLogin

- (void) awakeFromNib
{
    self.layer.borderWidth = 1.0f;
    self.errorMode = NO;
    self.font = [UIFont lightCustomFontOfSize:20.0f];
}

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    if(self.keyboardType == UIKeyboardTypeNumberPad)
        return CGRectOffset( bounds, 0.0f,  0.0f );
    else
        return CGRectOffset( bounds, 10.0f,  0.0f );
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 35;
    return CGRectOffset( bounds, 10, 0);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 35;
    return CGRectOffset( bounds , 10 , 0);
}

-(void)setErrorMode:(BOOL)errorMode
{
    _errorMode = errorMode;
    if(_errorMode)
    {
        UIColor* bgErrorColor = [UIColor colorWithRed:(251.0f/255.0f)
                                                green:(233.0f/255.0f)
                                                 blue:(233.0f/255.0f)
                                                alpha:1.0f];
        
        UIColor* borderErrorColor = [UIColor colorWithRed:(142.0f/255.0f)
                                                    green:(22.0f/255.0f)
                                                     blue:(41.0f/255.0f)
                                                    alpha:1.0f];
        
        self.textColor = borderErrorColor;
        self.backgroundColor = bgErrorColor;
        self.layer.borderColor = borderErrorColor.CGColor;
        self.tintColor = borderErrorColor;
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{ NSForegroundColorAttributeName: borderErrorColor}];
        
    }
    else // normal mode
    {
        UIColor* mediumGrayColor = [UIColor colorWithWhite:167/255.0 alpha:1.0f];
		UIColor *textColor = [UIColor colorWithWhite:117/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = mediumGrayColor.CGColor;
        self.tintColor = mediumGrayColor;
        self.textColor = textColor;
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{ NSForegroundColorAttributeName: mediumGrayColor}];
    }
}

@end
