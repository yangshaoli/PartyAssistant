package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.gsm.SmsManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class EditActivity extends Activity {
	private String userName;
	private String userId;
	private AirenaoActivity activityFromDetail;
	private boolean fromDetail;
	private AirenaoActivity activityDb;
	private String link;
	private String partyId = "";
	private String sendWithOwn = "1"; // 1表示用自己的手机发送 0表示用服务器

	private TextView userTitle;
	private LinearLayout userLayout;
	private EditText edtActivityDes;
	private Button btnOver;
	private Runnable editSaveTask;
	private Runnable getClientTask;
	private Handler myHandler;
	private JSONArray clientMap;
	private ProgressDialog progressDialog;
	private ArrayList<String> tempContactNumbers = new ArrayList<String>();

	private static final int SUCCESS = 4;
	private static final int FAIL = 3;
	private static final int EXCEPTION = 2;
	private static final int MSG_ID_SUCC = 5;
	private static final int MSG_ID_FAIL = 6;
	private static final int MSG_ID_SEND = 7;
	
	private static final int MENU_FALG_SET_WAY = 0;
	private static final int SEND_WAY_ONE = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		AirenaoUtills.activityList.add(this);
		setContentView(R.layout.edit_activity_layout);
		initWedgit();
		initDataFromOther();
		setWidget();
		initRunable();
		initMyHandler();

	}

	public void initMyHandler() {
		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case SUCCESS:

					break;
				case FAIL:
					Toast.makeText(EditActivity.this, "保存失败",
							Toast.LENGTH_SHORT);
					break;
				case EXCEPTION:
					Toast.makeText(EditActivity.this, "出现异常",
							Toast.LENGTH_SHORT);
					break;
				case MSG_ID_FAIL:

					Toast.makeText(EditActivity.this, (String) msg.getData()
							.get(MSG_ID_FAIL + ""), Toast.LENGTH_SHORT);
					break;
				case MSG_ID_SUCC:

					/*
					 * Intent mIntent = new Intent(EditActivity.this,
					 * SendAirenaoActivity.class);
					 * activityFromDetail.setClients(clientMap);
					 * mIntent.putExtra("sendWithClients", activityFromDetail);
					 * mIntent.putExtra("sendWithClientsTag", true);
					 * mIntent.putExtra("mode", -2);// -2发送短信
					 * startActivity(mIntent);
					 */
					break;
				case MSG_ID_SEND:
					// 发送短信
					if ("1".equals(sendWithOwn)) {
						try {
							sendSMSorEmail();
						} catch (Exception e) {
							Toast.makeText(EditActivity.this, "短信发送失败,是否重新发送？",
									2000).show();
						}
						Toast.makeText(EditActivity.this, "发送成功", 2000).show();
					}
					break;
				}

				super.handleMessage(msg);
			}

		};
	}

	/**
	 * 发送信息
	 * 
	 * @param sendSms
	 */
	@SuppressWarnings("deprecation")
	public void sendSMSorEmail() {

		// 用自己手机发送
		for (int i = 0; i < tempContactNumbers.size(); i++) {
			try {
				SmsManager mySmsManager = SmsManager.getDefault();
				// 如果短信内容超过70个字符 将这条短信拆成多条短信发送出去
				if ((edtActivityDes.getText().toString() + link).length() > 70) {
					ArrayList<String> msgs = mySmsManager
							.divideMessage((edtActivityDes.getText().toString() + link));
					for (String msg : msgs) {
						mySmsManager.sendTextMessage(tempContactNumbers.get(i),
								null, msg, null, null);
					}
				} else {
					mySmsManager.sendTextMessage(tempContactNumbers.get(i),
							null, (edtActivityDes.getText().toString() + link),
							null, null);
				}

			} catch (Exception e) {
				Toast.makeText(EditActivity.this, "短信发送失败,是否重新发送？", 2000)
						.show();
			}
		}
	}

	public void initRunable() {
		editSaveTask = new Runnable() {

			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				String url = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_EDIT_URL;
				HashMap<String, String> params = new HashMap<String, String>();
				partyId = activityFromDetail.getId();
				params.put("partyID", partyId);
				params.put(Constants.DESCRIPTION, edtActivityDes.getText()
						.toString());
				params.put("uID", userId);
				// myAirenaoActivity
				String result = httpHelper.performPost(url, params,
						EditActivity.this);
				result = AirenaoUtills.linkResult(result);
				try {
					JSONObject output = new JSONObject(result)
							.getJSONObject(Constants.OUT_PUT);
					String status = output.getString(Constants.STATUS);
					String description = output
							.getString(Constants.DESCRIPTION);
					if ("ok".equals(status)) {
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(SUCCESS + "", description);
						message.what = SUCCESS;
						message.setData(bundle);
						myHandler.sendMessage(message);
					} else {
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(FAIL + "", description);
						message.what = FAIL;
						message.setData(bundle);
						myHandler.sendMessage(message);
					}

				} catch (JSONException e) {
					// result
					Message message = new Message();
					Bundle bundle = new Bundle();
					bundle.putString(EXCEPTION + "", result);
					message.what = EXCEPTION;
					message.setData(bundle);
					myHandler.sendMessage(message);
				}
			}
		};

		getClientTask = new Runnable() {

			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				String url = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_GET_PEOPLE_INFO_URL;;
				url = url + activityFromDetail.getId() + "/" + "all/";
				// myAirenaoActivity
				String result = httpHelper.performGet(url, EditActivity.this);
				result = AirenaoUtills.linkResult(result);

				try {
					JSONObject output = new JSONObject(result)
							.getJSONObject(Constants.OUT_PUT);
					String status = output.getString(Constants.STATUS);
					String description = output
							.getString(Constants.DESCRIPTION);
					if ("ok".equals(status)) {

						clientMap = new JSONArray();
						JSONObject dataSource = output
								.getJSONObject("datasource");
						// '_isApplyTips':BOOL,
						// '_isSendBySelf':BOOL
						// msgType = dataSource.getString("msgType");
						JSONArray receiverArray = dataSource
								.getJSONArray("clientList");
						JSONObject client;
						tempContactNumbers.clear();
						for (int i = 0; i < receiverArray.length(); i++) {
							client = new JSONObject();
							tempContactNumbers.add(receiverArray.getJSONObject(
									i).getString("cValue"));
							client.put("cName", receiverArray.getJSONObject(i)
									.getString("cName"));
							client.put("cValue", receiverArray.getJSONObject(i)
									.getString("cValue"));
							clientMap.put(client);

						}

						String reSendUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_PARTY_RESEND_URL;
						HashMap<String, String> params = new HashMap<String, String>();
						params.put("receivers", clientMap.toString());
						params.put(Constants.CONTENT, edtActivityDes.getText()
								.toString());
						params.put("_issendbyself", sendWithOwn);
						params.put("uID", userId);
						params.put("addressType", "android");
						params.put("partyID", partyId);
						String respond = httpHelper.savePerformPost(reSendUrl,
								params, EditActivity.this);
						respond = AirenaoUtills.linkResult(respond);
						output = new JSONObject(respond)
								.getJSONObject(Constants.OUT_PUT);
						status = output.getString(Constants.STATUS);
						if ("ok".equals(status)) {
							link = output.getJSONObject(Constants.DATA_SOURCE)
									.getString("applyURL");
							Message message = new Message();
							Bundle bundle = new Bundle();
							bundle.putString(MSG_ID_SEND + "", description);
							message.what = MSG_ID_SEND;
							message.setData(bundle);
							myHandler.sendMessage(message);
							progressDialog.cancel();
						} else {
							Message message = new Message();
							Bundle bundle = new Bundle();
							bundle.putString(MSG_ID_FAIL + "", description);
							message.what = MSG_ID_FAIL;
							message.setData(bundle);
							myHandler.sendMessage(message);
							progressDialog.cancel();
						}
					} else {
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(MSG_ID_FAIL + "", description);
						message.what = MSG_ID_FAIL;
						message.setData(bundle);
						myHandler.sendMessage(message);
						progressDialog.cancel();
					}

				} catch (JSONException e) {
					progressDialog.cancel();
					// result
					Message message = new Message();
					Bundle bundle = new Bundle();
					bundle.putString(EXCEPTION + "", result);
					message.what = EXCEPTION;
					message.setData(bundle);
					myHandler.sendMessage(message);
				}
			}

		};

	}

	// 获得UI控件
	public void initWedgit() {
		userTitle = (TextView) findViewById(R.id.userTitle);
		edtActivityDes = (EditText) findViewById(R.id.edtActivityDes);
		userLayout = (LinearLayout) findViewById(R.id.userChange);
		btnOver = (Button) findViewById(R.id.btn_ok_edit);

	}

	public void setWidget() {
		userTitle.setText(userName);
		userLayout.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				AlertDialog dialog = new AlertDialog.Builder(EditActivity.this)
						.setTitle(R.string.user_off)
						.setMessage(R.string.user_off_message)
						.setPositiveButton(R.string.btn_ok,
								new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										finish();
										Intent intent = new Intent();
										intent.setClass(EditActivity.this,
												LoginActivity.class);
										startActivity(intent);
									}
								}).create();
				dialog.show();

			}
		});
		btnOver.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// 保存并发送
				progressDialog = ProgressDialog.show(EditActivity.this, "",
						"保存并发送中...");
				myHandler.post(editSaveTask);
				myHandler.post(getClientTask);
				Intent intent = new Intent();
				intent.setClass(EditActivity.this, DetailActivity.class);
				activityFromDetail.setActivityContent(edtActivityDes.getText()
						.toString());
				intent.putExtra(Constants.TO_DETAIL_ACTIVITY, activityFromDetail);
				startActivity(intent);
				finish();
				
			}
		});
	}

	/**
	 * 获取传过来的数据
	 */
	public void initDataFromOther() {
		Intent intent = getIntent();
		SharedPreferences mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(EditActivity.this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME,
				null);

		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);
		Editor editor = mySharedPreferences.edit();
		editor.putInt(Constants.APP_USED_FLAG, Constants.APP_USED_FLAG_O);
		editor.commit();

		activityFromDetail = (AirenaoActivity) intent
				.getSerializableExtra(Constants.TO_CREATE_ACTIVITY);
		fromDetail = intent.getBooleanExtra(Constants.FROMDETAIL, false);
		activityDb = (AirenaoActivity) intent
				.getSerializableExtra(Constants.TRANSFER_DATA);
		// 邀请人的所有电话数据
		if (activityFromDetail != null && fromDetail == true) {
			this.edtActivityDes
					.setText(activityFromDetail.getActivityContent());
		}

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.addSubMenu(0, MENU_FALG_SET_WAY, 0, getString(R.string.send_ways));
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch(item.getItemId()){
			case MENU_FALG_SET_WAY:
				AlertDialog oneDialog = new AlertDialog.Builder(
						EditActivity.this)
						.setTitle(R.string.memu_send_way)
						.setItems(R.array.sendWay,
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog,
											int whichButton) {
										if (whichButton == SEND_WAY_ONE) {
											sendWithOwn = "1";
										} else {
											sendWithOwn = "0";
										}

									}
								}).create();
				oneDialog.show();
				break;
		}
		return super.onOptionsItemSelected(item);
	}
	
	

}
