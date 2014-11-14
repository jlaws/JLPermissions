#import <Foundation/Foundation.h>


@interface FlattenEnumerator : NSEnumerator
- (FlattenEnumerator *)initWithEnumerator:(NSEnumerator *)anEnumerator;

+ (NSEnumerator *)withEnumerator:(NSEnumerator *)enumerator;
@end