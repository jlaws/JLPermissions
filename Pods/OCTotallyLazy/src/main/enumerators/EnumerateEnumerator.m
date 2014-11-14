#import "EnumerateEnumerator.h"


@implementation EnumerateEnumerator {
    id (^callableFunc)(id);
    id seed;
}

- (EnumerateEnumerator *)initWithCallable:(id (^)(id))aCallableFunc seed:(id)aSeed {
    self = [super init];
    callableFunc = [aCallableFunc copy];
    seed = aSeed;
    return self;
}

- (id)nextObject {
    id result = seed;
    seed = callableFunc(seed);
    return result;
}


+ (EnumerateEnumerator *)withCallable:(id (^)(id))callableFunc seed:(id)aSeed {
    return [[EnumerateEnumerator alloc] initWithCallable:callableFunc seed:aSeed];
}

@end