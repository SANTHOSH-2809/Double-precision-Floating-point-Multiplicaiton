(* X_CORE_INFO = "floatingpointmultiplication,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "design_1_floatingpointmultipl_0_0,floatingpointmultiplication,{}" *)
(* CORE_GENERATION_INFO = "design_1_floatingpointmultipl_0_0,floatingpointmultiplication,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=floatingpointmultiplication,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_floatingpointmultipl_0_0 (
  A,
  B,
  final_product
);

input wire [63 : 0] A;
input wire [63 : 0] B;
output wire [63 : 0] final_product;

  floatingpointmultiplication inst (
    .A(A),
    .B(B),
    .final_product(final_product)
  );
endmodule
