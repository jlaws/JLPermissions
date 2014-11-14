#import "Range.h"
#import "EasyEnumerable.h"
#import "EnumerateEnumerator.h"
#import "Callables.h"
#import "Predicates.h"


@implementation Range

+ (EasyEnumerable *)incrementingEnumerator:(NSNumber *)start {
    return [EasyEnumerable with:^{ return [EnumerateEnumerator withCallable:TL_increment() seed:start]; }];
}

+ (Sequence *)range:(NSNumber *)start {
    return [Sequence with:[self incrementingEnumerator:start]];
}

+ (Sequence *)range:(NSNumber *)start end:(NSNumber *)end {
    return [[Sequence with:[self incrementingEnumerator:start]] takeWhile:TL_lessThanOrEqualTo(end)];
}

@end