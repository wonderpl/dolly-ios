//
//  SYNArcMenuView.m
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//
//  Inspired by https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import "SYNArcMenuView.h"
#import "AppConstants.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kSYNArcMenuDefaultNearRadius = 88.0f;
static CGFloat const kSYNArcMenuDefaultEndRadius = 90.0f;
static CGFloat const kSYNArcMenuDefaultFarRadius = 97.0f;
static CGFloat const kSYNArcMenuDefaultActiveRadius = 110.0f;
static CGFloat const kSYNArcMenuDefaultStartPointX = 160.0;
static CGFloat const kSYNArcMenuDefaultStartPointY = 240.0;
static CGFloat const kSYNArcMenuDefaultRotateAngle = 0.0;
static CGFloat const kSYNArcMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kSYNArcMenuDefaultExpandRotation = M_PI;
static CGFloat const kSYNArcMenuDefaultCloseRotation = M_PI * 2;
static CGFloat const kSYNArcMenuDefaultAnimationDuration = 0.25f;
static CGFloat const kSYNArcMenuStartMenuDefaultAnimationDuration = 0.25f;
static CGFloat const kSYNMinimumActivationDistance = 70.0f; // Pixels


static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    
    return CGPointApplyAffineTransform(point, transformGroup);
}

static CGPoint RotateAndScaleCGPointAroundCenter(CGPoint point, CGPoint center, float angle, float scaleFactor)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), scale), translation);
    
    return CGPointApplyAffineTransform(point, transformGroup);
}


@interface SYNArcMenuView ()


@property (nonatomic, strong) SYNArcMenuItem *startButton;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;

@end


@implementation SYNArcMenuView

#pragma mark - Object lifecycle

- (id) initWithFrame: (CGRect) frame
           startItem: (SYNArcMenuItem *) startItem
         optionMenus: (NSArray *) menuItemArray
       cellIndexPath: (NSIndexPath *) cellIndexPath
      componentIndex: (NSInteger) componentIndex
{
    if ((self = [super initWithFrame: frame]))
    {
        // Assume no component index for now
        self.componentIndex = componentIndex;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.nearRadius = kSYNArcMenuDefaultNearRadius;
        self.endRadius = kSYNArcMenuDefaultEndRadius;
        self.farRadius = kSYNArcMenuDefaultFarRadius;
        self.activeRadius = kSYNArcMenuDefaultActiveRadius;
        self.rotateAngle = kSYNArcMenuDefaultRotateAngle;
        self.menuWholeAngle = kSYNArcMenuDefaultMenuWholeAngle;
        self.startPoint = CGPointMake(kSYNArcMenuDefaultStartPointX, kSYNArcMenuDefaultStartPointY);
        self.expandRotation = kSYNArcMenuDefaultExpandRotation;
        self.closeRotation = kSYNArcMenuDefaultCloseRotation;
        self.animationDuration = kSYNArcMenuDefaultAnimationDuration;
        
        self.menusArray = menuItemArray;
        self.cellIndexPath = cellIndexPath;
        
        // assign startItem to "Add" Button.
        self.startButton = startItem;
        self.startButton.center = self.startPoint;
//        self.startButton.tag = kArcMenuStartButtonTag;
        [self addSubview: self.startButton];
    }
    
    return self;
}


- (void) show: (BOOL) show
{
    if (show)
    {
        self.startButton.imageView.highlighted = TRUE;
        [self setMenu];
        [self expandMenu];
    }
    else
    {
        [self closeMenu];
    }
}


