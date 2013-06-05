// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
  layout: 'vertical',
	backgroundColor:'white'
});

// TODO: write your module tests here
var TiTwilio = require('org.selfkleptomaniac.mod.titwilio');
Ti.API.info("module is => " + TiTwilio);

//TiTwilio.addEventListener('loginStart', function(e){
//  Ti.API.info(e);
//});
//TiTwilio.addEventListener('loginError', function(e){
//  Ti.API.info(e);
//});
//TiTwilio.addEventListener('loggedIn', function(e){
//  Ti.API.info(e);
//});
//TiTwilio.addEventListener('incomingConnection', function(e){
//  Ti.API.info(e);
//  var dialog = Ti.UI.createAlertDialog({
//    title: 'Phone call!',
//    message: 'You have a incoming call',
//    buttonNames: ['Accept', 'Ignore']
//  });
//  dialog.addEventListener('click', function(elem){
//    if(elem.index === 0){
//      Ti.API.info('accept');
//      TiTwilio.acceptIncomingCall();
//    }else{
//      Ti.API.info('ignore');
//      TiTwilio.ignoreIncomingCall();
//    }
//  });
//  dialog.show();
//});

var login = Ti.UI.createButton({
  title: 'Login',
  width: Ti.UI.SIZE,
  height: Ti.UI.SIZE,
  top: 30
});

win.add(login);

var connect = Ti.UI.createButton({
  title: 'Connect',
  width: Ti.UI.SIZE,
  height: Ti.UI.SIZE,
  top: 30
});

win.add(connect);

var disconnect = Ti.UI.createButton({
  title: 'Disconnect',
  width: Ti.UI.SIZE,
  height: Ti.UI.SIZE,
  top: 30
});

win.add(disconnect);

function isOnline(){
  //return Ti.Network.online && 
  //(Ti.Network.networkType === Ti.Network.NETWORK_LAN || Ti.Network.networkType === Ti.Network.NETWORK_WIFI);
  return true;
}

var tf = Ti.UI.createTextField({
  value: '',
  left: 10,
  right: 10,
  top: 30
});
win.add(tf);

login.addEventListener('click', function(){
  if(isOnline()){
    //TiTwilio.login();
    TiTwilio.login({
      url: 'http://dev.voidoid.com/auth?name=' + tf.value
    });
  }else{
    alert("Twilio works only with Wifi or LAN network");
  }
});

connect.addEventListener('click', function(){
  if(isOnline()){
    //TiTwilio.connect();
    TiTwilio.connect({
      url: 'http://dev.voidoid.com/auth',
      params: {phoneNumber: '+818054694667'}
    });
  }else{
     alert("Twilio works only with Wifi or LAN network");
  }
});
disconnect.addEventListener('click', function(){
  TiTwilio.disconnect();
});
win.open();
