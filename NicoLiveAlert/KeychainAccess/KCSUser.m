//
//  KCSUser.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/11/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "KCSUser.h"

#pragma mark constant definition
	// Common Mask Bit
const UInt8 maskBitAccount				= 0x01 << 0;
	// Internet Keychain specific Bits
const UInt8 maskBitInetServerName		= 0x01 << 1;
const UInt8 maskBitInetServerPath		= 0x01 << 2;
const UInt8 maskBitInetProtocol			= 0x01 << 3;
const UInt8 maskBitInetAuthType			= 0x01 << 4;
const UInt8 maskBitInetPort				= 0x01 << 5;
const UInt8 maskBitInetSecurityDomain	= 0x01 << 6;
const UInt8 mastBitsInetRequired = 
	maskBitAccount | maskBitInetServerName | maskBitInetServerPath | 
	maskBitInetProtocol | maskBitInetPort;
const UInt8 maskBitsInetOptional = 
	maskBitAccount | maskBitInetServerName | maskBitInetServerPath | 
	maskBitInetProtocol | maskBitInetPort | maskBitInetSecurityDomain;
	// Generic KeyChain specific Bits


@implementation KCSUser
@synthesize status;

#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		account = NULL;
		password = NULL;
		keyChain = NULL;
		keyChainItem = NULL;
		syncronized = NO;
		paramFlags = 0x00;
		status = 1;
	}
	return self;
}// - (id) init

- (void) dealloc
{
	if (keyChainItem != NULL)
		CFRelease(keyChainItem);
#if __has_feature(objc_arc) == 0
	// relase account
    if (account != NULL)
		[account release];
	// relase password
	if (password != NULL)
		[password release];
	// no need care synced
	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
#pragma mark account’s accessor
- (NSString *) account
{
	return account;
}// - (NSString *) account

- (void) setAccount:(NSString *)account_
{
	syncronized = NO;
	account = [account_ copy];
	paramFlags |= maskBitAccount;
}// end - (void) setAccount:(NSString *)account_
#pragma mark -
#pragma mark password’s accessor
- (NSString *) password
{
	return password;
}// - (NSString *) account

#pragma mark -
#pragma mark keyChain’s accessor
//@synthesize keyChain
- (SecKeychainRef) keyChain
{
	return keyChain;
}// end - (SecKeychainRef) keyChain

- (void) setKeyChain:(SecKeychainRef)keyChain_
{
#if __has_feature(objc_arc) == 0
	if (keyChain != NULL)
		CFRelease(keyChain);
#endif
	keyChain = keyChain;
}// end - (void) setKeyChain:(SecKeychainRef)keyChain_

#pragma mark -
#pragma mark keyChain’s accessor
//@synthesize keyChain
- (SecKeychainItemRef) keyChainItem
{
	return keyChainItem;
}// end - (SecKeychainRef) keyChain

- (void) setKeyChainItem:(SecKeychainItemRef)keyChainItem_
{
#if __has_feature(objc_arc) == 0
	if (keyChainItem_ != NULL)
		CFRelease(keyChainItem);
#endif
	keyChainItem = keyChainItem_;
}// end - (void) setKeyChain:(SecKeychainItemRef)keyChainItem_

@end

#pragma mark -

@implementation KCSInternetUser
#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		keyChain = NULL;
		serverName = NULL;
		serverPath = NULL;
		securityDomain = NULL;
		protocol = kSecProtocolTypeAny;
		authType = kSecAuthenticationTypeAny;
		port = 0;
	}// end if self
	return self;
}// end - (id) init

