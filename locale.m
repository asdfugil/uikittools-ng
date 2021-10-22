#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <getopt.h>
#import <stdio.h>

// clang-format off
void help() {
	printf(
		"Usage: deviceinfo locale [OPTION...]\n"
		"Print the current locale\n\n"

		" -h --help      Give this help list.\n"
		" -i --identifer Print the locale identifer (default)\n"
		" -l --language  Print the language code\n"
		" -c --country   Print the country code\n"
		" -v --variant   Print the variant code\n\n"
		"If multiple output formats are specified the last will be used\n");
}
// clang-format on

// clang-format off
enum outformat {
	IDENTIFIER,
	LANGUAGE,
	COUNTRY,
	VARIANT };
// clang-format on

int handle_locale(int argc, char *argv[]) {
// clang-format off
	struct option longOptions[] = {
		{"identifier", no_argument, 0, 'i'},
		{"language", no_argument, 0, 'l'},
		{"country", no_argument, 0, 'c'},
		{"variant", no_argument, 0, 'v'},
		{"help", no_argument, 0, 'h'},
		{NULL, 0, NULL, 0}};
// clang-format on

	int format = IDENTIFIER;

	int index = 0, code = 0;

	while ((code = getopt_long(argc, argv, "ilcvh", longOptions, &index)) != -1) {
		switch (code) {
			case 'i':
				format = IDENTIFIER;
				break;
			case 'l':
				format = LANGUAGE;
				break;
			case 'c':
				format = COUNTRY;
				break;
			case 'v':
				format = VARIANT;
				break;
			case 'h':
				help();
				return 0;
				break;
		}
	}

	NSLocale *locale = [NSLocale currentLocale];
	NSString *out;

	switch (format) {
		default:
		case IDENTIFIER:
			out = [locale localeIdentifier];
			break;
		case LANGUAGE:
			out = [locale languageCode];
			break;
		case COUNTRY:
			out = [locale countryCode];
			break;
		case VARIANT:
			out = [locale variantCode];
			break;
	}

	printf("%s\n", out ? out.UTF8String : "");

	return 0;
}
