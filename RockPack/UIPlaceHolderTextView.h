//
//  UIPlaceHolderTextView.h
//  dolly
//
//  Created by Cong Le on 04/04/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)setPlaceHolderLabelFont:(UIFont*)font;

@end