- (void) positionUpdate: (CGPoint) tapPoint
{
    int currentIndex = [self nearestMenuItemToPoint: tapPoint];
    int count = self.menusArray.count;
    int adjustedCount = (count == 1) ? 1 : (count -1);
    
    // If we don't have anu menu items highlighted, then ensure that the main button is highlighted instead
    self.startButton.imageView.highlighted = (currentIndex == -1) ? TRUE : FALSE;
    
    for (int index = 0; index < count; index++)
    {
        SYNArcMenuItem *item = self.menusArray[index];
        
        if (index == currentIndex)
        {            
            if (item.imageView.highlighted == FALSE)
            {
                item.imageView.highlighted = TRUE;
                
                // Bounce-o-tron
                item.labelView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
                
                [UIView animateWithDuration: 0.1f
                                 animations: ^{
                                     item.labelView.alpha = 1.0f;
                                     item.labelView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                                 } completion: ^(BOOL finished) {
                                     [UIView animateWithDuration: 0.1f
                                                      animations: ^{
                                                          item.labelView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                                                      } completion: ^(BOOL finished) {
                                                          [UIView animateWithDuration: 0.1f
                                                                           animations:^{
                                                                               item.labelView.transform = CGAffineTransformIdentity;
                                                                           }];
                                                      }];
                                 }];
            }
            
            CGFloat distance = [self distanceBetweenPoint: tapPoint
                                                 andPoint: item.endPoint];
            
            CGFloat scaleFactor = ((kSYNMinimumActivationDistance - distance) / kSYNMinimumActivationDistance);
            CGFloat zoomFactor = scaleFactor * 0.25;
            
            CGPoint farPoint = CGPointMake(self.startPoint.x + self.endRadius * sinf(currentIndex * self.menuWholeAngle / adjustedCount), self.startPoint.y - self.endRadius * cosf(currentIndex * self.menuWholeAngle / adjustedCount));
            
            item.center = RotateAndScaleCGPointAroundCenter(farPoint, self.startPoint, self.rotateAngle, 1 + (scaleFactor * 0.4));
            
//            item.transform = CGAffineTransformMakeScale(0.5 + zoomFactor, 0.5 + zoomFactor);
            item.imageView.transform = CGAffineTransformMakeScale(1 + zoomFactor, 1 + zoomFactor);
        }
        else if (item.imageView.highlighted)
        {
            item.imageView.highlighted = FALSE;
            
            [UIView animateWithDuration: 0.1
                             animations: ^{
                                 item.labelView.alpha = 0.0;
                             } completion: ^(BOOL finished) {
                             }];
            
            [UIView animateWithDuration: kSYNArcMenuDefaultAnimationDuration
                                  delay: 0.0f
                                options: 0
                             animations: ^{
                                 item.center = item.endPoint;
                                 item.transform = CGAffineTransformMakeScale(0.5, 0.5);
                             }
                             completion: ^(BOOL finished){
                             }];
        }
    }
}


// Find the nearest menu item that is within the minimum activation distance

- (int) nearestMenuItemToPoint: (CGPoint) point
{
    CGFloat foundDistance = 99999.0f; // Arbitraily large distance
    int foundIndex = -1; // Inidcate not found or too far away

    for (int index = 0; index < self.menusArray.count; index++)
    {
        SYNArcMenuItem *item = self.menusArray[index];
    
        CGFloat distance = [self distanceBetweenPoint: point
                                             andPoint: item.endPoint];
        
        // If nearer and within range, then store as nearest so far
        if (distance < foundDistance && distance < kSYNMinimumActivationDistance)
        {
            foundDistance = distance;
            foundIndex = index;
        }
    }

    return foundIndex;
}


// Simple distance between two points
- (CGFloat) distanceBetweenPoint: (CGPoint) point1
                        andPoint: (CGPoint) point2
{
    CGFloat absoluteX = abs (point1.x - point2.x);
    CGFloat absoluteY = abs (point1.y - point2.y);
    
    CGFloat distance = sqrt(absoluteX*absoluteX + absoluteY*absoluteY);
    
    return distance;
}


#pragma mark - Getters & Setters

- (void) setStartPoint: (CGPoint) point
{
    _startPoint = point;
    self.startButton.center = point;
}


#pragma mark - Instant methods

- (void) setMenusArray: (NSArray *) menusArray
{
    if (self.menusArray == menusArray)
    {
        return;
    }
    
    _menusArray = [menusArray copy];
    
    // clean subviews
    for (UIView *v in self.subviews)
    {
        if (v.tag >= 1000)
        {
            [v removeFromSuperview];
        }
    }
}


- (void) setMenu
{
    int count = self.menusArray.count;
    
    for (int i = 0; i < count; i++)
    {
        SYNArcMenuItem *item = self.menusArray[i];
        item.tag = 1000 + i;
        item.startPoint = self.startPoint;
        
        // avoid overlap
        if (self.menuWholeAngle >= M_PI * 2)
        {
            self.menuWholeAngle = self.menuWholeAngle - self.menuWholeAngle / count;
        }
        
        int adjustedCount = (count == 1) ? 1 : count -1;
        
        CGPoint endPoint = CGPointMake(self.startPoint.x + self.endRadius * sinf(i * self.menuWholeAngle / adjustedCount), self.startPoint.y - self.endRadius * cosf(i * self.menuWholeAngle / adjustedCount));
        
        item.endPoint = RotateCGPointAroundCenter(endPoint, self.startPoint, self.rotateAngle);
        
        CGPoint nearPoint = CGPointMake(self.startPoint.x + self.nearRadius * sinf(i * self.menuWholeAngle / adjustedCount), self.startPoint.y - self.nearRadius * cosf(i * self.menuWholeAngle / adjustedCount));
        
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, self.startPoint, self.rotateAngle);
        
        CGPoint farPoint = CGPointMake(self.startPoint.x + self.farRadius * sinf(i * self.menuWholeAngle / adjustedCount), self.startPoint.y - self.farRadius * cosf(i * self.menuWholeAngle / adjustedCount));
        
        item.farPoint = RotateCGPointAroundCenter(farPoint, self.startPoint, self.rotateAngle);
        
        item.center = item.startPoint;
        
        // The images are actually double-size, so scale them down
        item.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        [self insertSubview: item
               belowSubview: self.startButton];
    }
}


