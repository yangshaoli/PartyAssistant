package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class LoginActivity extends Activity {
	private EditText userNameText;
	private EditText passWordText;
	private Button loginBtn;
	private Button findBackBtn;
	private String userName;
	private String passWord;
	private Thread loginThread;
	private String loginUrl;
	private AirenaoActivity tempActivity;
	private Handler myHandler;
	private ProgressDialog myProgressDialog;
	private ArrayList<Map<String, Object>> activityList;
	
	private Context myContext;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);
		AirenaoUtills.activityList.add(this);
		setContentView(R.layout.login);
		myContext = this.getBaseContext();
		initView();
		initData();
	}

	public void initView() {
		userNameText = (EditText) findViewById(R.id.username_edit);
		passWordText = (EditText) findViewById(R.id.password_edit);
		loginBtn = (Button) findViewById(R.id.signin_button);
		findBackBtn = (Button) findViewById(R.id.find_back);
		loginBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				myProgressDialog = AirenaoUtills.generateProgressingDialog(LoginActivity.this,
						"",getString(R.string.logining));
				myProgressDialog.setOwnerActivity(LoginActivity.this);
				myProgressDialog.show();
				boolean isEmail;
				userName = userNameText.getText().toString();
				passWord = passWordText.getText().toString();
				if (userName == null || "".equals(userName)) {
					Toast.makeText(LoginActivity.this,
							R.string.user_name_check, Toast.LENGTH_LONG).show();
					return;
				}
				if (userName == null || "".equals(userName)) {
					Toast.makeText(LoginActivity.this, R.string.pass_tip,
							Toast.LENGTH_LONG).show();
					return;
				}
				isEmail = AirenaoUtills.matchString(AirenaoUtills.regEmail,
						userName);
				/*if (!isEmail) {
					new AlertDialog.Builder(LoginActivity.this)
							.setIcon(R.drawable.alert_dialog_icon)
							.setTitle(R.string.error_email)
							.setNegativeButton(R.string.btn_cancle,
									new DialogInterface.OnClickListener() {
										public void onClick(
												DialogInterface dialog,
												int whichButton) {

										}
									}).create();
					return;
				}*/
			
				// 启动线程登录
				loginThread.start();
				return;
			}
		});

		findBackBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				LayoutInflater factory = LayoutInflater
						.from(LoginActivity.this);
				final View textEntryView = factory.inflate(
						R.layout.alert_dialog_text_entry, null);
				new AlertDialog.Builder(LoginActivity.this)
						.setIcon(R.drawable.alert_dialog_icon)
						.setTitle(R.string.find_lable_message)
						.setView(textEntryView)

						.setPositiveButton(R.string.btn_ok,
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog,
											int whichButton) {
										/* 启动线程去发送 */
										// 如果是短信
										// 如果是email

									}
								})
						.setNegativeButton(R.string.btn_cancle,
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog,
											int whichButton) {

									}
								}).create().show();

			}
		});
	}

	public void initData() {
		
		//初始化handler
		myHandler = new Handler(){

			@Override
			public void handleMessage(Message msg) {
				switch(msg.what){
					case Constants.POST_MESSAGE_CASE:
						myProgressDialog.cancel();
						String message = (String) msg.getData().get(Constants.HENDLER_MESSAGE);
						AlertDialog aDig = new AlertDialog.Builder(
								LoginActivity.this).setMessage(
										message).create();
						aDig.show();
					case Constants.LOGIN_SUCCESS_CASE:
					/*
					 * 保存用户名和密码
					 */ myProgressDialog.cancel();
						userName = (String) msg.getData().get(Constants.AIRENAO_USER_NAME);
						String uId = (String) msg.getData().get(Constants.AIRENAO_USER_ID);
						SharedPreferences mySharedPreferences = AirenaoUtills
								.getMySharedPreferences(myContext);
						Editor editor = mySharedPreferences.edit();
						editor.putString(Constants.AIRENAO_USER_NAME, userName);
						editor.putString(Constants.AIRENAO_USER_ID, uId);
						editor.commit();
				}
				super.handleMessage(msg);
			}
			
		};
		
		//初始化登录线程
		loginUrl = getString(R.string.loginUrl);
		loginThread = new Thread() {

			@Override
			public void run() {
				Map<String, String> params = new HashMap<String, String>();
				params.put("username", userName);
				params.put("password", passWord);
				String loginResult = new HttpHelper().performPost(loginUrl,
						userName, passWord, null, params, LoginActivity.this);
				String result = "";
				result = AirenaoUtills.linkResult(loginResult);
				JSONObject jsonObject;
				try {
					jsonObject = new JSONObject(result).getJSONObject("output");
					String status = jsonObject.getString("status");
					String description = jsonObject.getString("description");
					
					if ("ok".equals(status)) {
						String uId = jsonObject.getJSONObject("datasource").getString("uid");
						Message message = new Message();
						message.what = 2;
						Bundle bundle = new Bundle();
						bundle.putString(Constants.AIRENAO_USER_NAME, userName);
						bundle.putString(Constants.AIRENAO_USER_ID, uId);
						message.setData(bundle);
						myHandler.sendMessage(message);
						
						SQLiteDatabase db = DbHelper.openOrCreateDatabase();
						tempActivity = DbHelper.select(db);
						activityList = (ArrayList<Map<String, Object>>) DbHelper.selectActivitys(db);
						if (tempActivity != null) {
							Intent intent = new Intent(LoginActivity.this,
									CreateActivity.class);
							intent.putExtra(Constants.TRANSFER_DATA,
									tempActivity);
							startActivity(intent);

						} else {
							if(activityList.size()>0){
								Intent intent = new Intent(LoginActivity.this,
										MeetingListActivity.class);
								startActivity(intent);
							}else{
								Intent intent = new Intent(LoginActivity.this,
										CreateActivity.class);
								startActivity(intent);
							}
							
						}
						
						//myProgressDialog.cancel();
					}else{
						Message message = new Message();
						message.what = 1;
						Bundle bundle = new Bundle();
						bundle.putString(Constants.HENDLER_MESSAGE, description);
						message.setData(bundle);
						myHandler.sendMessage(message);
						//myProgressDialog.cancel();
					}
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			}

		};
	}
}
