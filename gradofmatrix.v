module gradient_matrix_vivado #(
    parameter M = 5,
    parameter N = 5
)
(
    input clk,
    input rst,
    input [7:0] pixel_in,
    input valid,
    output [15:0] Gx_out,
    output [15:0] Gy_out,
    output valid_out
);

    wire [7:0] matrix [0:(M*N)-1];
    wire [15:0] Gx_wire;
    wire [15:0] Gy_wire;
    wire valid_wire;

   
    function integer index;
        input integer i, j;
        index = i * N + j;
    endfunction

    genvar i, j;
    generate
        for (i = 0; i < M; i = i + 1) begin : ROW
            for (j = 0; j < N; j = j + 1) begin : COL
                if (j < N-1) begin
                    dff matrix_reg(
                        .clk(clk),
                        .rst(rst),
                        .d(matrix[index(i, j+1)]),
                        .q(matrix[index(i, j)])
                    );
                end
            end
        end
    endgenerate

    dff pixel_in_reg(
        .clk(clk),
        .rst(rst),
        .d(pixel_in),
        .q(matrix[index(M-1, N-1)])
    );
    assign Gx_wire = (matrix[index(M/2, N/2 + 1)] - matrix[index(M/2, N/2 - 1)]);
    assign Gy_wire = (matrix[index(M/2 + 1, N/2)] - matrix[index(M/2 - 1, N/2)]);

    dff #(.WIDTH(16)) Gx_reg(
        .clk(clk),
        .rst(rst),
        .d(Gx_wire),
        .q(Gx_out)
    );

    dff #(.WIDTH(16)) Gy_reg(
        .clk(clk),
        .rst(rst),
        .d(Gy_wire),
        .q(Gy_out)
    );

    assign valid_wire = 1'b1;  

    dff valid_out_reg(
        .clk(clk),
        .rst(rst),
        .d(valid_wire),
        .q(valid_out)
    );

endmodule

module dff #(parameter WIDTH = 1) (
    input clk,
    input rst,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 0;
        else
            q <= d;
    end
endmodule