#pragma mark - Private methods

- (void) expandMenu
{
    // Shade appropriate view in viewController
    if ([self.delegate respondsToSelector: @selector(arcMenuViewToShade)])
    {
        [self animateOpen: self.delegate.arcMenuViewToShade];
    }

    [CATransaction begin];
    
    for (SYNArcMenuItem *item in self.menusArray)
    {
        item.alpha = 1.0f;
        
        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
        positionAnimation.duration = self.animationDuration;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
        CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
        CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y);
        CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
        positionAnimation.path = path;
        CGPathRelease(path);
        
        [item.layer addAnimation: positionAnimation
                          forKey: @"Expand"];
        
        item.center = item.endPoint;
    }
    
    [CATransaction commit];
}


- (void) animateOpen: (UIView *) shadedView
{
    // The user opened a menu, so dim the screen
//    UIView *shadeView = [[UIView alloc] initWithFrame: shadedView.bounds];
//    shadeView.tag = kShadeViewTag;
//    shadeView.backgroundColor = [UIColor blackColor];
//    shadeView.alpha = 0.0f;
//    
////    UIView *startButtonView = [shadedView viewWithTag: kArcMenuStartButtonTag];
//    
//    [shadedView insertSubview: shadeView
//                 belowSubview: startButtonView.superview];
//
//    [UIView animateWithDuration:  kShadeViewAnimationDuration
//                     animations: ^{
//                         // Fade in the view slightly
//                         shadeView.alpha = 0.2f;
//                     }];
}


- (void) closeMenu
{
    BOOL userDidSelectMenuItem = FALSE;
    
    for (SYNArcMenuItem *item in self.menusArray)
    {
        if (item.imageView.highlighted == TRUE)
        {
             userDidSelectMenuItem = TRUE;
            
            // blowup the selected menu button
            CAAnimationGroup *blowup = [self blowupAnimationAtPoint: item.center];
            
            [item.layer addAnimation: blowup
                              forKey: @"blowup"];
            
            // Notify out delegate with out choice of menu i
            if ([self.delegate respondsToSelector: @selector(arcMenu:didSelectMenuName:forCellAtIndex:andComponentIndex:)])
            {
                [self.delegate arcMenu: self
                     didSelectMenuName: item.name
                        forCellAtIndex: self.cellIndexPath
                     andComponentIndex: self.componentIndex];
            }
        }
        else
        {
            item.alpha = 0.0f;
            item.center = item.startPoint;
        }
    }
    
    self.startButton.alpha = 0.0f;
    
    // Shade appropriate view in viewController
    if ([self.delegate respondsToSelector: @selector(arcMenuViewToShade)])
    {
        [self animateClose: self.delegate.arcMenuViewToShade];
    }
    
    if (!userDidSelectMenuItem)
    {
        [self removeFromSuperview];
    }
}

- (void) animateClose: (UIView *) shadedView
{
    // The user closed the menu so remove the shading from the screen
    UIView *shadeView = [shadedView.superview viewWithTag: kShadeViewTag];
    
    [UIView animateWithDuration:  kShadeViewAnimationDuration
                     animations: ^{
                         shadeView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         // remove the view altogether
                         [shadeView removeFromSuperview];
                     }
     ];
}


- (CAAnimationGroup *) blowupAnimationAtPoint: (CGPoint) point
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    
    positionAnimation.values = @[[NSValue valueWithCGPoint: point]];
    positionAnimation.keyTimes = @[@(0.3f)];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opacityAnimation.toValue = @(0.0f);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.delegate = self;
    
    [animationgroup setValue: @"blowupAnimationAtPoint"
                      forKey:@"animationName"];
    
    animationgroup.animations = @[positionAnimation, scaleAnimation, opacityAnimation];
    animationgroup.duration = self.animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;

    return animationgroup;
}

// Wait until the blowUpAnimation is finished before removing ourselves from the superview
- (void) animationDidStop: (CAAnimation *) animation
                 finished: (BOOL) finished
{
    if (finished)
    {
        NSString *animationName = [animation valueForKey: @"animationName"];
        if ([animationName isEqualToString: @"blowupAnimationAtPoint"])
        {
            for (SYNArcMenuItem *item in self.menusArray)
            {
                item.alpha = 0.0f;
                item.center = item.startPoint;
            }
        }
    }
    
    [self removeFromSuperview];
}

@end
