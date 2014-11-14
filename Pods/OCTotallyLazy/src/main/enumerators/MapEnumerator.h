#import <Foundation/Foundation.h>


@interface MapEnumerator : NSEnumerator
- (MapEnumerator *)initWithEnumerator:(NSEnumerator *)anEnumerator andFunction:(id (^)(id))aFunc;

+ (NSEnumerator *)withEnumerator:(NSEnumerator *)enumerator andFunction:(id (^)(id))func;
@end