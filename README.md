# Ventus FPGA Simulation Project

## 1. 项目简介

本项目旨在为 Chisel/FIRRTL 生成的 Verilog HDL 代码提供一个基于 Synopsys VCS 的仿真验证环境。主要用于对 `ventus_fpga` 设计进行功能验证和性能测试。

## 2. 目录结构

-   `src/`: 存放项目的主要源文件，包括 Chisel 生成的 Verilog 代码以及仿真所需的数据处理脚本。
-   `testcase/`: 包含所有的仿真测试用例。每个子目录代表一个独立的测试场景（如 `tc_vecadd`, `tc_bfs` 等），其中包含了对应的 `Makefile`、testbench 文件和测试数据。

## 3. 本地服务器仿真流程

在本地服务器上运行一个典型测试用例的流程如下：

### 第一步：进入测试用例目录

首先，进入您希望运行的具体测试用例目录。例如，如果要运行向量加法 (`vecadd`) 的测试：

```bash
cd testcase/test_gpgpu_axi_top/tc_vecadd/
```

### 第二步：编译与运行仿真

每个测试用例目录下都提供了一个 `Makefile` 来自动化编译和仿真流程。您可以根据 `Makefile` 中定义的 `help` 目标来查看所有可用的仿真命令。

```bash
# 查看所有可用的 make 命令
make help

# 运行一个具体的仿真任务，例如 8 warps 4 threads
make run-vcs-8w4t
```

如果遇到 License 不足导致仿真中断的问题，可以使用 `retry-` 前缀来让脚本在失败后自动重试：

```bash
make retry-run-vcs-8w4t
```

### 第三步：查看仿真波形

仿真成功后，通常会生成一个 `.fsdb` 格式的波形文件（例如 `test.fsdb`）。您可以使用 Verdi 工具来打开和分析波形：

```bash
verdi -ssf test.fsdb &
```

### 第四步：清理生成文件

完成仿真后，可以运行 `clean` 命令来删除所有生成的过程文件和输出文件，保持目录整洁。

```bash
make clean
```

## 4. 环境依赖

本项目依赖于 Synopsys 的 EDA 工具套件，请确保您的环境中已正确安装并配置好以下工具：

-   **VCS**: 用于 Verilog 编译和仿真。
-   **Verdi**: 用于波形查看和调试。
