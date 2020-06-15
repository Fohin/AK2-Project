#include <cstdio>
#include <cstring>
#include <string>

extern "C" char* add(char* first_number, char* second_number);
extern "C" char* sub(char* first_number, char* second_number);
extern "C" char* multiplication(char* first_number, char* second_number);

int main(int argc, char **argv) 
{
	std::string operation = argv[1];
	std::string fn = (char*)argv[2];
	std::string sn = (char*)argv[3];

	char *first_number = new char[fn.length() + 1];
	std::strcpy(first_number, fn.c_str());
	std::strcat(first_number, "\n");

	char *second_number = new char[sn.length() + 1];
	std::strcpy(second_number, sn.c_str());
	std::strcat(second_number, "\n");

	if (operation == "a") {
	char* add_result = add(first_number, second_number);
	printf("ADD: %s\n", add_result);
	} else if (operation == "s") {
		char* sub_result = sub(first_number, second_number);
		printf("SUB: %s\n", sub_result);
	} else if (operation == "m") { 
		char* multiplication_result = multiplication(first_number, second_number);
		printf("MULTI: %s\n", multiplication_result);
	} else {
		delete first_number;
		delete second_number;
		puts("No operation");
		return 1;
	}

	delete first_number;
	delete second_number;
	return 0;
}