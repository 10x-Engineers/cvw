module test_zicntr_coverage import cvw::*; #(parameter cvw_t P) (input clk);

    rvviTrace #(.XLEN(P.XLEN), .FLEN(P.FLEN)) rvvi();
    wallyTracer #(P) wallyTracer(rvvi);

    covergroup cg_cycle @(posedge clk iff wallyTracer.valid);
        
        ins: coverpoint wallyTracer.InstrRawW {
            bins rdcycle_incr = (32'b110000000000_00000_010_?????_1110011 => 32'h???????? => 32'b110000000000_00000_010_?????_1110011);
            bins rdcycle = {32'b110000000000_00000_010_?????_1110011};
        }
        priv_mode: coverpoint dut.core.priv.priv.privmode.PrivilegeModeW{
            bins U_mode = {2'b00};
        }
        illegal_CSR_access_exception: coverpoint dut.core.priv.priv.csr.IllegalCSRCAccessM {
            bins illegal_ins = {1'b1};
        }
        zicntr_support: coverpoint P.ZICNTR_SUPPORTED {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        lower_priv_mode: cross priv_mode, zicntr_support, ins {
            ignore_bins ig1 = binsof(ins.rdcycle_incr);
            ignore_bins ig2 = binsof(zicntr_support.not_set);
        }
        zicntr_not_support : cross illegal_CSR_access_exception, zicntr_support, ins {
            ignore_bins ig1 = binsof(ins.rdcycle_incr);
            ignore_bins ig2 = binsof(zicntr_support.set);
        }
       
    endgroup

    covergroup cg_time @(posedge clk iff wallyTracer.valid);
        ins: coverpoint wallyTracer.InstrRawW {
            bins rdtime_incr = (32'b110000000001_00000_010_?????_1110011 => 32'h???????? => 32'b110000000001_00000_010_?????_1110011);
            bins rdtime = {32'b110000000001_00000_010_?????_1110011};
        }
        priv_mode: coverpoint dut.core.priv.priv.privmode.PrivilegeModeW{
            bins U_mode = {2'b00};
        }
        illegal_CSR_access_exception: coverpoint dut.core.priv.priv.csr.IllegalCSRCAccessM {
            bins illegal_ins = {1'b1};
        }
        zicntr_support: coverpoint P.ZICNTR_SUPPORTED {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        lower_priv_mode: cross priv_mode, zicntr_support, ins {
            ignore_bins ig1 = binsof(ins.rdtime_incr);
            ignore_bins ig2 = binsof(zicntr_support.not_set);
        }
        zicntr_not_support : cross illegal_CSR_access_exception, zicntr_support, ins {
            ignore_bins ig1 = binsof(ins.rdtime_incr);
            ignore_bins ig2 = binsof(zicntr_support.set);
        }
    endgroup

    covergroup cg_instret @(posedge clk iff wallyTracer.valid);
        ins: coverpoint wallyTracer.InstrRawW {
            bins rdinstret_incr_any = (32'b110000000010_00000_010_?????_1110011 => 32'h???????? => 32'b110000000010_00000_010_?????_1110011);
            bins rdinstret_incr_count_incr = (32'b110000000010_00000_010_?????_1110011 => (!32'b000000000000_00000_000_00000_1110011 && !32'h000000000001_00000_000_00000_1110011) => 32'b110000000010_00000_010_?????_1110011);
            bins rdinstret_incr_count_notincr = (32'b110000000010_00000_010_?????_1110011 => (32'b000000000000_00000_000_00000_1110011 || !32'h000000000001_00000_000_00000_1110011) => 32'b110000000010_00000_010_?????_1110011);
            bins rdinstret = {32'b110000000010_00000_010_?????_1110011};
        }
        priv_mode: coverpoint dut.core.priv.priv.privmode.PrivilegeModeW{
            bins U_mode = {2'b00};
        }
        illegal_CSR_access_exception: coverpoint dut.core.priv.priv.csr.IllegalCSRCAccessM {
            bins illegal_ins = {1'b1};
        }
        zicntr_support: coverpoint P.ZICNTR_SUPPORTED {
            bins set = {1'b1};
            bins not_set = {1'b0};
        }
        lower_priv_mode: cross priv_mode, zicntr_support, ins {
            ignore_bins ig1 = binsof(ins.rdinstret_incr_any);
            ignore_bins ig2 = binsof(ins.rdinstret_incr_count_incr);
            ignore_bins ig3 = binsof(ins.rdinstret_incr_count_notincr);
            ignore_bins ig4 = binsof(zicntr_support.not_set);
        }
        zicntr_not_support : cross illegal_CSR_access_exception, zicntr_support, ins {
            ignore_bins ig1 = binsof(ins.rdinstret_incr_any);
            ignore_bins ig2 = binsof(ins.rdinstret_incr_count_incr);
            ignore_bins ig3 = binsof(ins.rdinstret_incr_count_notincr);
            ignore_bins ig4 = binsof(zicntr_support.set);
        }
    endgroup

    initial begin

        cg_cycle    cycleCG = new();
        cg_time     timeCG = new();
        cg_instret  instretCG = new();

        forever begin

            @(posedge clk iff wallyTracer.valid) begin
                
                cycleCG.sample(); 
                timeCG.sample();
                instretCG.sample();

            end
        end
    end

endmodule