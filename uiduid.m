#import <Foundation/Foundation.h>

NSString *MGCopyAnswer(NSString *key);

int handle_uniqueid(void) {
	printf("%s\n", [MGCopyAnswer(@"UniqueDeviceID") UTF8String]);
	return 0;
}
