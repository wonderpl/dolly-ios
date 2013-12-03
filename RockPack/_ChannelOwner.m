// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.m instead.

#import "_ChannelOwner.h"

const struct ChannelOwnerAttributes ChannelOwnerAttributes = {
	.channelOwnerDescription = @"channelOwnerDescription",
	.displayName = @"displayName",
	.followersTotalCount = @"followersTotalCount",
	.position = @"position",
	.subscribedByUser = @"subscribedByUser",
	.thumbnailURL = @"thumbnailURL",
	.username = @"username",
};

const struct ChannelOwnerRelationships ChannelOwnerRelationships = {
	.channels = @"channels",
	.starred = @"starred",
	.subscriptions = @"subscriptions",
};

const struct ChannelOwnerFetchedProperties ChannelOwnerFetchedProperties = {
};

@implementation ChannelOwnerID
@end

@implementation _ChannelOwner

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ChannelOwner" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ChannelOwner";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ChannelOwner" inManagedObjectContext:moc_];
}

- (ChannelOwnerID*)objectID {
	return (ChannelOwnerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"followersTotalCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"followersTotalCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"subscribedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subscribedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic channelOwnerDescription;






@dynamic displayName;






@dynamic followersTotalCount;



- (int64_t)followersTotalCountValue {
	NSNumber *result = [self followersTotalCount];
	return [result longLongValue];
}

- (void)setFollowersTotalCountValue:(int64_t)value_ {
	[self setFollowersTotalCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveFollowersTotalCountValue {
	NSNumber *result = [self primitiveFollowersTotalCount];
	return [result longLongValue];
}

- (void)setPrimitiveFollowersTotalCountValue:(int64_t)value_ {
	[self setPrimitiveFollowersTotalCount:[NSNumber numberWithLongLong:value_]];
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





@dynamic subscribedByUser;



- (BOOL)subscribedByUserValue {
	NSNumber *result = [self subscribedByUser];
	return [result boolValue];
}

- (void)setSubscribedByUserValue:(BOOL)value_ {
	[self setSubscribedByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSubscribedByUserValue {
	NSNumber *result = [self primitiveSubscribedByUser];
	return [result boolValue];
}

- (void)setPrimitiveSubscribedByUserValue:(BOOL)value_ {
	[self setPrimitiveSubscribedByUser:[NSNumber numberWithBool:value_]];
}





@dynamic thumbnailURL;






@dynamic username;






@dynamic channels;

	
- (NSMutableOrderedSet*)channelsSet {
	[self willAccessValueForKey:@"channels"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"channels"];
  
	[self didAccessValueForKey:@"channels"];
	return result;
}
	

@dynamic starred;

	
- (NSMutableOrderedSet*)starredSet {
	[self willAccessValueForKey:@"starred"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"starred"];
  
	[self didAccessValueForKey:@"starred"];
	return result;
}
	

@dynamic subscriptions;

	
- (NSMutableOrderedSet*)subscriptionsSet {
	[self willAccessValueForKey:@"subscriptions"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"subscriptions"];
  
	[self didAccessValueForKey:@"subscriptions"];
	return result;
}
	






@end
