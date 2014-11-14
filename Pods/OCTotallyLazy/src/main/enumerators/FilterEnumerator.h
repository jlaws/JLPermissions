#import <Foundation/Foundation.h>


@interface FilterEnumerator : NSEnumerator
- (FilterEnumerator *)initWithEnumerator:(NSEnumerator *)anEnumerator andFilter:(BOOL (^)(id))aFunc;

+ (NSEnumerator *)withEnumerator:(NSEnumerator *)enumerator andFilter:(BOOL (^)(id))func;
@end