//
//  Copyright 2011 Twilio. All rights reserved.
//
 
// Notification strings used with NSNotification to convey significant events
// between the model and the views.

extern NSString* const BPLoginDidStart;
extern NSString* const BPLoginDidFinish;
extern NSString* const BPLoginDidFailWithError;

extern NSString* const BPPendingIncomingConnectionReceived;
extern NSString* const BPPendingIncomingConnectionDidDisconnect;
extern NSString* const BPConnectionIsConnecting;
extern NSString* const BPConnectionIsDisconnecting;
extern NSString* const BPConnectionDidConnect;
extern NSString* const BPConnectionDidFailToConnect;
extern NSString* const BPConnectionDidDisconnect;
extern NSString* const BPConnectionDidFailWithError;

extern NSString* const BPDeviceDidStartListeningForIncomingConnections;
extern NSString* const BPDeviceDidStopListeningForIncomingConnections; // has an optional "error" payload in the userInfo
