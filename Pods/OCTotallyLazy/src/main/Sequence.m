#define TL_COERCIONS

#import "NSEnumerator+OCTotallyLazy.h"
#import "PairEnumerator.h"
#import "MemoisedEnumerator.h"
#import "MemoisedSequence.h"
#import "RepeatEnumerator.h"
#import "EasyEnumerable.h"
#import "Callables.h"
#import "GroupedEnumerator.h"
#import "Pair.h"
#import "Range.h"
#import "PartitionEnumerator.h"
#import "OCTotallyLazy.h"
#import "MergeEnumerator.h"

@implementation Sequence {
    id <Enumerable> enumerable;
    NSEnumerator *forwardOnlyEnumerator;
}

- (Sequence *)initWith:(id <Enumerable>)anEnumerable {
    self = [super init];
    enumerable = anEnumerable;
    forwardOnlyEnumerator = [enumerable toEnumerator];
    return self;
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id[])buffer count:(NSUInteger)len {
    return [forwardOnlyEnumerator countByEnumeratingWithState:state objects:buffer count:len];
}

- (Sequence *)add:(id)value {
    return [self join:sequence(value, nil)];
}

- (Sequence *)cons:(id)value {
    return [sequence(value, nil) join:self];
}

- (Sequence *)drop:(int)toDrop {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] drop:toDrop];
    }]];
}

- (Sequence *)dropWhile:(BOOL (^)(id))funcBlock {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] dropWhile:funcBlock];
    }]];
}

- (id)first {
    return [self head];
}

- (Sequence *)flatMap:(id (^)(id))funcBlock {
    return [Sequence with:[EasyEnumerable with:^{
        return [[[self toEnumerator] map:funcBlock] flatten];
    }]];
}

- (Sequence *)filter:(BOOL (^)(id))predicate {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] filter:predicate];
    }]];
}

- (Option *)find:(BOOL (^)(id))predicate {
    return [[self toEnumerator] find:predicate];
}

- (Sequence *)flatten {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] flatten];
    }]];
}

- (id)fold:(id)value with:(id (^)(id, id))functorBlock {
    return [[self asArray] fold:value with:functorBlock];
}

- (void)foreach:(void (^)(id))funcBlock {
    [[self asArray] foreach:funcBlock];
}

- (Sequence *)grouped:(int)n {
    return [Sequence with:[EasyEnumerable with:^{
        return [GroupedEnumerator with:[self toEnumerator] groupSize:n];
    }]];
}

- (Sequence *)groupBy:(FUNCTION1)groupingBlock {
    return [[[self asArray] groupBy:groupingBlock] asSequence];
}

- (id)head {
    id item = [self toEnumerator].nextObject;
    if (item == nil) {
        [NSException raise:@"NoSuchElementException" format:@"Expected a sequence with at least one element, but sequence was empty."];
    }
    return item;
}

- (Option *)headOption {
    return option([self toEnumerator].nextObject);
}

- (Sequence *)join:(id <Enumerable>)toJoin {
    return [sequence(self, toJoin, nil) flatten];
}

- (Sequence *)map:(id (^)(id))funcBlock {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] map:funcBlock];
    }]];
}

- (Sequence *)mapWithIndex:(id (^)(id, NSInteger))funcBlock {
    return [[self zipWithIndex] map:^(Pair *itemAndIndex) {
        return funcBlock(itemAndIndex.left, [itemAndIndex.right intValue]);
    }];
}

- (Sequence *)merge:(Sequence *)toMerge {
    return [[Sequence with:[EasyEnumerable with:^{
        return [MergeEnumerator with:[self toEnumerator] toMerge:[toMerge toEnumerator]];
    }]] flatten];
}

