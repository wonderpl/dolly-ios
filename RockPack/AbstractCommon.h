#import "_AbstractCommon.h"


@interface AbstractCommon : _AbstractCommon

typedef enum
{
    kIgnoreNothing = 0,
    kIgnoreVideoInstanceObjects = 1 << 0,
    kIgnoreChannelObjects = 1 << 2,
    kIgnoreChannelOwnerObject = 1 << 3,
    kIgnoreSubscriptionObjects = 1 << 9,
    kIgnoreAll = INT32_MAX
} IgnoringObjects;

@end
