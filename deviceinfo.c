#include "deviceinfo.h"

#include <libgen.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#define KNOWN_COMMANDS "cfversion, ecid, locale, serial, uniqueid"

static int handle_backwards_compat(const char* progname, int argc,
								   const char** args);
static int handle_command(const char* cmd, int argc, const char** args);

static bool STRINGS_ARE_EQUAL(const char* a, const char* b) {
	return !strcmp(a, b);
}

int main(int argc, const char** argv) {
	int rc = handle_backwards_compat(basename((char*)argv[0]), argc, argv);
	if (rc != -1) {
		return rc;
	}

	if (argc < 2) {
		fprintf(stderr, "Not enough arguments. Known commands are %s\n",
				KNOWN_COMMANDS);
		return 1;
	}

	return handle_command(argv[1], argc - 1, argv + 1);
}

static int handle_backwards_compat(const char* progname, int argc,
								   const char** args) {
	if (STRINGS_ARE_EQUAL(progname, "cfversion")) {
		return handle_cfversion();
	}

	if (STRINGS_ARE_EQUAL(progname, "ecidecid")) {
		return handle_ecid();
	}

	if (STRINGS_ARE_EQUAL(progname, "uiduid")) {
		return handle_uniqueid();
	}

	return -1;
}

static int handle_command(const char* cmd, int argcount, const char** args) {
	if (STRINGS_ARE_EQUAL(cmd, "cfversion")) {
		return handle_cfversion();
	}

	if (STRINGS_ARE_EQUAL(cmd, "ecid")) {
		return handle_ecid();
	}

	if (STRINGS_ARE_EQUAL(cmd, "locale")) {
		return handle_locale(argcount, args);
	}

	if (STRINGS_ARE_EQUAL(cmd, "serial")) {
		return handle_serial();
	}

	if (STRINGS_ARE_EQUAL(cmd, "uniqueid")) {
		return handle_uniqueid();
	}

	fprintf(stderr, "Unknown command %s. Known commands are %s\n", cmd,
			KNOWN_COMMANDS);
	return 1;
}
