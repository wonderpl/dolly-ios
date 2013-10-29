// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FeedItem.m instead.

#import "_FeedItem.h"

const struct FeedItemAttributes FeedItemAttributes = {
	.channelOwnerId = @"channelOwnerId",
	.dateAdded = @"dateAdded",
	.itemCount = @"itemCount",
	.itemType = @"itemType",
	.position = @"position",
	.resourceId = @"resourceId",
	.resourceType = @"resourceType",
	.title = @"title",
};

const struct FeedItemRelationships FeedItemRelationships = {
	.aggregate = @"aggregate",
	.feedItems = @"feedItems",
};

const struct FeedItemFetchedProperties FeedItemFetchedProperties = {
};

@implementation FeedItemID
@end

@implementation _FeedItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FeedItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:moc_];
}

- (FeedItemID*)objectID {
	return (FeedItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"itemCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"itemCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"itemTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"itemType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"resourceTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"resourceType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic channelOwnerId;






@dynamic dateAdded;






@dynamic itemCount;



- (int32_t)itemCountValue {
	NSNumber *result = [self itemCount];
	return [result intValue];
}

- (void)setItemCountValue:(int32_t)value_ {
	[self setItemCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveItemCountValue {
	NSNumber *result = [self primitiveItemCount];
	return [result intValue];
}

- (void)setPrimitiveItemCountValue:(int32_t)value_ {
	[self setPrimitiveItemCount:[NSNumber numberWithInt:value_]];
}





@dynamic itemType;



- (int32_t)itemTypeValue {
	NSNumber *result = [self itemType];
	return [result intValue];
}

- (void)setItemTypeValue:(int32_t)value_ {
	[self setItemType:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveItemTypeValue {
	NSNumber *result = [self primitiveItemType];
	return [result intValue];
}

- (void)setPrimitiveItemTypeValue:(int32_t)value_ {
	[self setPrimitiveItemType:[NSNumber numberWithInt:value_]];
}





@dynamic position;



- (int64_t)positionValue {
	NSNumber *result = [self position];
	return [result longLongValue];
}

- (void)setPositionValue:(int64_t)value_ {
	[self setPosition:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result longLongValue];
}

- (void)setPrimitivePositionValue:(int64_t)value_ {
	[self setPrimitivePosition:[NSNumber numberWithLongLong:value_]];
}





@dynamic resourceId;






@dynamic resourceType;



- (int32_t)resourceTypeValue {
	NSNumber *result = [self resourceType];
	return [result intValue];
}

- (void)setResourceTypeValue:(int32_t)value_ {
	[self setResourceType:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveResourceTypeValue {
	NSNumber *result = [self primitiveResourceType];
	return [result intValue];
}

- (void)setPrimitiveResourceTypeValue:(int32_t)value_ {
	[self setPrimitiveResourceType:[NSNumber numberWithInt:value_]];
}





@dynamic title;






@dynamic aggregate;

	

@dynamic feedItems;

	
- (NSMutableSet*)feedItemsSet {
	[self willAccessValueForKey:@"feedItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"feedItems"];
  
	[self didAccessValueForKey:@"feedItems"];
	return result;
}
	






@end
