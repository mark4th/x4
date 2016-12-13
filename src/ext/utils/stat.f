\ stat.f    - x4 stat and fstat
\ ------------------------------------------------------------------------

\ ------------------------------------------------------------------------

struct: stat
  2 dd st_dev               \ device
  1 dw st_ino               \ inode
  1 dd st_mode              \ protection
  1 dd st_nlink             \ number of hard links
  1 dd st_uid               \ user ID of owner
  1 dd st_gid               \ group ID of owner
  2 dd st_rdev              \ device type (if inode device)
  1 dd st_size              \ total size, in bytes
  1 dd st_blksize           \ blocksize for filesystem I/O
  1 dd st_blocks            \ number of blocks allocated
  1 dd st_atime             \ time of last access
  1 dd st_mtime             \ time of last modification
  1 dd st_ctime             \ time of last change
;struct

\ ------------------------------------------------------------------------
\ define some syscalls...

 2 106 syscall <stat>
 2 107 syscall <lstat>
 2 108 syscall <fstat>

\ ------------------------------------------------------------------------


\ ========================================================================
