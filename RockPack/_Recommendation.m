// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Recommendation.m instead.

#import "_Recommendation.h"

const struct RecommendationAttributes RecommendationAttributes = {
	.avatarUrl = @"avatarUrl",
	.categoryId = @"categoryId",
	.descriptionText = @"descriptionText",
	.displayName = @"displayName",
	.position = @"position",
	.resourceUrl = @"resourceUrl",
};

const struct RecommendationRelationships RecommendationRelationships = {
};

const struct RecommendationFetchedProperties RecommendationFetchedProperties = {
};

@implementation RecommendationID
@end

@implementation _Recommendation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Recommendation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Recommendation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Recommendation" inManagedObjectContext:moc_];
}

- (RecommendationID*)objectID {
	return (RecommendationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic avatarUrl;






@dynamic categoryId;






@dynamic descriptionText;






@dynamic displayName;






@dynamic position;



- (int32_t)positionValue {
	NSNumber *result = [self position];
	return [result intValue];
}

- (void)setPositionValue:(int32_t)value_ {
	[self setPosition:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result intValue];
}

- (void)setPrimitivePositionValue:(int32_t)value_ {
	[self setPrimitivePosition:[NSNumber numberWithInt:value_]];
}





@dynamic resourceUrl;











@end
