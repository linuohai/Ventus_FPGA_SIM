#!/usr/bin/env python3
"""
此脚本用于将Ventus GPGPU的metadata文件转换为人类可读的Markdown格式
用法: python metadata_to_md.py <metadata文件路径>
"""

import sys
import os
import struct


def hex_to_bytes(hex_str):
    """将十六进制字符串转换为字节数"""
    value = int(hex_str, 16)
    if value == 0:
        return "0 B"
    
    # 转换为适当的单位
    units = ["B", "KB", "MB", "GB"]
    unit_index = 0
    
    while value >= 1024 and unit_index < len(units) - 1:
        value /= 1024
        unit_index += 1
    
    # 对于KB及以上的单位，保留小数点后两位
    if unit_index == 0:
        return f"{int(value)} {units[unit_index]}"
    else:
        # 同时保留原始字节数
        original_bytes = int(hex_str, 16)
        return f"{value:.2f} {units[unit_index]} ({original_bytes:,} B)"


def read_uint64(lines, index):
    """从两行文本中读取一个uint64_t值"""
    if index + 1 >= len(lines):
        return "0", 0
    
    high = lines[index].strip()
    low = lines[index + 1].strip()
    
    # 合并高32位和低32位
    value = high
    
    return value, 2  # 返回值和消耗的行数


def read_metadata(file_path):
    """读取metadata文件并解析"""
    try:
        with open(file_path, 'r') as file:
            lines = [line.strip() for line in file if line.strip()]
        
        # 提取基本信息
        index = 0
        
        start_addr, offset = read_uint64(lines, index)
        index += offset
        
        kernel_id, offset = read_uint64(lines, index)
        index += offset
        
        kernel_size_x, offset = read_uint64(lines, index)
        index += offset
        
        kernel_size_y, offset = read_uint64(lines, index)
        index += offset
        
        kernel_size_z, offset = read_uint64(lines, index)
        index += offset
        
        wf_size, offset = read_uint64(lines, index)
        index += offset
        
        wg_size, offset = read_uint64(lines, index)
        index += offset
        
        metaDataBaseAddr, offset = read_uint64(lines, index)
        index += offset
        
        ldsSize, offset = read_uint64(lines, index)
        index += offset
        
        pdsSize, offset = read_uint64(lines, index)
        index += offset
        
        sgprUsage, offset = read_uint64(lines, index)
        index += offset
        
        vgprUsage, offset = read_uint64(lines, index)
        index += offset
        
        pdsBaseAddr, offset = read_uint64(lines, index)
        index += offset
        
        num_buffer_str, offset = read_uint64(lines, index)
        index += offset
        num_buffer = int(num_buffer_str, 16)
        
        # 提取缓冲区信息
        buffer_base = []
        buffer_size = []
        buffer_allocsize = []
        
        # 读取buffer_base
        for i in range(num_buffer):
            base, offset = read_uint64(lines, index)
            buffer_base.append(base)
            index += offset
        
        # 读取buffer_size
        for i in range(num_buffer):
            size, offset = read_uint64(lines, index)
            buffer_size.append(size)
            index += offset
        
        # 读取buffer_allocsize
        for i in range(num_buffer):
            allocsize, offset = read_uint64(lines, index)
            buffer_allocsize.append(allocsize)
            index += offset
        
        metadata = {
            "start_addr": start_addr,
            "kernel_id": kernel_id,
            "kernel_size_x": kernel_size_x,
            "kernel_size_y": kernel_size_y,
            "kernel_size_z": kernel_size_z,
            "wf_size": wf_size,
            "wg_size": wg_size,
            "metaDataBaseAddr": metaDataBaseAddr,
            "ldsSize": ldsSize,
            "pdsSize": pdsSize,
            "sgprUsage": sgprUsage,
            "vgprUsage": vgprUsage,
            "pdsBaseAddr": pdsBaseAddr,
            "num_buffer": num_buffer,
            "buffer_base": buffer_base,
            "buffer_size": buffer_size,
            "buffer_allocsize": buffer_allocsize
        }
        
        return metadata
    
    except Exception as e:
        print(f"Error reading metadata file: {e}")
        sys.exit(1)


