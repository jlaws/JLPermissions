#import "Types.h"

@interface Numbers : NSObject
+ (FUNCTION2)sum;

+ (FUNCTION2)average;

+ (FUNCTION2)multiplyBy;

+ (FUNCTION1)multiplyBy:(NSNumber *)number;

+ (FUNCTION2)divideBy;

+ (FUNCTION1)divideBy:(NSNumber *)divisor;

+ (FUNCTION2)add;

+ (FUNCTION1)add:(NSNumber *)addition;

+ (FUNCTION2)subtract;

+ (FUNCTION1)substract:(NSNumber *)subtractor;
@end

static FUNCTION2 TL_sum() {
    return [Numbers sum];
}

static FUNCTION2 TL_average() {
    return [Numbers average];
}

static FUNCTION1 TL_multiplyBy(NSNumber *multiplier) {
    return [Numbers multiplyBy:multiplier];
}

static FUNCTION1 TL_divideBy(NSNumber *divisor) {
    return [Numbers divideBy:divisor];
}

static FUNCTION1 TL_add(NSNumber *addition) {
    return [Numbers add:addition];
}

static FUNCTION1 TL_subtract(NSNumber *subtractor) {
    return [Numbers substract:subtractor];
}

#ifdef TL_SHORTHAND
    #define sum() TL_sum()
    #define average() TL_average()
    #define multiplyBy(multiplier) TL_multiplyBy(multiplier)
    #define divideBy(divisor) TL_divideBy(divisor)
    #define add(addition) TL_add(addition)
    #define subtract(subtractor) TL_subtract(subtractor)
#endif