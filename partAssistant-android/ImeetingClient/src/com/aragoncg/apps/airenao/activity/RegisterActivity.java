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
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class RegisterActivity extends Activity {
	private String userNameReg;
	private String pass1Reg;
	private String pass2Reg;
	private boolean checked = false;
	private EditText pass1;
	private EditText pass2;
	private EditText userName;
	private Context myContext;
	private Thread registerThread;
	private String registerUrl;
	private String loginUrl;
	private ProgressDialog myProgressDialog;
	private Handler myHandler;
	private int appFlag = -1;
	ArrayList<Map<String, Object>> listActivity;
	private AirenaoActivity tempActivity;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		AirenaoUtills.activityList.add(this);
		setContentView(R.layout.register_layout);
		myContext = getBaseContext();
		initData();

		getTheWedgit();

	}

	public void initData() {
		SharedPreferences mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(RegisterActivity.this);
		appFlag = mySharedPreferences.getInt(Constants.APP_USED_FLAG,
				Constants.APP_USED_FLAG_Z);

		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case Constants.POST_MESSAGE_CASE:
					String message = (String) msg.getData().get(
							Constants.HENDLER_MESSAGE);
					AlertDialog aDig = new AlertDialog.Builder(
							RegisterActivity.this).setMessage(message).create();
					aDig.show();
				case Constants.LOGIN_SUCCESS_CASE:
					/*
					 * 保存用户名和密码
					 */
					userNameReg = (String) msg.getData().get(
							Constants.AIRENAO_USER_NAME);
					String uId = (String) msg.getData().get(
							Constants.AIRENAO_USER_ID);
					SharedPreferences mySharedPreferences = AirenaoUtills
							.getMySharedPreferences(myContext);
					Editor editor = mySharedPreferences.edit();
					editor.putString(Constants.AIRENAO_USER_NAME, userNameReg);
					editor.putString(Constants.AIRENAO_USER_ID, uId);
					editor.commit();
				}
				super.handleMessage(msg);
			}

		};
		registerUrl = getString(R.string.registerUrl);
		loginUrl = getString(R.string.loginUrl);
	}

	/**
	 * 初始化线程
	 */
	public void initThread() {
		registerThread = new Thread() {

			@Override
			public void run() {
				Map<String, String> params = new HashMap<String, String>();
				params.put("username", userNameReg);
				params.put("password", pass1Reg);
				// 后台注册返回的结果
				String result = new HttpHelper().performPost(registerUrl,
						userNameReg, pass1Reg, null, params,
						RegisterActivity.this);
				result = AirenaoUtills.linkResult(result);

				JSONObject jsonObject;
				try {
					jsonObject = new JSONObject(result).getJSONObject("output");
					String status;
					String description;
					status = jsonObject.getString("status");
					description = jsonObject.getString("description");
					if ("ok".equals(status) && "ok".equals(description)) {
						// myProgressDialog.setMessage(getString(R.string.rgVictoryMessage));
						// 注册成功后，登陆
						String loginResult = new HttpHelper().performPost(
								loginUrl, userNameReg, pass1Reg, null, params,
								RegisterActivity.this);
						result = AirenaoUtills.linkResult(loginResult);
						jsonObject = new JSONObject(result)
								.getJSONObject("output");
						status = jsonObject.getString("status");
						description = jsonObject.getString("description");
						jsonObject =  jsonObject.getJSONObject("datasource");
						String UserId = jsonObject.getString("uid");
						if ("ok".equals(status) && "ok".equals(description)) {
							Message message = new Message();
							message.what = 2;
							Bundle bundle = new Bundle();
							bundle.putString(Constants.AIRENAO_USER_NAME,
									userNameReg);
							bundle.putString(Constants.AIRENAO_USER_ID,
									UserId);
							message.setData(bundle);
							myHandler.sendMessage(message);

							// 如果不是第一次启动
							if (appFlag == Constants.APP_USED_FLAG_O) {

								SQLiteDatabase db = DbHelper.openDatabase();
								tempActivity = DbHelper.select(db);
								listActivity = (ArrayList<Map<String, Object>>) DbHelper
										.selectActivitys(db);
								if (tempActivity != null) {
									Intent intent = new Intent(
											RegisterActivity.this,
											CreateActivity.class);
									intent.putExtra(Constants.TRANSFER_DATA,
											tempActivity);
									startActivity(intent);

								} else {

									if (listActivity.size() > 0) {
										Intent intent = new Intent(
												RegisterActivity.this,
												MeetingListActivity.class);
										startActivity(intent);
									} else {
										Intent intent = new Intent(
												RegisterActivity.this,
												CreateActivity.class);
										startActivity(intent);
									}
								}
							}
							// 如果第一启动就进入创建活动
							if (appFlag == Constants.APP_USED_FLAG_Z) {
								Intent intent = new Intent(
										RegisterActivity.this,
										CreateActivity.class);
								startActivity(intent);
							}

							myProgressDialog.cancel();
						}
					} else {

						Message message = new Message();
						message.what = 1;
						Bundle bundle = new Bundle();
						bundle.putString(Constants.HENDLER_MESSAGE, description);
						message.setData(bundle);
						myHandler.sendMessage(message);
						// registerThread.stop();
						myProgressDialog.cancel();
					}
				} catch (JSONException e) {

					e.printStackTrace();
				}

			}
		};
	}

	/**
	 * 
	 * Method:getTheWedgit: TODO(获得所有的组件并添加事件)
	 * 
	 * @author cuikuangye void
	 * @Date 2011 2011-11-7 am 10:45:46
	 * @throws
	 * 
	 */
	public void getTheWedgit() {
		pass1 = (EditText) findViewById(R.id.reg_pass1);
		pass2 = (EditText) findViewById(R.id.reg_pass2);
		userName = (EditText) findViewById(R.id.reg_user_name);
		CheckBox myCheckBox = (CheckBox) findViewById(R.id.CheckBox);
		Button saveBtn = (Button) findViewById(R.id.appect);
		Button exitBtn = (Button) findViewById(R.id.exit);

		// 获得内容或添加事件
		checked = myCheckBox.isChecked();
		// 校验用户名
		userName.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {

				if (!userName.hasFocus()) {
					userNameReg = userName.getText().toString();
					// 用户名校验
					/*
					 * boolean isDigital =
					 * AirenaoUtills.matchString(AirenaoUtills.regDigital,
					 * userNameReg); boolean isEmail =
					 * AirenaoUtills.matchString(AirenaoUtills.regEmail,
					 * userNameReg); if(!isEmail && !isDigital){
					 * Toast.makeText(RegisterActivity.this, R., duration) }
					 */
					if ("".equals(userNameReg)) {
						Toast.makeText(RegisterActivity.this,
								R.string.user_name_check, Toast.LENGTH_LONG)
								.show();
						return;
					}
				}

			}
		});

		saveBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				userNameReg = userName.getText().toString();
				if (userNameReg == null || userNameReg.equals("")) {
					Toast.makeText(RegisterActivity.this,
							R.string.user_name_check, Toast.LENGTH_SHORT)
							.show();
					return;
				}
				pass1Reg = pass1.getText().toString();
				pass2Reg = pass2.getText().toString();
				if (pass1Reg.length() < 6) {
					Toast.makeText(RegisterActivity.this, R.string.pass_tip1,
							Toast.LENGTH_SHORT).show();
					return;
				}
				if ("".equals(pass1Reg)) {
					Toast.makeText(RegisterActivity.this, R.string.pass_tip,
							Toast.LENGTH_SHORT).show();
					return;
				}
				if ("".equals(pass2Reg)) {
					Toast.makeText(RegisterActivity.this, R.string.pass_tip2,
							Toast.LENGTH_SHORT).show();
					return;
				}
				if (!pass1Reg.equals(pass2Reg)) {
					Toast.makeText(RegisterActivity.this, R.string.pass_tip3,
							Toast.LENGTH_LONG).show();
					return;
				}

				// 用户名有了，密码有了，就可以自动登录了
				if (checked) {

					/**
					 * 
					 * 开启线程去登录
					 */
					myProgressDialog = AirenaoUtills.generateProgressingDialog(
							RegisterActivity.this, "",
							getString(R.string.rgMessage));
					myProgressDialog.setOwnerActivity(RegisterActivity.this);
					myProgressDialog.show();
					initThread();
					registerThread.start();

				} else {
					AlertDialog aDig = new AlertDialog.Builder(
							RegisterActivity.this).setMessage(
							R.string.alert_message).create();
					aDig.show();
					return;
				}

			}
		});
		exitBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				userName.setText("");
				pass1.setText("");
				pass2.setText("");
				checked = true;

			}
		});

	}

}
