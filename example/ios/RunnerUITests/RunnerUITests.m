@import XCTest;
#import "PatrolIntegrationTestIosRunner.h"
@import ObjectiveC.runtime;

__attribute__((objc_runtime_name("_TtC6patrol16ObjCLocalization")))
@interface ObjCLocalization : NSObject
+ (NSString *)getLocalizedStringWithKey:(NSString *)key;
@end

__attribute__((objc_runtime_name("_TtC6patrol12PatrolServer")))
@interface PatrolServer : NSObject
@property(nonatomic, readonly) BOOL appReady;
- (BOOL)startAndReturnError:(NSError **)error;
@end

__attribute__((objc_runtime_name("_TtC6patrol23ObjCRunDartTestResponse")))
@interface ObjCRunDartTestResponse : NSObject
@property(nonatomic, readonly) BOOL passed;
@property(nonatomic, readonly, copy) NSString *details;
@end

__attribute__((objc_runtime_name("_TtC6patrol26ObjCPatrolAppServiceClient")))
@interface ObjCPatrolAppServiceClient : NSObject
- (void)listDartTestsWithCompletion:(void (^)(NSArray<NSDictionary *> *tests, NSError *error))completion;
- (void)runDartTestWithName:(NSString *)name completion:(void (^)(ObjCRunDartTestResponse *response, NSError *error))completion;
@end

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
