#import <Foundation/Foundation.h>


@interface MemoisedEnumerator : NSEnumerator
-(int)previousIndex;
-(int)nextIndex;
-(id)previousObject;

- (MemoisedEnumerator *)initWith:(NSEnumerator *)anEnumerator memory:(NSMutableArray *)aMemory;

- (id)firstObject;

- (void)reset;

+ (MemoisedEnumerator *)with:(NSEnumerator *)enumerator;

+ (MemoisedEnumerator *)with:(NSEnumerator *)enumerator memory:(NSMutableArray *)memory;

@end