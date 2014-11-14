#import <Foundation/Foundation.h>
#import "Types.h"
#import "Function1.h"

@interface Function2 : Function1

- (id)initF2:(FUNCTION2)f2Block;

- (Function1 *)apply:(id)argument1;

@end