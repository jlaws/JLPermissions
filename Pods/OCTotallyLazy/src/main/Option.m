#import "Option.h"
#import "None.h"
#import "Some.h"
#import "Sequence.h"

@implementation Option

- (Sequence *)asSequence {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

+ (id)option:(id)value {
    return (value == nil) ? [None none] : [Some some:value];
}

- (BOOL)isEmpty {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return FALSE;
}

- (id)flatMap:(id (^)(id))funcBlock {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (id)fold:(id)value with:(id (^)(id, id))functorBlock {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (id)get {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (id)getOrElse:(id)other {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (id)getOrInvoke:(id (^)())funcBlock {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (id)map:(id (^)(id))funcBlock {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (void)maybe:(void (^)(id))invokeWhenSomeBlock {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
}

- (NSEnumerator *)toEnumerator {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

- (Option *)flatten {
    return [self isEmpty] ? [None none] : [[[self asSequence] flatten] headOption];
}

- (id)copyWithZone:(NSZone *)zone {
    [NSException raise:@"Unsupported" format:@"Unsupported"];
    return nil;
}

@end