//
//  SYNMoodCell.m
//  dolly
//
//  Created by Nick Banks on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMoodCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNMoodCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        
        self.titleLabel.font = [UIFont regularCustomFontOfSize:(IS_IPAD ? 33.0f : 23.0f)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:self.titleLabel];
        
    }
    return self;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"[SYNMoodCell <%p> title:'%@']", self, self.titleLabel.text];
}

@end
