#import <Foundation/Foundation.h>

@interface GroupedEnumerator : NSEnumerator
- (GroupedEnumerator *)initWithEnumerator:(NSEnumerator *)anEnumerator groupSize:(int)groupSize;

+ (GroupedEnumerator *)with:(NSEnumerator *)enumerator groupSize:(int)groupSize;
@end