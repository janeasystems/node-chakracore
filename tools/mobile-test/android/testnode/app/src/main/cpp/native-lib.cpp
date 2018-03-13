#include <jni.h>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <android/log.h>

namespace node {
    extern int Start(int argc, char *argv[]);
}

extern "C"
int startNode(int argc, char *argv[]) {
    const int exit_code = node::Start(argc,argv);
    return exit_code;
}

// Forward declaration
int start_redirecting_stdout_stderr();

const char *TAG = "TestNode";
JNIEnv* cacheEnvPointer = NULL;

void AtExitHook()
{
    // If the process is exiting, we might has well say it has failed,
    //because if it doesn't have a RESULT line before, it will block
    //the test suite until a timeout occurs.
    fprintf(stdout,"RESULT:FAIL\n");
}

extern "C"
JNIEXPORT jint JNICALL
Java_nodejsmobile_test_testnode_MainActivity_startNodeWithArguments(
        JNIEnv *env,
        jobject /* this */,
        jobjectArray arguments,
        jstring nodePath,
        jboolean redirectOutputToLogcat) {


    // Node's libuv requires all arguments being on contiguous memory.
    cacheEnvPointer = env;
    const char* path_path = env->GetStringUTFChars(nodePath, 0);
    setenv("NODE_PATH", path_path, 1);
    env->ReleaseStringUTFChars(nodePath, path_path);

    // argc to pass to Node.
    jsize argc = env->GetArrayLength(arguments);

    // Compute byte size need for all arguments in contiguous memory.
    int c_arguments_size = 0;
    for (int i = 0; i < argc ; i++) {
        c_arguments_size += strlen(env->GetStringUTFChars((jstring)env->GetObjectArrayElement(arguments, i), 0));
        c_arguments_size++; // for '\0'
    }

    // Stores arguments in contiguous memory.
    char* args_buffer = (char*)calloc(c_arguments_size, sizeof(char));

    // argv to pass to Node.
    char* argv[argc];

    // To iterate through the expected start position of each argument in args_buffer.
    char* current_args_position = args_buffer;

    // Populate the args_buffer and argv.
    for (int i = 0; i < argc ; i++) {
        const char* current_argument = env->GetStringUTFChars((jstring)env->GetObjectArrayElement(arguments, i), 0);

        // Copy current argument to its expected position in args_buffer
        strncpy(current_args_position, current_argument, strlen(current_argument));

        // Save current argument start position in argv
        argv[i] = current_args_position;

        // Increment to the next argument's expected position.
        current_args_position += strlen(current_args_position)+1;
    }

    if (redirectOutputToLogcat == true) {
        // Start threads to show stdout and stderr in logcat.
        if (start_redirecting_stdout_stderr() == -1) {
            __android_log_write(ANDROID_LOG_ERROR, TAG, "Couldn't start redirecting stdout and stderr to logcat.");
        }
    }

    // Registers atExitHook
    atexit(AtExitHook);

    int result = 0;

    result = startNode(argc, argv);

    // Use node's return code as a PASS(==0) or a FAIL(!=0).
    if (result==0) {
        fprintf(stdout,"RESULT:PASS\n");
    } else {
        fprintf(stdout,"RESULT:FAIL\n");
    }

    return jint(result);
}

/**
 * Redirect stdout and staderr to Android's logcat
 */

int pipe_stdout[2];
int pipe_stderr[2];
pthread_t thread_stdout;
pthread_t thread_stderr;

void redirect(int pipe, int log_level) {
    ssize_t redirect_size;
    // Big enough buffer to not get logcat linebreaks in the middle of message tests output.
    char buf[10240];
    while ((redirect_size = read(pipe, buf, sizeof buf - 1)) > 0) {
        // __android_log_write will add a new line anyway.
        if (buf[redirect_size - 1] == '\n')
            --redirect_size;
        buf[redirect_size] = 0;
        __android_log_write(log_level, TAG, buf);
    }
}

void* thread_stderr_func(void*) {
    redirect(pipe_stderr[0], ANDROID_LOG_ERROR);
    return 0;
}

void* thread_stdout_func(void*) {
    redirect(pipe_stdout[0], ANDROID_LOG_INFO);
    return 0;
}

int start_redirecting_stdout_stderr() {
    // Set stdout as unbuffered.
    setvbuf(stdout, 0, _IONBF, 0);
    pipe(pipe_stdout);
    dup2(pipe_stdout[1], STDOUT_FILENO);

    // Set stderr as unbuffered.
    setvbuf(stderr, 0, _IONBF, 0);
    pipe(pipe_stderr);
    dup2(pipe_stderr[1], STDERR_FILENO);

    if (pthread_create(&thread_stdout, 0, thread_stdout_func, 0) == -1) {
        return -1;
    }
    pthread_detach(thread_stdout);

    if(pthread_create(&thread_stderr, 0, thread_stderr_func, 0) == -1) {
        return -1;
    }
    pthread_detach(thread_stderr);

    return 0;
}