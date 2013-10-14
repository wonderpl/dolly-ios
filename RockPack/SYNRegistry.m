//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNRegistry.h"

@implementation SYNRegistry

#pragma mark - Initializers


- (id) init
{
    if (self = [super init])
    {
        appDelegate = UIApplication.sharedApplication.delegate;
    }
    
    return self;
}


+ (id) registryWithParentContext: (NSManagedObjectContext *) moc
{
    return [[self alloc] initWithParentManagedObjectContext: moc];
}


- (id) initWithParentManagedObjectContext: (NSManagedObjectContext *) moc
{
    if (self = [self init])
    {
        importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        
        if (moc)
        {
            importManagedObjectContext.parentContext = moc;
        }
        else
        {
            DebugLog(@"Warning: Initializing Registry without a parent context");
        }
    }
    
    return self;
}


#pragma mark - Import Context Management

- (BOOL) saveImportContext
{
    NSError *error;
    
    if ([importManagedObjectContext save: &error])
    {
        DebugLog(@"saving MOC from registry: %@", [[self class] description]);
        return YES;
    }
    else
    {
        // Something went wrong, so print as much debug info as we can
        NSArray *detailedErrors = [error userInfo][NSDetailedErrorsKey];
        {
            if ([detailedErrors count] > 0)
            {
                for (NSError *detailedError in detailedErrors)
                {
                    DebugLog(@"Import MOC Save Error (Detailed): %@", [detailedError userInfo]);
                }
            }
        }
    }
    
    return NO;
}


- (BOOL) clearImportContextFromEntityName: (NSString *) entityName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: entityName
                                                         inManagedObjectContext: importManagedObjectContext];
    
    [fetchRequest setEntity: entityDescription];
    
    NSError *error = nil;
    NSArray *result = [importManagedObjectContext executeFetchRequest: fetchRequest
                                                                error: &error];
    
    // Bail, if our fetch request failed
    if (error)
    {
        AssertOrLog(@"clearImportContextFromEntityName: Fetch request failed");
        return NO;
    }
    
    for (id basket in result)
    {
        [importManagedObjectContext deleteObject: basket];
    }
    
    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
    {
        AssertOrLog(@"clearImportContextFromEntityName: Save failed");
        return NO;
    }
    
    return YES;
}


#pragma mark - Backgrounding

- (void) performInBackground: (SYNRegistryActionBlock) actionBlock
             completionBlock: (SYNRegistryCompletionBlock) completionBlock
{
    [importManagedObjectContext performBlock: ^{
        BOOL result = actionBlock(importManagedObjectContext);
        
        if (completionBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result);
            });
        }
    }];
}


@end
