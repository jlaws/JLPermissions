#import <Foundation/Foundation.h>
#import "Sequence.h"
#ifdef TL_SHORTHAND
    #define range(num) [Range range:num]
#endif

@interface Range : NSObject
+ (Sequence *)range:(NSNumber *)start;

+ (Sequence *)range:(NSNumber *)start end:(NSNumber *)end;

@end