//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@class SYNAppDelegate;

typedef void (^SYNRegistryCompletionBlock)(BOOL success);

typedef BOOL (^SYNRegistryActionBlock)(NSManagedObjectContext *backgroundContext);

@interface SYNRegistry : NSObject
{
    @protected __weak SYNAppDelegate *appDelegate;
    @protected NSManagedObjectContext *importManagedObjectContext;
}

- (id) initWithParentManagedObjectContext: (NSManagedObjectContext *) moc;
+ (id) registryWithParentContext: (NSManagedObjectContext *) moc;


- (BOOL) saveImportContext;
- (BOOL) clearImportContextFromEntityName: (NSString *) entityName;

- (BOOL) clearImportContextFromEntityName: (NSString *) entityName
                                andViewId:(NSString*)viewId;

- (void) performInBackground: (SYNRegistryActionBlock) actionBlock
             completionBlock: (SYNRegistryCompletionBlock) completionBlock;

@end
