package com.aragoncg.apps.airenao.activity;

import java.util.HashMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.DialogInterface.OnClickListener;
import android.database.sqlite.SQLiteDatabase;
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
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.ClientsData;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class DetailPeopleInfo extends Activity {
	private final static int INVATED_PEOPLE = 0;
	private final static int SIGNED_PEOPLE = 1;
	private final static int UNSIGNED_PEOPLE = 3;
	private final static int UNRESPONSED_PEOPLE = 2;
	private final static int SUCCESS = 0;
	private final static int FAIL = 1;
	private final static int EXCEPTION = 2;
	String SEND_SMS_ACTION = "sendSmsAction";
	private int peopleTag = -1;
	private TextView name;
	private TextView txtMessage;
	private TextView phoneNumber;
	private TextView levMsg;
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
	private int joinOrUnjoin = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		ActivityManager.getInstance().addActivity(this);
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
		message = (String) transIntent.getStringExtra(Constants.LEAVE_MESSAGE);
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
					unJoin.setVisibility(View.VISIBLE);
					join.setVisibility(View.VISIBLE);
					AlertDialog aDigError = new AlertDialog.Builder(
							DetailPeopleInfo.this).setMessage("数据错误，请先更新数据")
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
		phoneNumber = (TextView) findViewById(R.id.txtNumberDPI);
		txtMessage = (TextView) findViewById(R.id.txtMessageDetail);
		sms = (ImageButton) findViewById(R.id.btnSMSDetail);
		call = (ImageButton) findViewById(R.id.btnCallDetail);
		join = (Button) findViewById(R.id.btnJony);
		unJoin = (Button) findViewById(R.id.btnUnJony);
		levMsg = (TextView) findViewById(R.id.leveMsg);
	}

	public void setWedgit() {
		phoneNumber.setText(cValue);
		name.setText(frdName);
		txtMessage.setText(message);

		if (peopleTag == INVATED_PEOPLE) {
			unJoin.setVisibility(View.GONE);
			join.setVisibility(View.GONE);
			levMsg.setVisibility(View.GONE);
			txtMessage.setVisibility(View.GONE);
		}
		if (peopleTag == SIGNED_PEOPLE) {
			join.setVisibility(View.GONE);
		}

		if (peopleTag == UNRESPONSED_PEOPLE) {
			unJoin.setVisibility(View.GONE);

			levMsg.setVisibility(View.GONE);
			txtMessage.setVisibility(View.GONE);
		}
		if (peopleTag == UNSIGNED_PEOPLE) {
			unJoin.setVisibility(View.GONE);
		}

		sms.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					// 发送短信
					try {

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
					joinOrUnjoin = 1;
					progressDialog = ProgressDialog.show(DetailPeopleInfo.this,
							"", "报名中...", true, true);
					// 参加
					action = "apply";
					applayRunnable = getRunnable();
					myHandler.post(applayRunnable);
					join.setVisibility(View.GONE);
					unJoin.setVisibility(View.VISIBLE);
					return false;
				}
				return false;
			}

		});
		unJoin.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					joinOrUnjoin = 2;
					progressDialog = ProgressDialog.show(DetailPeopleInfo.this,
							"", "取消报名中...", true, true);
					// 不参加
					action = "";
					applayRunnable = getRunnable();
					myHandler.post(applayRunnable);
					unJoin.setVisibility(View.GONE);
					join.setVisibility(View.VISIBLE);
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
				String result = httpHelper.savePerformPost(applayUrl, map,
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
						
						//改变数据库中的数据
						if (joinOrUnjoin == 1) {//1是参加
							switch (peopleTag) {
							case INVATED_PEOPLE:
								break;
							case SIGNED_PEOPLE:
								break;
							case UNSIGNED_PEOPLE:
								if (insertDeletetDetailPeopleInfo(
										DbHelper.REFUSED_TABLE_NAME,
										DbHelper.APPLIED_TABLE_NAME,
										backendID)) {
									String[] files = {"unsignup","signup"};
									DbHelper.updataBySql(DbHelper.ACTIVITY_TABLE_NAME, files, partyIdValue);
									
									Toast.makeText(
											DetailPeopleInfo.this,
											"sucess",
											Toast.LENGTH_SHORT)
											.show();
									
									peopleTag = SIGNED_PEOPLE;
								}
								break;
							case UNRESPONSED_PEOPLE:
								if (insertDeletetDetailPeopleInfo(
										DbHelper.DONOTHING_TABLE_NAME,
										DbHelper.APPLIED_TABLE_NAME,
										backendID)) {
									String[] files = {"unjoin","signup"};
									DbHelper.updataBySql(DbHelper.ACTIVITY_TABLE_NAME, files, partyIdValue);
									Toast.makeText(
											DetailPeopleInfo.this,
											"sucess",
											Toast.LENGTH_SHORT)
											.show();
									peopleTag = SIGNED_PEOPLE;
								}
								break;
							}
						}
						if (joinOrUnjoin == 2) {//2是不参加
							switch (peopleTag) {
							case INVATED_PEOPLE:
								break;
							case SIGNED_PEOPLE:
								if (insertDeletetDetailPeopleInfo(
										DbHelper.APPLIED_TABLE_NAME,
										DbHelper.REFUSED_TABLE_NAME,
										backendID)) {
									String[] files = {"signup","unsignup"};
									DbHelper.updataBySql(DbHelper.ACTIVITY_TABLE_NAME, files, partyIdValue);
									Toast.makeText(
											DetailPeopleInfo.this,
											"sucess",
											Toast.LENGTH_SHORT)
											.show();
									peopleTag = UNSIGNED_PEOPLE;
								}
								break;
							case UNSIGNED_PEOPLE:
								break;
							case UNRESPONSED_PEOPLE:
								if (insertDeletetDetailPeopleInfo(
										DbHelper.DONOTHING_TABLE_NAME,
										DbHelper.REFUSED_TABLE_NAME,
										backendID)) {
									String[] files = {"unjoin","unsignup"};
									DbHelper.updataBySql(DbHelper.ACTIVITY_TABLE_NAME, files, partyIdValue);
									Toast.makeText(
											DetailPeopleInfo.this,
											"sucess",
											Toast.LENGTH_SHORT)
											.show();
									peopleTag = UNSIGNED_PEOPLE;
								}
								break;
							}
						}
						
						
						
						
						
						
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

	protected boolean insertDeletetDetailPeopleInfo(String sourceTable,
			String targetTable, String id) {
		ClientsData clientData = null;
		SQLiteDatabase db = null;
		boolean flag;
		try {
			db = DbHelper.openOrCreateDatabase();
			clientData = DbHelper.selectDetailPeopleInfo(db, sourceTable, id);
			if (clientData != null) {
				flag = false;
				flag = DbHelper.insertDetailPeopleInfo(db, targetTable,
						clientData);
				if (flag) {
					DbHelper.deleteDetailPeopleInfo(db, sourceTable, id);
					if (db != null) {
						db.close();
					}
					return true;
				}
			}
			if (db != null) {
				db.close();
			}
			return false;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}

}