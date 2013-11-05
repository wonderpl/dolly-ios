//
//  SYNVideoQueue.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

#import "Channel.h"

@interface SYNVideoQueue : NSObject

@property (nonatomic, strong) Channel *currentlyCreatingChannel;
@property (nonatomic, readonly) BOOL isEmpty;

+ (id) queue;

- (BOOL) videoInstanceIsAddedToChannel: (VideoInstance *) videoInstance;

@end
