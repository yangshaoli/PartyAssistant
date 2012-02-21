package com.aragoncg.apps.airenao.activity;




import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.aragoncg.apps.airenao.R;
import com.mobclick.android.MobclickAgent;


/** 
 * 类说明：   自己实现WebView，供OAuth认证时打开Url 
 * 为什么要自己实现这样一个WebView？
 * 答：
 * 就是当用户认证是选择用UC、QQ浏览器第三方的浏览器进行用户认证时，当用户输入账号密码后点击授权按钮后不会跳转。
 * 只有用Android自带的浏览器才没有问题。但是大多数的用户都会用UC等第三方的浏览器了，这样导致认证不能正常进行。
 * 所以需要自己实现一个WebView
 * @author  @cuiky
 * 
 * @version 1.0
 */
public class WebViewActivity extends BaseActivity 
{
	private WebView webView;
	private boolean loginDirectly = false;
	private Intent intent = null;
	public static WebViewActivity webInstance = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_PROGRESS);
		setContentView(R.layout.web);
		webInstance = this;
		mContext = getApplicationContext();
		webView  = (WebView)findViewById(R.id.web);  
		WebSettings webSettings = webView.getSettings();
		webSettings.setJavaScriptEnabled(true);
        webSettings.setSaveFormData(true);
        webSettings.setSavePassword(true);
        webSettings.setSupportZoom(true);
        webSettings.setBuiltInZoomControls(true);
        webSettings.setCacheMode( WebSettings.LOAD_NO_CACHE );
        
        webView.setOnTouchListener(new OnTouchListener()
        {
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				webView.requestFocus();
				return false;
			}
        });
        
		intent = this.getIntent();
		if(!intent.equals(null))
		{
			Bundle b=intent.getExtras();
		    if(b!=null&&b.containsKey("url"))
		    {  
		    	loginDirectly = b.getBoolean("loginDirectly");
		    	webView.loadUrl(b.getString("url"));
		    	webView.setWebChromeClient(new WebChromeClient() {            
		    		  public void onProgressChanged(WebView view, int progress)               
		    		  {                   
		    			  setTitle("请等待，爱热闹加载中..." + progress + "%");
		    			  setProgress(progress * 100);

		    			  if (progress == 100)	setTitle(R.string.app_name);
		    		  }
		    	});
		    }
		}
	}
	
	@Override
	protected void onPause()
	{
		super.onPause();
		MobclickAgent.onPause(WebViewActivity.this);
	}

	@Override
	protected void onResume() 
	{
		super.onResume();
		MobclickAgent.onResume(WebViewActivity.this);
	}
	
    /**
     * 监听BACK键
     * @param keyCode
     * @param event
     * @return
     */
    public boolean onKeyDown(int keyCode, KeyEvent event) 
    {	
		if ( event.getKeyCode() == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0 )
		{
			finish();
			return true;
		}
		
		return super.onKeyDown(keyCode, event);
	}
}