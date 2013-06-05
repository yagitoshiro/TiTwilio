/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "OrgSelfkleptomaniacModTitwilioModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation OrgSelfkleptomaniacModTitwilioModule

@synthesize device = _device;
@synthesize connection = _connection;
@synthesize pendingIncomingConnection = _pendingIncomingConnection;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"be8ecb45-1ed2-4fef-a979-1e4a9dcb8bce";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"org.selfkleptomaniac.mod.titwilio";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
    if ( self = [super init] )
	{
		_speakerEnabled = YES; // enable the speaker by default
    }
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
    [_connection release];
	[_pendingIncomingConnection release];
	[_device release];
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs
-(id)example:(id)args
{
    // example method
    return @"hello world";
}

//TCConnection Methods
-(void)connect:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    NSString *url;
    NSString *params;
    NSDictionary *paramsDict;
    
    ENSURE_ARG_OR_NIL_FOR_KEY(url, args, @"url", NSString);
    ENSURE_ARG_OR_NIL_FOR_KEY(paramsDict, args, @"params", NSDictionary);
    
	// First check to see if the token we have is valid, and if not, refresh it.
	// Your own client may ask the user to re-authenticate to obtain a new token depending on
	// your security requirements.
	if (![self capabilityTokenValid])
	{
		//Capability token is not valid, so create a new one and update device
		[self login:args];
	}
	
	// Now check to see if we can make an outgoing call and attempt a connection if so
	NSNumber* hasOutgoing = [_device.capabilities objectForKey:TCDeviceCapabilityOutgoingKey];
	if ( [hasOutgoing boolValue] == YES )
	{
		//Disconnect if we've already got a connection in progress
		if(_connection){
            [self disconnect:args];
        }
        [self fireEvent: @"connecting"];
        if(paramsDict == nil){
            _connection = [_device connect:nil delegate:self];
        }else{
            _connection = [_device connect:paramsDict delegate:self];
        }
		[_connection retain];
		if ( !_connection ) // if a connection is established, connectionDidStartConnecting: gets invoked next
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:BPConnectionDidFailToConnect object:nil];
            [self fireEvent: @"connectionError"];
		}//else{
        //   //NSLog(@"[INFO] Connected! yay!");
        //   [self fireEvent: @"connected"];
        //}
	}
}

-(void)disconnect:(id)args
{
    //Destroy TCConnection
	// We don't release until after the delegate callback for connectionDidConnect:
	[_connection disconnect];
    [_connection release];
    _connection = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:BPConnectionIsDisconnecting object:nil];
}

-(void)login:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    NSString *url;
    ENSURE_ARG_OR_NIL_FOR_KEY(url, args, @"url", NSString);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BPLoginDidStart object:nil];
    [self fireEvent: @"loginStart"];
    
    if(url == nil){
        [self fireEvent:@"loginError" withObject: [NSDictionary dictionaryWithObject:@"url is null" forKey: @"message"]];
    }else{
        NSError* loginError = nil;
        NSString* capabilityToken = [self getCapabilityToken:&loginError myUrlStr:url];
        
        if ( !loginError && capabilityToken )
        {
            NSDictionary* keyInfo = [NSDictionary dictionaryWithObject:capabilityToken forKey:@"capabilityToken"];
            [self fireEvent: @"capabilyToken" withObject:[NSDictionary dictionaryWithObject:@"capabilityToken" forKey: @"capabilityToken"]];
            if ( !_device )
            {
                // initialize a new device
                _device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken delegate:self];
            }
            else
            {
                // update its capabilities
                [_device updateCapabilityToken:capabilityToken];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:BPLoginDidFinish object:nil];
            [self fireEvent: @"loggedIn"];
        }
        else if ( loginError )
        {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:loginError forKey:@"error"];
            [[NSNotificationCenter defaultCenter] postNotificationName:BPLoginDidFailWithError object:nil userInfo:userInfo];
            [self fireEvent:@"loginError" withObject: [NSDictionary dictionaryWithObject:[loginError localizedDescription] forKey:@"message"]];
        }
    }
}

-(void)acceptIncomingCall: (id)args
{
    [_pendingIncomingConnection accept];
	_connection = _pendingIncomingConnection;
	_pendingIncomingConnection = nil;
    
}

-(void)ignoreIncomingCall: (id)args
{
    [_pendingIncomingConnection ignore];
    _pendingIncomingConnection = nil;
}

