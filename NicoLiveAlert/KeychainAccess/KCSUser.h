//
//  KCSUser.h
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark constant definition
extern const UInt8 maskBitAccount;
extern const UInt8 maskBitInetServerName;
extern const UInt8 maskBitInetServerPath;
extern const UInt8 maskBitInetProtocol;
extern const UInt8 maskBitInetAuthType;
extern const UInt8 maskBitInetPort;
extern const UInt8 maskBitInetSecurityDomain;
extern const UInt8 mastBitsInetRequired;
extern const UInt8 maskBitsInetOptional;

#pragma mark -
@interface KCSUser : NSObject {
@protected
	NSString			*account;
	NSString			*password;
	SecKeychainRef		keyChain;			// optional
	SecKeychainItemRef	keyChainItem;
	BOOL				syncronized;
	UInt8				paramFlags;
}
@property (copy, readwrite)		NSString			*account;
@property (copy, readonly)		NSString			*password;
@property (assign, readwrite)	SecKeychainRef		keyChain;
@property (assign, readwrite)	SecKeychainItemRef	keyChainItem;

#pragma mark construct / destruct
- (id) init;
@end

#pragma mark -
@interface KCSInternetUser : KCSUser {
@protected
	NSString				*serverName;
	NSString				*serverPath;
	NSString				*securityDomain;	// optional
	SecProtocolType			protocol;
	SecAuthenticationType	authType;
	UInt16					port;
}
@property (copy, readwrite)		NSString				*serverName;
@property (copy, readwrite)		NSString				*serverPath;
@property (copy, readwrite)		NSString				*securityDomain;
@property (assign, readwrite)	SecProtocolType			protocol;
@property (assign, readwrite)	SecAuthenticationType	authType;
@property (assign, readwrite)	UInt16					port;

#pragma mark construct / destruct
- (id) init;
- (id) initWithURI:(NSURL *)URI;
- (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;
#pragma mark constructor support
- (NSDictionary *) protocolDict;
#pragma mark accessor
- (NSString *) password:(OSStatus *)error;
- (OSStatus) changePasswordTo:(NSString *)newPassword;
@end
