package com.aragoncg.apps.airenao.activity;

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
import android.view.View;
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

	private TextView userTitle;
	private LinearLayout userLayout;
	private EditText edtActivityDes;
	private Button btnOver;
	private Runnable editSaveTask;
	private Runnable getClientTask;
	private Handler myHandler;
	private HashMap<String, String> clientMap;
	private ProgressDialog progressDialog;

	private static final int SUCCESS = 4;
	private static final int FAIL = 3;
	private static final int EXCEPTION = 2;
	private static final int MSG_ID_SUCC = 5;
	private static final int MSG_ID_FAIL = 6;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
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

					/*Intent mIntent = new Intent(EditActivity.this,
							SendAirenaoActivity.class);
					activityFromDetail.setClients(clientMap);
					mIntent.putExtra("sendWithClients", activityFromDetail);
					mIntent.putExtra("sendWithClientsTag", true);
					mIntent.putExtra("mode", -2);// -2发送短信
					startActivity(mIntent);*/
					break;
				}

				super.handleMessage(msg);
			}

		};
	}

	public void initRunable() {
		editSaveTask = new Runnable() {

			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				String url = getString(R.string.editUrl);
				HashMap<String, String> params = new HashMap<String, String>();
				params.put("partyID", activityFromDetail.getId() + "");
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
					}else{
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
				String url = getString(R.string.getPartyMsg);
				url = url + activityFromDetail.getId() + "/";
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

						clientMap = new HashMap<String, String>();
						JSONObject dataSource = output
								.getJSONObject("datasource");
						// '_isApplyTips':BOOL,
						// '_isSendBySelf':BOOL
						// msgType = dataSource.getString("msgType");
						JSONArray receiverArray = dataSource
								.getJSONArray("receiverArray");
						JSONObject client;
						for (int i = 0; i < receiverArray.length(); i++) {
							client = receiverArray.getJSONObject(i);
							clientMap.put(client.getString("cName"),
									client.getString("cVal"));
						}
						String receiverType = dataSource
								.getString("receiverType");
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(MSG_ID_SUCC + "", description);
						message.what = MSG_ID_SUCC;
						message.setData(bundle);
						myHandler.sendMessage(message);
						progressDialog.cancel();
					}else{
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
				progressDialog = ProgressDialog.show(EditActivity.this, "", "保存并发送中...");
				myHandler.post(editSaveTask);
				myHandler.post(getClientTask);
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

}
