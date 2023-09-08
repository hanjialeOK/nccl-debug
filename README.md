# NCCl_DEBUG_VSCODE

## Introduction

示例代码在 [NCCL 2.11 Examples](https://docs.nvidia.com/deeplearning/nccl/archives/nccl_2114/user-guide/docs/examples.html)

如果需要检查 IB 网卡信息

```c
apt install infiniband-diags
ibstat
```

## Compile NCCL

编译 nccl-2.11-4。如果不加 NVCC_GENCODE，二进制文件会非常大，可能会导致错误，参考 [DEBUG=1 compilation fails with nccl 2.16.2 #775](https://github.com/NVIDIA/nccl/issues/775)。这里使用的 A100-SXM-80G 的计算能力是 80。

```c
cd nccl/
make -j32 src.build DEBUG=1 NVCC_GENCODE="-gencode=arch=compute_80,code=sm_80"
```

## GDB

如果使用 gdb，执行

```c
make demo DEBUG=1 NCCL_HOME=$(pwd)/nccl/build NVCC_GENCODE=-gencode=arch=compute_80,code=sm_80
gdb ./demo
```

然后通过 `directory nccl/src` 或者 `set substitute-path FROM TO` 告诉 gdb 源码位置，否则 gdb 会找不到 nccl 源码，参考 [GDB stepping into shared library shows "no such file" even though debug symbols are loaded](https://stackoverflow.com/questions/60855553/gdb-stepping-into-shared-library-shows-no-such-file-even-though-debug-symbols)。这个问答里介绍了.gdbinit文件，可以把 `directory nccl/src` 或者 `set substitute-path FROM TO` 写到 ～/.gdbinit 文件 或者当前工作目录下/.gdbinit 文件中，从而开启 gdb 后可以自动读取并执行。

```c
(gdb) directory nccl/src
Source directories searched: ***/nccl/src:$cdir:$cwd
(gdb) b demo.cu:110
(gdb) b demo.cu:119
(gdb) b demo.cu:128
```

start 是开始，step(s) 是进入函数，finish(fin) 是跳出函数，continue(c) 是运行至断点。

## VSCODE

如果使用 vscode，必须安装 C/C++ 拓展。

一种方式需要上面 GDB 部分提到的 .gdbinit 文件，然后直接点击 demo.cu 文件编辑界面的右上角三角形符号运行 Debug C/C++ File 即可。

第二种方式是点击左侧栏的 Debugger 按钮，选择 create a launch.json，然后编辑该文件。最主要的是 [sourceFileMap](https://code.visualstudio.com/docs/cpp/launch-json-reference#_sourcefilemap)。这个字段告诉 gdb 不要去 /nccl/src 路径下找源码文件，而应该去 ${workspaceFolder}/nccl/src。其实 vscode 的 `sourceFileMap` 就是通过 gdb 中的
`set substitute-path` 实现的。

```c
            "sourceFileMap": {
                "/nccl/src": "${workspaceFolder}/nccl/src",
            },
```

## MPI GDB

[How do I debug an MPI program?](https://stackoverflow.com/questions/329259/how-do-i-debug-an-mpi-program)

[[feature request] very basic support for MPI debugging multiple processes at the same time #1723](https://github.com/Microsoft/vscode-cpptools/issues/1723)

首先运行 gdb

```c
mpirun -np 2 demo
```

然后使用 vscode attach 到 rank 0 进行 gdb。
