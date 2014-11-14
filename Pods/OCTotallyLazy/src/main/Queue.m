#import <OCTotallyLazy/OCTotallyLazy.h>
#import "Queue.h"


@implementation Queue {
    NSMutableArray *queue;
}

- (id)init {
    self = [super init];
    if (self) {
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}


- (BOOL)isEmpty {
    return [queue isEmpty];
}

- (id)remove {
    if ([self isEmpty]) {
        return nil;
    }
    id item = [queue objectAtIndex:0];
    [queue removeObjectAtIndex:0];
    return item;
}

- (void)add:(id)item {
    [queue addObject:item];
}

+(Queue *)queue {
    return [[Queue alloc]init];
}

@end