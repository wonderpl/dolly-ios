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
        self.backgroundColor = [UIColor colorWithWhite:(255.0/255.0) alpha:(1.0)];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor colorWithWhite:(209.0/255.0) alpha:(1.0)].CGColor;
        self.textColor = [UIColor darkGrayColor];
    }
    return self;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect origValue = [super textRectForBounds: bounds];
    
    /* Just a sample offset */
    return CGRectOffset(origValue, 10.0f, 2.0f);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect origValue = [super textRectForBounds: bounds];
    
    /* Just a sample offset */
    return CGRectOffset(origValue, 10.0f, 2.0f);
}



@end
