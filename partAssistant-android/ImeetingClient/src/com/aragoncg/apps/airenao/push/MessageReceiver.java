package com.aragoncg.apps.airenao.push;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.aragoncg.apps.xmpp.service.AndroidPushService;

public class MessageReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		
		String msg = "";
		
		if (intent.getExtras().containsKey(AndroidPushService.MESSAGE_CONTENT)){
			msg = intent.getStringExtra(AndroidPushService.MESSAGE_CONTENT);
		}
		
		AndroidPushService.setCustomNotificationContent(context, msg);
		//Toast.makeText(context, msg, Toast.LENGTH_LONG).show();
		
	}
}