#import <Foundation/Foundation.h>

CFTypeRef MGCopyAnswer(CFStringRef);

int handle_uniqueid(void) {
	printf("%s\n", [(__bridge_transfer NSString *)MGCopyAnswer(CFSTR("UniqueDeviceID")) UTF8String]);
	return 0;
}
