#import <Foundation/Foundation.h>
#import "Some.h"
#import "None.h"
#import "Sequence.h"

@interface NSSet (Functional) <Mappable, Foldable, Enumerable>
- (Option *)find:(PREDICATE)filterBlock;
- (NSSet *)filter:(PREDICATE)filterBlock;
- (NSSet *)groupBy:(FUNCTION1)groupingBlock;
- (id)head;
- (Option *)headOption;
- (NSSet *)join:(NSSet *)toJoin;
- (id)reduce:(FUNCTION2)functorBlock;

- (Sequence *)asSequence;
- (NSArray *)asArray;
@end

static NSSet *set() {
    return [NSSet set];
}