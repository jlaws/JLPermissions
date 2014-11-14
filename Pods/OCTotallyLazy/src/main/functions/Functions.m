#import "Functions.h"


@implementation Functions

+(Function2 *)f2:(FUNCTION2)f2Block {
    return [[Function2 alloc] initF2:f2Block];
}

+(Function1 *)f1:(FUNCTION1)f1Block {
    return [[Function1 alloc] initF1:f1Block];
}

+ (Function1 *)compose:(Function1 *)a and:(Function1 *)b {
    return [Functions f1:^(id argument) {
        return [b apply:[a apply:argument]];
    }];
}

@end