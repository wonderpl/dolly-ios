//
//  SYNCategoriesTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNGenreTabView.h"
#import "Genre.h"
#import "SubGenre.h"
#import "SYNGenreItemView.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

#define kSecondaryTabsOffset 30.0

@interface SYNGenreTabView ()

@property (nonatomic, strong) UIView* dividerOverlayView;
@property (nonatomic, strong) UIView* mainTabsView;
@property (nonatomic, strong) UIView* secondaryDividerOverlay;
@property (nonatomic, strong) UIView* secondaryTabsBGView;
@property (nonatomic, strong) UIView* secondaryTabsView;
@property (nonatomic, weak) UIButton* homeButton;
@property (nonatomic, assign) NSString* homeButtonString;
@property (nonatomic, strong) UILabel* loadingLabel;

@end


@implementation SYNGenreTabView


- (id) initWithSize: (CGFloat) totalWidth
      andHomeButton: (NSString*) homeButtonString;
{
    if ((self = [super init]))
    {
        self.homeButtonString = homeButtonString;
        
        // == Tob Bar == //
        UIImage* mainTabsBGImage = [UIImage imageNamed: @"CategoryBar"];
        CGRect mainFrame = CGRectMake(0.0, 0.0, totalWidth, mainTabsBGImage.size.height);
        self.mainTabsView = [[UIView alloc] initWithFrame:mainFrame];
        self.mainTabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIView* bgMainTabsView = [[UIView alloc] initWithFrame: mainFrame];
        bgMainTabsView.backgroundColor = [UIColor colorWithPatternImage: mainTabsBGImage];
        bgMainTabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

       
        
        // == Bottom Bar == //
        UIImage* secondaryTabsBGImage = [UIImage imageNamed: @"SubCategoryBar"];
        CGRect secondaryFrame = CGRectMake(0.0, 0.0, totalWidth, secondaryTabsBGImage.size.height);
        self.secondaryTabsView = [[UIView alloc] initWithFrame: secondaryFrame];
        self.secondaryTabsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.secondaryDividerOverlay = [[UIView alloc] initWithFrame:secondaryFrame];
        self.secondaryDividerOverlay.userInteractionEnabled = NO;
        self.secondaryDividerOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        self.secondaryTabsBGView = [[UIView alloc] initWithFrame: secondaryFrame];
        self.secondaryTabsBGView.backgroundColor = [UIColor colorWithPatternImage: secondaryTabsBGImage];
        self.secondaryTabsBGView.userInteractionEnabled = NO;
        self.secondaryTabsBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CGRect masterFrame = CGRectMake(0.0, 0.0, totalWidth, mainFrame.size.height + secondaryFrame.size.height);
        self.frame = masterFrame;
        
        [self addSubview:self.secondaryTabsBGView];
        [self addSubview:self.secondaryTabsView];
        [self addSubview:self.secondaryDividerOverlay];
        
        [self addSubview: bgMainTabsView];
        [self addSubview:self.mainTabsView];
        
        
        self.dividerOverlayView = [[UIView alloc] initWithFrame: self.mainTabsView.frame];
        self.dividerOverlayView.userInteractionEnabled = NO;
        self.dividerOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview: self.dividerOverlayView];
        
        // == Loading Label == //
        NSString* loadingString = NSLocalizedString(@"channels_screen_loading_categories", nil);
        CGRect loadingLabelFrame = CGRectZero;
        UIFont* rpFont = [UIFont rockpackFontOfSize:18];
        loadingLabelFrame.size = [loadingString sizeWithAttributes: @{NSFontAttributeName: rpFont}];
        self.loadingLabel = [[UILabel alloc] initWithFrame:loadingLabelFrame];
        self.loadingLabel.font = rpFont;
        self.loadingLabel.text = loadingString;
        self.loadingLabel.textColor = [UIColor grayColor];
        self.loadingLabel.backgroundColor = [UIColor clearColor];
        self.loadingLabel.center = CGPointMake(self.frame.size.width * 0.5, 26.0);
        self.loadingLabel.frame = CGRectIntegral(self.loadingLabel.frame);
        [self addSubview:self.loadingLabel];
    }
    
    return self;
}


