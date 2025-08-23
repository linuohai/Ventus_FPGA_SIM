#!/bin/bash
LOG_FILE="vcs_license_bug_report_$(date +%Y%m%d_%H%M%S).log"

{
    echo "=========================================="
    echo "VCS License Bug Report"
    echo "=========================================="
    echo "Start Time: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Working Directory: $(pwd)"
    echo "Command to execute: make re-run-vcs-4w8t"
    echo "Expected to run for maximum 300 seconds (5 minutes)"
    echo "=========================================="
    echo ""
    
    # 记录开始时间
    START_TIME=$(date +%s)
    ATTEMPT=1
    
    # 修改make命令以添加尝试计数和分隔符
    export MAKEFLAGS="--no-print-directory"
    
    # 使用timeout和循环来更好地控制重试
    timeout 24h bash -c '
        ATTEMPT=1
        while true; do
            echo ""
            echo "██████████████████████████████████████████████"
            echo "█ ATTEMPT #$ATTEMPT - $(date)"
            echo "██████████████████████████████████████████████"
            echo ""
            
            if make run-vcs-4w8t; then
                echo ""
                echo "██████████████████████████████████████████████"
                echo "█ SUCCESS ON ATTEMPT #$ATTEMPT - $(date)"
                echo "██████████████████████████████████████████████"
                break
            else
                echo ""
                echo "██████████████████████████████████████████████"
                echo "█ FAILED ATTEMPT #$ATTEMPT - $(date)"
                echo "█ VCS command failed, retrying in 5 seconds..."
                echo "██████████████████████████████████████████████"
                echo ""
                sleep 5
                ATTEMPT=$((ATTEMPT + 1))
            fi
        done
    '
    
    EXIT_CODE=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo ""
    echo "=========================================="
    echo "FINAL REPORT"
    echo "=========================================="
    echo "End Time: $(date)"
    echo "Total Duration: ${DURATION} seconds"
    echo "Exit Code: $EXIT_CODE"
    if [ $EXIT_CODE -eq 124 ]; then
        echo "Status: TIMEOUT after 300 seconds (5 minutes)"
        echo "Issue: Still unable to obtain VCS license after timeout"
    elif [ $EXIT_CODE -eq 0 ]; then
        echo "Status: SUCCESS - License obtained and compilation completed"
    else
        echo "Status: FAILED - Command completed with errors"
    fi
    echo "=========================================="
} 2>&1 | tee "$LOG_FILE"

echo ""
echo "Log saved to: $LOG_FILE"
echo "You can send this file to the administrator as evidence of the VCS license issue."