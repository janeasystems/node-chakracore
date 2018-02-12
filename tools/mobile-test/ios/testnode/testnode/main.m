//
//  main.m
//  testnode
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NodeRunner.hpp"
int main(int argc, char * argv[]) {

    if(argc<2)
    {
        //This application needs some arguments to pass to node.
        return 0;
    } else {
        //If we receive arguments we are probably running tests.

        NSString* srcTestsPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:nil];
        NSString* dstTestsPath = [NSString stringWithFormat:@"%@/test", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];

        //--copy-path-for-testing indicates that we should copy the test folder to Documents.
        if(strncmp(argv[1],"--copy-path-for-testing",strlen("--copy-path-for-testing"))==0) {
            [NodeRunner CopyTestDir:srcTestsPath:dstTestsPath];
            return 0;
        }

        //NSArray to manipulate the arguments in, to use the NodeRunner startEngineWithArguments interface.
        NSMutableArray *arguments=[NSMutableArray array];
        [arguments addObject:@"node"]; //first argument.
        int i=1;
        NSString* file_replace_prefix=NULL;

        //--substitute-dir indicates a path prefix that should be replaced with the test path in Documents.
        if(argc>=3 && strncmp(argv[1],"--substitute-dir",strlen("--substitute-dir"))==0) {
            file_replace_prefix=[[NSString alloc] initWithCString:argv[2] encoding:NSUTF8StringEncoding];
            i+=2;
        }

        //Add following arguments to the node invocation.
        for(; i < argc; i++) {
            NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
            if(file_replace_prefix!=NULL && [str hasPrefix:file_replace_prefix])
            {
                //If the argument starts with the prefix, it needs to be translated into a Documents path.
                str = [NSString stringWithFormat:@"%@/%@", dstTestsPath, [str substringFromIndex:[file_replace_prefix length]]];
            }
            [arguments addObject:str];
        }

        //start Node
        return [NodeRunner startEngineWithArguments:arguments] ;
    }
}
