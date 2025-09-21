#!/bin/bash

# RTL日志提取脚本 (Bash版本)
# 用于从rtl.log文件中提取特定SM和Warp的日志行

# 显示使用帮助
show_help() {
    cat << EOF
用法: $0 -f <日志文件> -s <SM编号> -w <Warp编号> [选项]

选项:
    -f, --file      输入的RTL日志文件路径
    -s, --sm        SM编号 (例如: 0, 1, 2...)
    -w, --warp      Warp编号 (例如: 0, 1, 2, 3...)
    -o, --output    输出文件路径 (可选，默认输出到控制台)
    -h, --help      显示此帮助信息

示例:
    $0 -f rtl.log -s 0 -w 3
    $0 --file rtl.log --sm 1 --warp 2 --output filtered.log
    $0 -f rtl.log -s 0 -w 3 > sm0_warp3.log

EOF
}

# 初始化变量
input_file=""
sm_id=""
warp_id=""
output_file=""

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            input_file="$2"
            shift 2
            ;;
        -s|--sm)
            sm_id="$2"
            shift 2
            ;;
        -w|--warp)
            warp_id="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "错误: 未知参数 '$1'"
            show_help
            exit 1
            ;;
    esac
done

# 检查必需参数
if [[ -z "$input_file" || -z "$sm_id" || -z "$warp_id" ]]; then
    echo "错误: 缺少必需参数"
    show_help
    exit 1
fi

# 检查文件是否存在
if [[ ! -f "$input_file" ]]; then
    echo "错误: 文件 '$input_file' 不存在"
    exit 1
fi

# 检查SM和Warp编号是否为数字
if ! [[ "$sm_id" =~ ^[0-9]+$ ]] || ! [[ "$warp_id" =~ ^[0-9]+$ ]]; then
    echo "错误: SM和Warp编号必须是数字"
    exit 1
fi

# 构建grep模式，匹配 "sm <sm_id> warp <warp_id>" 开头的行
pattern="^sm[[:space:]]\+${sm_id}[[:space:]]\+warp[[:space:]]\+${warp_id}[[:space:]]\+"

# 提取匹配的行
if [[ -n "$output_file" ]]; then
    # 输出到文件
    count=$(grep "$pattern" "$input_file" | tee "$output_file" | wc -l)
    echo "已提取 $count 行日志到文件 '$output_file'"
else
    # 输出到控制台
    echo "提取的 SM $sm_id Warp $warp_id 日志行:"
    echo "================================================================================"
    matched_lines=$(grep "$pattern" "$input_file")
    count=$(echo "$matched_lines" | grep -c .)
    
    if [[ $count -gt 0 ]]; then
        echo "$matched_lines"
        echo "================================================================================"
        echo "总共提取了 $count 行"
    else
        echo "未找到匹配的日志行"
        echo "================================================================================"
    fi
fi

exit 0 