def generate_markdown(metadata, output_path):
    """生成Markdown文件"""
    try:
        with open(output_path, 'w') as md_file:
            # 标题
            base_name = os.path.basename(output_path).replace('.md', '')
            md_file.write(f"# `{base_name}` 文件解析\n\n")
            
            # 基本内核信息
            md_file.write("## 基本内核信息\n")
            md_file.write(f"- **指令起始地址**: 0x{metadata['start_addr']}\n")
            md_file.write(f"- **内核ID**: 0x{metadata['kernel_id']}\n")
            md_file.write("- **线程块维度**:\n")
            md_file.write(f"  - X维度: {int(metadata['kernel_size_x'], 16)}\n")
            md_file.write(f"  - Y维度: {int(metadata['kernel_size_y'], 16)}\n")
            md_file.write(f"  - Z维度: {int(metadata['kernel_size_z'], 16)}\n")
            md_file.write(f"- **每warp线程数**: {int(metadata['wf_size'], 16)}\n")
            md_file.write(f"- **每个线程块的warp数**: {int(metadata['wg_size'], 16)}\n\n")
            
            # 内存配置
            md_file.write("## 内存配置\n")
            md_file.write(f"- **元数据基址(CSR_KNL值)**: 0x{metadata['metaDataBaseAddr']}\n")
            lds_size_bytes = hex_to_bytes(metadata['ldsSize'])
            md_file.write(f"- **每线程块share memory大小**: {lds_size_bytes}\n")
            pds_size_bytes = hex_to_bytes(metadata['pdsSize'])
            md_file.write(f"- **每线程private memory大小**: {pds_size_bytes}\n\n")
            
            # 寄存器使用
            md_file.write("## 寄存器使用\n")
            md_file.write(f"- **每warp标量寄存器使用**: {int(metadata['sgprUsage'], 16)}\n")
            md_file.write(f"- **每warp向量寄存器使用**: {int(metadata['vgprUsage'], 16)}\n\n")
            
            # Private Memory配置
            md_file.write("## Private Memory配置\n")
            md_file.write(f"- **内核private memory基址**: 0x{metadata['pdsBaseAddr']}\n\n")
            
            # Buffer信息
            md_file.write("## Buffer信息\n")
            md_file.write(f"- **Buffer数量**: {metadata['num_buffer']}\n\n")
            
            # 创建Buffer表格
            md_file.write("| Buffer Index | 基址 (Hex) | 初始化数据大小 | 实际分配大小 |\n")
            md_file.write("|---|---|---|---|\n")
            
            for i in range(metadata['num_buffer']):
                base = metadata['buffer_base'][i]
                size = metadata['buffer_size'][i]
                allocsize = metadata['buffer_allocsize'][i]
                
                size_bytes = hex_to_bytes(size)
                allocsize_bytes = hex_to_bytes(allocsize)
                
                md_file.write(f"| {i} | 0x{base} | {size_bytes} | {allocsize_bytes} |\n")
            
            print(f"成功生成Markdown文件: {output_path}")
    
    except Exception as e:
        print(f"Error generating Markdown file: {e}")
        sys.exit(1)


def main():
    if len(sys.argv) != 2:
        print("Usage: python metadata_to_md.py <metadata_file_path>")
        sys.exit(1)
    
    metadata_path = sys.argv[1]
    if not os.path.exists(metadata_path):
        print(f"Error: File '{metadata_path}' does not exist.")
        sys.exit(1)
    
    # 生成输出文件路径
    output_path = metadata_path + ".md"
    
    # 读取并解析metadata
    metadata = read_metadata(metadata_path)
    
    # 生成Markdown文件
    generate_markdown(metadata, output_path)


if __name__ == "__main__":
    main()