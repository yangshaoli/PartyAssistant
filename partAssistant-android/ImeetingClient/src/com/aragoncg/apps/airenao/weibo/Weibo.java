/*
 * Copyright 2011 Sina.
 *
 * Licensed under the Apache License and Weibo License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.open.weibo.com
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.aragoncg.apps.airenao.weibo;


import java.io.IOException;
import java.net.MalformedURLException;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;



/**
 * Encapsulation main Weibo APIs, Include: 1. getRquestToken , 2. getAccessToken, 3. url request.
 * Used as a single instance class. Implements a weibo api as a synchronized way.
 *
 * @author  ZhangJie (zhangjie2@staff.sina.com.cn)
 */
public class Weibo {
	
	public static String SERVER = "http://api.t.sina.com.cn/";
	public static String URL_OAUTH_TOKEN = "http://api.t.sina.com.cn/oauth/request_token";
	public static String URL_AUTHORIZE = "http://api.t.sina.com.cn/oauth/authorize";
	public static String URL_ACCESS_TOKEN = "http://api.t.sina.com.cn/oauth/access_token";
	public static String URL_AUTHENTICATION = "http://api.t.sina.com.cn/oauth/authenticate";
	
	public static String APP_KEY = "999433557";
	public static String APP_SECRET = "8ebb477102459b3387da43686b21c963";
	
	private static Weibo mWeiboInstance = null;
	private AccessToken mAccessToken = null;
	private RequestToken mRequestToken = null;
	
	
	private Weibo(){
		Utility.setRequestHeader("Accept-Encoding","gzip");	
		Utility.setTokenObject(this.mRequestToken);
	}
	
	
	
	public static Weibo getInstance(){	
		if(mWeiboInstance == null){
			mWeiboInstance = new Weibo();
		}
		return mWeiboInstance;
	}
	
	//设置accessToken
	public void setAccessToken(AccessToken token){
		mAccessToken = token;
	}
	
	public AccessToken getAccessToken(){
		return this.mAccessToken;
	}
	
	public void setupConsumerConfig(String consumer_key, String consumer_secret){
		Weibo.APP_KEY = consumer_key;
		Weibo.APP_SECRET = consumer_secret;
	}
	
	public void setRequestToken(RequestToken token){
		this.mRequestToken = token;
	}
	
	//设置oauth_verifier
	public void addOauthverifier(String verifier){
		mRequestToken.setVerifier(verifier);
	}
	
	
    /**
     * Requst sina weibo open api by get or post
     *
     * @param url
     *            Openapi request URL.
     * @param params
     *            http get or post parameters . e.g. gettimeling?max=max_id&min=min_id
     *            max and max_id is a pair of key and value for params, also the min and min_id
     * @param httpMethod
     *            http verb: e.g. "GET", "POST", "DELETE" 
     * @throws IOException 
     * @throws MalformedURLException 
     * @throws WeiboException 
     */
	public String request(Context context, String url, WeiboParameters params, String httpMethod, AccessToken token) 
		throws WeiboException{
			Utility.setAuthorization(new RequestHeader());
			String rlt = Utility.openUrl(context, url, httpMethod, params, token);
			return rlt;
	}
	
	
	/**/
	public RequestToken getRequestToken(Context context, String key, String secret, String callback_url) 
		throws WeiboException{
		Utility.setAuthorization(new RequestTokenHeader());
		WeiboParameters postParams = new WeiboParameters();
		postParams.add("oauth_callback", callback_url);
		String rlt;
		rlt = Utility.openUrl(context, Weibo.URL_OAUTH_TOKEN, "POST", postParams, null);
		RequestToken request = new RequestToken(rlt);
		this.mRequestToken = request;
		return request;
	}
	
	
	public AccessToken generateAccessToken(Context context, RequestToken requestToken) 
		throws WeiboException{
		Utility.setAuthorization(new AccessTokenHeader());
		WeiboParameters authParam = new WeiboParameters();
		authParam.add("oauth_verifier", this.mRequestToken.getVerifier()/*"605835"*/);
		authParam.add("source", APP_KEY);
		String rlt = Utility.openUrl(context, Weibo.URL_ACCESS_TOKEN, "POST", authParam, this.mRequestToken);
		AccessToken accessToken = new AccessToken(rlt);
		this.mAccessToken = accessToken;
		return accessToken;
	}
	
	
	public AccessToken getXauthAccessToken(Context context, String app_key, String app_secret, String usrname, String password)
		throws WeiboException{
		Utility.setAuthorization(new XAuthHeader());
		WeiboParameters postParams = new WeiboParameters();
		postParams.add("x_auth_username", usrname);
		postParams.add("x_auth_password", password);
		postParams.add("oauth_consumer_key", APP_KEY);
		String rlt = Utility.openUrl(context, Weibo.URL_ACCESS_TOKEN, "POST", postParams, null);
		AccessToken accessToken = new AccessToken(rlt);
		this.mAccessToken = accessToken;
		return accessToken;
	}
    /**
     * Share text content or image to weibo .
     *
     */
	public boolean share2weibo(Activity activity, String accessToken, String tokenSecret, String content, String picPath) 
		throws WeiboException{
			if(TextUtils.isEmpty(accessToken)){
				throw new WeiboException("token can not be null!");
			}else if(TextUtils.isEmpty(tokenSecret)){
				throw new WeiboException("secret can not be null!");
			}
			
			if(TextUtils.isEmpty(content) && TextUtils.isEmpty(picPath)){
				throw new WeiboException("weibo content can not be null!");
			}
			Intent i = new Intent(activity, ShareActivity.class);
			i.putExtra(ShareActivity.EXTRA_ACCESS_TOKEN, accessToken);
			i.putExtra(ShareActivity.EXTRA_TOKEN_SECRET, tokenSecret);
			i.putExtra(ShareActivity.EXTRA_WEIBO_CONTENT, content);
			i.putExtra(ShareActivity.EXTRA_PIC_URI, picPath);
			activity.startActivity(i);	
			
			return true;
	}
	
	
	private void startActivitySignOn(Activity activity, String key, String secret){
		
	}
	
	
	private void startDialogAuth(Activity activity, String app_key, String app_secret){
		
		
	}
	
	public void authorizeCallBack(int requestCode, int resultCode , Intent data){
		
		
	}
	
}
