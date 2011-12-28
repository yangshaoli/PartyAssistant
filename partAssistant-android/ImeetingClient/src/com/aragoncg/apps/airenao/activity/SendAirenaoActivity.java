package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.Data;
import android.telephony.PhoneNumberUtils;
import android.telephony.gsm.SmsManager;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CursorAdapter;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListAdapter;
import android.widget.MultiAutoCompleteTextView;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.activity.Collapser.Collapsible;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.model.MyPerson;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class SendAirenaoActivity extends Activity {
	private static final int FAILT = 0;
	private static final int EXCEPTION = 1;
	private static final int SUCCESS = 3;
	private static final int SEND_WAY_ONE = 0;

	private ImageButton btnSendReciever;
	private EditText txtSendLableContent;
	private boolean ckSendLableWithLink = true;
	private boolean ckSendLableUseOwn = true;
	private int ckLable;
	private Button btnSendLable;
	private Button btnSendLableRecovery;
	private String stringLink;
	private String smsContent;
	private static final int MENU_SET = 0;
	private static final int MENU_SEND_WAY = 1;
	private boolean sendSMS = true;
	private boolean isShow = false;

	private String theTime;
	private String thePosition;
	private int theNumber;
	private String theContent;

	private MultiAutoCompleteTextView peopleNumbers;
	private ArrayList<MyPerson> personList;
	private String names = "";
	private String tempName = "";
	private List<String> tempContactNumbers;
	private String oneNumber;
	private String oneEmail;
	private BroadcastReceiver sendMessageB;
	private PendingIntent sentPI;
	private String partyId;
	private String applyURL;

	String SEND_SMS_ACTION = "sendSmsAction";
	String DELIVERED_SMS_ACTION = "deliveredSmsAction";
	private Runnable threadSaveMessage;
	private Cursor cursor;
	private String userName;
	private String userId;
	static final String NAME_COLUMN = Contacts.DISPLAY_NAME;
	private int modeTag = -2;// -2代表是查询手机号
	private Handler myHandler;
	private Dialog oneDialog;
	private HashMap<String, String> clientDicts = new HashMap<String, String>();
	private int count = 0;
	private ArrayList<String> phoneNumbers = new ArrayList<String>();
	private ProgressDialog progerssDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.send_airenao_layout);
		AirenaoUtills.activityList.add(this);
		SharedPreferences perferences = AirenaoUtills
				.getMySharedPreferences(this);
		userName = perferences.getString(Constants.AIRENAO_USER_NAME, "");

		// Intent dataIntent = getIntent();
		// getItentData(dataIntent);
		init();
		initHandler();
		getContacts();

		// 绑定自动提示框信息
		final ContentApdater adapter = new ContentApdater(this, cursor);
		peopleNumbers.setAdapter(adapter);
		peopleNumbers
				.setTokenizer(new MultiAutoCompleteTextView.CommaTokenizer());
		peopleNumbers.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// 将游标定位到要显示数据的行
				Cursor myCursor = adapter.getCursor();
				myCursor.moveToPosition(position);
				int nameIndex = myCursor
						.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME);
				String name = myCursor.getString(nameIndex);
				// 通过获得的Id去查询电话号码
				showPhones(myCursor);
				// String email = showEmail(myCursor);

				// 将电话或者电子邮件加入到联系列表
				if (tempContactNumbers == null) {
					tempContactNumbers = new ArrayList<String>();
				}
				/*
				 * if (modeTag == -1) { if (email != null && !"".equals(email))
				 * { tempContactNumbers.add(email); clientDicts.put(name,
				 * email); } else { Toast.makeText(SendAirenaoActivity.this,
				 * "此人无邮件", Toast.LENGTH_SHORT).show(); }
				 * 
				 * }
				 */
				if (modeTag == -2) {
					int phoneNumberSize = phoneNumbers.size();
					if (phoneNumberSize <= 1) {
						String phone = "";
						if (phoneNumberSize == 0) {
							phone = "";
						} else {
							phone = phoneNumbers.get(0);
						}
						tempContactNumbers.add(phone);
						clientDicts.put(name, phone);
					} else {
						SharedPreferences msp = AirenaoUtills
								.getMySharedPreferences(SendAirenaoActivity.this);

						for (int i = 0; i < phoneNumberSize; i++) {
							String phone = phoneNumbers.get(i);
							String mark = msp.getString(phone, "");
							if (Constants.IS_SUPER_PRIMARY != mark) {
								continue;

							} else {
								isShow = true;
								tempContactNumbers.add(phone);
								clientDicts.put(name, phone);
								return;
							}
						}
						if (!isShow) {
							// Display dialog to choose a number to call.
							PhoneDisambigDialog phoneDialog = new PhoneDisambigDialog(
									SendAirenaoActivity.this, null, false,
									phoneNumbers, position, name);
							isShow = false;
							phoneDialog.show();
						}
					}

				}
			}
		});
	}

	// 显示电话号码
	public ArrayList<String> showPhones(Cursor myCursor) {

		phoneNumbers.clear();
		String contactId = myCursor.getString(myCursor
				.getColumnIndexOrThrow(ContactsContract.Contacts._ID));

		String hasPhone = myCursor.getString(myCursor
				.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER));
		if (hasPhone.equals("1")) {

			// You now have the number so now query it like this

			Cursor phones = getContentResolver().query(
					ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
					null,
					ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = "
							+ contactId, null, null);

			while (phones.moveToNext()) {
				String phoneNumber = phones
						.getString(phones
								.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
				if (phoneNumber != null) {

					if (AirenaoUtills.phoneNumberCompare(phoneNumbers,
							phoneNumber)) {
						continue;
					} else {
						phoneNumbers.add(phoneNumber);
					}
				}

				// 1 == is primary
				String isPrimary = phones
						.getString(phones
								.getColumnIndex(ContactsContract.CommonDataKinds.Phone.IS_SUPER_PRIMARY));
				SharedPreferences msp = AirenaoUtills
						.getMySharedPreferences(SendAirenaoActivity.this);

				String mark = msp.getString(phoneNumber, "");
				if (Constants.IS_SUPER_PRIMARY.equals(mark)) {
					phoneNumbers.clear();
					phoneNumbers.add(phoneNumber);
					phones.close();
					return phoneNumbers;
				}

			}
			phones.close();
		}
		return phoneNumbers;

	}

	/*
	 * //显示电子邮件 public String showEmail(Cursor myCursor) { String id =
	 * myCursor.getString
	 * (cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID)); Cursor
	 * emailCursor = getContentResolver().query
	 * (ContactsContract.CommonDataKinds.Email.CONTENT_URI, null,
	 * ContactsContract.CommonDataKinds.Email.CONTACT_ID+"=?", new String[]{id},
	 * null);
	 * 
	 * if(emailCursor.moveToNext()) { String email =
	 * emailCursor.getString(emailCursor
	 * .getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Email.DATA));
	 * return email; } return null; }
	 */
	public String showEmail(Cursor myCursor) {
		String id = myCursor.getString(myCursor
				.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
		Cursor emailCursor = getContentResolver().query(
				android.provider.Contacts.ContactMethods.CONTENT_URI, null,
				"_id=?", new String[] { id }, null);
		if (emailCursor.moveToNext()) {
			String email = emailCursor
					.getString(emailCursor
							.getColumnIndexOrThrow(android.provider.Contacts.ContactMethods.DATA));
			return email;
		}
		return null;
	}

	@Override
	protected void onResume() {
		sendMessageB = new BroadcastReceiver() {

			@Override
			public void onReceive(Context context, Intent intent) {
				// 判断短信是否发送成功

				switch (getResultCode()) {
				case Activity.RESULT_OK:
					if (count == 0) {
						showOkOrNotDialog("短信发送成功", true);
					}
					count++;

					return;
				default:

					if (count == 0) {
						showOkOrNotDialog("短信发送失败,是否重新发送？", false);
					}
					count++;
					break;
				}
			}
		};

		// 注册广播 发送消息

		registerReceiver(sendMessageB, new IntentFilter(SEND_SMS_ACTION));
		// create the sentIntent parameter
		Intent sentIntent = new Intent(SEND_SMS_ACTION);
		sentPI = PendingIntent.getBroadcast(SendAirenaoActivity.this, 0,
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

	/**
	 * 初始化Handler
	 */
	public void initHandler() {
		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case FAILT:

					String message = (String) msg.getData().get(FAILT + "");
					AlertDialog aDig = new AlertDialog.Builder(
							SendAirenaoActivity.this).setMessage(message)
							.create();
					aDig.show();
					break;
				case EXCEPTION:
					String message1 = (String) msg.getData()
							.get(EXCEPTION + "");
					/*
					 * AlertDialog aDig1 = new AlertDialog.Builder(
					 * SendAirenaoActivity.this).setMessage(message1).create();
					 * aDig1.show();
					 */
					Toast.makeText(SendAirenaoActivity.this, message1,
							Toast.LENGTH_LONG).show();

					break;
				case SUCCESS:
					if (msg.getData().getString("noContacts") == null) {// 等于null说明联系人不为空
						if (sendSMS) {
							// 如果用自己手机发送
							if (ckSendLableUseOwn) {
								if (tempContactNumbers.size() > 0) {
									sendSMSorEmail(sendSMS, ckSendLableUseOwn);
									progerssDialog.dismiss();
								}
							} else {
								sendSMSorEmail(sendSMS, !ckSendLableUseOwn);
								progerssDialog.dismiss();
							}
						}
					}
					break;
				}
				super.handleMessage(msg);
			}
		};
	}

	/**
	 * 保存数据
	 */
	public void initThreadSaveMessage(final String noContacts) {
		threadSaveMessage = new Runnable() {

			@Override
			public void run() {
				// 用自己手机发送短信
				if (sendSMS && ckSendLableUseOwn) {
					saveToPcAndSaveDicts(noContacts);
				}
				// 用电脑发送短信
				if (sendSMS && !ckSendLableUseOwn) {
					saveToPcAndSaveDicts(noContacts);
				}
			}

		};
	}

	/**
	 * 将数据同步到后台
	 */
	public void saveToPcAndSaveDicts(final String noContacts) {
		smsContent = txtSendLableContent.getText().toString();
		String name = "";
		String dict = "";
		JSONObject Json = new JSONObject();
		JSONArray myDicts = new JSONArray();
		Iterator<Entry<String, String>> iter = clientDicts.entrySet()
				.iterator();
		while (iter.hasNext()) {
			Map.Entry entry = (Map.Entry) iter.next();
			name = (String) entry.getKey();
			dict = (String) entry.getValue();
			try {
				Json.put("cName", name);
				Json.put("cValue", dict);
				myDicts.put(Json);
			} catch (JSONException e) {

				e.printStackTrace();

			}

		}

		HashMap<String, String> params = new HashMap<String, String>();
		params.put(Constants.ACTIVITY_RECEIVERS, myDicts.toString());
		params.put(Constants.CONTENT, smsContent);
		if (ckSendLableUseOwn) {
			ckLable = 1;
		} else {
			ckLable = 0;
		}
		params.put(Constants.ACTIVITY_SEND_BYSELF, ckLable + "");

		params.put("uID", userId);
		params.put(Constants.ADDRESS_TYPE, "android");
		String createUrl = getString(R.string.partyCreateUrl);
		HttpHelper httpHelper = new HttpHelper();
		// 保存到后台，没有提示信息
		String result = httpHelper.savePerformPost(createUrl, params,
				SendAirenaoActivity.this);
		String resultOut = AirenaoUtills.linkResult(result);
		try {
			JSONObject output = new JSONObject(resultOut)
					.getJSONObject(Constants.OUT_PUT);
			String status = output.getString(Constants.STATUS);
			String description = output.getString(Constants.DESCRIPTION);
			if ("ok".equals(status)) {
				JSONObject data = output.getJSONObject(Constants.DATA_SOURCE);
				partyId = data.getString("partyId");
				applyURL = data.getString("applyURL");
				if (ckSendLableWithLink) {
					stringLink = applyURL;
				}

				smsContent = "";
				smsContent = txtSendLableContent.getText().toString() + "\n"
						+ stringLink;
				Message message = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(SUCCESS + "", description);
				bundle.putString("noContacts", noContacts);
				message.what = SUCCESS;
				message.setData(bundle);
				myHandler.sendMessage(message);
			} else {
				progerssDialog.dismiss();
				Message message = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(FAILT + "", description);
				message.what = FAILT;
				message.setData(bundle);
				myHandler.sendMessage(message);
			}

		} catch (JSONException e) {
			progerssDialog.dismiss();
			// result
			Message message = new Message();
			Bundle bundle = new Bundle();
			bundle.putString(EXCEPTION + "", "错误！");
			message.what = EXCEPTION;
			message.setData(bundle);
			myHandler.sendMessage(message);
		}
	}

	/**
	 * 获得联系人
	 */
	public void getContacts() {
		// 查询已存在的联系人信息 并将信息绑定到autocompleteTextView中
		ContentResolver cr = getContentResolver();
		// 制定查询字段
		String[] fieldes = { ContactsContract.Contacts._ID,
				ContactsContract.Contacts.DISPLAY_NAME };
		// 获得查询的信息
		cursor = cr.query(ContactsContract.Contacts.CONTENT_URI, fieldes, null,
				null, getSortOrder());
	}

	/**
	 * 获得查询的顺序
	 * 
	 * @return
	 */
	private static String getSortOrder() {

		if (Constants.SDK_VERSION < Constants.SDK_VERSION_8) {
			return NAME_COLUMN + " COLLATE LOCALIZED ASC";
		} else {
			return Constants.SORT_ORDER;
		}
	}

	/**
	 * get the data from createActivity
	 * 
	 * @param intent
	 */
	public void getItentData(Intent intent) {
		if (intent != null) {

			boolean fromPeopleInfo = intent.getBooleanExtra(
					Constants.FROM_PEOPLE_INFO, false);
			if (!fromPeopleInfo) {
				boolean sendWithClientsTag = intent.getBooleanExtra(
						"sendWithClientsTag", false);
				if (sendWithClientsTag) {
					AirenaoActivity airenao = (AirenaoActivity) intent
							.getSerializableExtra("sendWithClients");
					modeTag = intent.getIntExtra("mode", -2);
					if (modeTag == -2) {
						sendSMS = true;
					} else {
						sendSMS = false;
					}

					// Iterator iter = map.entrySet().iterator();
					// 　　while (iter.hasNext()) {
					// 　　Map.Entry entry = (Map.Entry) iter.next();
					// 　　Object key = entry.getKey();
					// 　　Object val = entry.getValue();

					HashMap<String, String> clients = (HashMap<String, String>) airenao
							.getClients();
					Iterator iter = null;
					if (clients != null) {
						iter = clients.entrySet().iterator();
					}
					String names = "";
					if (iter != null) {
						if (tempContactNumbers == null) {
							tempContactNumbers = new ArrayList<String>();
						}
						tempContactNumbers.clear();
						while (iter.hasNext()) {
							Map.Entry entry = (Map.Entry) iter.next();
							String name = (String) entry.getKey();
							String number = (String) entry.getValue();
							names = name + ";" + names;
							tempContactNumbers.add(number);

						}
						;
					}
					theContent = airenao.getActivityContent();
					if (theTime == null || "".equals(theTime)) {
						theTime = getString(R.string.sendLableTime);
					}
					if (thePosition == null || "".equals(thePosition)) {
						thePosition = getString(R.string.sendLablePosition);
					}
				} else {
					Bundle dataBundle = (Bundle) intent
							.getBundleExtra(Constants.TO_SEND_ACTIVITY);
					modeTag = intent.getIntExtra("mode", -2);
					if (modeTag == -2) {
						sendSMS = true;
					} else {
						sendSMS = false;
					}
					theTime = dataBundle.getString(Constants.SEND_TIME).trim();
					thePosition = dataBundle.getString(Constants.SEND_POSITION)
							.trim();
					theNumber = dataBundle.getInt(Constants.SEND_NUMBER);
					theContent = dataBundle.getString(Constants.SEND_CONTENT)
							.trim();
					if (theTime == null || "".equals(theTime)) {
						theTime = getString(R.string.sendLableTime);
					}
					if (thePosition == null || "".equals(thePosition)) {
						thePosition = getString(R.string.sendLablePosition);
					}
				}

			} else {
				AirenaoActivity airenao = (AirenaoActivity) intent
						.getSerializableExtra(Constants.ONE_PARTY);
				theContent = airenao.getActivityContent();
				List<Map<String, Object>> list = airenao.getPeopleList();
				String names = "";
				tempContactNumbers = new ArrayList<String>();
				for (int i = 0; i < list.size(); i++) {
					HashMap<String, Object> map = (HashMap<String, Object>) list
							.get(i);
					tempContactNumbers.add(String.valueOf(map
							.get(Constants.PEOPLE_CONTACTS)));
					String tempNames = String.valueOf(map
							.get(Constants.PEOPLE_CONTACTS));
					if (!"".equals(tempNames)) {
						names = names + tempNames + ";";
					}
					if (peopleNumbers == null) {
						peopleNumbers = (MultiAutoCompleteTextView) findViewById(R.id.txtSendReciever);
						peopleNumbers.setText(names);
					}

				}
			}

		}
	}

	public void init() {

		SharedPreferences mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(SendAirenaoActivity.this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME,
				null);
		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);

		stringLink = getString(R.string.sendLableLink);
		btnSendReciever = (ImageButton) findViewById(R.id.btnSendReciever);
		btnSendLable = (Button) findViewById(R.id.btnSend);
		txtSendLableContent = (EditText) findViewById(R.id.txtSendLable);

		peopleNumbers = (MultiAutoCompleteTextView) findViewById(R.id.txtSendReciever);
		ArrayAdapter<CharSequence> mAdapter = ArrayAdapter.createFromResource(
				this, R.array.sendWay, android.R.layout.simple_spinner_item);
		mAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

		btnSendReciever.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					// Toast.makeText(SendAirenaoActivity.this, "asd",
					// Toast.LENGTH_LONG).show();
					Intent intent = new Intent();
					intent.putExtra("mode", -2);// -2 是查询电话
					intent.setClass(SendAirenaoActivity.this,
							ContactsListActivity.class);
					startActivityForResult(intent, 24);// 24 只是一个requestCode
														// 没有别的意义
					return false;//
				}
				return false;
			}
		});
		// 发送
		btnSendLable.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				count = 0;
				getPhoneNumbersOrgetEmail(sendSMS);

				if (peopleNumbers.getText().toString() == null
						|| "".equals(peopleNumbers.getText().toString())) {

					AlertDialog noticeDialog = new AlertDialog.Builder(
							SendAirenaoActivity.this)
							.setCancelable(true)
							.setTitle(R.string.sendLableTitle)
							.setMessage(R.string.sendSmsTip)
							.setNegativeButton(
									R.string.btn_cancle,
									new android.content.DialogInterface.OnClickListener() {

										@Override
										public void onClick(
												DialogInterface dialog,
												int which) {

										}
									})
							.setPositiveButton(
									R.string.btn_ok,
									new android.content.DialogInterface.OnClickListener() {

										@Override
										public void onClick(
												DialogInterface dialog,
												int which) {
											initThreadSaveMessage("no");// no指的是收件人为空
											myHandler.post(threadSaveMessage);
											// threadSaveMessage.start();
											/*Intent myIntent = new Intent(
													SendAirenaoActivity.this,
													MeetingListActivity.class);
											myIntent.putExtra(
													Constants.NEED_REFRESH,
													true);
											startActivity(myIntent);*/
											finish();
											return;
										}

									}).create();
					noticeDialog.show();
				} else {
					progerssDialog = ProgressDialog.show(
							SendAirenaoActivity.this, "", "发送中...", true, true);
					initThreadSaveMessage(null);
					myHandler.post(threadSaveMessage);

				}

			}
		});

	}

	/**
	 * 获得电话号码或者email
	 * 
	 * @return
	 */
	public List<String> getPhoneNumbersOrgetEmail(boolean sendSms) {
		if (sendSms) {
			if (tempContactNumbers == null) {
				tempContactNumbers = new ArrayList<String>();
			}
			// 电话本中的电话
			if (personList != null && personList.size() > 0) {
				for (int i = 0; i < personList.size(); i++) {
					oneNumber = personList.get(i).getPhoneNumber();
					tempName = personList.get(i).getName();
					clientDicts.put(tempName, oneNumber);
					tempContactNumbers.add(oneNumber);
				}
			}
			// 用户自己输入的电话

			String inputedPhoneNumbers = peopleNumbers.getText().toString();
			String[] phoneNumbers = inputedPhoneNumbers.split("\\,", 0);
			for (int i = 0; i < phoneNumbers.length; i++) {
				// if(AirenaoUtills.checkPhoneNumber(phoneNumbers[i])){
				if (phoneNumbers[i].equals("")) {
					continue;
				}
				tempContactNumbers.add(phoneNumbers[i]);
				clientDicts.put("佚名", phoneNumbers[i]);
				// }
			}

			return tempContactNumbers;
		} else {
			if (tempContactNumbers == null) {
				tempContactNumbers = new ArrayList<String>();
			}
			// 电话本中email
			if (personList != null && personList.size() > 0) {
				for (int i = 0; i < personList.size(); i++) {
					oneEmail = personList.get(i).getEmail();
					clientDicts.put(personList.get(i).getName(), oneEmail);
					tempContactNumbers.add(oneEmail);
				}
			}
			// 用户自己输入的email

			String inputedEmails = peopleNumbers.getText().toString();
			String[] emailNumbers = inputedEmails.split(";", 0);
			for (int i = 0; i < emailNumbers.length; i++) {

				if (AirenaoUtills.matchString(AirenaoUtills.regEmail,
						emailNumbers[i])) {
					tempContactNumbers.add(emailNumbers[i]);
					clientDicts.put("佚名", emailNumbers[i]);
				}
			}

			return tempContactNumbers;
		}

	}

	public void showOkOrNotDialog(String message, final boolean ok) {
		/*
		 * initThreadSaveMessage(); myHandler.post(threadSaveMessage);
		 */
		AlertDialog aDig = new AlertDialog.Builder(SendAirenaoActivity.this)
				.setMessage(message)
				.setPositiveButton(R.string.btn_ok, new OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						if (ok) {
							// 跳转到meeting list 页面
							Intent intent = new Intent(
									SendAirenaoActivity.this,
									MeetingListActivity.class);
							intent.putExtra(Constants.NEED_REFRESH, true);
							startActivity(intent);
						} else {
							// 还在本页
						}

					}
				})
				.setNegativeButton(R.string.btn_cancle, new OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						if (ok) {

						} else {
							Intent intent = new Intent(
									SendAirenaoActivity.this,
									MeetingListActivity.class);
							intent.putExtra(Constants.NEED_REFRESH, true);
							startActivity(intent);
						}
					}
				}).create();
		aDig.show();

	}

	/**
	 * 发送信息
	 * 
	 * @param sendSms
	 */
	@SuppressWarnings("deprecation")
	public void sendSMSorEmail(final boolean sendSms, final boolean sendWithOwn) {

		if (sendSms) {
			if (sendWithOwn) {
				// 用自己手机发送
				for (int i = 0; i < tempContactNumbers.size(); i++) {
					try {
						SmsManager mySmsManager = SmsManager.getDefault();
						// 如果短信内容超过70个字符 将这条短信拆成多条短信发送出去
						if (smsContent.length() > 70) {
							ArrayList<String> msgs = mySmsManager
									.divideMessage(smsContent);
							for (String msg : msgs) {
								mySmsManager.sendTextMessage(
										tempContactNumbers.get(i), null, msg,
										sentPI, null);
							}
						} else {
							mySmsManager.sendTextMessage(
									tempContactNumbers.get(i), null,
									smsContent, sentPI, null);
						}

					} catch (Exception e) {
						showOkOrNotDialog("短信发送失败,是否重新发送？", false);
					}
				}
				if (oneDialog != null) {
					oneDialog.cancel();
				}
			} else {
				// 用电脑发送
				initThreadSaveMessage(null);
				myHandler.post(threadSaveMessage);
				if (oneDialog != null) {
					oneDialog.cancel();
				}
				return;
			}
		} /*
		 * else { // 发送Email // 系统邮件系统的动作为android.content.Intent.ACTION_SEND
		 * Intent email = new Intent(android.content.Intent.ACTION_SEND);
		 * email.setType("plain/text"); String[] emailReciver = new
		 * String[tempContactNumbers.size()]; for (int i = 0; i <
		 * tempContactNumbers.size(); i++) { emailReciver[i] =
		 * tempContactNumbers.get(i); } String emailSubject = "请填入主题"; String
		 * emailBody = smsContent;
		 * 
		 * // 设置邮件默认地址 email.putExtra(android.content.Intent.EXTRA_EMAIL,
		 * emailReciver); // 设置邮件默认标题
		 * email.putExtra(android.content.Intent.EXTRA_SUBJECT, emailSubject);
		 * // 设置要默认发送的内容 email.putExtra(android.content.Intent.EXTRA_TEXT,
		 * emailBody); // 调用系统的邮件系统 startActivity(Intent.createChooser(email,
		 * "请选择邮件发送软件")); if (oneDialog != null) { oneDialog.cancel(); }
		 * 
		 * // threadSaveMessage.start();
		 * 
		 * return; }
		 */

	}

	// 获得返回的数据
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		super.onActivityResult(requestCode, resultCode, data);
		if (21 == resultCode) {
			names = "";
			String beforeNames = peopleNumbers.getText().toString();
			if (!"".equals(beforeNames)) {
				names = beforeNames;
			} else {
				names = beforeNames;
			}
			personList = data
					.getParcelableArrayListExtra(Constants.FROMCONTACTSLISTTOSEND);
			if (personList != null && personList.size() > 0) {
				for (int i = 0; i < personList.size(); i++) {
					names += personList.get(i).getName() + ",";
				}
				peopleNumbers.setText(names);
			}
		}

	}

	/**
	 * this Adapter is used to AutoCompleteText
	 * 
	 * @author cuikuangye
	 * 
	 */
	class ContentApdater extends CursorAdapter {
		ContentResolver resolver;
		final String[] CONTACTS_SUMMARY_PROJECTION = new String[] {
				Contacts._ID, // 0
				Contacts.DISPLAY_NAME, // 1
				Contacts.STARRED, // 2
				Contacts.TIMES_CONTACTED, // 3
				Contacts.CONTACT_PRESENCE, // 4
				Contacts.PHOTO_ID, // 5
				Contacts.LOOKUP_KEY, // 6
				Contacts.HAS_PHONE_NUMBER // 7
		};

		// 构造函数
		public ContentApdater(Context context, Cursor c) {
			super(context, c);
			resolver = context.getContentResolver();
		}

		@Override
		// 将信息绑定到控件的方法
		public void bindView(View view, Context context, Cursor cursor) {
			((TextView) view)
					.setText(cursor.getString(cursor
							.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME)));

		}

		@Override
		public CharSequence convertToString(Cursor cursor) {
			return cursor
					.getString(cursor
							.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));
		}

		@Override
		// 创建自动绑定选项
		public View newView(Context context, Cursor cursor, ViewGroup parent) {
			final LayoutInflater inflater = LayoutInflater.from(context);
			final TextView tv = (TextView) inflater.inflate(
					android.R.layout.simple_dropdown_item_1line, parent, false);
			tv.setText(cursor.getString(cursor
					.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME)));
			return tv;
		}

		@Override
		public Cursor runQueryOnBackgroundThread(CharSequence constraint) {
			if (getFilterQueryProvider() != null) {
				return getFilterQueryProvider().runQuery(constraint);
			}

			Uri uri = Uri.withAppendedPath(
					ContactsContract.Contacts.CONTENT_FILTER_URI,
					Uri.encode(constraint.toString()));
			return resolver.query(uri, null, Contacts.IN_VISIBLE_GROUP + "="
					+ "1 and " + Contacts.HAS_PHONE_NUMBER, null,
					ContactsContract.Contacts.TIMES_CONTACTED + ", "
							+ ContactsContract.Contacts.STARRED + ", "
							+ ContactsContract.Contacts.DISPLAY_NAME + " DESC");
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(0, MENU_SET, 0, getString(R.string.btn_setting));
		menu.add(0, MENU_SEND_WAY, 1, getString(R.string.memu_send_way));
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case MENU_SET:
			AlertDialog settingDialog = new AlertDialog.Builder(
					SendAirenaoActivity.this)
					.setTitle(R.string.btn_setting)
					.setIcon(R.drawable.settings)
					.setItems(R.array.setMenu,
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									switch (which) {
									case 0:
										break;

									case 1:
										break;
									}
								}
							}).create();
			settingDialog.show();
			return true;
		case MENU_SEND_WAY:
			AlertDialog oneDialog = new AlertDialog.Builder(
					SendAirenaoActivity.this)
					.setTitle(R.string.memu_send_way)
					.setItems(R.array.sendWay,
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									if (whichButton == SEND_WAY_ONE) {
										ckSendLableUseOwn = true;
									} else {
										ckSendLableUseOwn = false;
									}

								}
							}).create();
			oneDialog.show();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * Class used for displaying a dialog with a list of phone numbers of which
	 * one will be chosen to make a call or initiate an sms message.
	 */
	public class PhoneDisambigDialog implements
			DialogInterface.OnClickListener, DialogInterface.OnDismissListener,
			CompoundButton.OnCheckedChangeListener {

		private boolean mMakePrimary = false;
		private Context mContext;
		private AlertDialog mDialog;
		private boolean mSendSms;
		private Cursor mPhonesCursor;
		private ListAdapter mPhonesAdapter;
		private ArrayList<PhoneItem> mPhoneItemList;
		private int position;
		/*
		 * private Map<Integer,MyPerson> positions; private Map<Integer,
		 * MyPerson> personMap;
		 */
		private String name;
		private Handler mHandler;

		/*
		 * public PhoneDisambigDialog(Context context, Cursor phonesCursor) {
		 * this(context, phonesCursor, false make call , null); }
		 */
		public PhoneDisambigDialog(Context context, Cursor phonesCursor,
				boolean sendSms, ArrayList phones, int position, String name) {
			mContext = context;
			mSendSms = sendSms;
			mPhonesCursor = phonesCursor;
			this.position = position;
			this.mHandler = mHandler;
			if (mPhonesCursor != null) {
				mPhoneItemList = makePhoneItemsList(phonesCursor);
			} else {
				mPhoneItemList = makePhoneItemsList(phones);
			}
			Collapser.collapseList(mPhoneItemList);

			mPhonesAdapter = new PhonesAdapter(mContext, mPhoneItemList);

			LayoutInflater inflater = (LayoutInflater) mContext
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			View setPrimaryView = inflater.inflate(
					R.layout.set_primary_checkbox, null);
			((CheckBox) setPrimaryView.findViewById(R.id.setPrimary))
					.setOnCheckedChangeListener(this);

			// Need to show disambig dialogue.
			AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(
					mContext).setAdapter(mPhonesAdapter, this)
					.setTitle("请选择电话号码").setView(setPrimaryView);

			mDialog = dialogBuilder.create();
		}

		/**
		 * Show the dialog.
		 */
		public void show() {
			if (mPhoneItemList.size() == 1) {
				// If there is only one after collapse, just select it, and
				// close;

				onClick(mDialog, 0);
			}
			mDialog.show();
		}

		public void onClick(DialogInterface dialog, int which) {
			if (mPhoneItemList.size() > which && which >= 0) {
				PhoneItem phoneItem = mPhoneItemList.get(which);
				long id = phoneItem.id;
				String phone = phoneItem.phoneNumber;
				if (mPhonesCursor != null) {
					if (mMakePrimary) {
						ContentValues values = new ContentValues(1);
						values.put(Data.IS_SUPER_PRIMARY, 1);
						mContext.getContentResolver()
								.update(ContentUris.withAppendedId(
										Data.CONTENT_URI, id), values, null,
										null);
					}
				} else {
					if (mMakePrimary) {
						SharedPreferences msp = AirenaoUtills
								.getMySharedPreferences(mContext);
						Editor myEditor = msp.edit();
						myEditor.putString(phone, Constants.IS_SUPER_PRIMARY);
						myEditor.commit();
					}
				}

				tempContactNumbers.add(phone);
				clientDicts.put(name, phone);
			} else {
				dialog.dismiss();
			}
		}

		public void onCheckedChanged(CompoundButton buttonView,
				boolean isChecked) {
			mMakePrimary = isChecked;
		}

		public void onDismiss(DialogInterface dialog) {
			mPhonesCursor.close();
		}

		private class PhonesAdapter extends ArrayAdapter<PhoneItem> {

			public PhonesAdapter(Context context, List<PhoneItem> objects) {
				super(context, android.R.layout.simple_dropdown_item_1line,
						android.R.id.text1, objects);
			}
		}

		private class PhoneItem implements Collapsible<PhoneItem> {

			String phoneNumber;
			long id;

			public PhoneItem(String newPhoneNumber, long newId) {
				phoneNumber = newPhoneNumber;
				id = newId;
			}

			public boolean collapseWith(PhoneItem phoneItem) {
				if (!shouldCollapseWith(phoneItem)) {
					return false;
				}
				// Just keep the number and id we already have.
				return true;
			}

			public boolean shouldCollapseWith(PhoneItem phoneItem) {
				if (PhoneNumberUtils.compare(PhoneDisambigDialog.this.mContext,
						phoneNumber, phoneItem.phoneNumber)) {
					return true;
				}
				return false;
			}

			public String toString() {
				return phoneNumber;
			}
		}

		private ArrayList<PhoneItem> makePhoneItemsList(Cursor phonesCursor) {
			ArrayList<PhoneItem> phoneList = new ArrayList<PhoneItem>();

			phonesCursor.moveToPosition(-1);
			while (phonesCursor.moveToNext()) {
				long id = phonesCursor.getLong(phonesCursor
						.getColumnIndex(Data._ID));
				String phone = phonesCursor.getString(phonesCursor
						.getColumnIndex(Phone.NUMBER));
				phoneList.add(new PhoneItem(phone, id));
			}

			return phoneList;
		}

		private ArrayList<PhoneItem> makePhoneItemsList(ArrayList<String> phones) {
			ArrayList<PhoneItem> phoneList = new ArrayList<PhoneItem>();
			for (int i = 0; i < phones.size(); i++) {
				phoneList.add(new PhoneItem(phones.get(i), i));
			}
			return phoneList;
		}

	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		smsContent = txtSendLableContent.getText().toString();
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			if (this.smsContent != null && !"".equals(this.smsContent)) {

				AlertDialog noticeDialog = new AlertDialog.Builder(
						SendAirenaoActivity.this)
						.setCancelable(true)
						.setTitle(R.string.sendLableTitle)
						.setMessage(R.string.createToList)
						.setNegativeButton(
								R.string.btn_cancle,
								new android.content.DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {

									}
								})
						.setPositiveButton(
								R.string.btn_ok,
								new android.content.DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										Intent myIntent = new Intent(
												SendAirenaoActivity.this,
												MeetingListActivity.class);
										startActivity(myIntent);

									}

								}).create();
				noticeDialog.show();
				event.startTracking();
				return false;
			} else {
				Intent myIntent = new Intent(SendAirenaoActivity.this,
						MeetingListActivity.class);
				startActivity(myIntent);
			}

		}
		return super.onKeyDown(keyCode, event);
	}

}
