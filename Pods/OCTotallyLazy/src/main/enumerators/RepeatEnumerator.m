#import "RepeatEnumerator.h"
#import "MemoisedEnumerator.h"


@implementation RepeatEnumerator {
    MemoisedEnumerator *enumerator;
}
- (RepeatEnumerator *)initWith:(MemoisedEnumerator *)anEnumerator {
    self = [super init];
    enumerator = anEnumerator;
    return self;
}

- (id)nextObject {
    id item = [enumerator nextObject];
    return (item == nil) ? [enumerator firstObject] : item;
}


+ (RepeatEnumerator *)with:(MemoisedEnumerator *)anEnumerator {
    return [[RepeatEnumerator alloc] initWith:anEnumerator];
}
@end