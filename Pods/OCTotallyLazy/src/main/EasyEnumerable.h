#import <Foundation/Foundation.h>
#import "Enumerable.h"

@interface EasyEnumerable : NSObject <Enumerable>
+ (EasyEnumerable *)with:(NSEnumerator * (^)())aConvertToEnumerator;
@end