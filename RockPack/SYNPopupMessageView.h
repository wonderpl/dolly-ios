//
//  SYNFeedMessagesView.h
//  rockpack
//
//  Created by Michael Michailidis on 30/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNPopupMessageView : UIView

+ (id) withMessage: (NSString*) message;

+ (id) withMessage: (NSString *) message
         andLoader: (BOOL) isLoader;

- (id) initWithMessage: (NSString*) message;
- (void) setMessage: (NSString*) newMessage;

@end
