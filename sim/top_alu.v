`timescale 1ns/1ps

module top_alu(
    input  wire        clk,
    input  wire        rst,       // activo-alto

    // Enables de carga
    input  wire        en_a,
    input  wire        en_b,
    input  wire        en_op,

    // Único bus de switches
    input  wire [7:0]  sw,
    

    // Salidas de la ALU
    output wire [7:0]  y,
    output wire        carry,
    output wire        borrow,
    output wire        overflow,
    output wire        zero,
    output wire        neg
);

    wire [7:0] A_q;
    wire [7:0] B_q;
    wire [5:0] OP_q;

    // -------- Registros de entrada (tus módulos) --------
    dato_a u_regA (
        .clk(clk),
        .rst(rst),
        .en (en_a),
        .d  (sw),        // 8 bits completos desde el mismo bus
        .q  (A_q)
    );

    dato_b u_regB (
        .clk(clk),
        .rst(rst),
        .en (en_b),
        .d  (sw),        // 8 bits completos desde el mismo bus
        .q  (B_q)
    );

    reg_op u_regOP (
        .clk(clk),
        .rst(rst),
        .en (en_op),
        .d  (sw[5:0]),   // SOLO 6 LSB para el opcode
        .q  (OP_q)
    );

    alu #(
        .w  (8),
        .wop(6)
    ) u_alu (
        .a       (A_q),
        .b       (B_q),
        .op      (OP_q),
        .y       (y),
        .carry   (carry),
        .borrow  (borrow),
        .overflow(overflow),
        .zero    (zero),
        .neg     (neg)
    );
endmodule