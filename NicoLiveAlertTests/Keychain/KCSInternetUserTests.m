//
//  KCSInternetUserTests.m
//  NicoLiveAlert
//
//  Created by Чайка on 3/16/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "KCSInternetUserTests.h"

#define USERNAME	@"chajka.niconico@gmail.com"
#define USERNAME1	@"chajka"
#define USERNAME2	@"mellanie"
#define PASSWORD	@"somepassword"
#define SERVER		@"chajka.from.tv"
#define SERVPATH	@"/"
#define SECDOMAIN	@"chajka.from.tv"
#define URI			@"https://chajka@chajka.from.tv/"
#define URI2		@"https://chajka.from.tv"
#define URIUSERNAME	@"chajka"
const UInt8 portNo = 80;

@implementation KCSInternetUserTests

- (void) setUp
{
    [super setUp];
    // Set-up code here.
}// end - (void) setUp

- (void) tearDown
{
    // Tear-down code here.
    [super tearDown];
}// end - (void) tearDown

- (void) test_01_InitializeKCSInternetUser
{
		// allocation test
	KCSInternetUser *user = [[KCSInternetUser alloc] init];
	
		// check initial value (inherited)
	STAssertNotNil(user, @"Generate KCSInternetUser instance failed");
	NSString *username = [user account];
	STAssertNil(username, @"Initial accout is not NILL");
	NSString *password = [user password];
	STAssertNil(password, @"Initial password is not NILL");
	
		// check inital value (class sepecific)
	NSString *server = [user serverName];
	STAssertNil(server, @"Initial server name is not NILL");
	NSString *path = [user serverPath];
	STAssertNil(path, @"Initial server path is not NILL");
	NSString *domain = [user securityDomain];
	STAssertNil(domain, @"Initial domain is not NILL");
	SecProtocolType protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeAny), @"Initial protocol is not kSecProtocolTypeAny");
	SecAuthenticationType auth = [user authType];
	STAssertTrue((auth == kSecAuthenticationTypeAny), @"Initial authentication type is not kSecAuthenticationTypeAny");
}// end - (void) testInitializeKCSInternetUser

- (void) test_02_SetGetValues
{
	KCSInternetUser *user = [[KCSInternetUser alloc] init];
	
		// set get value check (inherited)
	[user setAccount:USERNAME];
	NSString *username = [user account];
	STAssertEquals(USERNAME, username, @"Set and get user name is not match");
	NSString *password = [user password];
	STAssertNil(password, @"Set and get password is not match");
	
		// set get value check (class specific)
	[user setServerName:SERVER];
	NSString *server = [user serverName];
	STAssertEquals(server, SERVER, @"Set and get server name is not match");

	[user setServerPath:SERVPATH];
	NSString *path = [user serverPath];
	STAssertEquals(path, SERVPATH, @"Set and get server path is not match");

	[user setSecurityDomain:SERVER];
	NSString *domain = [user securityDomain];
	STAssertEquals(domain, SERVER, @"Set and get sercurity domain is not match");

	[user setProtocol:kSecProtocolTypeHTTP];
	SecProtocolType protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeHTTP), @"Set and Get protocol is not match");

	[user setAuthType:kSecAuthenticationTypeHTMLForm];
	SecAuthenticationType auth = [user authType];
	STAssertTrue((auth == kSecAuthenticationTypeHTMLForm), @"Set and Get authentication type is not match");

	[user setPort:portNo];
	UInt8 port = [user port];
	STAssertEquals(port, portNo, @"Port number is not match");
	
}// end - (void) testSetGetValues

- (void) test_03_InitWithURI
{
		// test initWithURI:
	KCSInternetUser *user = [[KCSInternetUser alloc] initWithURI:[NSURL URLWithString:URI]];
	STAssertNotNil(user, @"KCSInternetUser allocation failed");

	NSString *username = [user account];
	STAssertTrue([username isEqualToString:URIUSERNAME], @"username and account is not match");

	NSString *server = [user serverName];
	STAssertTrue([server isEqualToString:SERVER], @"server and serverName is not match");

	NSString *path = [user serverPath];
	STAssertTrue([path isEqualToString:@"/"], @"Path and serverPath is not match");

	NSString *domain = [user securityDomain];
	STAssertTrue([domain isEqualToString:SECDOMAIN], @"Domain and securityDomain is not match");

	SecProtocolType protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeHTTPS), @"protocol and protocol is not match");

	OSStatus status = [user status];
	STAssertEquals(status, errSecItemNotFound, @"status in not Equqal");
	
	NSString *password = [user password];
	STAssertNil(password, @"password is not nil");
}// end - (void) testInitWithURI

