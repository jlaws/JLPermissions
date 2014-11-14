#import "MemoisedEnumerator.h"


@implementation MemoisedEnumerator {
    NSEnumerator *enumerator;
    NSMutableArray *memory;
    NSInteger position;
}

- (int)previousIndex {
    return position - 1;
}

- (int)nextIndex {
    return position;
}

- (id)previousObject {
    return position > 0 ? [memory objectAtIndex:(NSUInteger) --position] : nil;
}

- (BOOL)hasCachedAnswer {
    return position < [memory count];
}

- (id)cachedAnswer:(NSInteger)index {
    return [memory objectAtIndex:(NSUInteger) index];
}

- (id)nextObject {
    if ([self hasCachedAnswer]) {
        return [self cachedAnswer:position++];
    }
    id item = [enumerator nextObject];
    if (item != nil) {
        [memory addObject:item];
        position++;
        return item;
    }
    return nil;
}

- (MemoisedEnumerator *)initWith:(NSEnumerator *)anEnumerator memory:(NSMutableArray *)aMemory {
    self = [super init];
    enumerator = anEnumerator;
    memory = aMemory;
    position = 0;
    return self;
}


- (id)firstObject {
    position = 0;
    return [self nextObject];
}

- (void)reset {

}

+ (MemoisedEnumerator *)with:(NSEnumerator *)enumerator {
    return [[MemoisedEnumerator alloc] initWith:enumerator memory:[NSMutableArray array]];
}

+ (MemoisedEnumerator *)with:(NSEnumerator *)enumerator memory:(NSMutableArray *)memory {
    return [[MemoisedEnumerator alloc] initWith:enumerator memory:memory];
}
@end