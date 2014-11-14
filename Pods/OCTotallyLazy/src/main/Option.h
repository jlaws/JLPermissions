#import <Foundation/Foundation.h>
#import "Mappable.h"
#import "Foldable.h"
#import "Enumerable.h"
#import "Flattenable.h"
@class Sequence;

@interface Option : NSObject <NSCopying, Mappable, Foldable, Enumerable, Flattenable>
-(BOOL)isEmpty;
-(id)get;
-(id)getOrElse:(id)other;
-(id)getOrInvoke:(id (^)())funcBlock;

- (id)flatMap:(id (^)(id))funcBlock;

-(Sequence *)asSequence;

- (void)maybe:(void (^)(id))invokeWhenSomeBlock;

+(id)option:(id)value;
@end

static Option* option(id value) {
    return [Option option:value];
}