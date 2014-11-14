#import <Foundation/Foundation.h>
#import "Option.h"
#import "Predicates.h"

@interface NSEnumerator (OCTotallyLazy)
- (NSEnumerator *)drop:(int)toDrop;
- (NSEnumerator *)dropWhile:(BOOL (^)(id))filterBlock;
- (NSEnumerator *)filter:(BOOL (^)(id))filterBlock;
- (NSEnumerator *)flatten;
- (NSEnumerator *)map:(id (^)(id))func;

- (NSEnumerator *)take:(int)n;
- (NSEnumerator *)takeWhile:(BOOL (^)(id))predicate;
- (Option *)find:(PREDICATE)predicate;

@end