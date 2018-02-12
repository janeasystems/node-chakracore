//
//  NodeRunner.hpp
//  testnode
//
#import <Foundation/Foundation.h>
#ifndef NodeRunner_hpp
#define NodeRunner_hpp
@interface NodeRunner : NSObject
{
}
+ (void) CopyTestDir:(NSString*)srcTestsPath:(NSString*)dstTestsPath;
+ (int) startEngineWithArguments:(NSArray*)arguments;
@end
#endif /* NodeRunner_h */
