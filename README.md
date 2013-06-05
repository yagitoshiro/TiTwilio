TiTwilio
========

Titanium + Twilio = TiTwilio!

You can create VoIP mobile application by adding just a few lines to your JavaScript.

```javascript
TiTwilio.connect({
  url: 'http://your-auth-server.example.com',
  params: {key: value, post: data}
});

TiTwilio.addEventListener('incomingConnection', function(e){
  TiTwilio.acceptIncomngCall();
  //TiTwilio.ignoreIncomingCall();
});
```