- (void) createCategoriesTab: (NSArray*) categories
{
    
    SYNGenreItemView* tab = nil;
    
    // clean existing //
    
    for (SYNGenreItemView* tabView in self.mainTabsView.subviews)
        [tabView removeFromSuperview];
    
    for (UIView* divider in self.dividerOverlayView.subviews)
        [divider removeFromSuperview];
    
    if(self.homeButton)
        [self.homeButton removeFromSuperview];
    
    if(self.loadingLabel)
    {
        [self.loadingLabel removeFromSuperview];
        self.loadingLabel = nil;
    }
    

    CGFloat nextOrigin = 0.0;
    
    
    //TODO: This should be reworked. The home label string should not be used to define behaviour.
    
    if ([self.homeButtonString isEqualToString:@"icon"]) // special case where we put the 'home' icon instead of text
    {
        self.homeButton = [UIButton buttonWithType: UIButtonTypeCustom];
        UIImage* homeButtonImage = [UIImage imageNamed: @"IconCategoryAll"];
        self.homeButton.frame = CGRectMake(nextOrigin, 0.0, homeButtonImage.size.width, self.mainTabsView.frame.size.height);
        [self.homeButton setImage: homeButtonImage forState: UIControlStateNormal];
        
        [self.homeButton addTarget: self
                            action: @selector(homeButtonPressed)
                  forControlEvents: UIControlEventTouchUpInside];
        
        [self addSubview: self.homeButton];
    }
    else if ([self.homeButtonString isEqualToString:@"hiden"]) // special case where we dont display anything
    {
        
    }
    else
    {
        // Create a special Other tab with tag id 0
        tab = [[SYNGenreItemView alloc] initWithLabel: [self.homeButtonString uppercaseString]
                                                  andTag: 0];
        
        [tab makeHighlighted];
        
        [self.mainTabsView addSubview: tab];
        
        [tab addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                           action: @selector(mainTapPressed:)]];
    }


    for (Genre* category in categories)
    {
        tab = [[SYNGenreItemView alloc] initWithTabItemModel: category];
        
        [self.mainTabsView addSubview: tab];
        
        [tab addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                           action: @selector(mainTapPressed:)]];
    }
    
    
    
    // Layout tabs according to orientation //
    
    [self refreshViewForOrientation: [[UIApplication sharedApplication] statusBarOrientation]];
}


- (UIImageView*) createDividerAtOffset: (CGFloat) offset
{
    UIImageView* dividerImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"CategoryBarDivider"]];
    CGRect dividerFrame = dividerImageView.frame;
    dividerFrame.origin.x = offset;
    dividerImageView.frame = dividerFrame;
    return dividerImageView;
}


- (void) createSubcategoriesTab: (NSArray*) subcategories
{
    // Clean current subviews
    for (UIView* sview in self.secondaryTabsView.subviews)
        [sview removeFromSuperview];
    
    for(SYNGenreItemView* divider in self.secondaryDividerOverlay.subviews)
        [divider removeFromSuperview];
    
    SYNGenreItemView* tab = nil;
        
    for (SubGenre* subcategory in subcategories)
    {
        tab = [[SYNGenreItemView alloc] initWithTabItemModel: subcategory];
        [self.secondaryTabsView addSubview: tab];
        
        [tab addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                           action: @selector(secondaryTapPressed:)]];
    }
    [self showSecondaryTabs];
    
    //Layout tabs according to orientation
    [self refreshViewForOrientation: [[UIApplication sharedApplication] statusBarOrientation]];    
}


- (void) showSecondaryTabs
{
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         CGRect secondaryFrame = self.secondaryTabsView.frame;
                         secondaryFrame.origin.y = self.mainTabsView.frame.size.height - 6.0;
                         self.secondaryTabsView.frame = secondaryFrame;
                         self.secondaryTabsBGView.frame = secondaryFrame;
                         self.secondaryDividerOverlay.frame = secondaryFrame;
                     }
                     completion:^(BOOL result){
                         
                     }];
}


- (void) hideSecondaryTabs
{
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         CGRect secondaryFrame = self.secondaryTabsView.frame;
                         secondaryFrame.origin.y = 0.0;
                         self.secondaryTabsView.frame = secondaryFrame;
                         self.secondaryTabsBGView.frame = secondaryFrame;
                         self.secondaryDividerOverlay.frame = secondaryFrame;
                     }
                     completion:^(BOOL result){
                         
                     }];
}


