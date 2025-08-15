debImport "-f" "../common/run.f"
debLoadSimResult \
           /home/sunhn/ventus_test/ventus-gpgpu-verilog/testcase/test_gpgpu_axi_top/tc_gaussian/test.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 -32 -32 "900" "700"
verdiWindowResize -win $_Verdi_1 -32 -32 "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "test_gpu_axi_top.u_dut.gpgpu_top" -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut.gpgpu_top.SM_wrapper.icache" -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut.gpgpu_top.SM_wrapper.icache" -win $_nTrace1
srcSetScope "test_gpu_axi_top.u_dut.gpgpu_top.SM_wrapper.icache" -delim "." -win \
           $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut.gpgpu_top.SM_wrapper.icache" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_coreReq_valid" -line 90 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_coreReq_bits_addr" -line 91 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetCursor -win $_nWave2 92898002269.546906
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_coreReq_valid" -line 90 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 69163368163.685791 -snap {("G2" 0)}
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 39034876140.208702 239390877567.828583
wvZoom -win $_nWave2 39479716285.465584 49355167510.361588
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_coreReq_bits_addr" -line 91 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_coreReq_bits_warpid" -line 93 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_externalFlushPipe_valid" -line 94 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "io_coreRsp_valid" -line 96 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoom -win $_nWave2 41812638155.639694 42461646495.464119
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "test_gpu_axi_top.u_dut.gpgpu_top" -win $_nTrace1
srcSetScope "test_gpu_axi_top.u_dut.gpgpu_top" -delim "." -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut.gpgpu_top" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "test_gpu_axi_top.u_dut.l2_2_mem" -win $_nTrace1
srcSetScope "test_gpu_axi_top.u_dut.l2_2_mem" -delim "." -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut.l2_2_mem" -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut" -win $_nTrace1
srcSetScope "test_gpu_axi_top.u_dut" -delim "." -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_dut" -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_ram" -win $_nTrace1
srcSetScope "test_gpu_axi_top.u_ram" -delim "." -win $_nTrace1
srcHBSelect "test_gpu_axi_top.u_ram" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "s_axi_awid" -line 40 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "s_axi_awaddr" -line 41 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 42110916855.327278 -snap {("G2" 0)}
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
