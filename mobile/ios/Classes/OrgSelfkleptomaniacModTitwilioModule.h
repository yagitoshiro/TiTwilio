/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "TCDevice.h"
#import "TCConnection.h"
#import "BasicPhoneNotifications.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface OrgSelfkleptomaniacModTitwilioModule : TiModule <TCDeviceDelegate, TCConnectionDelegate>
{
 @private
    TCDevice* _device;
    TCConnection* _connection;
	TCConnection* _pendingIncomingConnection;
	BOOL _speakerEnabled;
}
@property (nonatomic,retain) TCDevice* device;
@property (nonatomic,retain) TCConnection* connection;
@property (nonatomic,retain) TCConnection* pendingIncomingConnection;

// notifications
//-(void)loginDidStart:(NSNotification*)notification;
//-(void)loginDidFinish:(NSNotification*)notification;
//-(void)loginDidFailWithError:(NSNotification*)notification;
//
//-(void)connectionDidConnect:(NSNotification*)notification;
//-(void)connectionDidFailToConnect:(NSNotification*)notification;
//-(void)connectionIsDisconnecting:(NSNotification*)notification;
//-(void)connectionDidDisconnect:(NSNotification*)notification;
//-(void)connectionDidFailWithError:(NSNotification*)notification;
//
//-(void)pendingIncomingConnectionDidDisconnect:(NSNotification*)notification;
//-(void)pendingIncomingConnectionReceived:(NSNotification*)notification;
//
//-(void)deviceDidStartListeningForIncomingConnections:(NSNotification*)notification;
//-(void)deviceDidStopListeningForIncomingConnections:(NSNotification*)notification;


-(void)login:(id)args;

// Turn the speaker on or off.
-(void)setSpeakerEnabled:(BOOL)enabled;

//TCConnection Methods
-(void)connect:(id)args;
-(void)disconnect:(id)args;
-(void)acceptIncomingCall;
-(void)ignoreIncomingCall;

-(NSString*)getCapabilityToken:(NSError**)error :(NSString*)url;
-(BOOL)capabilityTokenValid;

-(void)updateAudioRoute;
-(void)connectionDidConnect;
-(void)connectionDidDisconnect;

//+(NSError*)errorFromHTTPResponse:(NSHTTPURLResponse*)response domain:(NSString*)domain;

@end