-(NSString*)getCapabilityToken:(NSError**)error myUrlStr:(NSString*)urlStr
{
	//Creates a new capability token from the auth.php file on server
	NSString *capabilityToken = nil;
    
    NSURL *url = [NSURL URLWithString:urlStr];
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
										 returningResponse:&response error:error];
	if (data)
	{
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
		
		if (httpResponse.statusCode==200)
		{
			capabilityToken = [[[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding] autorelease];
		}
		else
		{
			*error = [self errorFromHTTPResponse:httpResponse domain:@"CapabilityTokenDomain"];
		}
	}
	// else there is likely an error which got assigned to the incoming error pointer.
	
	return capabilityToken;
}

-(BOOL)capabilityTokenValid
{
	//Check TCDevice's capability token to see if it is still valid
	BOOL isValid = NO;
	NSNumber* expirationTimeObject = [_device.capabilities objectForKey:@"expiration"];
	long long expirationTimeValue = [expirationTimeObject longLongValue];
	long long currentTimeValue = (long long)[[NSDate date] timeIntervalSince1970];
    
	if((expirationTimeValue-currentTimeValue)>0){
		isValid = YES;
        [self fireEvent: @"invalidCapabilityToken"];
    }else{
        [self fireEvent: @"validCapabilityToken"];
    }
	
	return isValid;
}

-(void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
	[[NSNotificationCenter defaultCenter] postNotificationName:BPDeviceDidStartListeningForIncomingConnections object:nil];
    [self fireEvent: @"didStartListening"];
}

-(void)device:(TCDevice*)device didStopListeningForIncomingConnections:(NSError*)error
{
	// The TCDevice is no longer listening for incoming connections, possibly due to an error.
	NSDictionary* userInfo = nil;
	if ( error ) {
		userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
        [self fireEvent: @"didStopListening" withObject: [NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"message"]];
    }else{
        [self fireEvent: @"didStopListening"];
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:BPDeviceDidStopListeningForIncomingConnections object:nil userInfo:userInfo];
}

-(void)device:(TCDevice*)device didReceiveIncomingConnection:(TCConnection*)connection
{
	//Device received an incoming connection
	if ( _pendingIncomingConnection )
	{
		//NSLog(@"A pending exception already exists");
        [self fireEvent: @"callWaiting"];
		return;
	}
	
	// Initalize pending incoming conneciton
	_pendingIncomingConnection = [connection retain];
	[_pendingIncomingConnection setDelegate:self];
	
	// Send a notification out that we've received this.
	[[NSNotificationCenter defaultCenter] postNotificationName:BPPendingIncomingConnectionReceived object:nil];
    [self fireEvent: @"incomingConnection"];
}

-(void)device:(TCDevice *)device didReceivePresenceUpdate:(TCPresenceEvent *)presenceEvent
{
}

-(void)connection:(TCConnection*)connection didFailWithError:(NSError*)error
{
	//Connection failed
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"]; // autoreleased
	[[NSNotificationCenter defaultCenter] postNotificationName:BPConnectionDidFailWithError object:nil userInfo:userInfo];
    [self fireEvent:@"connectionFailed" withObject:[error localizedDescription]];
}

-(void)updateAudioRoute
{
    if (_speakerEnabled)
	{
		UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
		
		AudioSessionSetProperty (
								 kAudioSessionProperty_OverrideAudioRoute,
								 sizeof (audioRouteOverride),
								 &audioRouteOverride
								 );
	}
	else
	{
		UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
		
		AudioSessionSetProperty (
								 kAudioSessionProperty_OverrideAudioRoute,
								 sizeof (audioRouteOverride),
								 &audioRouteOverride
								 );
	}
}

// Turn the speaker on or off.
-(void)setSpeakerEnabled:(BOOL)enabled
{
    _speakerEnabled = enabled;
	[self updateAudioRoute];
}

-(NSError*)errorFromHTTPResponse:(NSHTTPURLResponse*)response domain:(NSString*)domain
{
	NSString* localizedDescription = [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode];
    NSLog(@"[INFO] localizedDescription: %@", localizedDescription);
	
	NSDictionary* errorUserInfo = [NSDictionary dictionaryWithObject:localizedDescription
															  forKey:NSLocalizedDescriptionKey];
	
	NSError* error = [NSError errorWithDomain:domain
										 code:response.statusCode
									 userInfo:errorUserInfo];
	return error;
}

-(void)connectionDidConnect:(TCConnection *)connection
{
//    NSLog(@"[INFO] connected");
    [self fireEvent: @"connected"];
}

-(void)connectionDidDisconnect:(TCConnection *)connection
{
//    NSLog(@"[INFO] disconnected");
    [self fireEvent: @"disconnected"];
}

@end
