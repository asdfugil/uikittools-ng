#import <CoreFoundation/CoreFoundation.h>

CFTypeRef MGCopyAnswer(CFStringRef);

int handle_ecid(void) {
	uint64_t ecid;
	CFNumberRef ecidRef = MGCopyAnswer(CFSTR("UniqueChipID"));
	CFNumberGetValue(ecidRef, kCFNumberSInt64Type, &ecid);
	printf("0x%llX\n", ecid);
	CFRelease(ecidRef);
	return 0;
}
