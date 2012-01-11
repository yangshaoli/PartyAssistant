package com.aragoncg.apps.airenao.activity;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.weibo.RequestToken;
import com.aragoncg.apps.airenao.weibo.Weibo;


import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebView;

public class AuthorizeActivity extends Activity {
	private static final String APP_KEY = "";
	private static final String APP_SECRET = "";
	private static final String UIL_ACTIVITY_CALLBACK = "";
	RequestToken requestToken = null;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		setContentView(R.layout.oauth_layout);
		super.onCreate(savedInstanceState);
		
		try{
			Weibo weibo = Weibo.getInstance();
			requestToken = weibo.getRequestToken(AuthorizeActivity.this, Weibo.APP_KEY, Weibo.APP_SECRET, null);
		}catch(Exception e){
			
		}
		
		Uri uri = Uri.parse(Weibo.URL_AUTHENTICATION + "?display=wap2.0&oauth_token=" + 
				requestToken.getToken() + "&from=" 
				+ "xweibo");
		
		WebView wv = (WebView) findViewById(R.id.web);
		wv.loadUrl(uri.toString());
	}

	
}
