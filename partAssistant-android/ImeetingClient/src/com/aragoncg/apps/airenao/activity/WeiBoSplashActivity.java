package com.aragoncg.apps.airenao.activity;



import java.io.File;
import java.util.SortedSet;

import oauth.signpost.commonshttp.CommonsHttpOAuthConsumer;
import oauth.signpost.commonshttp.CommonsHttpOAuthProvider;
import oauth.signpost.exception.OAuthCommunicationException;
import oauth.signpost.exception.OAuthExpectationFailedException;
import oauth.signpost.exception.OAuthMessageSignerException;
import oauth.signpost.exception.OAuthNotAuthorizedException;
import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.StringUtils;
import com.aragoncg.apps.airenao.weibo.ShareActivity;
import com.aragoncg.apps.airenao.weibo.Weibo;
import com.mobclick.android.MobclickAgent;

public class WeiBoSplashActivity extends Activity {
	public static final String EXTRA_WEIBO_CONTENT = "com.weibo.android.content";
	public static final String EXTRA_PIC_URI = "com.weibo.android.pic.uri";
	public static final String EXTRA_ACCESS_TOKEN = "com.weibo.android.accesstoken";
	public static final String EXTRA_TOKEN_SECRET = "com.weibo.android.token.secret";
	CommonsHttpOAuthConsumer httpOauthConsumer;
	CommonsHttpOAuthProvider httpOauthprovider;
	private String partyId;
	public final static String SDCARD_MNT = "/mnt/sdcard";
	public final static String SDCARD = "/sdcard";
	private final static String callBackUrl="founderapp://WeiBoSplashActivity";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
		
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.weibo_splash);
		MobclickAgent.onError(this);
		partyId = getIntent().getStringExtra(Constants.PARTY_ID);
		
		//弹出一个自定义dialog
		View diaView=View.inflate(this, R.layout.weibo_dialog, null);
		final Dialog dialog=new Dialog(WeiBoSplashActivity.this,R.style.dialog);
		dialog.setContentView(diaView);
		Button btnOk = (Button) diaView.findViewById(R.id.btn_start);
		Button btnCancle = (Button) diaView.findViewById(R.id.btn_cancel);
		btnOk.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dialog.dismiss();
				httpOauthConsumer = new CommonsHttpOAuthConsumer(Weibo.APP_KEY, 
						Weibo.APP_SECRET);
		    	
				httpOauthprovider = new CommonsHttpOAuthProvider(
						Weibo.URL_OAUTH_TOKEN,
						Weibo.URL_ACCESS_TOKEN,
						Weibo.URL_AUTHORIZE);
				
				String authUrl="";
				
				try {
					authUrl = httpOauthprovider.retrieveRequestToken(httpOauthConsumer, callBackUrl);
				} catch (Exception e) {
					String a = e.getMessage();
					e.printStackTrace();
				} 
	    		
	    		Intent intent = new Intent();
	    		Bundle bundle = new Bundle();
	    		bundle.putString("url", authUrl);
	    		intent.putExtras(bundle);
	    		intent.setClass(WeiBoSplashActivity.this , WebViewActivity.class);
	    		startActivity(intent);
			}
		});
		dialog.show();
		btnCancle.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dialog.dismiss();
				finish();
				
			}
		});
	}
	
	
	@Override
    protected void onNewIntent(Intent intent) 
	{
    	super.onNewIntent(intent);
    	
    	Uri uri = intent.getData();
    	if(uri==null)
    	{
    		return;
    	}
    	
    	String verifier = uri.getQueryParameter(oauth.signpost.OAuth.OAUTH_VERIFIER);
    	
    	try 
    	{
            httpOauthprovider.setOAuth10a(true); 
            httpOauthprovider.retrieveAccessToken(httpOauthConsumer,verifier);
        } 
    	catch (OAuthMessageSignerException ex) {
            ex.printStackTrace();
        } 
    	catch (OAuthNotAuthorizedException ex) {
            ex.printStackTrace();
        } 
    	catch (OAuthExpectationFailedException ex) {
            ex.printStackTrace();
        } 
    	catch (OAuthCommunicationException ex) {
            ex.printStackTrace();
        }
        
        SortedSet<String> userInfoSet = httpOauthprovider.getResponseParameters().get("user_id");
        if(userInfoSet!=null&&!userInfoSet.isEmpty())
        {
            String userID = userInfoSet.first();
            String accessToken = httpOauthConsumer.getToken();
            String accessSecret = httpOauthConsumer.getTokenSecret();
            //保存access token
            SharedPreferences spf = AirenaoUtills.getMySharedPreferences(WeiBoSplashActivity.this);
            Editor eidt = spf.edit();
            eidt.putString(EXTRA_ACCESS_TOKEN, accessToken);
            eidt.putString(EXTRA_TOKEN_SECRET, accessSecret);
            eidt.commit();
            Intent intent2 = new Intent();
    		Bundle bundle = new Bundle();
    		
    		String backUrl = spf.getString(partyId, null);
    		if(backUrl==null){
    			throw new RuntimeException("获得邀请链接错误");
    		}
    		backUrl = "我使用@我们爱热闹 发布了一个活动！大家快来报名："+backUrl;
    		bundle.putString(EXTRA_WEIBO_CONTENT, backUrl);
    		bundle.putString(EXTRA_PIC_URI, getImgPathByCaptureSendFilter());
    		bundle.putString(EXTRA_ACCESS_TOKEN, accessToken);
    		bundle.putString(EXTRA_TOKEN_SECRET, accessSecret);
    		intent2.putExtras(bundle);
    		intent2.setClass(WeiBoSplashActivity.this, ShareActivity.class);
    		startActivity(intent2);
    		
    		WebViewActivity.webInstance.finish();
    		finish();
        }
    }
	
	/**
	 * 捕捉android.intent.action.SEND，并得到捕捉到的图片路径
	 * @return
	 */
	private String getImgPathByCaptureSendFilter()
	{
		String thisLarge = "";
		Uri mUri = null;
		final Intent intent = getIntent();
		final String action = intent.getAction();
		if( !StringUtils.isBlank(action) && "android.intent.action.SEND".equals(action) ) 
		{
			boolean hasExtra = intent.hasExtra("android.intent.extra.STREAM");
			if(hasExtra)
			{
				mUri = (Uri)intent.getParcelableExtra("android.intent.extra.STREAM");
			}
			
			if( mUri!=null )
			{   
				String mUriString = mUri.toString();
				mUriString = Uri.decode(mUriString);
				
				String pre1 = "file://" + SDCARD + File.separator;
				String pre2 = "file://" + SDCARD_MNT + File.separator;
				
				if( mUriString.startsWith(pre1) )
				{    
					thisLarge = Environment.getExternalStorageDirectory().getPath() + File.separator + mUriString.substring( pre1.length() );
				}
				else if( mUriString.startsWith(pre2) )
				{
					thisLarge = Environment.getExternalStorageDirectory().getPath() + File.separator + mUriString.substring( pre2.length() );
				}
				else
				{
					thisLarge = mUri.toString();
				}
			}	
		}
		return thisLarge;
	}
	
	@Override
	protected void onResume() 
	{
		super.onResume();
		MobclickAgent.onResume(this);
       
	}
	
	@Override
	protected void onPause()
	{
		super.onPause();
		MobclickAgent.onPause(this);
	}
}
