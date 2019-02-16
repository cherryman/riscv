`include "vunit_defines.svh"
`include "common.sv"
`include "ifu.v"

module tb_IFU;
    localparam XLEN = `XLEN;

    logic is_branch, is_jmp, jmp_reg;
    logic eq, lt, ltu;
    logic [2:0] fn3;

    logic [XLEN-1:0] alu_out, b_imm, j_imm;
    logic [XLEN-1:0] pc;

    wire [XLEN-1:0] pc_next;

    IFU ifu (.*);

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            is_branch = 0;
            is_jmp    = 0;
            jmp_reg   = 0;

            pc = $urandom();
            #1;
        end

        `TEST_CASE("no jump or branch") begin
            `CHECK_EQUAL(pc_next, pc + 4);
        end

        `TEST_CASE("jal") begin
            is_jmp = 1;
            j_imm  = $urandom();
            #1 `CHECK_EQUAL(pc_next, pc + j_imm);
        end

        `TEST_CASE("jalr") begin
            is_jmp  = 1;
            jmp_reg = 1;
            alu_out = 1;
            #1 `CHECK_EQUAL(pc_next, pc + alu_out);
        end

        `TEST_CASE("branch") begin
            is_branch = 1;
            b_imm     = $urandom();

            `define test(fn, v, p) \
                fn3 = fn; \
                ``v = p;  #1 `CHECK_EQUAL(pc_next, pc + b_imm); \
                ``v = ~p; #1 `CHECK_EQUAL(pc_next, pc + 4);

              /* BEQ  */ `test(3'b000, eq,  1);
              /* BNE  */ `test(3'b001, eq,  0);
              /* BLT  */ `test(3'b100, lt,  1);
              /* BGE  */ `test(3'b101, lt,  0);
              /* BLTU */ `test(3'b110, ltu, 1);
              /* BGEU */ `test(3'b111, ltu, 0);

            `undef test
        end
    end
endmodule
