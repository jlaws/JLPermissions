#import <Foundation/Foundation.h>

@interface MergeEnumerator : NSEnumerator
- (MergeEnumerator *)initWith:(NSEnumerator *)leftEnumerator toMerge:(NSEnumerator *)rightEnumerator;

+(MergeEnumerator *)with:(NSEnumerator *)leftEnumerator toMerge:(NSEnumerator *)rightEnumerator;
@end