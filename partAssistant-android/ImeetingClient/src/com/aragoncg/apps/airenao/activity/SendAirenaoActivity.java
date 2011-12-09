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
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;
import android.telephony.gsm.SmsManager;
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
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CursorAdapter;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.MultiAutoCompleteTextView;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.model.MyPerson;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class SendAirenaoActivity extends Activity {
	private static final int SAVE_RESULT = 0;
	private static final int EXCEPTION = 1;
	private static final int SEND_WITHOUT_OWN = 2;
	private static final int SUCCESS = 3;
	
	
	private ImageButton btnSendReciever;
	private EditText txtSendLableContent;
	private CheckBox ckSendLableWithLink;
	private CheckBox ckSendLableUseOwn;
	private Button btnSendLable;
	private Button btnSendLableRecovery;
	private String stringLink;
	private String smsContent;
	public static final int MENU_SET = 0;
	private boolean sendSMS = true;
	
	
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
	
	String SEND_SMS_ACTION = "sendSmsAction";  
    String DELIVERED_SMS_ACTION = "deliveredSmsAction"; 
	private Runnable threadSaveMessage;
	private Cursor cursor;
	private String userName;
	private String userId;
	static final String NAME_COLUMN = Contacts.DISPLAY_NAME;
	private int modeTag;
	private Handler myHandler;
	private Dialog oneDialog;
	private HashMap<String, String> 	clientDicts = new HashMap<String, String>();
	private int count = 0 ;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.send_airenao_layout);
		AirenaoUtills.activityList.add(this);
		SharedPreferences perferences = AirenaoUtills.getMySharedPreferences(this);
		userName = perferences.getString(Constants.AIRENAO_USER_NAME, "");
		
		Intent dataIntent = getIntent();
		getItentData(dataIntent);
		init();
		initHandler();
		getContacts();
		
		 //绑定自动提示框信息
		  final ContentApdater adapter = new ContentApdater(this, cursor);
		  peopleNumbers.setAdapter(adapter);
		  peopleNumbers.setTokenizer(new MultiAutoCompleteTextView.CommaTokenizer());
		  peopleNumbers.setOnItemClickListener(new OnItemClickListener() {
		  
		   @Override
		   public void onItemClick(AdapterView<?> parent, View view,
		     int position, long id) {
			   //将游标定位到要显示数据的行
			   Cursor myCursor = adapter.getCursor();
			   myCursor.move(position);
		    String name= myCursor.getString(myCursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));
		    //通过获得的Id去查询电话号码
		    String phone = showPhone(myCursor);
		    String email = showEmail(myCursor);
		    
		    //将电话或者电子邮件加入到联系列表
		    if(tempContactNumbers == null){
		    	tempContactNumbers = new ArrayList<String>();
		    }
		    if(modeTag == -1){
		    	if(email != null && !"".equals(email)){
		    		tempContactNumbers.add(email);
		    		clientDicts.put(name, email);
		    	}else{
		    		Toast.makeText(SendAirenaoActivity.this, "此人无邮件", Toast.LENGTH_SHORT).show();
		    	}
		    	
		    }
		    if(modeTag == -2){
		    	if(phone != null && !"".equals(phone)){
		    		tempContactNumbers.add(phone);
		    		clientDicts.put(name, phone);
		    	}else{
		    		Toast.makeText(SendAirenaoActivity.this, "此人无电话", Toast.LENGTH_SHORT).show();
		    	}
		    }
		   }
		 });
	}
		  
		//显示电话号码
		   public String showPhone(Cursor myCursor)
		   {
		    String id = myCursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
		    Cursor phoneCursor = getContentResolver().query
		    (ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
		      null, ContactsContract.CommonDataKinds.Phone.CONTACT_ID+"=?", new String[]{id}, null);
		   
		    if(phoneCursor.moveToNext())
		    {
		     String phone =phoneCursor.getString(phoneCursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.DATA));
		     return phone;
		    }
		    phoneCursor.close();
		    return null;
		   }
		  /* //显示电子邮件
		   public String showEmail(Cursor myCursor)
		   {
		    String id = myCursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
		    Cursor emailCursor = getContentResolver().query
		    (ContactsContract.CommonDataKinds.Email.CONTENT_URI,
		      null, ContactsContract.CommonDataKinds.Email.CONTACT_ID+"=?", new String[]{id}, null);
		   
		      if(emailCursor.moveToNext())
		      {
		       String email = emailCursor.getString(emailCursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Email.DATA));
		       return email;
		      }
		    return null;
		   }	  */
		   public String showEmail(Cursor myCursor)
		   {
		    String id = myCursor.getString(myCursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
		    Cursor emailCursor = getContentResolver().query
		    (android.provider.Contacts.ContactMethods.CONTENT_URI,
		      null, "_id=?", new String[]{id}, null);
		      if(emailCursor.moveToNext())
		      {
		       String email = emailCursor.getString(emailCursor.getColumnIndexOrThrow(android.provider.Contacts.ContactMethods.DATA));
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
						if(count == 0){
							showOkOrNotDialog("短信发送成功",true);
						}
						count ++;
						
						return;
					default:
						
						if(count == 0){
							showOkOrNotDialog("短信发送失败,是否重新发送？",false);
						}
						count ++;
						break;
					}
				}
			};
			
			// 注册广播 发送消息
			
			registerReceiver(sendMessageB, new IntentFilter(SEND_SMS_ACTION));
			// create the sentIntent parameter
			Intent sentIntent = new Intent(SEND_SMS_ACTION);
			sentPI = PendingIntent.getBroadcast(
					SendAirenaoActivity.this, 0, sentIntent, 0);

			
			super.onResume();
		}

		@Override
		protected void onPause() {
		if(sendMessageB != null){
			unregisterReceiver(sendMessageB);
		}
			
			super.onDestroy();
		}

	/**
	 * 初始化Handler
	 */
	public void initHandler(){
		myHandler = new Handler(){

			@Override
			public void handleMessage(Message msg) {
				switch(msg.what){
					case SAVE_RESULT:
						String message = (String) msg.getData().get(
								SAVE_RESULT+"");
						AlertDialog aDig = new AlertDialog.Builder(
								SendAirenaoActivity.this).setMessage(message).create();
						aDig.show();
						break;
					case EXCEPTION:
						String message1 = (String) msg.getData().get(
								EXCEPTION+"");
						/*AlertDialog aDig1 = new AlertDialog.Builder(
								SendAirenaoActivity.this).setMessage(message1).create();
						aDig1.show();*/
						Toast.makeText(SendAirenaoActivity.this, message1, Toast.LENGTH_LONG).show();
						
						break;
					case SEND_WITHOUT_OWN:
						String message2 = (String) msg.getData().get(
								SEND_WITHOUT_OWN+"");
						AlertDialog aDig2 = new AlertDialog.Builder(
								SendAirenaoActivity.this).setMessage(message2).create();
						aDig2.show();
						break;
					case SUCCESS:
						if(msg.getData().getString("noContacts") == null){
							getPhoneNumbersOrgetEmail(sendSMS);
							if(smsContent.length() > 140){
								//return;
							}
							if(sendSMS){
								//如果用自己手机发送
								if(ckSendLableUseOwn.isChecked()){
									if(tempContactNumbers.size() > 0){
										sendSMSorEmail(sendSMS,ckSendLableUseOwn.isChecked());
									}
								}else{
									//使用后台电脑发送
									if(tempContactNumbers.size() > 0){
										sendSMSorEmail(sendSMS,ckSendLableUseOwn.isChecked());
									}
								}
							}else{
								//使用Email发送
								sendSMSorEmail(sendSMS,ckSendLableUseOwn.isChecked());
							}
							break;
						}
						
				}
				super.handleMessage(msg);
			}
			
		};
	}	   
		   /**
		    * 保存数据
		    */
	public void initThreadSaveMessage(final String noContacts){
		threadSaveMessage = new Runnable() {
			
			@Override
			public void run() {
				//用自己手机发送短信
				if( sendSMS && ckSendLableUseOwn.isChecked() ){
					saveToPcAndSaveDicts(noContacts);
				}
				//用电脑发送短信
				if(sendSMS && !ckSendLableUseOwn.isChecked()){
					saveToPcAndSaveDicts(noContacts);
				}
				//发送邮件
				if(!sendSMS){
					saveToPcAndSaveDicts(noContacts);
				}
			}
			
		};
	}
	
	/**
	 * 将数据同步到后台
	 */
	public void saveToPcAndSaveDicts(final String noContacts){
		
		String name = "";
		String dict = "";
		JSONObject Json = new JSONObject();	
		JSONArray myDicts = new JSONArray();
		Iterator<Entry<String, String>> iter = clientDicts.entrySet().iterator();
			while (iter.hasNext()) {
				Map.Entry entry = (Map.Entry) iter.next();
				name  = (String)entry.getKey();
				dict  = (String)entry.getValue();
				try {
					Json.put("cName", name);
					Json.put("cValue", dict);
					myDicts.put(Json);
				} catch (JSONException e) {
					
					e.printStackTrace();
					
				}
				
			}
			
		HashMap<String, String> params = new HashMap<String, String>();
		params.put(Constants.ACTIVITY_RECEIVERS,myDicts.toString());
		params.put(Constants.CONTENT, smsContent);
		// 邮件主题
		params.put(Constants.EMAIL_SUBJECT, smsContent);
		params.put(Constants.ACTIVITY_WITH_LINK, ckSendLableWithLink.isChecked()+"");
		params.put(Constants.ACTIVITY_SEND_BYSELF, ckSendLableUseOwn.isChecked()+"");
		params.put(Constants.MSG_TYPE,sendSMS+"");
		params.put(Constants.START_TIME,theTime+":00");
		params.put(Constants.LOCATION,thePosition);
		params.put(Constants.DESCRIPTION,theContent);
		params.put(Constants.POEPLE_MAXIMUM,theNumber+"");
		params.put("uID",userId);
		params.put(Constants.ADDRESS_TYPE,"android");
		String createUrl = getString(R.string.partyCreateUrl);
		HttpHelper httpHelper = new HttpHelper();
		//保存到后台，没有提示信息
		String result = httpHelper.savePerformPost(createUrl, params, SendAirenaoActivity.this);
		String resultOut = AirenaoUtills.linkResult(result);
		try {
			JSONObject output = new JSONObject(resultOut).getJSONObject(Constants.OUT_PUT);
			String status = output.getString(Constants.STATUS);
			String description = output.getString(Constants.DESCRIPTION);
			if("ok".equals(status)){
				Message message = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(SUCCESS+"", description);
				bundle.putString("noContacts", noContacts);
				message.what = SUCCESS;
				message.setData(bundle);
				myHandler.sendMessage(message);
			}
			if(sendSMS && !ckSendLableUseOwn.isChecked()){
				Message message = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(SEND_WITHOUT_OWN+"", description);
				message.what = SEND_WITHOUT_OWN;
				message.setData(bundle);
				myHandler.sendMessage(message);
			}
			
			if(!"ok".equals(status)){
				Message message = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(SAVE_RESULT+"", description);
				message.what = SAVE_RESULT;
				message.setData(bundle);
				myHandler.sendMessage(message);
			}
		} catch (JSONException e) {
			//result
			Message message = new Message();
			Bundle bundle = new Bundle();
			bundle.putString(EXCEPTION+"", result);
			message.what = EXCEPTION;
			message.setData(bundle);
			myHandler.sendMessage(message);
		}
	}
	/**
	 * 获得联系人
	 */
	public void getContacts(){
		  //查询已存在的联系人信息 并将信息绑定到autocompleteTextView中
		  ContentResolver cr = getContentResolver();
		  //制定查询字段
		  String[] fieldes = {ContactsContract.Contacts._ID,ContactsContract.Contacts.DISPLAY_NAME}; 
		  //获得查询的信息
		  cursor = cr.query(ContactsContract.Contacts.CONTENT_URI,
		       fieldes, null, null, getSortOrder());
	}
	
	/**
	 * 获得查询的顺序
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
	 * @param intent
	 */
	public void getItentData(Intent intent){
		if(intent != null){
			
			boolean fromPeopleInfo = intent.getBooleanExtra(Constants.FROM_PEOPLE_INFO, false);
			if(!fromPeopleInfo){
				Bundle dataBundle = (Bundle)intent.getBundleExtra(Constants.TO_SEND_ACTIVITY);
				modeTag = intent.getIntExtra("mode", -2);
				if(modeTag == -2){
					sendSMS = true;
				}else{
					sendSMS = false;
				}
				theTime = dataBundle.getString(Constants.SEND_TIME).trim();
				thePosition = dataBundle.getString(Constants.SEND_POSITION).trim();
				theNumber = dataBundle.getInt(Constants.SEND_NUMBER);
				theContent = dataBundle.getString(Constants.SEND_CONTENT).trim();
				if(theTime == null || "".equals(theTime)){
					theTime = getString(R.string.sendLableTime);
				}
				if(thePosition == null || "".equals(thePosition)){
					thePosition = getString(R.string.sendLablePosition);
				}
			}else{
				AirenaoActivity airenao = (AirenaoActivity) intent.getSerializableExtra(Constants.ONE_PARTY);
				theTime = airenao.getActivityTime();
				thePosition = airenao.getActivityPosition();
				theNumber = airenao.getPeopleLimitNum();
				theContent = airenao.getActivityContent();
				List<Map<String,Object>> list = airenao.getPeopleList();
				String names = "";
				tempContactNumbers = new ArrayList<String>();
				for(int i=0;i<list.size();i++){
					HashMap<String, Object> map = (HashMap<String, Object>) list.get(i);
					tempContactNumbers.add(String.valueOf(map.get(Constants.PEOPLE_CONTACTS)));
					String tempNames = String.valueOf(map.get(Constants.PEOPLE_CONTACTS));
					if(!"".equals(tempNames)){
						names = names + tempNames+";";
					}
					if(peopleNumbers == null){
						peopleNumbers = (MultiAutoCompleteTextView)findViewById(R.id.txtSendReciever);
						peopleNumbers.setText(names);
					}
					
				}
			}
			
		}
	}
	
	
	public void init(){
		
		
		SharedPreferences mySharedPreferences = AirenaoUtills.getMySharedPreferences(SendAirenaoActivity.this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME, null);
		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);
		
		stringLink = getString(R.string.sendLableLink);
		btnSendReciever = (ImageButton)findViewById(R.id.btnSendReciever);
		btnSendLable = (Button)findViewById(R.id.btnSend);
		btnSendLableRecovery = (Button)findViewById(R.id.btnRecover);
		txtSendLableContent = (EditText)findViewById(R.id.txtSendLable);
		ckSendLableWithLink = (CheckBox)findViewById(R.id.cekLink);
		ckSendLableUseOwn = (CheckBox)findViewById(R.id.cekWithMine);
		peopleNumbers = (MultiAutoCompleteTextView)findViewById(R.id.txtSendReciever);
		
		
		String content = userName+"邀请您参加："+theContent+"，时间在："+theTime+"，地点是："+thePosition;
		txtSendLableContent.setText(content);
		ckSendLableWithLink.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				 AlertDialog noticeDialog = new AlertDialog.Builder(SendAirenaoActivity.this)
					.setCancelable(true)
					.setTitle(R.string.sendLableTitle)
					.setMessage(R.string.sendlableNotice)
					.setPositiveButton(R.string.btn_ok, new DialogInterface.OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							stringLink = "";
							
						}
					})
					.setNegativeButton(R.string.btn_cancle, new DialogInterface.OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							
							ckSendLableWithLink.toggle();//如果checkbox初始时选中的，被点击后就不选中了，但用toggle后就会又被选中；
							stringLink = getString(R.string.sendLableLink);
						}
					})
					
					.create();
					if(!ckSendLableWithLink.isChecked()){
						 noticeDialog.show();
					}
					
			}
		
		});
		
		btnSendReciever.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(event.getAction() == MotionEvent.ACTION_UP){
					//Toast.makeText(SendAirenaoActivity.this, "asd", Toast.LENGTH_LONG).show();
					Intent intent = new Intent();
					intent.putExtra("mode", modeTag);
					intent.setClass(SendAirenaoActivity.this, ContactsListActivity.class);
					startActivityForResult(intent, 24);//24 只是一个requestCode 没有别的意义
					return false;//
				}
				return false;
			}
		});
		//发送
		 btnSendLable.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				count = 0;
				if(ckSendLableWithLink.isChecked()){
					stringLink = getString(R.string.sendLableLink);
				}
				
				smsContent = "";
				smsContent = txtSendLableContent.getText().toString()+ "\n" + stringLink;
				
				if(peopleNumbers.getText().toString() == null || "".equals(peopleNumbers.getText().toString())){
					
					AlertDialog noticeDialog = new AlertDialog.Builder(SendAirenaoActivity.this)
					.setCancelable(true)
					.setTitle(R.string.sendLableTitle)
					.setMessage(R.string.sendSmsTip)
					.setNegativeButton(R.string.btn_cancle, new android.content.DialogInterface.OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							
							
						}
					})
					.setPositiveButton(R.string.btn_ok, new android.content.DialogInterface.OnClickListener(){

						@Override
						public void onClick(DialogInterface dialog, int which) {
							initThreadSaveMessage("no");
							myHandler.post(threadSaveMessage);
							//threadSaveMessage.start();
							Intent myIntent = new Intent(SendAirenaoActivity.this,MeetingListActivity.class);
							myIntent.putExtra(Constants.NEED_REFRESH, true);
							startActivity(myIntent);
							return;
						}
						
					})
					.create();
					noticeDialog.show();	
				}else{
					
					initThreadSaveMessage(null);
					myHandler.post(threadSaveMessage);
					/*oneDialog = onOneCreateDialog();
					oneDialog.show();*/
					/*getPhoneNumbersOrgetEmail(sendSMS);
					if(smsContent.length() > 140){
						//return;
					}
					if(sendSMS){
						//如果用自己手机发送
						if(ckSendLableUseOwn.isChecked()){
							if(tempContactNumbers.size() > 0){
								sendSMSorEmail(sendSMS,ckSendLableUseOwn.isChecked());
							}
						}else{
							//使用后台电脑发送
							if(tempContactNumbers.size() > 0){
								sendSMSorEmail(sendSMS,ckSendLableUseOwn.isChecked());
							}
						}
					}else{
						//使用Email发送
						sendSMSorEmail(sendSMS,ckSendLableUseOwn.isChecked());
					}*/
				}
				
			}
		});
		 
		 btnSendLableRecovery.setVisibility(View.GONE);
	}
	/**
	 * 获得电话号码或者email
	 * @return
	 */
	public List<String> getPhoneNumbersOrgetEmail(boolean sendSms){
		if(sendSms){
			if(tempContactNumbers == null){
				tempContactNumbers = new ArrayList<String>();
			}
			//电话本中的电话
			if(personList != null && personList.size()>0){
				for(int i = 0;i < personList.size();i++){
					oneNumber =  personList.get(i).getPhoneNumber();
					tempName = personList.get(i).getName();
					clientDicts.put(tempName, oneNumber);
					tempContactNumbers.add(oneNumber);
				}
			}
			//用户自己输入的电话
			
			String inputedPhoneNumbers = peopleNumbers.getText().toString();
			String[] phoneNumbers = inputedPhoneNumbers.split(";", 0);
			for(int i = 0;i < phoneNumbers.length;i++){
				//if(AirenaoUtills.checkPhoneNumber(phoneNumbers[i])){
					tempContactNumbers.add(phoneNumbers[i]);
					clientDicts.put("佚名", phoneNumbers[i]);
				//}
			}
			
			return tempContactNumbers;
		}else{
			if(tempContactNumbers == null){
				tempContactNumbers = new ArrayList<String>();
			}
			//电话本中email
			if(personList != null && personList.size()>0){
				for(int i = 0;i < personList.size();i++){
					oneEmail =  personList.get(i).getEmail();
					clientDicts.put(personList.get(i).getName(), oneEmail);
					tempContactNumbers.add(oneEmail);
				}
			}
			//用户自己输入的email
			
			String inputedEmails = peopleNumbers.getText().toString();
			String[] emailNumbers = inputedEmails.split(";", 0);
			for(int i = 0;i < emailNumbers.length;i++){
				
				if(AirenaoUtills.matchString(AirenaoUtills.regEmail, emailNumbers[i])){
					tempContactNumbers.add(emailNumbers[i]);
					clientDicts.put("佚名", emailNumbers[i]);
				}
			}
			
			return tempContactNumbers;
		}
		
	}
	
	
	
	public void showOkOrNotDialog(String message,final boolean ok){
		/*initThreadSaveMessage();
		myHandler.post(threadSaveMessage);*/
		AlertDialog aDig = new AlertDialog.Builder(
				SendAirenaoActivity.this).setMessage(message)
				.setPositiveButton(R.string.btn_ok, new OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						if(ok){
							//跳转到meeting list 页面
							Intent intent = new Intent(
									SendAirenaoActivity.this,
									MeetingListActivity.class);
							intent.putExtra(Constants.NEED_REFRESH, true);
							startActivity(intent);
						}else{
							//还在本页
						}
						
					}
				})
				.setNegativeButton(R.string.btn_cancle, new OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						if(ok){
							
						}else{
							Intent intent = new Intent(
									SendAirenaoActivity.this,
									MeetingListActivity.class);
							intent.putExtra(Constants.NEED_REFRESH, true);
							startActivity(intent);
						}
					}
				})
				.create();
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
						//如果短信内容超过70个字符 将这条短信拆成多条短信发送出去  
						if (smsContent.length() > 70) { 
						    ArrayList<String> msgs = mySmsManager.divideMessage(smsContent);  
						    for (String msg : msgs) {  
						    	mySmsManager.sendTextMessage(tempContactNumbers.get(i), null, msg, sentPI, null);  
						    }  
						} else {  
							mySmsManager.sendTextMessage(tempContactNumbers.get(i), null, smsContent, sentPI, null);  
						}  
						
					} catch (Exception e) {
						showOkOrNotDialog("短信发送失败,是否重新发送？",false);
					}
				}
				if(oneDialog != null){
					oneDialog.cancel();
				}
			} else {
				// 用电脑发送
				initThreadSaveMessage(null);
				myHandler.post(threadSaveMessage);
				if(oneDialog != null){
					oneDialog.cancel();
				}
				return;
			}
		} else {
			// 发送Email
			//系统邮件系统的动作为android.content.Intent.ACTION_SEND
			Intent email = new Intent(android.content.Intent.ACTION_SEND);
			email.setType("plain/text");
			String[] emailReciver = new String[tempContactNumbers.size()];
			for(int i = 0;i<tempContactNumbers.size();i++){
				emailReciver[i] = tempContactNumbers.get(i);
			}
			String emailSubject = "请填入主题"; 
			String emailBody = smsContent;

			//设置邮件默认地址
			email.putExtra(android.content.Intent.EXTRA_EMAIL, emailReciver);
			//设置邮件默认标题
			email.putExtra(android.content.Intent.EXTRA_SUBJECT, emailSubject);
			//设置要默认发送的内容
			email.putExtra(android.content.Intent.EXTRA_TEXT, emailBody);
			//调用系统的邮件系统
			startActivity(Intent.createChooser(email, "请选择邮件发送软件"));
			if(oneDialog != null){
				oneDialog.cancel();
			}
			
			//threadSaveMessage.start();
			
			return;
		}

	}

	// 获得返回的数据
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		super.onActivityResult(requestCode, resultCode, data);
		if (21 == resultCode) {
			names = "";
			String beforeNames = peopleNumbers.getText().toString();
			if (!"".equals(beforeNames)) {
				names = beforeNames + ";";
			} else {
				names = beforeNames;
			}
			personList = data
					.getParcelableArrayListExtra(Constants.FROMCONTACTSLISTTOSEND);
			if (personList != null && personList.size() > 0) {
				for (int i = 0; i < personList.size(); i++) {
					names += personList.get(i).getName() + ";";
				}
				peopleNumbers.setText(names);
			}
		}

	}

	
	protected Dialog onOneCreateDialog() {
		ProgressDialog dialog = new ProgressDialog(SendAirenaoActivity.this);
		dialog.setMessage("正在发送...");
		dialog.setIndeterminate(true);
		dialog.setCancelable(true);
		
		return dialog;

	}
	
	protected void cancleDialog(Dialog dialog){
		dialog.cancel();
	}
	/**
	 * this Adapter is used to AutoCompleteText
	 * @author cuikuangye
	 *
	 */
	class ContentApdater extends CursorAdapter{
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
		//构造函数
		public ContentApdater(Context context, Cursor c) {
		  super(context, c);
		  resolver  = context.getContentResolver();
		}
		@Override  //将信息绑定到控件的方法
		public void bindView(View view, Context context, Cursor cursor) {
		  ((TextView)view).setText(cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME)));
		  
		}
		@Override
		public CharSequence convertToString(Cursor cursor) {  
		  return cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));  
		}


		@Override //创建自动绑定选项
		public View newView(Context context, Cursor cursor, ViewGroup parent) {
		  final LayoutInflater inflater = LayoutInflater.from(context);
		  final TextView tv = (TextView)inflater.inflate(android.R.layout.simple_dropdown_item_1line, parent,false);
		  tv.setText(cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME)));
		  return tv;
		}
		
		@Override
        public Cursor runQueryOnBackgroundThread(CharSequence constraint) {
            if (getFilterQueryProvider() != null) {
                return getFilterQueryProvider().runQuery(constraint);
            }

            StringBuilder buffer = null;
            String[] args = null;
            if (constraint != null) {
                buffer = new StringBuilder();
                buffer.append("UPPER(");
                buffer.append(ContactsContract.Contacts.DISPLAY_NAME);
                buffer.append(") GLOB ?");
                args = new String[] { constraint.toString().toUpperCase() + "*" };
            }

            return resolver.query(ContactsContract.Contacts.CONTENT_URI, CONTACTS_SUMMARY_PROJECTION,
                    buffer == null ? null : buffer.toString(), args,
                   getSortOrder());
        }
	}
	
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		  menu.add(0, MENU_SET, 0, getString(R.string.btn_setting)); 
		    
		return super.onCreateOptionsMenu(menu);
	}


	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		  switch (item.getItemId()) { 
		    case MENU_SET: 
		        //newGame(); 
		        return true; 
		  }
		return super.onOptionsItemSelected(item);
	}
		  
}


