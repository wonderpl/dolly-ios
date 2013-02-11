#import "_AbstractCommon.h"


@interface AbstractCommon : _AbstractCommon

typedef enum {
    kIgnoreNothing = 0,
    kIgnoreVideoInstanceObjects = 1,
    kIgnoreChannelObjects = 2,
    kIgnoreChannelOwnerObjects = 4,
    kIgnoreVideoObjects = 8
} IgnoringObjects;

@end
