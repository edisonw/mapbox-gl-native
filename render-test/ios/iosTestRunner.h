#import <Foundation/Foundation.h>
__attribute__((visibility ("default")))
@interface IosTestRunner : NSObject
- (NSString*) getResultPath;
- (NSString*) getMetricPath;
- (BOOL) getTestStatus;
@end
