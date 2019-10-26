/**
 * @File    X-Makina Memory Interfacer Module file.
 * @brief   Contains the code for the X-Makina Fetch Unit module.
 * @author  Manuel Burnay
 * @date    2019.10.26 (created)
 * @date    2019.10.26 (Last Modified)
 */


module memory_interfacer
#(
	parameter ACTIVE_EDGE = 1,
	parameter USE_DONE_SIGNAL = 0,
	parameter WORD = 16
 )
(
	input wire clk, reset, en,
	input wire[WORD-1:0] addr,

	input wire MEM_rd_done, MEM_wr_done, MEM_rd_err, MEM_wr_err,
	input wire[WORD-1:0] MEM_data,

	output reg MEM_rd_en, MEM_wr_en,
	output reg [WORD-1:0] MEM_rd_addr, MEM_wr_addr,

	output reg ready, bad_mem, exc_ret, err,

	output reg[WORD-1:0] inst
)