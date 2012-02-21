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
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;
import com.aragoncg.apps.xmpp.service.AndroidPushService;

public class RegisterActivity extends Activity {
	private static final int EXCEPTION = 0;
	private String userNameReg;
	private String nicknameReg;
	private String pass1Reg;
	private String pass2Reg;
	private boolean checked = false;
	private EditText pass1;
	private EditText pass2;
	private EditText nickname;
	private EditText userName;
	private Context myContext;
	private Thread registerThread;
	private Thread registerSecondThread;
	private String registerUrl;
	private String loginUrl;
	private int uidInt;
	private String uId;
	private ProgressDialog myProgressDialog;
	private Handler myHandler;
	private int appFlag = -1;
	ArrayList<Map<String, Object>> listActivity;
	private AirenaoActivity tempActivity;
	private LinearLayout layout;
	private TextView textView;
	private static Context ctx;
	CheckBox myCheckBox;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		ActivityManager.getInstance().addActivity(this);
		setContentView(R.layout.register_layout);
		ctx = this;
		textView = (TextView) findViewById(R.id.textview);
		String htmlLinkText = "我是超链接"
				+ "<a style=\"color:red;\" href='lianjie'>是否参加</a>";
		;
		textView.setText(Html.fromHtml(htmlLinkText));
		textView.setMovementMethod(LinkMovementMethod.getInstance());
		CharSequence text = textView.getText();
		if (text instanceof Spannable) {
			int end = text.length();
			Spannable sp = (Spannable) textView.getText();
			URLSpan[] urls = sp.getSpans(0, end, URLSpan.class);
			SpannableStringBuilder style = new SpannableStringBuilder(text);
			style.clearSpans();// should clear old spans
			// 循环把链接发过去
			for (URLSpan url : urls) {
				MyURLSpan myURLSpan = new MyURLSpan(url.getURL());
				style.setSpan(myURLSpan, sp.getSpanStart(url), sp
						.getSpanEnd(url), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
			}
			textView.setText(style);
		}

		myContext = getBaseContext();
		initData();
		getTheWedgit();

	}

	private static class MyURLSpan extends ClickableSpan {
		private String mUrl;

		MyURLSpan(String url) {
			mUrl = url;
		}

		@Override
		public void onClick(View widget) {
			widget.setBackgroundColor(Color.parseColor("#00000000"));
			Intent intent = new Intent(ctx, DetailAgreement.class);
			((Activity) ctx).startActivityForResult(intent, 40);
		}
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
				case Constants.POST_MESSAGE_SUCCESS:

					nicknameReg = (String) msg.getData().get(
							Constants.AIRENAO_NICKNAME);
					SharedPreferences mySharedPreferences = AirenaoUtills
							.getMySharedPreferences(myContext);
					Editor editor = mySharedPreferences.edit();
					editor.putString(Constants.AIRENAO_USER_NAME, userNameReg);
					editor.putString(Constants.AIRENAO_PASSWORD, pass2Reg);
					editor.putString(Constants.AIRENAO_USER_ID, uId);
					editor.putString(Constants.AIRENAO_NICKNAME, nicknameReg);
					editor.commit();
					Toast.makeText(RegisterActivity.this, nicknameReg,
							Toast.LENGTH_SHORT).show();
					break;

				case Constants.LOGIN_SUCCESS_CASE:
					/*
					 * 保存用户名和密码
					 */
					userNameReg = (String) msg.getData().get(
							Constants.AIRENAO_USER_NAME);
					pass2Reg = (String) msg.getData().get(
							Constants.AIRENAO_PASSWORD);
					uId = (String) msg.getData().get(Constants.AIRENAO_USER_ID);
					// uidInt = Integer.valueOf(uId);
					if (!"".equals(nicknameReg)) {
						SecondThread();
						registerSecondThread.start();
					}

					break;
				case EXCEPTION:
					Toast.makeText(RegisterActivity.this, "后台出现异常", 2000)
							.show();
					break;
				}

