//
//  SYNProfileDelegate.h
//  dolly
//
//  Created by Cong Le on 24/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNSocialFollowButton.h"

@protocol SYNProfileDelegate <NSObject>

- (void) followingsTabTapped;
- (void) collectionsTabTapped;
- (void) editButtonTapped;
- (void) moreButtonTapped;
- (void) followUserButtonTapped:(SYNSocialFollowButton*) button;


@end
