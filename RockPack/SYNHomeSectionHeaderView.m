//
//  SYNHomeSectionHeaderView.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNHomeSectionHeaderView.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/CoreAnimation.h>


@interface SYNHomeSectionHeaderView ()

@property (nonatomic, strong) IBOutlet UIImageView *highlightedSectionView;

@end


@implementation SYNHomeSectionHeaderView

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    
    if (IS_IPAD)
    {
        self.sectionTitleLabel.font = [UIFont lightCustomFontOfSize: 20.0f];
    }
    else
    {
        self.sectionTitleLabel.font = [UIFont lightCustomFontOfSize: 14.0f];
    }
    
    self.highlightedSectionView.hidden = TRUE;
    self.sectionView.hidden = FALSE;
}


// Need to do this outside awakeFromNib as the delegate is not set at that point
- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
}


- (void) setFocus: (BOOL) focus
{
    if (focus)
    {
        self.highlightedSectionView.hidden = FALSE;
        self.sectionView.hidden = TRUE;
    }
    else
    {
        self.highlightedSectionView.hidden = TRUE;
        self.sectionView.hidden = FALSE;
    }
}







@end

