@protocol Foldable
- (id)fold:(id)value with:(id (^)(id, id))functorBlock;
@end