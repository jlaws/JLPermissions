#import <Foundation/Foundation.h>
#import "MemoisedEnumerator.h"


@interface RepeatEnumerator : NSEnumerator
- (RepeatEnumerator *)initWith:(MemoisedEnumerator *)enumerator;

+ (RepeatEnumerator *)with:(MemoisedEnumerator *)anEnumerator;
@end