#import <OCTotallyLazy/OCTotallyLazy.h>
#import "NSDictionary+OCTotallyLazy.h"

@implementation NSDictionary (Functional)

- (NSMutableDictionary * (^)(NSMutableDictionary *, id))addObjectForKey {
    return [^(NSMutableDictionary *dict, id key) {
                [dict setObject:[self objectForKey:key] forKey:key];
                return dict;
            } copy];
}

- (NSDictionary *)filterKeys:(BOOL (^)(id))filterBlock {
    return [[[self allKeys] filter:filterBlock] fold:[NSMutableDictionary dictionary] with:[self addObjectForKey]];
}

- (NSDictionary *)filterValues:(BOOL (^)(id))filterBlock {
    return [[[self allValues] filter:filterBlock] fold:[NSMutableDictionary dictionary] with:^(NSMutableDictionary *dict, id value) {
        [[self allKeysForObject:value] fold:dict with:[self addObjectForKey]];
        return dict;
    }];
}

- (void)foreach:(void (^)(id, id))funcBlock {
    [[self allKeys] foreach:^(id key){funcBlock(key, [self objectForKey:key]);}];
}

- (id)map:(NSArray * (^)(id key, id value))funcBlock {
    return [[[[self allKeys] map:^(id key){return funcBlock(key, [self objectForKey:key]);}] flatten] asDictionary];
}

- (id)mapValues:(id (^)(id))funcBlock {
    return dictionary([[self allKeys] asSequence], [[[self allValues] asSequence] map:funcBlock]);
}

- (Option *)optionForKey:(id)key {
    return option([self objectForKey:key]);
}

@end