- (Pair *)partition:(BOOL (^)(id))predicate {
    Queue *matched = [Queue queue];
    Queue *unmatched = [Queue queue];
    NSEnumerator *underlyingEnumerator = [self toEnumerator];
    Sequence *leftSequence = memoiseSeq([EasyEnumerable with:^{
        return [PartitionEnumerator with:underlyingEnumerator
                               predicate:predicate
                                 matched:matched
                               unmatched:unmatched];
    }]);
    Sequence *rightSequence = memoiseSeq([EasyEnumerable with:^{
        return [PartitionEnumerator with:underlyingEnumerator
                               predicate:TL_not(predicate)
                                 matched:unmatched
                               unmatched:matched];
    }]);
    return [Pair left:leftSequence right:rightSequence];
}

- (id)reduce:(id (^)(id, id))functorBlock {
    return [[self asArray] reduce:functorBlock];
}

- (id)second {
    return [[self tail] head];
}

- (Pair *)splitAt:(int)splitIndex {
    return [self splitWhen:TL_not(TL_countTo(splitIndex))];
}

- (Pair *)splitOn:(id)splitItem {
    return [self splitWhen:TL_equalTo(splitItem)];
}

- (Pair *)splitWhen:(BOOL (^)(id))predicate {
    Pair *partitioned = [self partition:TL_whileTrue(TL_not(predicate))];
    return [Pair left:partitioned.left right:[partitioned.right tail]];
}

- (Sequence *)tail {
    return [Sequence with:[EasyEnumerable with:^{
        NSEnumerator *const anEnumerator = [self toEnumerator];
        [anEnumerator nextObject];
        return anEnumerator;
    }]];
}

- (Sequence *)take:(int)n {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] take:n];
    }]];
}

- (Sequence *)takeWhile:(BOOL (^)(id))funcBlock {
    return [Sequence with:[EasyEnumerable with:^{
        return [[self toEnumerator] takeWhile:funcBlock];
    }]];
}

- (NSDictionary *)toDictionary:(id (^)(id))valueBlock {
    return [self fold:[NSMutableDictionary dictionary] with:^(NSMutableDictionary *accumulator, id item) {
        if ([accumulator objectForKey:item] == nil) {
            [accumulator setObject:valueBlock(item) forKey:item];
        }
        return accumulator;
    }];
}

- (NSString *)toString {
    return [self toString:@""];
}

- (NSString *)toString:(NSString *)separator {
    return [self reduce:TL_appendWithSeparator(separator)];
}

- (NSString *)toString:(NSString *)start separator:(NSString *)separator end:(NSString *)end {
    return [[start stringByAppendingString:[self toString:separator]] stringByAppendingString:end];
}

- (Sequence *)zip:(Sequence *)otherSequence {
    return [Sequence with:[EasyEnumerable with:^{
        return [PairEnumerator withLeft:[self toEnumerator] right:[otherSequence toEnumerator]];
    }]];
}

- (Sequence *)zipWithIndex {
    return [self zip:[Range range:[NSNumber numberWithInt:0]]];
}

- (Sequence *)cycle {
    return [Sequence with:[EasyEnumerable with:^{
        return [RepeatEnumerator with:[MemoisedEnumerator with:[self toEnumerator]]];
    }]];
}

+ (Sequence *)with:(id <Enumerable>)enumerable {
    return [[Sequence alloc] initWith:enumerable];
}

- (NSDictionary *)asDictionary {
    return [[self asArray] asDictionary];
}

- (NSArray *)asArray {
    NSEnumerator *itemsEnumerator = [self toEnumerator];
    NSMutableArray *collect = [NSMutableArray array];
    id object;
    while ((object = [itemsEnumerator nextObject]) != nil) {
        [collect addObject:object];
    }
    return collect;
}

- (NSSet *)asSet {
    return [NSSet setWithArray:[self asArray]];
}

- (NSString *)description {
    NSEnumerator *itemsEnumerator = [self toEnumerator];
    NSString *description = @"Sequence [";
    int count = 3;
    id item;
    while (count > 0 && (item = itemsEnumerator.nextObject)) {
        description = [description stringByAppendingFormat:@"%@, ", item];
        count--;
    }
    if ([itemsEnumerator nextObject] != nil) {
        description = [description stringByAppendingString:@"..."];
    }
    return [description stringByAppendingString:@"]"];
}

- (NSEnumerator *)toEnumerator {
    return [enumerable toEnumerator];
}

@end