- (void) test_04_InitWithURIwithAuth
{
	KCSInternetUser *user = [[KCSInternetUser alloc] initWithURI:[NSURL URLWithString:URI] withAuth:kSecAuthenticationTypeHTTPBasic];

		// test initWithURI:withAuth:
	user = [[KCSInternetUser alloc] initWithURI:[NSURL URLWithString:URI2] withAuth:kSecAuthenticationTypeHTMLForm];
	STAssertNotNil(user, @"KCSInternetUser allocation failed");

	NSString *username = [user account];
	STAssertNil(username, @"username is not nil");

	NSString *server = [user serverName];
	STAssertTrue([server isEqualToString:SERVER], @"server and serverName is not match");

	NSString *path = [user serverPath];
	STAssertTrue([path isEqualToString:@""], @"Path and serverPath is not match");

	NSString *domain = [user securityDomain];
	STAssertTrue([domain isEqualToString:SECDOMAIN], @"Domain and securityDomain is not match");

	SecProtocolType protocol = [user protocol];
	STAssertTrue((protocol == kSecProtocolTypeHTTPS), @"protocol and protocol is not match");

	SecAuthenticationType auth = [user authType];
	STAssertTrue((auth == kSecAuthenticationTypeHTMLForm), @"authentication type is not match");

	OSStatus status = [user status];
	STAssertEquals(status, 1, @"status in not Equqal");
	
	NSString *password = [user password];
	STAssertNil(password, @"password is not nil");
}// end - (void) testInitWithURIwithAuth

- (void) test_05_SetAccountStartCollectPassword
{
	KCSInternetUser *user = [[KCSInternetUser alloc] initWithURI:[NSURL URLWithString:URI] withAuth:kSecAuthenticationTypeHTTPBasic];
	
	[user setAccount:USERNAME];
	
	OSStatus status = [user status];
	STAssertEquals(status, errSecItemNotFound, @"status in not Equqal");
	
	NSString *password = [user password];
	STAssertNil(password, @"password is not nil");
}// end - (void) testSetAccountStartCollectPassword

- (void) test_06_AddEntry
{
		// add entry test
	KCSInternetUser *newUser = [[KCSInternetUser alloc] initWithAccount:USERNAME andPassword:PASSWORD];
	STAssertTrue(([[newUser password] isEqualToString:PASSWORD]),@"password is invarid");
	[newUser setServerName:SERVER];
	[newUser setSecurityDomain:SERVER];
	[newUser setProtocol:kSecProtocolTypeHTTPS];
	[newUser setAuthType:kSecAuthenticationTypeHTMLForm];
	[newUser setPort:443];
	[newUser setKeychainName:@"Chajka's test"];
	[newUser setKeychainKind:@"Web Form password"];
	BOOL success = NO;
	if ([newUser status] != noErr)
		success = [newUser addTokeychain];
	STAssertTrue(success, @"addTokeychain is Failed");
	STAssertNotNil((__bridge id)[newUser keychainItem], @"keychainItem is Nil");

		// remove entry test
	[newUser removeFromkeychain];
	STAssertTrue(([newUser status] == noErr), @"removeFromkeychain Failed");
	STAssertNil((__bridge id)[newUser keychainItem], @"keychainItem is not cleard");	
}// end - (void) testAddPassword

- (void) test_07_fetchUsers
{
		// create first user
	KCSInternetUser *newUser = [[KCSInternetUser alloc] initWithAccount:USERNAME1 andPassword:PASSWORD];
	STAssertTrue(([[newUser password] isEqualToString:PASSWORD]),@"password is invarid");
	[newUser setServerName:SERVER];
	[newUser setSecurityDomain:SERVER];
	[newUser setProtocol:kSecProtocolTypeHTTPS];
	[newUser setAuthType:kSecAuthenticationTypeHTMLForm];
	[newUser setPort:443];
	[newUser setKeychainName:@"Chajka's test"];
	[newUser setKeychainKind:@"Web Form password"];
	BOOL success = NO;
	if ([newUser status] != noErr)
		success = [newUser addTokeychain];
	STAssertTrue(success, @"addTokeychain is Failed");
	STAssertNotNil((__bridge id)[newUser keychainItem], @"keychainItem is Nil");

	// create second user
#if __has_feature(objc_arc) == 0
	[newUser autorelease];
#endif
	newUser = [[KCSInternetUser alloc] initWithAccount:USERNAME2 andPassword:PASSWORD];
	STAssertTrue(([[newUser password] isEqualToString:PASSWORD]),@"password is invarid");
	[newUser setServerName:SERVER];
	[newUser setSecurityDomain:SERVER];
	[newUser setProtocol:kSecProtocolTypeHTTPS];
	[newUser setAuthType:kSecAuthenticationTypeHTMLForm];
	[newUser setPort:443];
	[newUser setKeychainName:@"Chajka's test"];
	[newUser setKeychainKind:@"Web Form password"];
	success = NO;
	if ([newUser status] != noErr)
		success = [newUser addTokeychain];
	STAssertTrue(success, @"addTokeychain is Failed");
	STAssertNotNil((__bridge id)[newUser keychainItem], @"keychainItem is Nil");
	
		// search users
	NSArray *users = [KCSInternetUser usersOfAccountsForServer:SERVER path:@"" forAuthType:kSecAuthenticationTypeAny inKeychain:NULL];
	STAssertNotNil(users, @"users of server not found");
	STAssertTrue(([users count] == 2), @"user count isn't match");

		// cleanup users
	for (KCSInternetUser *user in users)
	{
		[user removeFromkeychain];
		STAssertTrue(([user status] == noErr), @"removeFromkeychain Failed");
		STAssertNil((__bridge id)[user keychainItem], @"keychainItem is not cleard");	
	}// end for
}// end - (void) test_07_usersWith

@end
