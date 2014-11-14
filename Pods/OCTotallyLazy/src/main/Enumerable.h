#import <Foundation/Foundation.h>

@protocol Enumerable <NSObject>
-(NSEnumerator *)toEnumerator;
@end