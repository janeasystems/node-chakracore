/* Copyright Joyent, Inc. and other Node contributors. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#ifndef UV_LINUX_SYSCALL_H_
#define UV_LINUX_SYSCALL_H_

#undef  _GNU_SOURCE
#define _GNU_SOURCE

#include <stdint.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>

#define UV__IN_CLOEXEC        O_CLOEXEC
#define UV__IN_NONBLOCK       O_NONBLOCK

/* inotify flags */
#define UV__IN_ACCESS         0x001
#define UV__IN_MODIFY         0x002
#define UV__IN_ATTRIB         0x004
#define UV__IN_CLOSE_WRITE    0x008
#define UV__IN_CLOSE_NOWRITE  0x010
#define UV__IN_OPEN           0x020
#define UV__IN_MOVED_FROM     0x040
#define UV__IN_MOVED_TO       0x080
#define UV__IN_CREATE         0x100
#define UV__IN_DELETE         0x200
#define UV__IN_DELETE_SELF    0x400
#define UV__IN_MOVE_SELF      0x800

struct uv__inotify_event {
  int32_t wd;
  uint32_t mask;
  uint32_t cookie;
  uint32_t len;
  /* char name[0]; */
};

struct uv__statx_timestamp {
  int64_t tv_sec;
  uint32_t tv_nsec;
  int32_t unused0;
};

struct uv__statx {
  uint32_t stx_mask;
  uint32_t stx_blksize;
  uint64_t stx_attributes;
  uint32_t stx_nlink;
  uint32_t stx_uid;
  uint32_t stx_gid;
  uint16_t stx_mode;
  uint16_t unused0;
  uint64_t stx_ino;
  uint64_t stx_size;
  uint64_t stx_blocks;
  uint64_t stx_attributes_mask;
  struct uv__statx_timestamp stx_atime;
  struct uv__statx_timestamp stx_btime;
  struct uv__statx_timestamp stx_ctime;
  struct uv__statx_timestamp stx_mtime;
  uint32_t stx_rdev_major;
  uint32_t stx_rdev_minor;
  uint32_t stx_dev_major;
  uint32_t stx_dev_minor;
  uint64_t unused1[14];
};

int uv__inotify_init(void);
int uv__inotify_init1(int flags);
int uv__inotify_add_watch(int fd, const char* path, uint32_t mask);
int uv__inotify_rm_watch(int fd, int32_t wd);
ssize_t uv__preadv(int fd, const struct iovec *iov, int iovcnt, int64_t offset);
ssize_t uv__pwritev(int fd, const struct iovec *iov, int iovcnt, int64_t offset);
int uv__dup3(int oldfd, int newfd, int flags);
ssize_t
uv__fs_copy_file_range(int fd_in,
                       ssize_t* off_in,
                       int fd_out,
                       ssize_t* off_out,
                       size_t len,
                       unsigned int flags);
int uv__statx(int dirfd,
              const char* path,
              int flags,
              unsigned int mask,
              struct uv__statx* statxbuf);
ssize_t uv__getrandom(void* buf, size_t buflen, unsigned flags);

#endif /* UV_LINUX_SYSCALL_H_ */
