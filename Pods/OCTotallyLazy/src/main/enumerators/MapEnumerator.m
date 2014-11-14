#import <OCTotallyLazy/OCTotallyLazy.h>
#import "MapEnumerator.h"


@implementation MapEnumerator {
    NSEnumerator *enumerator;
    id (^func)(id);
}

- (MapEnumerator *)initWithEnumerator:(NSEnumerator *)anEnumerator andFunction:(id (^)(id))aFunc {
    self = [super init];
    enumerator = anEnumerator;
    func = [aFunc copy];
    return self;
}

+ (NSEnumerator *)withEnumerator:(NSEnumerator *)enumerator andFunction:(id (^)(id))func {
    return [[MapEnumerator alloc] initWithEnumerator:enumerator andFunction:func];
}

- (id)nextObject {
    id item = [enumerator nextObject];
    return (item == nil) ? nil : [item conformsToProtocol:@protocol(Mappable)] ? [item map:func] : func(item);
}



@end