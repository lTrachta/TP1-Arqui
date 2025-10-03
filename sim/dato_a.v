dato a:
module dato_a(
  input  wire       clk,   // reloj
  input  wire       rst,   // reset activo-alto, SINCRÓNICO
  input  wire       en,    // enable activo-alto
  input  wire [7:0] d,     // dato de entrada
  output reg  [7:0] q      // salida registrada
);
  always @(posedge clk) begin
    if (rst)      q <= 8'd0;  // prioridad 1: resetear a 0
    else if (en)  q <= d;     // prioridad 2: cargar nuevo dato
    // else: se mantiene el valor (q no se asigna => retiene)
  end
endmodule