#import "Some.h"
#import "Sequence.h"
#import "SingleValueEnumerator.h"

@implementation Some {
    id <NSObject> value;
}

-(Option *)initWithValue:(id <NSObject>)aValue {
    self = [super init];
    value = aValue;
    return self;
}

+ (Option *)some:(id)value {
    return [[Some alloc] initWithValue: value];
}

- (BOOL)isEmpty {
    return FALSE;
}

- (BOOL)isEqual:(id)otherObject {
    if (![otherObject isKindOfClass:[Some class]]) {
        return FALSE;
    }
    return [[otherObject get] isEqual:[self get]];
}

- (id)get {
    return value;
}

- (id)getOrElse:(id)other {
    return value;
}

- (id)getOrInvoke:(id (^)())funcBlock {
    return value;
}

- (id)map:(id (^)(id))funcBlock {
    return [Some some:funcBlock(value)];
}

- (id)flatMap:(id (^)(id))funcBlock {
    return [[self flatten] map:funcBlock];
}

- (id)fold:(id)seed with:(id (^)(id, id))functorBlock {
    return [Some some:functorBlock(seed, value)];
}

- (Sequence *)asSequence {
    return sequence(value, nil);
}

- (NSEnumerator *)toEnumerator {
    return [SingleValueEnumerator singleValue:value];
}

- (id)copyWithZone:(NSZone *)zone {
    return [Some some:value];
}

- (void)maybe:(void (^)(id))invokeWhenSomeBlock {
    invokeWhenSomeBlock(value);
}

@end