# NCCl_DEBUG_VSCODE

编译 nccl-2.11-4。如果不加 NVCC_GENCODE，二进制文件会非常大，可能会导致错误，参考 [DEBUG=1 compilation fails with nccl 2.16.2 #775](https://github.com/NVIDIA/nccl/issues/775)

```c
cd nccl/
make -j32 src.build DEBUG=1 NVCC_GENCODE="-gencode=arch=compute_80,code=sm_80"
```