				super.handleMessage(msg);
			}

		};
		registerUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_REGISTER_URL;
		loginUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_LOGIN_URL;
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
				params.put("clientId", AndroidPushService
						.getClientId(RegisterActivity.this));
				// 后台注册返回的结果
				String result = new HttpHelper().performPost(registerUrl,
						userNameReg, pass1Reg, null, params,
						RegisterActivity.this);
				result = AirenaoUtills.linkResult(result);

				JSONObject jsonObject;
				try {
					jsonObject = new JSONObject(result)
							.getJSONObject(Constants.OUT_PUT);
					String status;
					String description;
					status = jsonObject.getString(Constants.STATUS);
					description = jsonObject.getString(Constants.DESCRIPTION);
					if ("ok".equals(status)) {
						jsonObject = jsonObject.getJSONObject("datasource");
						String UserId = jsonObject.getString("uid");
						Message message = new Message();
						message.what = 2;
						Bundle bundle = new Bundle();
						bundle.putString(Constants.AIRENAO_USER_NAME,
								userNameReg);
						bundle.putString(Constants.AIRENAO_PASSWORD, pass1Reg);
						bundle.putString(Constants.AIRENAO_USER_ID, UserId);
						message.setData(bundle);
						myHandler.sendMessage(message);
					} else {

						Message message = new Message();
						message.what = 1;
						Bundle bundle = new Bundle();
						bundle
								.putString(Constants.HENDLER_MESSAGE,
										description);
						message.setData(bundle);
						myHandler.sendMessage(message);
						myProgressDialog.cancel();
					}
				} catch (JSONException e) {

					e.printStackTrace();
				}
			}
		};
	}

	public void SecondThread() {
		registerSecondThread = new Thread() {

			@Override
			public void run() {
				String saveRegisterUrl = Constants.DOMAIN_NAME
						+ Constants.SUB_DOMAIN_SAVE_NICKNAME_RUL;
				Map<String, String> params = new HashMap<String, String>();
				params.put("uid", uId);
				params.put("nickname", nicknameReg);

				// 后台注册返回的结果
				String result = new HttpHelper().savePerformPost(
						saveRegisterUrl, params, RegisterActivity.this);
				result = AirenaoUtills.linkResult(result);

				JSONObject jsonObject;
				try {
					jsonObject = new JSONObject(result)
							.getJSONObject(Constants.OUT_PUT);
					String status;
					String description;
					status = jsonObject.getString(Constants.STATUS);
					description = jsonObject.getString(Constants.DESCRIPTION);
					if ("ok".equals(status)) {

						// myProgressDialog.setMessage(getString(R.string.rgVictoryMessage));
						// 注册成功后，登陆
						Map<String, String> params1 = new HashMap<String, String>();
						params1.put("username", userNameReg);
						params1.put("password", pass1Reg);
						params1.put("device_token", "");
						params1.put("clientId", AndroidPushService
								.getClientId(myContext));
						String loginResult = new HttpHelper().performPost(
								loginUrl, userNameReg, pass2Reg, null, params1,
								RegisterActivity.this);

						result = AirenaoUtills.linkResult(loginResult);
						jsonObject = new JSONObject(result)
								.getJSONObject("output");
						status = jsonObject.getString("status");
						description = jsonObject.getString("description");
						Log.e("status", status);
						if ("ok".equals(status)) {

							JSONObject jsonObject1 = jsonObject
									.getJSONObject("datasource");
							Message message = new Message();
							message.what = 3;
							Bundle bundle = new Bundle();
							bundle.putString(Constants.AIRENAO_NICKNAME,
									nicknameReg);
							bundle.putString(Constants.AIRENAO_USER_ID, uId);
							message.setData(bundle);
							myHandler.sendMessage(message);

							Intent intent = new Intent(RegisterActivity.this,
									MeetingListActivity.class);
							startActivity(intent);

							myProgressDialog.cancel();

						} else {

							Message message = new Message();
							message.what = 1;
							Bundle bundle = new Bundle();
							bundle.putString(Constants.HENDLER_MESSAGE,
									description);
							message.setData(bundle);
							myHandler.sendMessage(message);
							myProgressDialog.cancel();
						}
					}
				} catch (JSONException e) {
					myHandler.sendEmptyMessage(EXCEPTION);
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
		myCheckBox = (CheckBox) findViewById(R.id.CheckBox);
		Button saveBtn = (Button) findViewById(R.id.appect);
		// Button exitBtn = (Button) findViewById(R.id.exit);
		nickname = (EditText) findViewById(R.id.reg_nickname);
		// 获得内容或添加事件
		checked = myCheckBox.isChecked();

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

				// 校验用户名

				if (!userName.hasFocus()) {
					userNameReg = userName.getText().toString();
					if ("".equals(userNameReg)) {
						Toast.makeText(RegisterActivity.this,
								R.string.user_name_check, Toast.LENGTH_LONG)
								.show();
						return;
					}
				}

			}
		});

		// 校验昵称
		nickname.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {

				if (!nickname.hasFocus()) {
					nicknameReg = nickname.getText().toString();
					if ("".equals(nicknameReg)) {
						Toast.makeText(RegisterActivity.this,
								R.string.nickname_check, Toast.LENGTH_LONG)
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
				nicknameReg = nickname.getText().toString();
				if (nicknameReg == null || nicknameReg.equals("")) {
					Toast.makeText(RegisterActivity.this,
							R.string.nickname_check, Toast.LENGTH_SHORT).show();
					return;
				}
				pass1Reg = pass1.getText().toString();
				// pass2Reg = pass2.getText().toString();
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
					return;

				} else {
					AlertDialog aDig = new AlertDialog.Builder(
							RegisterActivity.this).setMessage(
							R.string.alert_message).create();
					aDig.show();
					return;
				}

			}
		});
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == 41) {
			myCheckBox.setChecked(true);
		}
	}

}
