module dato_b(
  input  wire       clk,   // señal de reloj
  input  wire       rst,   // reset activo-alto (sincrónico)
  input  wire       en,    // enable activo-alto
  input  wire [7:0] d,     // dato de entrada (8 bits)
  output reg  [7:0] q      // salida registrada
);
  always @(posedge clk) begin
    if (rst)      
      q <= 8'd0;   // si rst=1, en el próximo flanco de clk, salida = 0
    else if (en)  
      q <= d;      // si rst=0 y en=1, carga el dato de entrada d
    // si rst=0 y en=0, mantiene el valor anterior de q
  end
endmodule