#import "PartitionEnumerator.h"
#import "Queue.h"


@implementation PartitionEnumerator {
    NSEnumerator *underlyingEnumerator;
    PREDICATE predicate;
    Queue *matched;
    Queue *unmatched;
}

- (id)nextObject {
    if(![matched isEmpty]) {
        return [matched remove];
    }
    id result = [underlyingEnumerator nextObject];
    if (result == nil) {
        return nil;
    }
    if (predicate(result)) {
        return result;
    }
    [unmatched add:result];
    return [self nextObject];
}

- (PartitionEnumerator *)initWith:(NSEnumerator *)anEnumerator predicate:(PREDICATE)aPredicate matched:(Queue *)aMatched unmatched:(Queue *)anUnmatched {
    self = [super init];
    underlyingEnumerator = anEnumerator;
    predicate = [aPredicate copy];
    matched = aMatched;
    unmatched = anUnmatched;
    return self;
}


+ (PartitionEnumerator *)with:(NSEnumerator *)enumerator predicate:(PREDICATE)predicate matched:(Queue *)matched unmatched:(Queue *)unmatched {
    return [[PartitionEnumerator alloc] initWith:enumerator predicate:predicate matched:matched unmatched:unmatched];
}
@end