#pragma mark - Delegate Methods

- (void) homeButtonPressed
{
    for (SYNGenreItemView* itemView in self.mainTabsView.subviews)
        [itemView makeStandard];
    
    [self hideSecondaryTabs];
    
    [self.tapDelegate handleMainTap: nil];
}


- (void) mainTapPressed: (UITapGestureRecognizer*) recogniser
{
    // Set as pressed
    SYNGenreItemView* itemView;
    
    for(SYNGenreItemView* itemView in self.mainTabsView.subviews)
        [itemView makeStandard];
    
    itemView = (SYNGenreItemView*)recogniser.view;
    [itemView makeHighlighted];
    
    
    // tapDelegate is the SYNCategoryViewController
    [self.tapDelegate handleMainTap: itemView];
}


- (void) secondaryTapPressed: (UITapGestureRecognizer*) recogniser
{
    SYNGenreItemView* itemView;
    
    for(SYNGenreItemView* itemView in self.secondaryTabsView.subviews)
        [itemView makeStandard];
    
    itemView = (SYNGenreItemView*)recogniser.view;
    [itemView makeHighlighted];
    
    [self.tapDelegate handleSecondaryTap: itemView];
}

- (void) deselectAll
{
    for(SYNGenreItemView* itemView in self.mainTabsView.subviews)
        [itemView makeStandard];
    
    for(SYNGenreItemView* itemView in self.secondaryTabsView.subviews)
        [itemView makeStandard];
}

- (void) refreshViewForOrientation: (UIInterfaceOrientation) orientation
{
    
    // Layout Main tabs //
    
    [[self.dividerOverlayView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    CGFloat nextOrigin = 0;
    
    if ([self.homeButtonString isEqualToString:@"icon"]) // special case where we have the 'home' icon
    {
        nextOrigin += self.homeButton.frame.size.width;
        [self.dividerOverlayView addSubview: [self createDividerAtOffset: nextOrigin]];
    }
    
    for (SYNGenreItemView* tab in [self.mainTabsView subviews])
    {
        [tab resizeForOrientation: orientation
                       withHeight: self.mainTabsView.frame.size.height];
        
        CGRect tabFrame = tab.frame;
        tabFrame.origin.x = nextOrigin;
        tab.frame = tabFrame;        
        nextOrigin += tabFrame.size.width;
        
        [self.dividerOverlayView addSubview: [self createDividerAtOffset: nextOrigin]];
    }
    
    //Layout secondary tabs
    
    [[self.secondaryDividerOverlay subviews]
     makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    nextOrigin = 0.0f;
    CGFloat midSecondaryFrame = self.secondaryTabsView.frame.size.height * 0.5;
    
    for (SYNGenreItemView* tab in [self.secondaryTabsView subviews])
    {
        [tab resizeForOrientation: orientation
                       withHeight: self.secondaryTabsView.frame.size.height -1.0f];
        
        CGRect tabFrame = tab.frame;
        tabFrame.origin.x = nextOrigin;
        tab.frame = tabFrame;
        nextOrigin += tabFrame.size.width;
        UIImageView* dividerImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"SubCategoryBarDivider"]];
        dividerImageView.center = CGPointMake(nextOrigin, midSecondaryFrame);
        
        [self.secondaryDividerOverlay addSubview: dividerImageView];        
    }
}



-(void)highlightTabWithGenre:(Genre*)genreToHighlight
{
    if(!genreToHighlight)
        return;
    
    if(![genreToHighlight isMemberOfClass:[SubGenre class]])
    {
        for(SYNGenreItemView* itemView in self.mainTabsView.subviews)
        {
            if([genreToHighlight.uniqueId intValue] == itemView.tag)
            {
                [itemView makeHighlighted];
            }
            else
            {
                [itemView makeStandard];
            }
        }
        return; // stop recursive call
           
    }
    else
    {
        for(SYNGenreItemView* itemView in self.secondaryTabsView.subviews)
        {
            if([genreToHighlight.uniqueId intValue] == itemView.tag)
            {
                [itemView makeHighlighted];
            }
            else
            {
                [itemView makeStandard];
            }
        }
        [self highlightTabWithGenre:((Genre*)((SubGenre*)genreToHighlight).genre)]; // recurse once for Genre as well.
    }
    
    
}

@end
