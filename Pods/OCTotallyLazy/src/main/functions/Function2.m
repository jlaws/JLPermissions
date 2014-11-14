#import "Function2.h"
#import "Function1.h"

@interface Function2()
@property (nonatomic, copy) FUNCTION2 f2Block;
@end

@implementation Function2

- (id)initF2:(FUNCTION2)f2Block {
    self = [super init];
    if (self) {
        self.f2Block = f2Block;
    }
    return self;
}

-(Function1 *)apply:(id)argument1 {
    return [[Function1 alloc] initF1:^(id argument2) {
        return self.f2Block(argument1, argument2);
    }];
}

@end