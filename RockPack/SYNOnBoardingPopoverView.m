//
//  SYNOnBoardingPopoverView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNDeviceManager.h"
#import "SYNOnBoardingPopoverView.h"
#import "UIFont+SYNFont.h"
@import QuartzCore;

@implementation SYNOnBoardingPopoverView

+ (id) withMessage: (NSString *) message
          withSize: (CGSize) size
       andFontSize: (CGFloat) fontSize
        pointingTo: (CGRect) pointRect
     withDirection: (PointingDirection) direction
{
    return [[self alloc] initWithMessage: message
                                withSize: size
                             andFontSize: fontSize
                              pointingTo: pointRect
                           withDirection: direction];
}


- (id) initWithMessage: (NSString *) message
              withSize: (CGSize) size
           andFontSize: (CGFloat) fontSize
            pointingTo: (CGRect) pointRect
         withDirection: (PointingDirection) direction
{
    if (self = [super initWithFrame: CGRectMake(0.0, 0.0, size.width, size.height)])
    {
        self.pointRect = pointRect;
        
        if (CGRectEqualToRect(self.pointRect, CGRectZero))
        {
            self.direction = PointingDirectionNone;
        }
        else
        {
            self.direction = direction;
        }
        
        self.backgroundColor = [UIColor colorWithWhite: 255.0 / 255.0
                                                 alpha: 0.90];
        
        [self.layer
         setCornerRadius: 5.0f];
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.2f;
        self.layer.shadowColor = [[UIColor blackColor]CGColor];
        //self.layer.masksToBounds = YES;
        
        // text view
        
        CGRect labelRect = self.frame;
        labelRect.origin.x = 15.0;
        labelRect.origin.y = 6.0;
        labelRect.size.width -= 30.0;
        
        
        
        
        UILabel *label = [[UILabel alloc] init];
        
        label.font = [UIFont lightCustomFontOfSize: fontSize];
        label.shadowColor = [UIColor colorWithWhite: 1.0f / 255.0f
                                              alpha: 0.15f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 4;
        label.textColor = [UIColor colorWithRed: (40.0 / 255.0)
                                          green: (45.0 / 255.0)
                                           blue: (51.0 / 255.0)
                                          alpha: (1.0)];
        label.text = message;
        
        label.shadowColor = [UIColor colorWithWhite: 0.0 / 255.0
                                              alpha: 0.15];
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString: message
                                                                             attributes: @{NSFontAttributeName: label.font}];
        
        CGRect rect = [attributedText boundingRectWithSize: (CGSize) { labelRect.size.width, CGFLOAT_MAX}
                                                   options: NSStringDrawingUsesLineFragmentOrigin
                                                   context: nil];
        
        CGFloat height = ceilf(rect.size.height);
        CGFloat width = ceilf(rect.size.width);
        
        CGSize textSize = (CGSize) {
            width, height
        };
        
        labelRect.size.height = textSize.height * label.numberOfLines;
        
        label.frame = labelRect;
        
        [self addSubview: label];
        
        UIImage *arrowImage;
        
        switch (direction)
        {
            case PointingDirectionDown:
                arrowImage = [UIImage imageNamed: @"onboarding_arrow_bottom"];
                break;
                
            case PointingDirectionUp:
                arrowImage = [UIImage imageNamed: @"onboarding_arrow_up"];
                break;
                
            case PointingDirectionLeft:
                arrowImage = [UIImage imageNamed: @"onboarding_arrow_left"];
                break;
                
            case PointingDirectionRight:
                arrowImage = [UIImage imageNamed: @"onboarding_arrow_right"];
                break;
                
            case PointingDirectionNone:
                arrowImage = [UIImage imageNamed: @""];
                break;
        }
        
        
        self.arrow = [[UIImageView alloc] initWithImage: arrowImage];
    }
    
    return self;
}


@end
