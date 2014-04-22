// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FeedItem.m instead.

#import "_FeedItem.h"

const struct FeedItemAttributes FeedItemAttributes = {
	.channelOwnerId = @"channelOwnerId",
	.dateAdded = @"dateAdded",
	.position = @"position",
	.resourceType = @"resourceType",
	.title = @"title",
};

const struct FeedItemRelationships FeedItemRelationships = {
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











@end
