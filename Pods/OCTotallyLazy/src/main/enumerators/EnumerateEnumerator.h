#import <Foundation/Foundation.h>

@interface EnumerateEnumerator : NSEnumerator
- (EnumerateEnumerator *)initWithCallable:(id (^)(id))aCallableFunc seed:(id)aSeed;

+ (EnumerateEnumerator *)withCallable:(id (^)(id))callableFunc seed:(id)aSeed;

@end