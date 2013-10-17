//
//  SYNPaddedUITextField.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNPaddedUITextField.h"
#import "UIFont+SYNFont.h"

@implementation SYNPaddedUITextField

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.font = [UIFont lightCustomFontOfSize:16.0f];        
    }
    return self;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect origValue = [super textRectForBounds: bounds];
    
    /* Just a sample offset */
    return CGRectOffset(origValue, 10.0f, IS_IOS_7_OR_GREATER ? 2.0f : 13.0f);}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect origValue = [super textRectForBounds: bounds];
    
    /* Just a sample offset */
    return CGRectOffset(origValue, 10.0f, IS_IOS_7_OR_GREATER ? 2.0f : 11.0f);}

-(CGRect)getRectUniversal:(CGRect)bounds
{
    if(self.leftView) {
        return CGRectInset( bounds , 10, 10 );
    } else {
        return CGRectInset( bounds , 10 , 10 );
    }
    
}

@end
