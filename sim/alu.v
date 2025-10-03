alu:
`timescale 1ns / 1ps

module alu #(
    parameter w   = 8,   // ancho de datos (bits) de a, b, y
    parameter wop = 6    // ancho del opcode (bits)
)(
    input  wire [w-1:0]   a,   // operando A
    input  wire [w-1:0]   b,   // operando B
    input  wire [wop-1:0] op,  // código de operación
    output reg  [w-1:0]   y,   // resultado
    output reg            carry,    // flag de acarreo (ADD)
    output reg            borrow,   // flag de préstamo (SUB)
    output reg            overflow, // flag de overflow (signed)
    output reg            zero,     // flag de resultado cero
    output reg            neg       // flag de signo (MSB)
);

    // Registro auxiliar con un bit extra para capturar carry/borrow
    reg [w:0] add;

    // ---- Tabla de opcodes (6 bits) ----
    // Notación estilo MIPS:
    localparam [wop-1:0] OP_ADD = 6'b100000; // A + B
    localparam [wop-1:0] OP_SUB = 6'b100010; // A - B
    localparam [wop-1:0] OP_AND = 6'b100100; // A & B
    localparam [wop-1:0] OP_OR  = 6'b100101; // A | B
    localparam [wop-1:0] OP_XOR = 6'b100110; // A ^ B
    localparam [wop-1:0] OP_SRA = 6'b000011; // shift right arithmetic (A >>> b)
    localparam [wop-1:0] OP_SRL = 6'b000010; // shift right logical    (A >> b)
    localparam [wop-1:0] OP_NOR = 6'b100111; // ~(A | B)

    // Bloque combinacional principal de la ALU
    always @(*) begin
        // Asignaciones por defecto (evitan latches y dejan todo en estado conocido)
        y        = {w{1'b0}};
        carry    = 1'b0;
        borrow   = 1'b0;
        overflow = 1'b0;
        zero     = 1'b0;
        neg      = 1'b0;
        add      = {(w+1){1'b0}};

        case (op)
            // --------- Suma ---------
            OP_ADD: begin
                // Extiendo a w+1 para capturar el bit de acarreo
                add    = {1'b0, a} + {1'b0, b};
                y      = add[w-1:0];  // resultado en w bits
                carry  = add[w];      // bit extra como carry (unsigned)
                borrow = 1'b0;        // en suma no hay borrow
                // Overflow (signed) en suma: si a y b tienen mismo signo y y cambia de signo
                overflow = (~(a[w-1] ^ b[w-1])) & (a[w-1] ^ y[w-1]);
            end

            // --------- Resta (A - B) ---------
            OP_SUB: begin
                // También puedo verlo como A + (~B) + 1 (2C); aquí uso el operador '-'
                add     = {1'b0, a} - {1'b0, b};
                y       = add[w-1:0];
                // Borrow (unsigned): ocurre cuando A < B
                borrow  = (a < b);
                // En esta definición 'carry' no se usa en resta
                carry   = 1'b0;
                // Overflow (signed) en resta: si a y b tienen signo distinto y y difiere de a
                overflow = (a[w-1] ^ b[w-1]) & (a[w-1] ^ y[w-1]);
            end

            // --------- Operaciones lógicas ---------
            OP_AND: begin
                y      = a & b;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            OP_OR: begin
                y      = a | b;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            OP_XOR: begin
                y      = a ^ b;
                carry  = 1'b0;
                borrow = 1'b0;
            end

            OP_NOR: begin
                y      = ~(a | b);
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // --------- Shifts a la derecha ---------
            OP_SRL: begin
                // Shift lógico a la derecha: entra 0 por la izquierda
                y      = (a >> b);
                carry  = 1'b0;
                borrow = 1'b0;
            end

            OP_SRA: begin
                // Shift aritmético a la derecha: replica el bit de signo (MSB)
                y      = ($signed(a) >>> b);
                carry  = 1'b0;
                borrow = 1'b0;
            end

            // --------- Caso por defecto ---------
            default: begin
                // Mantengo salidas en cero/por defecto
                y        = {w{1'b0}};
                carry    = 1'b0;
                borrow   = 1'b0;
                overflow = 1'b0;
            end
        endcase

        // Flags dependientes del resultado (comunes a todas las operaciones)
        zero = (y == {w{1'b0}}); // vale 1 si y = 0
        neg  = y[w-1];           // bit de signo (MSB) del resultado
    end

endmodule