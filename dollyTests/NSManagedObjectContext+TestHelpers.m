//
//  NSManagedObjectContext+Helpers.m
//  dolly
//
//  Created by Sherman Lo on 24/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "NSManagedObjectContext+TestHelpers.h"

@implementation NSManagedObjectContext (TestHelpers)

+ (instancetype)testManagedObjectContext {
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Rockpack" withExtension:@"momd"];
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	[persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
											 configuration:nil
													   URL:nil
												   options:nil
													 error:nil];
	
	NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
	
	return managedObjectContext;
}

@end
