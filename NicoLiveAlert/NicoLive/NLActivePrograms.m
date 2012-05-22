//
//  NLActivePrograms.m
//  NicoLiveAlert
//
//  Created by Чайка on 4/12/12.
//  Copyright (c) 2012 iom. All rights reserved.
//

#import "NLActivePrograms.h"

@interface NLActivePrograms ()
- (void) removeEndedProgram:(NSNotification *)notification;
@end

@implementation NLActivePrograms
@synthesize sbItem;
@synthesize users;

NSNumber *yes;

#pragma mark construct / destruct
- (id) init
{
	self = [super init];
	if (self)
	{
		yes = [[NSNumber alloc] initWithBool:YES];
		sbItem = nil;
		users = nil;
		programs = [[NSMutableArray alloc] init];
		liveNumbers = [[NSMutableDictionary alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeEndedProgram:) name:NLNotificationPorgramEnd object:nil];
	}// end if
	return self;
}// end - (id) init

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NLNotificationPorgramEnd object:nil];
#if __has_feature(objc_arc) == 0
	if (sbItem != nil)			[sbItem release];
	if (users != nil)			[users release];
	if (yes != nil)			[yes release];
	if (programs != nil)		[programs release];
	if (liveNumbers != nil)	[liveNumbers release];

    [super dealloc];
#endif
}// end - (void) dealloc

#pragma mark -
- (void) addUserProgram:(NSString *)liveNo withDate:(NSDate *)date community:(NSString *)community owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen isChannel:(BOOL) isChannel
{
	if ([[liveNumbers valueForKey:liveNo] isEqualTo:yes])
		return;
	else
		[liveNumbers setValue:yes forKey:liveNo];

	NLAccount *account = [users primaryAccountForCommunity:community];
	BOOL isMyBroadcast = NO;
	if ([owner isEqualToString:[account nickname]] == YES)
		isMyBroadcast = YES;
	// end if program is my broadcast
		
	NLProgram *program = [[NLProgram alloc] initWithProgram:liveNo withDate:date forAccount:account owner:owner autoOpen:autoOpen isMine:isMyBroadcast isChannel:isChannel];
	if (program == nil)
		return;

	NSMenuItem *item = [program programMenu];
	if (item == nil)
	{
#if __has_feature(objc_arc) == 0
		[program release];
#endif
		[liveNumbers removeObjectForKey:liveNo];
		return;
	}

		// check and remove prefeerd same community & owner's program
	for (NLProgram *prog in [programs reverseObjectEnumerator])
	{
		if ([program isSame:prog] == YES)
			[prog terminate];
		// end if same owner and community
	}// end foreach active programs

	[programs addObject:program];
	[sbItem addToUserMenu:item];

#if __has_feature(objc_arc) == 0
		// decrease retain count for remove means relase
	[program release];
#endif
}// end - (void) addUserProgram:(NSString *)liveNo withDate:(NSDate *)date community:(NSString *)community owner:(NSString *)owner autoOpen:(NSNumber *)autoOpen

- (void) addOfficialProgram:(NSString *)liveNo withDate:(NSDate *)date autoOpen:(NSNumber *)autoOpen isOfficial:(BOOL)official
{
	if ([[liveNumbers valueForKey:liveNo] isEqualTo:yes])
		return;
	else
		[liveNumbers setValue:yes forKey:liveNo];

	NLProgram *program = [[NLProgram alloc] initWithProgram:liveNo  withDate:date autoOpen:autoOpen isOfficial:official];
	if (program == nil)
		return;

	NSMenuItem *item = [program programMenu];
	if (item == nil)
	{
#if __has_feature(objc_arc) == 0
		[program release];
#endif
		[liveNumbers removeObjectForKey:liveNo];
		return;
	}

	[programs addObject:program];
	[sbItem addToOfficialMenu:item];
#if __has_feature(objc_arc) == 0
		// decrease retain count for remove means relase
	[program release];
#endif
}// end - (void) addOfficialProgram:(NSString *)liveNo withDate:(NSDate *)date autoOpen:(NSNumber *)autoOpen isOfficial:(BOOL)official

- (void) suspend
{
	for (NLProgram *program in programs)
	{
		[program suspend];
	}// end for each programs
}// end - (void) suspend

- (void) resume
{
	for (NLProgram *program in [programs reverseObjectEnumerator])
	{
		if ([program resume] == NO)
		{
			if ([program isOfficial] == YES)
				[sbItem removeFromOfficialMenu:[program programMenu]];
			else
				[sbItem removeFromUserMenu:[program programMenu]];
			//end if remove program item by kind

			[liveNumbers removeObjectForKey:[program programNumber]];
			[programs removeObject:program];
		}// end if program was already ended
	}// end for each programs
}// end - (void) resume

- (void) removeEndedProgram:(NSNotification *)notification
{		// iterate for find ended program.
	NLProgram *prog = [notification object];
	NSMenuItem *item = [prog programMenu];
	if ([prog isOfficial] == YES)
		[sbItem removeFromOfficialMenu:item];
	else 
		[sbItem removeFromUserMenu:item];

	[liveNumbers removeObjectForKey:[prog programNumber]];
	[programs removeObject:prog];
}// end - (void) removeEndedProgram:(NSNotification *)notification
@end
