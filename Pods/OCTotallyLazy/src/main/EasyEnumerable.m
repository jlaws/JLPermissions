#import "EasyEnumerable.h"


@implementation EasyEnumerable {
    NSEnumerator *(^convertToEnumerator)();
}
-(EasyEnumerable *)initWith:(NSEnumerator *(^)())aConvertToEnumerator {
    self = [super init];
    convertToEnumerator = [aConvertToEnumerator copy];
    return self;
}

+(EasyEnumerable *)with:(NSEnumerator *(^)())aConvertToEnumerator {
    return [[EasyEnumerable alloc] initWith:aConvertToEnumerator];
}

- (NSEnumerator *)toEnumerator {
    return convertToEnumerator();
}

@end