#import <Foundation/Foundation.h>
#include <err.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>

#include "gssc.h"

#ifndef NO_NLS
#	include <libintl.h>
#	define _(a) gettext(a)
#	define PACKAGE "uikittools-ng"
#else
#	define _(a) a
#endif

#ifndef LOCALEDIR
#	define LOCALEDIR "/usr/share/locale"
#endif

CFTypeRef MGCopyAnswer(CFStringRef);

const char *toJson(NSObject *object, bool prettyprint) {
	NSError *error;
	NSData *json;

	json = [NSJSONSerialization
		dataWithJSONObject:object
				   options:prettyprint ? NSJSONWritingPrettyPrinted : 0
					 error:&error];

	if (error)
		errx(1, _("JSON formating failed: %s"),
			 error.localizedDescription.UTF8String);

	return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]
		.UTF8String;
}

int main(int argc, char **argv) {
#ifndef NO_NLS
	setlocale(LC_ALL, "");
	bindtextdomain(PACKAGE, LOCALEDIR);
	textdomain(PACKAGE);
#endif

	bool json, plist, prettyprint, quiet, gssc;
	json = plist = prettyprint = quiet = gssc = false;
	int ch, index;

	if (!strcmp(getprogname(), "gssc")) {
		if (argc == 1) {
			gssc = plist = quiet = true;
			json = false;
		}
		fprintf(stderr, "The gssc utility is deprecated.\nPlease use mgask(1)\n");
	}

	enum options {
		OPT_GSSC = CHAR_MAX + 1,
		OPT_PRETTY
	};

	struct option longopts[] = {
		{"json", no_argument, 0, 'j'},
		{"plist", no_argument, 0, 'p'},
		{"quiet", no_argument, 0, 'q'},
		{"gssc", no_argument, NULL, OPT_GSSC},
		{"pretty", no_argument, NULL, OPT_PRETTY},
		{NULL, 0, NULL, 0}};

	while ((ch = getopt_long(argc, argv, "jpq", longopts, &index)) != -1) {
		switch (ch) {
			case 'j':
				json = true;
				plist = false;
				break;
			case 'p':
				plist = true;
				json = false;
				break;
			case OPT_GSSC:
				gssc = plist = quiet = true;
				json = false;
				break;
			case OPT_PRETTY:
				prettyprint = true;
				break;
			case 'q':
				quiet = true;
				break;
		}
	}
	argv += optind;
	argc -= optind;

	if (!gssc && argc == 0) {
		fprintf(stderr, _("Usage: %s [-jpq] [--gssc] [--pretty] question ...\n"), getprogname());
		return 1;
	}

	int i = 0, count;
	char **array;
	NSMutableDictionary *outDict = [[NSMutableDictionary alloc] init];

	if (gssc) {
		count = sizeof(gsscKeys) / sizeof(gsscKeys[0]);
		array = gsscKeys;
	} else {
		count = argc;
		array = argv;
	}

	for (i = 0; i < count; i++) {
		const char *answer;
		CFTypeRef mganswer;
		mganswer = MGCopyAnswer(
			(__bridge CFStringRef)[NSString stringWithUTF8String:array[i]]);

		if (mganswer == NULL) {
			if (!quiet)
				fprintf(stderr, _("Cannot find key %s\n"), array[i]);
			goto skipprint;
		}

		CFTypeID typeid = CFGetTypeID(mganswer);

		if (typeid == CFStringGetTypeID()) {
			if (!json && !plist)
				answer = [(__bridge_transfer NSString *)mganswer UTF8String];
			else
				[outDict setObject:(__bridge_transfer NSString *)mganswer
										forKey:[NSString stringWithUTF8String:array[i]]];
		} else if (typeid == CFBooleanGetTypeID()) {
			if (!json && !plist)
				answer = CFBooleanGetValue(mganswer) ? _("true") : _("false");
			else
				[outDict setObject:CFBooleanGetValue(mganswer) ? @YES : @NO
										forKey:[NSString stringWithUTF8String:array[i]]];
		} else if (typeid == CFNumberGetTypeID()) {
			if (!json && !plist)
				answer = [(__bridge_transfer NSNumber *)mganswer stringValue]
							 .UTF8String;
			else
				[outDict setObject:(__bridge_transfer NSNumber *)mganswer
										forKey:[NSString stringWithUTF8String:array[i]]];
		} else if (typeid == CFDictionaryGetTypeID()) {
			if (!json && !plist)
				answer = toJson((__bridge NSObject *)mganswer, prettyprint);
			else
				[outDict setObject:(__bridge_transfer NSDictionary *)mganswer
										forKey:[NSString stringWithUTF8String:array[i]]];
		} else if (typeid == CFArrayGetTypeID()) {
			if (!json && !plist)
				answer = toJson((__bridge NSObject *)mganswer, prettyprint);
			else
				[outDict setObject:(__bridge_transfer NSArray *)mganswer
										forKey:[NSString stringWithUTF8String:array[i]]];
		} else {
			if (!quiet)
				fprintf(stderr, "%s has an unknown answer type\n", array[i]);
			if (mganswer != NULL)
				CFRelease(mganswer);
			goto skipprint;
		}

		if (!json && !plist) {
			if (argc != 1)
				printf("%s: ", array[i]);

			printf("%s\n", answer);
		}

	skipprint:
		continue;
	}

	if (json)
		printf("%s\n", toJson(outDict, prettyprint));
	else if (plist)
		printf("%s\n", [outDict descriptionWithLocale:nil].UTF8String);

	return 0;
}
