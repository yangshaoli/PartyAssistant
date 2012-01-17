package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.DialogInterface.OnClickListener;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.gsm.SmsManager;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class DetailPeopleInfo extends Activity {
	private final static int INVATED_PEOPLE = 0;
	private final static int SIGNED_PEOPLE = 1;
	private final static int UNSIGNED_PEOPLE = 2;
	private final static int UNRESPONSED_PEOPLE = 3;
	private final static int SUCCESS = 0;
	private final static int FAIL = 1;
	private final static int EXCEPTION = 2;
	String SEND_SMS_ACTION = "sendSmsAction";
	private int peopleTag = -1;
	private TextView name;
	private TextView txtMessage;
	private TextView phoneNumber;
	private ImageButton sms;
	private ImageButton call;
	private Button join;
	private Button unJoin;
	private String frdName;
	private String cValue;
	private String partyIdValue;
	private String message;
	private Intent transIntent;
	private String contenMessage;
	private String action;
	private String backendID;
	private String applayUrl;
	private Runnable applayRunnable;

	private BroadcastReceiver sendMessageB;
	private PendingIntent sentPI;
	private Handler myHandler;
	private ProgressDialog progressDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		AirenaoUtills.activityList.add(this);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.detail_people_info);
		initWedgit();
		initData();
		setWedgit();

	}

	public void initData() {
		SharedPreferences spf = AirenaoUtills
				.getMySharedPreferences(DetailPeopleInfo.this);
		peopleTag = spf.getInt(Constants.PEOPLE_TAG, -1);
		transIntent = getIntent();
		frdName = (String) transIntent.getStringExtra(Constants.PEOPLE_NAME);
		cValue = (String) transIntent.getStringExtra(Constants.PEOPLE_CONTACTS);
		partyIdValue = (String) transIntent.getStringExtra(Constants.PARTY_ID);
		backendID = (String) transIntent.getStringExtra(Constants.BACK_END_ID);
		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case SUCCESS:
					AlertDialog aDig = new AlertDialog.Builder(
							DetailPeopleInfo.this).setMessage("成功")
							.setPositiveButton("OK", new OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {

								}
							}).create();
					aDig.show();
					break;
				case FAIL:
					AlertDialog aDigFail = new AlertDialog.Builder(
							DetailPeopleInfo.this).setMessage("失败")
							.setPositiveButton("OK", new OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {

								}
							}).create();
					aDigFail.show();
					break;
				case EXCEPTION:
					AlertDialog aDigError = new AlertDialog.Builder(
							DetailPeopleInfo.this).setMessage("系统错误,请重试")
							.setPositiveButton("OK", new OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {

								}
							}).create();
					aDigError.show();
					break;

				}
				super.handleMessage(msg);
			}

		};
	}

	public void initWedgit() {
		applayUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_APPLAY_URL;
		name = (TextView) findViewById(R.id.txtName);
		phoneNumber = (TextView)findViewById(R.id.txtNumberDPI);
		txtMessage = (TextView) findViewById(R.id.txtMessageDetail);
		sms = (ImageButton) findViewById(R.id.btnSMSDetail);
		call = (ImageButton) findViewById(R.id.btnCallDetail);
		join = (Button) findViewById(R.id.btnJony);
		unJoin = (Button) findViewById(R.id.btnUnJony);
	}

	public void setWedgit() {
		phoneNumber.setText(cValue);
		name.setText(frdName);
		txtMessage.setText(message);

		if (peopleTag == INVATED_PEOPLE) {

		}
		if (peopleTag == SIGNED_PEOPLE) {
			join.setVisibility(View.GONE);
		}
		if (peopleTag == UNSIGNED_PEOPLE) {
			unJoin.setVisibility(View.GONE);
		}
		if (peopleTag == UNRESPONSED_PEOPLE) {
		}

		sms.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					// 发送短信
					try {
						/*
						 * SmsManager mySmsManager = SmsManager.getDefault(); //
						 * 如果短信内容超过70个字符 将这条短信拆成多条短信发送出去 if
						 * (contenMessage.length() > 70) { ArrayList<String>
						 * msgs = mySmsManager .divideMessage(contenMessage);
						 * for (String msg : msgs) {
						 * mySmsManager.sendTextMessage(cValue, null, msg,
						 * sentPI, null); } } else {
						 * mySmsManager.sendTextMessage(cValue, null,
						 * contenMessage, sentPI, null); }
						 */
						Intent intent = new Intent(Intent.ACTION_SENDTO, Uri
								.fromParts("sms", cValue, null));
						intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
						startActivity(intent);
					} catch (Exception e) {
						showOkOrNotDialog("短信发送失败", false);
					}
				}
				return false;
			}
		});
		call.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					Intent intent = new Intent(Intent.ACTION_CALL, Uri
							.fromParts("tel", cValue, null));
					intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
					startActivity(intent);
				}
				return false;
			}
		});
		join.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					progressDialog = ProgressDialog.show(DetailPeopleInfo.this,
							"", "报名中...", true, true);
					// 参加
					action = "apply";
					applayRunnable = getRunnable();
					myHandler.post(applayRunnable);
					return false;
				}
				return false;
			}

		});
		unJoin.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					progressDialog = ProgressDialog.show(DetailPeopleInfo.this,
							"", "取消报名中...", true, true);
					// 不参加
					action = "";
					applayRunnable = getRunnable();
					myHandler.post(applayRunnable);
					return false;
				}
				return false;
			}
		});
	}

	public Runnable getRunnable() {
		return new Runnable() {
			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				HashMap<String, String> map = new HashMap<String, String>();
				map.put("cpID", backendID);
				map.put("cpAction", action);
				String result = httpHelper.performPost(applayUrl, map,
						DetailPeopleInfo.this);
				result = AirenaoUtills.linkResult(result);
				String status;
				String description;
				try {
					JSONObject resultObject = new JSONObject(result)
							.getJSONObject(Constants.OUT_PUT);
					status = resultObject.getString(Constants.STATUS);
					description = resultObject.getString(Constants.DESCRIPTION);
					progressDialog.cancel();
					// message.what = APPLAY_RESULT;
					if ("ok".equals(status)) {
						myHandler.sendEmptyMessage(SUCCESS);
					} else {
						myHandler.sendEmptyMessage(FAIL);
					}

				} catch (JSONException e) {
					progressDialog.cancel();
					myHandler.sendEmptyMessage(EXCEPTION);
				}

			}

		};

	}

	public void showOkOrNotDialog(String message, final boolean ok) {
		/*
		 * initThreadSaveMessage(); myHandler.post(threadSaveMessage);
		 */
		AlertDialog aDig = new AlertDialog.Builder(DetailPeopleInfo.this)
				.setMessage(message)
				.setPositiveButton(R.string.btn_ok, new OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						if (ok) {

						} else {
							// 还在本页
						}

					}
				}).create();
		aDig.show();

	}

	@Override
	protected void onResume() {
		sendMessageB = new BroadcastReceiver() {

			@Override
			public void onReceive(Context context, Intent intent) {
				// 判断短信是否发送成功

				switch (getResultCode()) {
				case Activity.RESULT_OK:
					Toast.makeText(DetailPeopleInfo.this, "短信发送成功",
							Toast.LENGTH_SHORT).show();
					return;
				default:
					Toast.makeText(DetailPeopleInfo.this, "短信发送失败",
							Toast.LENGTH_SHORT).show();
					break;
				}
			}
		};

		// 注册广播 发送消息

		registerReceiver(sendMessageB, new IntentFilter(SEND_SMS_ACTION));
		// create the sentIntent parameter
		Intent sentIntent = new Intent(SEND_SMS_ACTION);
		sentPI = PendingIntent.getBroadcast(DetailPeopleInfo.this, 0,
				sentIntent, 0);

		super.onResume();
	}

	@Override
	protected void onPause() {
		if (sendMessageB != null) {
			unregisterReceiver(sendMessageB);
		}

		super.onDestroy();
	}

}
