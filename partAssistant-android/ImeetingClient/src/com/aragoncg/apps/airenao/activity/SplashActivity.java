package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.Window;
import android.view.WindowManager;
import android.widget.SlidingDrawer;
import android.widget.Toast;

public class SplashActivity extends Activity {
	/** Called when the activity is first created. */

	private String userName = "";
	private String passWord = "";
	boolean isFinished = false;
	private AirenaoActivity tempActivity;
	private ArrayList<Map<String, Object>> activityList;
	private boolean netLinking = true;
	private boolean sdcardUse = true;

	private static final int MSG_ID_CLOSE = 2;
	private static final int MSG_ID_LOG = 1;
	private static final int MSG_ID_LOG_CREATE = 3;
	private static final int MSG_ID_LOG_LIST = 4;
	private static final int MSG_ID_LOG_CREATE_NULL = 5;
	private static final int MSG_ID_NET_DOWN = 6;
	private static final int MSG_ID_SDCARD_DOWN = 7;
	private static final int MSG_ID_NET_UP = 8;

	Handler mHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case MSG_ID_LOG:
				// 登陆失败

				AlertDialog aDig = new AlertDialog.Builder(SplashActivity.this)
						.setPositiveButton(R.string.btn_ok,
								new OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										Intent intent = new Intent();
										intent.setClass(SplashActivity.this,
												LoginActivity.class);
										startActivity(intent);
										finish();
									}
								}).setMessage(getString(R.string.loginFalse))
						.create();

				aDig.show();

				break;
			case MSG_ID_CLOSE:
				closeMe();
				break;
			case MSG_ID_LOG_CREATE:
				finish();
				AirenaoActivity oneParty = (AirenaoActivity) msg.getData()
						.getSerializable(Constants.ONE_PARTY);
				Intent intent = new Intent(SplashActivity.this,
						CreateActivity.class);
				intent.putExtra(Constants.TRANSFER_DATA, oneParty);
				startActivity(intent);
				break;
			case MSG_ID_LOG_LIST:
				finish();
				Intent intentTO = new Intent(SplashActivity.this,
						MeetingListActivity.class);
				intentTO.putExtra(Constants.NEED_REFRESH, false);
				startActivity(intentTO);
				break;
			case MSG_ID_LOG_CREATE_NULL:
				finish();
				Intent intentTh = new Intent(SplashActivity.this,

				MeetingListActivity.class);
				startActivity(intentTh);
				break;
			case MSG_ID_NET_DOWN:
				// show dialog
				AlertDialog netDig = new AlertDialog.Builder(
						SplashActivity.this)
						.setTitle(getString(R.string.netdown))
						.setPositiveButton(R.string.btn_ok,
								new OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										Intent intent = new Intent(
												"android.settings.WIRELESS_SETTINGS");
										startActivity(intent);
										finish();
									}
								}).setMessage(getString(R.string.netdownTip))
						.create();

				netDig.show();
				break;
			case MSG_ID_NET_UP:
				// 检测sdcard
				sdcardUse = AirenaoUtills.checkSDCard();
				if (!sdcardUse) {
					//mHandler.sendEmptyMessageDelayed(MSG_ID_SDCARD_DOWN, 3000);
				} else {

					SharedPreferences mySharedPreferences = AirenaoUtills
							.getMySharedPreferences(SplashActivity.this);
					userName = mySharedPreferences.getString(
							Constants.AIRENAO_USER_NAME, null);
					passWord = mySharedPreferences.getString(
							Constants.AIRENAO_PASSWORD, null);
					if ("".equals(userName) || userName == null
							|| "".equals(passWord) || passWord == null) {
						mHandler.sendEmptyMessageDelayed(MSG_ID_CLOSE, 3000);
					} else {
						//
						login();
					}
				}
				break;
			case MSG_ID_SDCARD_DOWN:
				// show dialog
				AlertDialog sdcardDig = new AlertDialog.Builder(
						SplashActivity.this)
						.setPositiveButton(R.string.btn_ok,
								new OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										finish();
									}
								}).setMessage(getString(R.string.chkSdcard))
						.create();

				sdcardDig.show();
				break;

			}
			super.handleMessage(msg);
		}

	};

	@Override
	public void onBackPressed() {
		mHandler.removeMessages(MSG_ID_CLOSE);
		super.onBackPressed();
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.splash);
		createDb();
		AirenaoUtills.activityList.add(this);
		// 检测网络
		netLinking = AirenaoUtills.isNetWorkExist(SplashActivity.this);
		if (!netLinking) {
			mHandler.sendEmptyMessageDelayed(MSG_ID_NET_DOWN, 3000);
		} else {
			mHandler.sendEmptyMessageDelayed(MSG_ID_NET_UP, 3000);
		}

	}

	public void createDb() {
		DbHelper.getInstance(SplashActivity.this);

	}

	@Override
	protected void onStart() {

		super.onStart();
	}

	public void login() {
		// 初始化登录线程
		final String loginUrl = getString(R.string.loginUrl);
		Runnable loginThread = new Runnable() {

			@Override
			public void run() {
				Map<String, String> params = new HashMap<String, String>();
				params.put("username", userName);
				params.put("password", passWord);
				params.put("device_token", "");
				String loginResult = new HttpHelper().performPost(loginUrl,
						userName, passWord, null, params, SplashActivity.this);
				String result = "";
				result = AirenaoUtills.linkResult(loginResult);
				JSONObject jsonObject;
				try {
					jsonObject = new JSONObject(result).getJSONObject("output");
					String status = jsonObject.getString("status");
					String description = jsonObject.getString("description");

					if ("ok".equals(status)) {

						String uId = jsonObject.getJSONObject("datasource")
								.getString("uid");
						SQLiteDatabase db = DbHelper.openOrCreateDatabase();
						tempActivity = DbHelper.select(db);
						activityList = (ArrayList<Map<String, Object>>) DbHelper
								.selectActivitys(db);
						if (tempActivity != null) {

							Message message = new Message();
							message.what = MSG_ID_LOG_CREATE;
							Bundle bundle = new Bundle();
							bundle.putSerializable(Constants.ONE_PARTY,
									tempActivity);
							message.setData(bundle);
							mHandler.sendMessageDelayed(message, 0);

						} else {

							if (activityList.size() > 0) {
								mHandler.sendEmptyMessageDelayed(
										MSG_ID_LOG_LIST, 0);

							} else {
								mHandler.sendEmptyMessageDelayed(
										MSG_ID_LOG_CREATE_NULL, 0);
							}

						}

						// myProgressDialog.cancel();
					} else {
						Message message = new Message();
						message.what = MSG_ID_LOG;
						Bundle bundle = new Bundle();
						bundle.putString(Constants.HENDLER_MESSAGE, description);
						message.setData(bundle);
						mHandler.sendMessage(message);
						// myProgressDialog.cancel();
					}
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

			}

		};
		loginThread.run();
	}

	private void closeMe() {
		if (!isFinished) {
			finish();
			Intent intent = new Intent(this, RegisterActivity.class);
			startActivity(intent);
			isFinished = true;
		}
	}

}