- (id) initWithURI:(NSURL *)URI
{
	self = [super init];
	if (self)
	{
		account = [[URI user] copy];
		if (account != NULL)
			paramFlags |= maskBitAccount;
		serverName = [[URI host] copy];
		if (serverName != NULL)
			paramFlags |= maskBitInetServerName;
		serverPath = [[URI path] copy];
		if (serverPath != NULL)
			paramFlags |= maskBitInetServerPath;
		securityDomain = [[URI host] copy];
		if (securityDomain != NULL)
			paramFlags |= maskBitInetSecurityDomain;
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *protocolDict = [self protocolDict];
			protocol = [[protocolDict valueForKey:[URI scheme]] integerValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
			paramFlags |= maskBitInetProtocol;
		}// end if scheme
		port = [[URI port] integerValue];
		paramFlags |= maskBitInetPort;
		authType = kSecAuthenticationTypeAny;
		paramFlags |= maskBitInetAuthType;
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI

- (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth
{
	self = [super init];
	if (self)
	{
		account = [[URI user] copy];
		if (account != NULL)
			paramFlags |= maskBitAccount;
		serverName = [[URI host] copy];
		if (serverName != NULL)
			paramFlags |= maskBitInetServerName;
		serverPath = [[URI path] copy];
		if (serverPath != NULL)
			paramFlags |= maskBitInetServerPath;
		securityDomain = [[URI host] copy];
		if (securityDomain != NULL)
			paramFlags |= maskBitInetSecurityDomain;
		if ([[URI scheme] isEqualToString:@""] == NO)
		{
			NSDictionary *protocolDict = [self protocolDict];
			protocol = [[protocolDict valueForKey:[URI scheme]] integerValue];
			if (protocol == 0)
				protocol = kSecProtocolTypeAny;
			paramFlags |= maskBitInetProtocol;
		}// end if scheme
		port = [[URI port] integerValue];
		paramFlags |= maskBitInetPort;
		authType = auth;
		paramFlags |= maskBitInetAuthType;
	}// end if self
	return self;
}// end - (id) initWithURI:(NSURL *)URI withAuth:(SecAuthenticationType)auth;

- (void) dealloc
{
#if __has_feature(objc_arc) == 0
	if (serverName)
		[serverName release];
	if (serverPath)
		[serverPath release];
	if (securityDomain)
		[securityDomain release];
	[super dealloc];
#endif
}// end - (void) dealloc

#pragma mark constructor support
- (NSDictionary *) protocolDict
{
	NSDictionary *protocolDict = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSNumber numberWithInteger:kSecProtocolTypeHTTP], @"http", 
	 [NSNumber numberWithInteger:kSecProtocolTypeHTTPS], @"https",
	 [NSNumber numberWithInteger:kSecProtocolTypeFTP],@"ftp", 
	 [NSNumber numberWithInteger:kSecProtocolTypePOP3],@"pop3", 
	 [NSNumber numberWithInteger:kSecProtocolTypeSMTP], @"smtp", 
	 [NSNumber numberWithInteger:kSecProtocolTypeAFP],@"afp", 
	 [NSNumber numberWithInteger:kSecProtocolTypeSMB],@"smb", 
	 nil];

	return protocolDict;
}// end - (NSDictionary *) protocolDict

#pragma mark -
#pragma mark serverName’s accessor
//@synthesize serverName
- (NSString *) serverName
{
	return serverName;
}// end - (NSString *) serverName

- (void) setServerName:(NSString *)serverName_
{
	syncronized = NO;
#if __has_feature(objc_arc) == 0
	if (serverName != NULL)
		[serverName autorelease];
#endif
	serverName = [serverName_ copy];
		// set/clear server name flag
	if (serverName != NULL)	// set server name flag
		paramFlags |= maskBitInetServerName;
	else	// clear server name flag
		paramFlags &= ~maskBitInetServerName;
}// end - (void) setServerName:(NSString *)serverName_

#pragma mark -
#pragma mark serverPath’s accessor
//@synthesize serverPath;
- (NSString *) serverPath
{
	return serverPath;
}// end - (NSString *) serverPath

- (void) setServerPath:(NSString *)serverPath_
{
	syncronized = NO;
#if __has_feature(objc_arc) == 0
	if (serverPath != NULL)
		[serverPath autorelease];
#endif
	serverPath = [serverPath_ copy];
		// set/clear server path flag
	if (serverPath != NULL)	// set server path flag
		paramFlags |= maskBitInetServerPath;
	else	// clear server path flag
		paramFlags &= ~maskBitInetServerPath;
}// end - (void) setServerPath:(NSString *)serverPath_

#pragma mark -
#pragma mark securityDomain’s accessor
//@synthesize securityDomain;
- (NSString *) securityDomain
{
	return securityDomain;
}// end - (NSString *) securityDomain

- (void) setSecurityDomain:(NSString *)securityDomain_
{
	syncronized = NO;
#if __has_feature(objc_arc) == 0
	if (securityDomain != NULL)
		[securityDomain autorelease];
#endif
	securityDomain = [securityDomain_ copy];
		// set/clear security domain flag
	if (securityDomain != NULL)	// set security domain flag
		paramFlags |= maskBitInetSecurityDomain;
	else	// clear security domain flag
		paramFlags &= ~maskBitInetSecurityDomain;
}// end - (void) setSecurityDomain:(NSString *)securityDomain_

#pragma mark -
#pragma mark protocol’s accessor
//@synthesize protocol;
- (SecProtocolType) protocol
{
	return protocol;
}// end - (SecProtocolType) protocol

- (void) setProtocol:(SecProtocolType)protocol_
{
	syncronized = NO;
	protocol = protocol_;
		// set protocol flag
	paramFlags |= maskBitInetProtocol;
}// end - (SecProtocolType) protocol

#pragma mark -
#pragma mark authType’s accessor
//@synthesize authType;
- (SecAuthenticationType) authType
{
	return authType;
}// end - (SecAuthenticationType) authType

- (void) setAuthType:(SecAuthenticationType)authType_
{
	syncronized = NO;
	authType = authType_;
		// set authentication flag
	paramFlags |= maskBitInetAuthType;
}// end - (void) setAuthType:(SecAuthenticationType)authType_

#pragma mark -
#pragma mark port’s accessor
//@synthesize port;
- (UInt16) port
{
	return port;
}// end - (UInt16) port

- (void) setPort:(UInt16)port_
{
	syncronized = NO;
	port = port_;
		// set port flag
	paramFlags |= maskBitInetPort;
}// end - (void) setPort:(UInt16)port_

#pragma mark -
#pragma mark password’s accessor
- (NSString *) password:(OSStatus *)error
{
	*error = noErr;
	if (syncronized)
		return password;
	
	// make cstring & length data;
	const char *strAccountName = [account UTF8String];
	UInt32		lenAccountName = [account length];
	const char *strServerName = [serverName UTF8String];
	UInt32		lenServerName = [serverName length];
	const char *strSecurityDomain = [securityDomain UTF8String];
	UInt32		lenSecurityDomain = [securityDomain length];
	const char *strServerPath = [serverPath UTF8String];
	UInt32		lenServerPath = [serverPath	length];
	// returned password data
	const char *strPassword = NULL;
	UInt32 lenPassword;
	
	// fetch password from keychain
	*error = SecKeychainFindInternetPassword(NULL, lenServerName, strServerName, lenSecurityDomain, strSecurityDomain, lenAccountName, strAccountName, lenServerPath, strServerPath, port, protocol, authType, &lenPassword, (void **)&strPassword, NULL);
	
	// check err 
	if (*error == noErr)
	{
		NSData *data = [[NSData alloc] initWithBytes:strPassword length:lenPassword];
		password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		SecKeychainItemFreeContent(NULL, (void *)strPassword);
#if __has_feature(objc_arc) == 0
		[data release];
		[password autorelease];
#endif
	}
	
	return password;
}// end - (NSString *) getPassword:(OSStatus  *)error

- (OSStatus) changePasswordTo:(NSString *)newPassword
{
	OSStatus error = errSecItemNotFound;
	if (keyChainItem == NULL)
		return error;

	return error;
}// end - (OSStatus ) changePasswordTo:(NSString *)newPassword
@end