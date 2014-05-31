//
//  SYNProfileDelegate.h
//  dolly
//
//  Created by Cong Le on 24/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYNSocialFollowButton;


@protocol SYNProfileHeaderDelegate <NSObject>

- (void) videosTabTapped;
- (void) followingsTabTapped;
- (void) collectionsTabTapped;
- (void) editButtonTapped;
- (void) moreButtonTapped;
- (void) followUserButtonTapped:(SYNSocialFollowButton*) button;


@end
