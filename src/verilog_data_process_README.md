# Verilog Data Process Tool 使用说明

## 概述

`verilog_data_process.py` 是一个用于处理 Ventus GPGPU Verilog 项目文件的Python工具脚本。该工具提供了三个主要功能，帮助用户管理项目文件、生成文件列表和处理软链接。

## 主要功能

### 1. get 命令 - 解压tar.gz文件
- **功能**: 列出 `/tmp/` 目录下所有以 `ventus` 开头的 `.tar.gz` 文件，让用户选择并解压
- **特点**: 
  - 自动扫描并列出可用的压缩文件
  - 交互式选择要解压的文件
  - 可以自定义解压目录名，默认使用tar.gz文件名（去除扩展名）
  - 解压到当前工作目录

### 2. run 命令 - 生成filelist并创建软链接
- **功能**: 选择项目目录，扫描其中的Verilog文件，生成 `filelist.f` 文件，并创建软链接
- **特点**:
  - 列出当前目录下的所有文件夹供用户选择
  - 递归扫描选定目录中的所有 `.v` 和 `.sv` 文件
  - 自动用 `src/axi_replace/` 目录中的文件替换同名文件
  - 生成标准格式的 `filelist.f` 文件
  - 创建名为 `gen_fpga_verilog` 的软链接指向选定目录

### 3. show 命令 - 显示软链接状态
- **功能**: 显示当前 `gen_fpga_verilog` 软链接的状态信息
- **特点**:
  - 显示软链接目标路径
  - 检查目标目录是否存在
  - 检查是否包含 `filelist.f` 文件
  - 显示 `filelist.f` 中的文件数量

## 使用方法

### 基本语法
```bash
python verilog_data_process.py <command>
```

### 命令示例

#### 1. 解压文件
```bash
python verilog_data_process.py get
```
运行后会显示可用的tar.gz文件列表，按提示选择即可。

#### 2. 生成filelist和软链接
```bash
python verilog_data_process.py run
```
运行后会显示当前目录下的文件夹列表，选择目标文件夹后自动处理。

#### 3. 查看软链接状态
```bash
python verilog_data_process.py show
```
直接显示当前软链接状态和相关信息。

## 工作原理

### filelist.f 文件格式
- 每行包含一个Verilog文件的相对路径
- 支持 `.v` 和 `.sv` 文件格式
- 文件路径相对于包含 `filelist.f` 的目录

### axi_replace 机制
- 脚本会检查 `src/axi_replace/` 目录
- 如果该目录中存在与目标目录中同名的Verilog文件
- 会在 `filelist.f` 中使用 `axi_replace` 中的文件路径替换原始文件路径
- 这允许用特定的AXI适配器文件替换标准实现

### 软链接管理
- 软链接名称固定为 `gen_fpga_verilog`
- 如果已存在同名软链接或文件，会先删除再创建新的
- 软链接指向用户选择的目录

## 依赖要求

- Python 3.6+
- 标准库模块：`os`, `sys`, `tarfile`, `glob`, `argparse`, `pathlib`
- 无需额外安装第三方包

## 注意事项

1. **权限**: 确保脚本有执行权限 (`chmod +x verilog_data_process.py`)
2. **路径**: 脚本假设 `axi_replace` 目录位于 `src/axi_replace/`
3. **备份**: 在创建新的软链接前，现有的 `gen_fpga_verilog` 会被删除
4. **文件覆盖**: 如果目标目录已有 `filelist.f` 文件，会被覆盖

## 错误处理

脚本包含完善的错误处理机制：
- 文件不存在检查
- 用户输入验证
- 权限错误处理
- 键盘中断处理 (Ctrl+C)

## 示例使用场景

### 场景1: 设置新的开发环境
```bash
# 1. 解压项目文件
python verilog_data_process.py get

# 2. 为特定配置生成filelist
python verilog_data_process.py run

# 3. 检查配置状态
python verilog_data_process.py show
```

### 场景2: 切换不同的FPGA配置
```bash
# 切换到不同的生成配置
python verilog_data_process.py run

# 验证切换结果
python verilog_data_process.py show
```

## 技术特性

- **交互式界面**: 友好的用户交互界面，支持中文提示
- **自动化处理**: 最小化手动操作，自动处理文件替换和链接创建
- **错误恢复**: robust的错误处理和用户反馈
- **跨平台**: 兼容Linux/Unix系统（软链接功能）
