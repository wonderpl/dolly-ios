@import UIKit;

@interface SYNAccountSettingsPopoverBackgroundView : UIPopoverBackgroundView
{    
    
    UIImageView                *_popoverBackgroundImageView;   
}

@property (nonatomic, readwrite, strong) UIImageView *popoverBackgroundImageView;

+ (CGFloat) arrowHeight;
+ (CGFloat) arrowBase;
+ (UIEdgeInsets) contentViewInsets;

+ (BOOL) wantsDefaultContentAppearance;


@end
