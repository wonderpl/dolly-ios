//
//  SYNButton.m
//  dolly
//
//  Created by Nick Banks on 07/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNButton.h"
#import "UIFont+SYNFont.h"

@implementation SYNButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
    

    
//    [self setTitleColor: [self.titleLabel.textColor colorWithAlphaComponent: 0.8f]
//               forState: UIControlStateHighlighted];
}


- (void) setTitle: (NSString *) title
{
    _title = title;
    
    [self setTitle: title
          forState: UIControlStateNormal];
    
    [self setTitle: title
          forState: UIControlStateHighlighted];
}


- (void) setTitle: (NSString *) title
         andCount: (NSInteger) count
{
    _title = title;
    
    // Two different ways of formatting
#if NOT_CENTERED
    NSString *countString = @" ";
    
    if (count > 0)
    {
        countString = [NSString stringWithFormat: @"%d", count];
    }
    
    [self setTitle: [NSString stringWithFormat: @"\n%@\n%@", title, countString]
          forState: UIControlStateNormal];
    
#else
    [self setTitle: [NSString stringWithFormat: @"%@\n%d", title, count]
          forState: UIControlStateNormal];
    
    [self setTitle: [NSString stringWithFormat: @"%@\n%d", title, count]
          forState: UIControlStateHighlighted];
#endif
}

@end
