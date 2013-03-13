// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.dateOfBirth = @"dateOfBirth",
	.emailAddress = @"emailAddress",
	.firstName = @"firstName",
	.lastName = @"lastName",
	.thumbnailURL = @"thumbnailURL",
	.userName = @"userName",
	.userid = @"userid",
};

const struct UserRelationships UserRelationships = {
	.accessInfo = @"accessInfo",
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic dateOfBirth;






@dynamic emailAddress;






@dynamic firstName;






@dynamic lastName;






@dynamic thumbnailURL;






@dynamic userName;






@dynamic userid;






@dynamic accessInfo;

	






@end
