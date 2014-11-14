#import <Foundation/Foundation.h>
#import "Sequence.h"

@interface Pair : NSObject

@property(nonatomic, readonly) id left;
@property(nonatomic, readonly) id right;

- (Pair *)initWithLeft:(id)aKey right:(id)aValue;
- (Sequence *)toSequence;
+ (Pair *)left:(id)aLeft right:(id)aRight;

@end