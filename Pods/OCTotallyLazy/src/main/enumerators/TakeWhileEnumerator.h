#import <Foundation/Foundation.h>


@interface TakeWhileEnumerator : NSEnumerator
- (NSEnumerator *)initWith:(NSEnumerator *)anEnumerator predicate:(PREDICATE)aPredicate;

+ (NSEnumerator *)with:(NSEnumerator *)anEnumerator predicate:(PREDICATE)predicate;
@end