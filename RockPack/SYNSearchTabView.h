//
//  SYNSearchTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 19/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    SearchTabTypeVideos = 0,
    SearchTabTypeChannels = 1,
    SearchTabTypeUsers = 2
} SearchTabType;

@interface SYNSearchTabView : UIControl {
    UIImage *backgroundImageOn;
    UIImage *backgroundImageOff;
    UIImage *backgroundImageHighlighted;
    UIImageView *bgImageView;
    UILabel *titleLabel;
    NSString *typeTitle;
    SearchTabType type;
    UIColor *onColor;
    UIColor *offColor;
    UIButton *overButton;
    BOOL selected;
}

- (BOOL) isClicked: (UIButton *) button;

- (void) setNumberOfItems: (NSInteger) numberOfItems animated: (BOOL) animated;

+ (id) tabViewWithSearchType: (SearchTabType) itsType;

@end
