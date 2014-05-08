#import "VideoAnnotation.h"

@implementation VideoAnnotation

+ (NSArray *)videoAnnotationsFromDictionaries:(NSArray *)dictionaries
					 inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	
	NSMutableArray *videoAnnotations = [NSMutableArray array];
	for (NSDictionary *dictionary in dictionaries) {
		VideoAnnotation *videoAnnotation = [self insertInManagedObjectContext:managedObjectContext];
		
		[videoAnnotation setAttributesFromDictionary:dictionary];
		
		[videoAnnotations addObject:videoAnnotation];
	}
	
	return videoAnnotations;
}

- (void)setAttributesFromDictionary:(NSDictionary *)dictionary {
	self.startTimestamp = dictionary[@"time_start"];
	self.endTimestamp = dictionary[@"time_end"];
	
	NSDictionary *location = dictionary[@"location"];
	self.originX = location[@"origin_x"];
	self.originY = location[@"origin_y"];
	self.width = location[@"width"];
	self.height = location[@"height"];
	
	self.url = dictionary[@"url"];
}

- (CGRect)frameForAnnotationInRect:(CGRect)rect {
	return CGRectMake(self.originXValue * CGRectGetWidth(rect),
					  self.originYValue * CGRectGetHeight(rect),
					  self.widthValue * CGRectGetWidth(rect),
					  self.heightValue * CGRectGetHeight(rect));
}

@end
