#include <CoreFoundation/CoreFoundation.h>

int handle_cfversion(void) {
	printf("%.2f\n", kCFCoreFoundationVersionNumber);
	return 0;
}
