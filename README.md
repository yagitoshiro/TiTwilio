TiTwilio
========

Titanium + Twilio = TiTwilio!

You can create VoIP mobile application by adding just a few lines to your JavaScript.

```javascript
var TiTwilio = require('org.selfkleptomaniac.mod.titwilio');

var pendingIntent;
if(Ti.Platform.osname === 'android'){
  var intent = Ti.Android.createServiceIntent({url:'service.js', twilio: TiTwilio});
  pendingIntent = Ti.Android.createPendingIntent({intent: intent});
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
