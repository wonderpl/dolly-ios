// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.m instead.

#import "_ChannelOwner.h"

const struct ChannelOwnerAttributes ChannelOwnerAttributes = {
	.channelOwnerDescription = @"channelOwnerDescription",
	.coverPhotoURL = @"coverPhotoURL",
	.displayName = @"displayName",
	.followersTotalCount = @"followersTotalCount",
	.position = @"position",
	.subscribedByUser = @"subscribedByUser",
	.subscribersCount = @"subscribersCount",
	.subscriptionCount = @"subscriptionCount",
	.thumbnailURL = @"thumbnailURL",
	.totalVideos = @"totalVideos",
	.totalVideosValueChannel = @"totalVideosValueChannel",
	.totalVideosValueSubscriptions = @"totalVideosValueSubscriptions",
	.username = @"username",
};

const struct ChannelOwnerRelationships ChannelOwnerRelationships = {
	.channels = @"channels",
	.originatedVideos = @"originatedVideos",
	.starred = @"starred",
	.subscriptions = @"subscriptions",
	.userSubscriptions = @"userSubscriptions",
	.userVideoInstances = @"userVideoInstances",
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
	if ([key isEqualToString:@"subscribersCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subscribersCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"subscriptionCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subscriptionCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalVideosValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalVideos"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalVideosValueChannelValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalVideosValueChannel"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalVideosValueSubscriptionsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalVideosValueSubscriptions"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic channelOwnerDescription;






@dynamic coverPhotoURL;






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





@dynamic subscribersCount;



- (int64_t)subscribersCountValue {
	NSNumber *result = [self subscribersCount];
	return [result longLongValue];
}

- (void)setSubscribersCountValue:(int64_t)value_ {
	[self setSubscribersCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSubscribersCountValue {
	NSNumber *result = [self primitiveSubscribersCount];
	return [result longLongValue];
}

- (void)setPrimitiveSubscribersCountValue:(int64_t)value_ {
	[self setPrimitiveSubscribersCount:[NSNumber numberWithLongLong:value_]];
}





@dynamic subscriptionCount;



- (int64_t)subscriptionCountValue {
	NSNumber *result = [self subscriptionCount];
	return [result longLongValue];
}

- (void)setSubscriptionCountValue:(int64_t)value_ {
	[self setSubscriptionCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSubscriptionCountValue {
	NSNumber *result = [self primitiveSubscriptionCount];
	return [result longLongValue];
}

- (void)setPrimitiveSubscriptionCountValue:(int64_t)value_ {
	[self setPrimitiveSubscriptionCount:[NSNumber numberWithLongLong:value_]];
}





@dynamic thumbnailURL;






@dynamic totalVideos;



- (int64_t)totalVideosValue {
	NSNumber *result = [self totalVideos];
	return [result longLongValue];
}

- (void)setTotalVideosValue:(int64_t)value_ {
	[self setTotalVideos:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalVideosValue {
	NSNumber *result = [self primitiveTotalVideos];
	return [result longLongValue];
}

- (void)setPrimitiveTotalVideosValue:(int64_t)value_ {
	[self setPrimitiveTotalVideos:[NSNumber numberWithLongLong:value_]];
}





@dynamic totalVideosValueChannel;



- (int64_t)totalVideosValueChannelValue {
	NSNumber *result = [self totalVideosValueChannel];
	return [result longLongValue];
}

- (void)setTotalVideosValueChannelValue:(int64_t)value_ {
	[self setTotalVideosValueChannel:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalVideosValueChannelValue {
	NSNumber *result = [self primitiveTotalVideosValueChannel];
	return [result longLongValue];
}

- (void)setPrimitiveTotalVideosValueChannelValue:(int64_t)value_ {
	[self setPrimitiveTotalVideosValueChannel:[NSNumber numberWithLongLong:value_]];
}





@dynamic totalVideosValueSubscriptions;



- (int64_t)totalVideosValueSubscriptionsValue {
	NSNumber *result = [self totalVideosValueSubscriptions];
	return [result longLongValue];
}

- (void)setTotalVideosValueSubscriptionsValue:(int64_t)value_ {
	[self setTotalVideosValueSubscriptions:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalVideosValueSubscriptionsValue {
	NSNumber *result = [self primitiveTotalVideosValueSubscriptions];
	return [result longLongValue];
}

- (void)setPrimitiveTotalVideosValueSubscriptionsValue:(int64_t)value_ {
	[self setPrimitiveTotalVideosValueSubscriptions:[NSNumber numberWithLongLong:value_]];
}





@dynamic username;






@dynamic channels;

	
- (NSMutableOrderedSet*)channelsSet {
	[self willAccessValueForKey:@"channels"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"channels"];
  
	[self didAccessValueForKey:@"channels"];
	return result;
}
	

@dynamic originatedVideos;

	
- (NSMutableSet*)originatedVideosSet {
	[self willAccessValueForKey:@"originatedVideos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"originatedVideos"];
  
	[self didAccessValueForKey:@"originatedVideos"];
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
	

@dynamic userSubscriptions;

	
- (NSMutableOrderedSet*)userSubscriptionsSet {
	[self willAccessValueForKey:@"userSubscriptions"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"userSubscriptions"];
  
	[self didAccessValueForKey:@"userSubscriptions"];
	return result;
}
	

@dynamic userVideoInstances;

	
- (NSMutableOrderedSet*)userVideoInstancesSet {
	[self willAccessValueForKey:@"userVideoInstances"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"userVideoInstances"];
  
	[self didAccessValueForKey:@"userVideoInstances"];
	return result;
}
	






@end
