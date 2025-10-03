`timescale 1ns/1ps

module tb_top_alu;

  // Parámetros del DUT (consistencia con top_alu/alu)
  localparam W   = 8;
  localparam WOP = 6;

  // ------------------ Señales del DUT ------------------
  reg                 clk, rst;
  reg                 en_a, en_b, en_op;
  reg  [7:0]          sw;

  wire [W-1:0]        y;
  wire                carry, borrow, overflow, zero, neg;

  // Instancia del toplevel (Device Under Test)
  top_alu dut (
    .clk(clk), .rst(rst),
    .en_a(en_a), .en_b(en_b), .en_op(en_op),
    .sw(sw),
    .y(y), .carry(carry), .borrow(borrow),
    .overflow(overflow), .zero(zero), .neg(neg)
  );

  // ------------------ Reloj ------------------
  localparam real TCLK_NS = 10.0;    // periodo 10 ns => 100 MHz
  initial clk = 1'b0;
  always #(TCLK_NS/2.0) clk = ~clk;  // toggling cada 5 ns

  // ------------------ Reset ------------------
  task apply_reset; begin
    rst  = 1'b1;
    en_a = 1'b0; en_b = 1'b0; en_op = 1'b0;
    sw   = 8'h00;                 // limpiar bus de switches
    repeat (3) @(posedge clk);
    rst = 1'b0;                   // desaserto
    @(posedge clk);               // un ciclo extra para estabilizar
  end endtask

  // ------------------ Tabla de opcodes ------------------
  localparam [WOP-1:0]
    OP_ADD = 6'b100000,
    OP_SUB = 6'b100010,
    OP_AND = 6'b100100,
    OP_OR  = 6'b100101,
    OP_XOR = 6'b100110,
    OP_SRA = 6'b000011,
    OP_SRL = 6'b000010,
    OP_NOR = 6'b100111;

  // ------------------ Carga por bus único ------------------
  task load_sw; input [7:0] v; input [2:0] en_sel;
  begin
    @(negedge clk);
    sw = v;
    {en_op, en_b, en_a} = en_sel;     // pulso enable elegido
    @(posedge clk);                   // captura
    {en_op, en_b, en_a} = 3'b000;     // suelto enable
    @(posedge clk);                   // estabiliza
  end
  endtask

  // ------------------ Modelo de referencia ------------------
  // AHORA: shifts variables por b (enmascaro a 3 bits: b[2:0] ∈ [0..7])
  function [W+2:0] alu_ref_pack;
    input [W-1:0]   a_in;
    input [W-1:0]   b_in;
    input [WOP-1:0] op_in;

    reg   [W-1:0] y_loc;
    reg           c_loc, b_loc, v_loc;
    reg   [W:0]   add_ext;
  begin
    y_loc  = {W{1'b0}};
    c_loc  = 1'b0;
    b_loc  = 1'b0;
    v_loc  = 1'b0;

    case (op_in)
      OP_ADD: begin
        add_ext = {1'b0, a_in} + {1'b0, b_in};
        y_loc   = add_ext[W-1:0];
        c_loc   = add_ext[W];
        v_loc   = (~(a_in[W-1]^b_in[W-1])) & (a_in[W-1]^y_loc[W-1]);
      end
      OP_SUB: begin
        add_ext = {1'b0, a_in} - {1'b0, b_in};
        y_loc   = add_ext[W-1:0];
        b_loc   = (a_in < b_in);
        v_loc   = (a_in[W-1]^b_in[W-1]) & (a_in[W-1]^y_loc[W-1]);
      end
      OP_AND: y_loc = a_in & b_in;
      OP_OR : y_loc = a_in | b_in;
      OP_XOR: y_loc = a_in ^ b_in;
      OP_NOR: y_loc = ~(a_in | b_in);

      // >>> CAMBIO: usar b_in[2:0] como cantidad de desplazamiento
      OP_SRL: y_loc = (a_in >>  b_in[2:0]);             // lógico: entra 0
      OP_SRA: y_loc = $signed(a_in) >>> b_in[2:0];      // aritmético: replica MSB

      default: y_loc = {W{1'b0}};
    endcase

    alu_ref_pack = {v_loc, b_loc, c_loc, y_loc};
  end
  endfunction

  // ------------------ Checker ------------------
  reg [W-1:0] y_ref;
  reg         carry_ref, borrow_ref, overflow_ref, zero_ref, neg_ref;

  task check_once;
    input [W-1:0]   a_chk, b_chk;
    input [WOP-1:0] op_chk;
    reg   [W+2:0]   pack;
  begin
    load_sw(a_chk,          3'b001);        // A
    load_sw(b_chk,          3'b010);        // B
    load_sw({2'b00,op_chk}, 3'b100);        // OP (solo 6 bits)

    pack         = alu_ref_pack(a_chk, b_chk, op_chk);
    y_ref        = pack[W-1:0];
    carry_ref    = pack[W];
    borrow_ref   = pack[W+1];
    overflow_ref = pack[W+2];
    zero_ref     = (y_ref == {W{1'b0}});
    neg_ref      =  y_ref[W-1];

    if ( y       !== y_ref        ||
         carry   !== carry_ref    ||
         borrow  !== borrow_ref   ||
         overflow!== overflow_ref ||
         zero    !== zero_ref     ||
         neg     !== neg_ref ) begin
      $display("[%0t] FAIL op=%b A=%0d(0x%0h) B=%0d(0x%0h) | DUT: y=%0d c=%b b=%b v=%b z=%b n=%b | REF: y=%0d c=%b b=%b v=%b z=%b n=%b",
               $time, op_chk, a_chk, a_chk, b_chk, b_chk,
               y, carry, borrow, overflow, zero, neg,
               y_ref, carry_ref, borrow_ref, overflow_ref, zero_ref, neg_ref);
      // SUGERENCIA: errors = errors + 1;
    end
  end
  endtask

  // ------------------ Secuencia de test ------------------
  integer i, errors, vectors;
  reg [32-1:0] seed;
  reg [W-1:0]   ra, rb;
  reg [WOP-1:0] rop;

  initial begin
    $timeformat(-9,1," ns",6);
    apply_reset;

    // Sanity (suma)
    check_once(8'd5, 8'd3, OP_ADD);
    if (y==8'd8 && carry==0 && borrow==0 && zero==0)
      $display("[SANITY] OK: A=5 B=3 ADD => y=%0d", y);
    else
      $display("[SANITY] ERROR: esperado y=8");

    // (Opcional) Sanity para shift variable: A=6, B=4
    check_once(8'd6, 8'd4, OP_SRL);  // 6 >> 4 = 0
    check_once(8'd6, 8'd4, OP_SRA);  // 6 >>> 4 = 0 (MSB=0)

    // Batería aleatoria
    errors  = 0;
    vectors = 300;
    seed    = 32'hFEED_BEEF;

    for (i = 0; i < vectors; i = i + 1) begin
      ra  = $random(seed);
      rb  = $random(seed);
      case ($random(seed) % 8)
        0: rop = OP_ADD;  1: rop = OP_SUB;
        2: rop = OP_AND;  3: rop = OP_OR;
        4: rop = OP_XOR;  5: rop = OP_NOR;
        6: rop = OP_SRL;  7: rop = OP_SRA;
      endcase
      check_once(ra, rb, rop);
      // if (último check fue FAIL) errors = errors + 1;  <-- podés implementarlo fácil
    end

    if (errors == 0)
      $display("\n==== TEST PASSED: %0d vectores sin errores ====\n", vectors);
    else
      $display("\n==== TEST FAILED: %0d errores en %0d vectores ====\n", errors, vectors);

    $stop;
  end

endmodule