#import "MergeEnumerator.h"
#import "Pair.h"


@implementation MergeEnumerator {
    NSEnumerator *left;
    NSEnumerator *right;
}

- (MergeEnumerator *)initWith:(NSEnumerator *)leftEnumerator toMerge:(NSEnumerator *)rightEnumerator {
    self = [super init];
    left = leftEnumerator;
    right = rightEnumerator;
    return self;
}

- (id)nextObject {
    id leftItem = [Option option:[left nextObject]];
    id rightItem = [Option option:[right nextObject]];
    if([leftItem isEmpty] && [rightItem isEmpty]) {
        return nil;
    }
    return sequence(leftItem, rightItem, nil);
}


+ (MergeEnumerator *)with:(NSEnumerator *)leftEnumerator toMerge:(NSEnumerator *)rightEnumerator {
    return [[MergeEnumerator alloc] initWith:leftEnumerator toMerge:rightEnumerator];
}

@end