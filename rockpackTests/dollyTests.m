//
//  rockpackTests.m
//  rockpackTests
//
//  Created by Nick Banks on 19/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "dollyTests.h"
#import "SYNNetworkEngine.h"
#import "SYNMainRegistry.h"

@implementation dollyTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

// Search Test

-(void)testSearchResults
{
    SYNNetworkEngine* ne = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    
    [ne searchVideosForTerm:@"Michael" inRange:NSMakeRange(0, 10) onComplete:^(int count) {
        
    }];
}

@end
