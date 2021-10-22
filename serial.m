#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CoreFoundation.h>

CFStringRef MGCopyAnswer(CFStringRef string);

int handle_serial(void) {
	uint64_t serial;
	CFStringRef serialRef = MGCopyAnswer(CFSTR("SerialNumber"));
	printf("%s\n", CFStringGetCStringPtr(serialRef, kCFStringEncodingASCII));
	return 0;
}
