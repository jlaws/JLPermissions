#import "Pair.h"

@implementation Pair {

@private
    id _left;
    id _right;
}
@synthesize left = _left;
@synthesize right = _right;

- (Pair *)initWithLeft:(id)aLeft right:(id)aRight {
    self = [super init];
    _left = aLeft;
    _right = aRight;
    return self;
}

- (Sequence *)toSequence {
    return sequence(_left, _right, nil);
}

+ (Pair *)left:(id)aLeft right:(id)aRight {
    return [[Pair alloc] initWithLeft:aLeft right:aRight];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Pair class]] || object == nil) {
        return FALSE;
    }
    Pair *otherObject = object;
    return [otherObject.left isEqual: self.left] && [otherObject.right isEqual: self.right]; 
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Pair left:(%@) right:(%@)]", [self.left description], [self.right description]];
}



@end