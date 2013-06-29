package org.selfkleptomaniac.mod.titwilio;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.titanium.TiApplication;

import com.twilio.client.Connection;
import com.twilio.client.ConnectionListener;
import com.twilio.client.Twilio;
import com.twilio.client.Device;
import com.twilio.client.Device.Capability;
import com.twilio.client.DeviceListener;
import com.twilio.client.PresenceEvent;
import ti.modules.titanium.android.PendingIntentProxy;

public class TwilioPhone implements Twilio.InitListener
{
	private static final String TAG = "TwilioPhone";
	private Device device;
	private Connection connection;
	private String capabilityToken;
	private Connection pendingConnection;
	
	private String url;
	private PendingIntent pendingIntent;
	
	public TwilioPhone(Context context, String url, PendingIntent pendingIntent){
		this.url = url;
		this.pendingIntent = pendingIntent;
		Twilio.initialize(context, this);
		Log.w(TAG, "Twilio SDK init");
	}

	@Override
	public void onError(Exception e) {
		// TODO Auto-generated method stub
		 Log.e(TAG, "Twilio SDK couldn't start: " + e.getLocalizedMessage());
	}
	
	@Override
	public void onInitialized() {
		Log.d(TAG, "Twilio SDK is ready");
		this.capabilityToken = null;
		this.device = null;
    getCapabilityToken(this.url, this.pendingIntent);
		//try {
		//	this.capabilityToken = HttpHelper.httpGet(this.url);
		//	this.device = Twilio.createDevice(this.capabilityToken, null);
		//	Log.d(TAG, this.capabilityToken);
		//	if(this.pendingIntent != null){
		//		Log.d(TAG, "setting pending intent");
		//		device.setIncomingIntent(pendingIntent);
		//	}else{
		//		Log.d(TAG, "incoming call unavailable");
		//	}
		//} catch (Exception e) {
    //      	Log.e(TAG, "Failed to obtain capability token: " + e.getLocalizedMessage());
		//}
	}
	
	private void getCapabilityToken(String url, PendingIntent intent){
		this.capabilityToken = null;
		this.device = null;
		try {
      this.pendingIntent = intent;
			this.capabilityToken = HttpHelper.httpGet(url);
			this.device = Twilio.createDevice(this.capabilityToken, null);
			Log.d(TAG, this.capabilityToken);
			if(this.pendingIntent != null){
				Log.d(TAG, "setting pending intent");
				device.setIncomingIntent(pendingIntent);
			}else{
				Log.d(TAG, "incoming call unavailable");
			}
		} catch (Exception e) {
          	Log.e(TAG, "Failed to obtain capability token: " + e.getLocalizedMessage());
		}
	}
	
	public void connect(KrollDict args) throws RuntimeException{
		if(device == null){
			//this.getCapabilityToken(args.get("url").toString());
			PendingIntentProxy proxy = (PendingIntentProxy) args.get("pendingIntent");
			PendingIntent pendingIntent = proxy.getPendingIntent();
		  this.getCapabilityToken(args.get("url").toString(), pendingIntent);
		}
		if(args.containsKey("params") && args.get("params") instanceof HashMap){
			HashMap<String, String> params = (HashMap<String, String>) args.get("params");
			Map<String, String> parameters = new HashMap<String, String>();
			for(String key : params.keySet()){
				parameters.put(key, params.get(key).toString());
			}
			connection = device.connect(parameters, null);
		}else{
			connection = device.connect(null, null);
		}
	}
	
	public void login(KrollDict args){
		Log.d(TAG, "loging in!");
		PendingIntentProxy proxy = (PendingIntentProxy) args.get("pendingIntent");
		PendingIntent pendingIntent = proxy.getPendingIntent();
		this.getCapabilityToken(args.get("url").toString(), pendingIntent);
	}
	
	public void handleIncomingConnection(Device inDevice, Connection inConnection) {
		device = inDevice;
		pendingConnection = inConnection;
		Log.d(TAG, "YES, we have handled in coming connection");
	}
	
	public void disconnect()
    {
        if (connection != null) {
            connection.disconnect();
            connection = null;
        }
    }
	
	public Device getDevice(){
		return device;
	}
	
	public Connection getConnection(){
		return this.connection;
	}
	
	public Connection getPendingConnection(){
		return this.pendingConnection;
	}
	
	public void setPendingConnection(Connection inConnection){
		this.pendingConnection = inConnection;
	}
	
	@Override
	public void finalize(){
		if (connection != null)
            connection.disconnect();
        if (device != null)
            device.release();
	}

	public void acceptIncomingCall(){
		if(pendingConnection != null){
			Log.d(TAG, "Yes, we have a pending connection");
			connection = pendingConnection;	
		}else{
			Log.d(TAG, "Well, do we have a connection?");
		}
		if(connection != null){
			connection.accept();
		}else{
			Log.d(TAG, "Strange, we have lost connection");
		}
	}
	
	public void ignoreIncomingCall(){
		if(pendingConnection != null){
			connection = pendingConnection;
		}
		connection.ignore();
	}

	public void setDevice(Device inDevice) {
		// TODO Auto-generated method stub
		device = inDevice;
	}

	public void setConnection(Connection inConnection) {
		// TODO Auto-generated method stub
		pendingConnection = inConnection;
	}
}
