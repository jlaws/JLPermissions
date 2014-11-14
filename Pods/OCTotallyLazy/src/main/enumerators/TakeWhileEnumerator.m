#import <OCTotallyLazy/OCTotallyLazy.h>
#import "TakeWhileEnumerator.h"


@implementation TakeWhileEnumerator {
    NSEnumerator *enumerator;

    BOOL (^predicate)(id);

}

- (NSEnumerator *)initWith:(NSEnumerator *)anEnumerator predicate:(PREDICATE)aPredicate {
    self = [super init];
    enumerator = anEnumerator;
    predicate = aPredicate;
    return self;

}

- (id)nextObject {
    id item = [enumerator nextObject];
    return predicate(item) ? item : nil;
}


+ (NSEnumerator *)with:(NSEnumerator *)anEnumerator predicate:(PREDICATE)predicate {
    return [[TakeWhileEnumerator alloc] initWith:anEnumerator predicate:predicate];
}
@end