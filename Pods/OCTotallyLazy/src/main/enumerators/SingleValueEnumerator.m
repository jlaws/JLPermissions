#import "SingleValueEnumerator.h"


@implementation SingleValueEnumerator {
    id value;
    BOOL valueRetrieved;
}
- (SingleValueEnumerator *)initWithValue:(id)aValue {
    self = [super init];
    value = aValue;
    valueRetrieved = FALSE;
    return self;

}

+ (SingleValueEnumerator *)singleValue:(id)value {
    return [[SingleValueEnumerator alloc] initWithValue:value];
}

- (id)nextObject {
    if (valueRetrieved) {
        return nil;
    }
    valueRetrieved = TRUE;
    return value;
}


@end