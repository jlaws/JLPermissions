#import <Foundation/Foundation.h>

@interface PairEnumerator : NSEnumerator
- (PairEnumerator *)initWithLeft:(NSEnumerator *)leftEnumerator right:(NSEnumerator *)rightEnumerator;

+(PairEnumerator *)withLeft:(NSEnumerator *)leftEnumerator right:(NSEnumerator *)rightEnumerator;
@end