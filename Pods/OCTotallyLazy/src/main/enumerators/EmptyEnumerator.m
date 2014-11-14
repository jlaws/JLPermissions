#import "EmptyEnumerator.h"


@implementation EmptyEnumerator

+ (NSEnumerator *)emptyEnumerator {
    return [[EmptyEnumerator alloc] init];
}

- (id)nextObject {
    return nil;
}

@end