#import "Function1.h"

@interface Function1()
@property(nonatomic, copy) FUNCTION1 f1Block;
@end

@implementation Function1

- (id)initF1:(FUNCTION1)f1Block {
    self = [super init];
    if (self) {
        self.f1Block = f1Block;
    }
    return self;
}

- (id)apply:(id)argument1 {
    return self.f1Block(argument1);
}

@end