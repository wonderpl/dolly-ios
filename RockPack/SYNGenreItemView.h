//
//  SYNCategoryItemView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Genre;

typedef enum : NSInteger {
    TabItemTypeMain,
    TabItemTypeSub
} TabItemType;

@interface SYNGenreItemView : UIView
{
    @private TabItemType type;
    @private UIColor* grayColor;
    @private Genre* model;
}


@property (nonatomic, readonly) Genre* model;

@property (nonatomic, strong) UIImageView* glowImageView;
@property (nonatomic, strong) UILabel* label;

- (id) initWithTabItemModel: (Genre*) tabItemModel;

- (id) initWithLabel: (NSString *) label
              andTag: (int) tag;

- (void) makeHighlighted;
- (void) makeStandard;

/**
 Helper method for resizing the item view which is assumed to have flexible width depending on orientation and a fixed height.
 
 @param orientation The orientation to adapt to
 @param height the fixed view height
 */
 
-(void) resizeForOrientation: (UIInterfaceOrientation) orientation
                  withHeight: (CGFloat) height;

@end
