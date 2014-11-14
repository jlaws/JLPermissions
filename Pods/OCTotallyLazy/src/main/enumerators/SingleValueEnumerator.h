#import <Foundation/Foundation.h>


@interface SingleValueEnumerator : NSEnumerator
- (SingleValueEnumerator *)initWithValue:(id)aValue;

+ (id)singleValue:(id)value;
@end