#import "JLPermissionsCore.h"

NS_ASSUME_NONNULL_BEGIN
@interface JLPermissionsCore (Internal)

- (NSString *)appName;
- (NSString *)defaultTitle:(NSString *)authorizationType;
- (NSString *__nullable)defaultMessage;
- (NSString *)defaultCancelTitle;
- (NSString *)defaultGrantTitle;
- (NSError *)userDeniedError;
- (NSError *)previouslyDeniedError;
- (NSError *)systemDeniedError:(NSError *__nullable)error;

#pragma mark - Abstract Methods

- (void)actuallyAuthorize;
- (void)canceledAuthorization:(NSError *)error;

@end
NS_ASSUME_NONNULL_END