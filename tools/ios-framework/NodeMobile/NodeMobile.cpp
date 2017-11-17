
#import "NodeMobile.h"

namespace node {
    int Start(int argc, char *argv[]);
} // namespace node

int node_start(int argc, char *argv[]) {
    return node::Start(argc, argv);
}
