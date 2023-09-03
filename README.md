# NCCl_DEBUG_VSCODE

## Compile NCCL

编译 nccl-2.11-4。如果不加 NVCC_GENCODE，二进制文件会非常大，可能会导致错误，参考 [DEBUG=1 compilation fails with nccl 2.16.2 #775](https://github.com/NVIDIA/nccl/issues/775)。这里使用的 A100-SXM-80G 的计算能力是 80。

```c
cd nccl/
make -j32 src.build DEBUG=1 NVCC_GENCODE="-gencode=arch=compute_80,code=sm_80"
```

## GDB

如果使用 gdb，执行

```c
make demo DEBUG=1 NCCL_HOME=nccl/build NVCC_GENCODE=-gencode=arch=compute_80,code=sm_80
gdb ./demo
```

然后告诉 gdb 源码位置，否则 gdb 会找不到 nccl 源码，参考 [GDB stepping into shared library shows "no such file" even though debug symbols are loaded](https://stackoverflow.com/questions/60855553/gdb-stepping-into-shared-library-shows-no-such-file-even-though-debug-symbols)。$cdir 和 $cwd 分别是当前路径和当前工作路径。

```c
(gdb) directory nccl/src
Source directories searched: ***/nccl/src:$cdir:$cwd
(gdb) b demo.cu:110
(gdb) b demo.cu:119
(gdb) b demo.cu:128
```

start 是开始，step(s) 是进入函数，finish(fin) 是跳出函数，continue(c) 是运行至断点。
