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
#import "SYNAppDelegate.h"
#import "SYNSearchRegistry.h"
#import <CoreData/CoreData.h>

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
    //SYNNetworkEngine* ne = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    
    
}

-(void)testSearchVideosRegistration
{
    // for: http://api.rockpack.com/ws/search/videos/?locale=en_gb&q=Michael&start=0&size=10 as received on 23 of December 2013
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    STAssertNotNil(appDelegate, @"AppDelegate does not exist...");
    
    NSString *jsonFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SearchVideosResultsForMichael" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
    
    
    NSError *error;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:&error];
    
    
    [appDelegate.searchRegistry registerVideoInstancesFromDictionary:jsonDictionary];
    
    // Get the objects from core data
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: kVideoInstance
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", kSearchViewId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    NSArray* fetchedObjects = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    
    STAssertNil(error, @"Error occured while fetching the data");
    
    STAssertEquals(fetchedObjects.count, (NSUInteger)10, @"Not all objects parsed");
    
    // == Clear the Search Registry == //
    
    BOOL success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"VideoInstance"];
    
    STAssertTrue(success, @"Could not clear search registry from VideoInstance");
    
    
    // == Do it Again! == //
    
    [appDelegate.searchRegistry registerVideoInstancesFromDictionary:jsonDictionary];
    
    fetchedObjects = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    
    STAssertNil(error, @"Error occured while fetching the data for the second time (after clearing db)");
    
    STAssertEquals(fetchedObjects.count, (NSUInteger)10, @"Not all objects parsed for the second time (after clearing db)");
    
    
    
    
}

@end
