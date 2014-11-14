#import <Foundation/Foundation.h>
#import "Types.h"
#import "Function2.h"


@interface Functions : NSObject
+(Function2 *)f2:(FUNCTION2)f2Block;

+ (Function1 *)f1:(FUNCTION1)f1Block;

+ (Function1 *)compose:(Function1 *)a and:(Function1 *)b;

@end

static Function2 *f2(FUNCTION2 function2) {
    return [Functions f2:function2];
}

static Function1 *f1(FUNCTION1 function1) {
    return [Functions f1:function1];
}