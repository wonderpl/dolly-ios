@import UIKit;

@interface SYNPopoverBackgroundView : UIPopoverBackgroundView
{
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
    UIImageView *_arrowImageView;
    UIImageView *_popoverBackgroundImageView;
}

@property (nonatomic, readwrite)            CGFloat arrowOffset;
@property (nonatomic, readwrite)            UIPopoverArrowDirection arrowDirection;
@property (nonatomic, readwrite, strong)    UIImageView *arrowImageView;
@property (nonatomic, readwrite, strong)    UIImageView *popoverBackgroundImageView;

+ (CGFloat) arrowHeight;
+ (CGFloat) arrowBase;
+ (UIEdgeInsets) contentViewInsets;

// Used to turn off shadow

+ (BOOL) wantsDefaultContentAppearance;

@end
