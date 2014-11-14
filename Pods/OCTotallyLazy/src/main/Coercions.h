#import <Foundation/Foundation.h>
#ifdef TL_COERCIONS
static NSNumber *num(NSInteger value) {
    return [NSNumber numberWithInteger:value];
}
static NSNumber *numl(long value) {
    return [NSNumber numberWithLong:value];
}
static NSNumber *numf(float value) {
    return [NSNumber numberWithFloat:value];
}
static NSNumber *numd(double value) {
    return [NSNumber numberWithDouble:value];
}
#endif