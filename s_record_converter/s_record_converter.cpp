/**
 * @file	s_record_converter.cpp
 * @author	Manuel Burnay
 * @date	2019.07.24
 * @brief	Project converts S-record formatted file to .mem file.
 * @details	.mem files are used in Verilog memory initialization.
 */

/*
 * Project was done with visual studio because that's what I had installed.
 * This means that the code comes with these "stdafx" that aren't needed
 * for the code, but can't remove them because then won't compile in visual studtio.
 * Go ahead and remove them if you need to though, they aren't used.
 */


#include "stdafx.h"
#include <iostream>
#include <fstream>
#include <string>

static const std::string FILLER_VALUE = "0000";
constexpr int RECORD_START = 0, PAIR_START = 2, ADDR_START = 4, DATA_START = 8;
constexpr int PAIR_LENGTH = 2, MEM_LENGTH = 4;

/**
 * @brief	Retrieves the filename without the extension.
 * @param	[in] filename [const std::string&]. File name with extension.
 * @return	[std::string]. Filename without the extension.
 */
inline std::string remove_file_extension(const std::string& filename) 
{
	return filename.substr(0, filename.find_last_of("."));
}

/**
 * @brief	Converts a record file into a mem file with same name.
 * @param	[in] record_filename [const std::string&]. File name of S-Record file.
 * @detail	This function will create/overwrite a file with the same name as the record file but with the .mem extension.
 *			It will then proceed to read through the record file, finding S1 records and populating the .mem file with its data. 
 *			.mem files need to continuous (no ability to jump to addr X), so if the S1 record starts 
 *			at a different address than where the next data will be written in the .mem file,
 *			filler x0000 values are placed until the next location is the record's start.
 */
inline void convert_record(const std::string& record_filename)
{
	std::string mem_filename(remove_file_extension(record_filename));
	mem_filename += ".mem";

	std::ifstream record_file(record_filename);
	std::ofstream mem_file(mem_filename);

	if (!record_file.is_open() || !mem_file.is_open()) {
		std::cout << "Failed to convert s record file. Press any key to exit." << std::endl;
		getchar();
		return;
	}

	std::string s_record_line;
	int pair_count = 0, record_addr = 0, next_mem_addr = 0;

	while (std::getline(record_file, s_record_line)) {
		if (s_record_line.find("S1") == RECORD_START) {
			pair_count = std::stoi(s_record_line.substr(PAIR_START, PAIR_LENGTH), nullptr, 16);
			record_addr = std::stoi(s_record_line.substr(ADDR_START, MEM_LENGTH), nullptr, 16);

			while (next_mem_addr < record_addr) {
				mem_file << FILLER_VALUE << std::endl;
				next_mem_addr++;
			}

			for (int i = DATA_START; i < (DATA_START + (pair_count - 3) * 2); i += MEM_LENGTH) {	// -3 so the address & checksum is ignored, *2 to go from 'pairs' to char count.
				mem_file << s_record_line.substr(i, MEM_LENGTH) << std::endl;
				next_mem_addr++;
			}
		}
	}
}

/**
 * @brief	Main function of project.
 *			Checks if file arguments are there and starts the conversion process if so.
 * @param	[in] argc: [int]. Number of arguments passed into program.
 * @param	[in] argv: [char **]. Arguments passed into the program.
 * @return	always 0.
 */
int main(int argc, char *argv[])
{
	if (argc == 2) {
		std::string filname(argv[1]);
		convert_record(filname);
	}
	else {
		std::cout << "Program was started without a file to convert. Press any key to exit." << std::endl;
		getchar();
	}

	return 0;
}