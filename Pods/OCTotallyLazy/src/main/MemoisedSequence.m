#import "MemoisedSequence.h"

@implementation MemoisedSequence {
    NSMutableArray *memory;
}

+ (Sequence *)with:(id <Enumerable>)enumerable {
    return [[MemoisedSequence alloc] initWith:enumerable];
}

- (Sequence *)initWith:(id <Enumerable>)enumerator {
    self = [super initWith:enumerator];
    if (self) {
        memory = [NSMutableArray array];
    }
    return self;
}

- (NSEnumerator *)toEnumerator {
    return [MemoisedEnumerator with:[super toEnumerator] memory:memory];
}


@end