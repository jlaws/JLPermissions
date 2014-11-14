#import "Sequence.h"
#import "MemoisedEnumerator.h"

@interface MemoisedSequence : Sequence
@end

#ifdef TL_COERCIONS
static Sequence *memoiseSeq(id<Enumerable> underlying) {
    return [MemoisedSequence with:underlying];
}
#endif
