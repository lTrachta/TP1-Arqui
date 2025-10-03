module reg_op(
  input  wire       clk,   // señal de reloj
  input  wire       rst,   // reset activo-alto (sincrónico)
  input  wire       en,    // enable activo-alto
  input  wire [5:0] d,     // código de operación (opcode) de 6 bits
  output reg  [5:0] q      // salida registrada
);
  always @(posedge clk) begin
    if (rst)      
      q <= 6'd0;   // si rst=1, al próximo flanco de clk la salida se pone en 0
    else if (en)  
      q <= d;      // si rst=0 y en=1, se carga el nuevo opcode
    // si rst=0 y en=0, mantiene el valor anterior
  end
endmodule