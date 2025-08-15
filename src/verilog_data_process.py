#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Verilog Data Process Tool
用于处理Ventus GPGPU Verilog项目文件的工具脚本

主要功能:
1. get - 列出并解压/tmp目录下的ventus tar.gz文件
2. run - 生成filelist.f文件并创建软链接
3. show - 显示当前软链接状态
"""

import os
import sys
import tarfile
import glob
import argparse
from pathlib import Path


def list_ventus_archives():
    """列出/tmp目录下所有以ventus开头的.tar.gz文件"""
    pattern = "/tmp/ventus*.tar.gz"
    archives = glob.glob(pattern)
    return sorted(archives)


def extract_archive(archive_path, extract_name=None):
    """解压tar.gz文件到指定目录"""
    if not os.path.exists(archive_path):
        print(f"错误: 文件 {archive_path} 不存在")
        return False
    
    if extract_name is None:
        # 使用tar.gz文件名作为默认解压目录名
        extract_name = os.path.basename(archive_path).replace('.tar.gz', '')
    
    current_dir = os.getcwd()
    extract_path = os.path.join(current_dir, extract_name)
    
    try:
        with tarfile.open(archive_path, 'r:gz') as tar:
            tar.extractall(path=current_dir)
        print(f"成功解压 {archive_path} 到 {extract_path}")
        return True
    except Exception as e:
        print(f"解压失败: {e}")
        return False


def get_command():
    """执行get命令 - 列出并解压tar.gz文件"""
    archives = list_ventus_archives()
    
    if not archives:
        print("在/tmp目录下没有找到以ventus开头的.tar.gz文件")
        return
    
    print("找到以下ventus tar.gz文件:")
    for i, archive in enumerate(archives, 1):
        print(f"{i}. {archive}")
    
    try:
        choice = input("\n请选择要解压的文件编号 (或按Enter退出): ").strip()
        if not choice:
            print("操作已取消")
            return
        
        choice_idx = int(choice) - 1
        if choice_idx < 0 or choice_idx >= len(archives):
            print("无效的选择")
            return
        
        selected_archive = archives[choice_idx]
        default_name = os.path.basename(selected_archive).replace('.tar.gz', '')
        
        print(f"默认解压目录名: {default_name}")
        extract_name = input("请输入解压目录名 (或按Enter使用默认名): ").strip()
        
        if not extract_name:
            extract_name = default_name
        
        extract_archive(selected_archive, extract_name)
        
    except ValueError:
        print("请输入有效的数字")
    except KeyboardInterrupt:
        print("\n操作已取消")


def list_directories():
    """列出当前文件夹中所有以'gen_fpga'开头的目录"""
    current_dir = os.getcwd()
    dirs = [d for d in os.listdir(current_dir) 
            if os.path.isdir(os.path.join(current_dir, d)) and not d.startswith('.') and d.startswith('gen_fpga')]
    return sorted(dirs)


def find_verilog_files(directory):
    """在指定目录中查找所有.v和.sv文件"""
    verilog_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.v', '.sv')):
                # 获取相对于起始目录的路径
                rel_path = os.path.relpath(os.path.join(root, file), directory)
                verilog_files.append(rel_path)
    return sorted(verilog_files)


def read_filelist_format():
    """读取现有filelist.f文件的格式作为参考"""
    filelist_files = glob.glob("src/*/filelist.f")
    if filelist_files:
        # 读取第一个找到的filelist.f文件作为格式参考
        with open(filelist_files[0], 'r') as f:
            return f.read().splitlines()
    return []


def replace_with_axi_files(verilog_files, selected_dir):
    """用axi_replace文件夹中的文件替换同名文件"""
    axi_replace_dir = "./axi_replace"
    if not os.path.exists(axi_replace_dir):
        print("警告: axi_replace目录不存在")
        return verilog_files
    
    # 获取axi_replace目录中的所有文件
    axi_files = {}
    for file in os.listdir(axi_replace_dir):
        if file.endswith(('.v', '.sv')):
            axi_files[file] = file
    
    # 替换同名文件
    updated_files = []
    for vfile in verilog_files:
        filename = os.path.basename(vfile)
        if filename in axi_files:
            # axi_replace文件将使用特殊标记，在create_filelist中处理
            updated_files.append(f"AXI_REPLACE:{filename}")
            print(f"替换文件: {filename} -> axi_replace/{filename}")
        else:
            updated_files.append(vfile)
    
    return updated_files


def create_filelist(selected_dir):
    """为选定目录创建filelist.f文件"""
    verilog_files = find_verilog_files(selected_dir)
    
    if not verilog_files:
        print(f"在目录 {selected_dir} 中没有找到.v或.sv文件")
        return False
    
    # 用axi_replace中的文件替换同名文件
    verilog_files = replace_with_axi_files(verilog_files, selected_dir)
    
    # 获取当前脚本的目录，filelist.f放在和脚本相同的目录下
    script_dir = os.path.dirname(os.path.abspath(__file__))
    filelist_path = os.path.join(script_dir, "filelist.f")
    
    with open(filelist_path, 'w') as f:
        for vfile in verilog_files:
            if vfile.startswith("AXI_REPLACE:"):
                # 处理axi_replace文件
                filename = vfile.replace("AXI_REPLACE:", "")
                f.write(f"../../../src/axi_replace/{filename}\n")
            else:
                # 处理普通文件，添加前缀 "../../../src/gen_fpga_verilog/"
                f.write(f"../../../src/gen_fpga_verilog/{vfile}\n")
    
    print(f"成功创建 {filelist_path}，包含 {len(verilog_files)} 个文件")
    return True


def create_symlink(target_dir):
    """创建软链接到gen_fpga_verilog"""
    symlink_name = "gen_fpga_verilog"
    
    # 如果软链接已存在，先删除
    if os.path.exists(symlink_name) or os.path.islink(symlink_name):
        os.unlink(symlink_name)
        print(f"已删除现有的 {symlink_name}")
    
    try:
        os.symlink(target_dir, symlink_name)
        print(f"成功创建软链接: {symlink_name} -> {target_dir}")
        return True
    except Exception as e:
        print(f"创建软链接失败: {e}")
        return False


def run_command():
    """执行run命令 - 选择gen_fpga目录并生成filelist"""
    dirs = list_directories()
    
    if not dirs:
        print("当前目录下没有找到以'gen_fpga'开头的子目录")
        return
    
    print("当前目录下以'gen_fpga'开头的文件夹:")
    for i, directory in enumerate(dirs, 1):
        print(f"{i}. {directory}")
    
    try:
        choice = input("\n请选择目录编号 (或按Enter退出): ").strip()
        if not choice:
            print("操作已取消")
            return
        
        choice_idx = int(choice) - 1
        if choice_idx < 0 or choice_idx >= len(dirs):
            print("无效的选择")
            return
        
        selected_dir = dirs[choice_idx]
        print(f"选择的目录: {selected_dir}")
        
        # 创建filelist.f文件
        if create_filelist(selected_dir):
            # 创建软链接
            create_symlink(selected_dir)
        
    except ValueError:
        print("请输入有效的数字")
    except KeyboardInterrupt:
        print("\n操作已取消")


def show_command():
    """执行show命令 - 显示当前软链接状态"""
    symlink_name = "gen_fpga_verilog"
    
    if os.path.islink(symlink_name):
        target = os.readlink(symlink_name)
        real_path = os.path.realpath(symlink_name)
        print(f"软链接状态:")
        print(f"  {symlink_name} -> {target}")
        print(f"  实际路径: {real_path}")
        
        if os.path.exists(real_path):
            print(f"  目标存在: 是")
            # 检查是否有filelist.f文件
            filelist_path = os.path.join(real_path, "filelist.f")
            if os.path.exists(filelist_path):
                print(f"  包含filelist.f: 是")
                # 显示文件数量
                with open(filelist_path, 'r') as f:
                    lines = f.read().splitlines()
                    non_empty_lines = [line for line in lines if line.strip()]
                    print(f"  filelist.f文件数量: {len(non_empty_lines)}")
            else:
                print(f"  包含filelist.f: 否")
        else:
            print(f"  目标存在: 否")
    else:
        if os.path.exists(symlink_name):
            print(f"{symlink_name} 存在但不是软链接")
        else:
            print(f"软链接 {symlink_name} 不存在")


def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description="Verilog数据处理工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  python verilog_data_process.py get   # 列出并解压tar.gz文件
  python verilog_data_process.py run   # 选择目录并生成filelist
  python verilog_data_process.py show  # 显示软链接状态
        """
    )
    
    parser.add_argument('command', choices=['get', 'run', 'show'],
                       help='要执行的命令')
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    args = parser.parse_args()
    
    try:
        if args.command == 'get':
            get_command()
        elif args.command == 'run':
            run_command()
        elif args.command == 'show':
            show_command()
    except KeyboardInterrupt:
        print("\n程序被用户中断")
    except Exception as e:
        print(f"执行过程中发生错误: {e}")


if __name__ == "__main__":
    main()
