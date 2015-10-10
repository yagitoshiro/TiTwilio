TiTwilio
========

Titanium + Twilio = TiTwilio!

You can create VoIP mobile application by adding just a few lines to your JavaScript.

```javascript
var TiTwilio, intent, pendingIntent;

TiTwilio = require('org.selfkleptomaniac.mod.titwilio');

if(Ti.Platform.osname === 'android'){
  intent = Ti.Android.createServiceIntent({url:'service.js', twilio: TiTwilio});
  pendingIntent = Ti.Android.createPendingIntent({intent: intent});
}else{
  intent = null;
  pendingIntent = null;
}

// login
TiTwilio.login({
  url: 'http://your-auth-server.example.com', // auth server (required)
  params: {key: value, post: data}, // post data (optional)
  pendingIntent: pendingIntent
});

// call
TiTwilio.connect({
  url: 'http://your-auth-server.example.com', // auth server (required)
  params: {key: value, post: data} // post data (optional)
});

// handle incoming connection
TiTwilio.addEventListener('incomingConnection', function(e){
  var intent = null;
  if(Ti.Platform.osname == 'android'){
   intent = e.intent;
  }
  TiTwilio.acceptIncomngCall({intent: intent}); // intent can be null for iOS
  //TiTwilio.ignoreIncomingCall({intent: intent});
});
```

## API Reference

### Methods

#### login(obj):void
Connect to your authentication server and retrieve a capability token. 

Object should contain at least these two values:

- string **url** (required)

URL of your authentication server. Used to retrieve a capability token.

- obj **[params]** 

{key: value} pairs to be sent with your request through your TwiML app.

#### connect(obj):void
Create an outgoing VoIP call. Will run the "voice" URL in your TwiML app with any parameters specified in the params object. 

Object should contain at least these two values:

- string **url** (required)

URL of your authentication server. Used to retrieve a capability token.

- obj **[params]** 

{key: value} pairs to be sent with your request through your TwiML app.

#### acceptIncomingCall(obj {intent: intent}):void
- obj {intent: intent}

Accept an incoming call. Intent can be null for iOS.

#### ignoreIncomingCall(obj {intent: intent}):void
- obj {intent: intent}

Ignore an incoming call. Intent can be null for iOS.

----


### Events

#### connecting
Fired when TiTwilio is beginning an outgoing call.

#### connectionError
Fired when an outgoing call fails to connect.

#### connectionFailed


#### connected
Fired when TiTwilio is connected to an outgoing VoIP call. It is considered "connected" as soon as  TwiML begins being executed, not when the recipient answers the call.

#### disconnected
Fired after a connection terminates. 

#### loginStart
Fired when TiTwilio begins requesting a capability token from the auth server.

#### loginError
Fired if an auth server URL is not provided *or* if a capability token can not be retrieved from the auth server.

#### capabilyToken
*Yes, the typo is currently correct.* Fired when a capability token is received. Passes an object including the capability token.

#### loggedIn
When the "login" process has completed. 

#### invalidCapabilityToken
TiTwilio checked the capability token and has determined it is invalid or expired.

#### validCapabilityToken
TiTwilio checked the capability token and determined it is okay to use.

#### didStartListening
TiTwilio has begun listening for incoming connections.

#### didStopListening
TiTwilio stopped listening for incoming conncetions.

#### callWaiting
An incoming connection has been received while another is currently in progress.

#### incomingConnection
Incoming connection has been received. Fired regardless of whether one is currently in progress.



