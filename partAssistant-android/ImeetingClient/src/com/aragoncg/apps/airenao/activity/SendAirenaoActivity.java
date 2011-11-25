package com.aragoncg.apps.airenao.activity;


import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;
import android.telephony.gsm.SmsManager;
import android.view.LayoutInflater;
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

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.MyPerson;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;

public class SendAirenaoActivity extends Activity {
	private ImageButton btnSendReciever;
	private EditText txtSendLableContent;
	private CheckBox ckSendLableWithLink;
	private CheckBox ckSendLableUseOwn;
	private Button btnSendLable;
	private Button btnSendLableRecovery;
	private String stringLink;
	private String smsContent;
	private boolean sendWithPc = true;
	
	private String theTime;
	private String thePosition;
	private int theNumber;
	private String theContent;
	private boolean sendSMS = true;
	private MultiAutoCompleteTextView peopleNumbers;
	private ArrayList<MyPerson> personList;
	private String names = "";
	private List<String> tempPhoneNumbers;
	private List<String> tempEmailAddress;
	private String oneNumber;
	
	private Thread threadSendMessage;
	private Cursor cursor;
	private String userName;
	static final String NAME_COLUMN = Contacts.DISPLAY_NAME;

	
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
		if(sendSMS){
			getContacts();
		}
		
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
		    String info =name+"的\n \t\t电话是："+phone;
		    
		    info += "\n \t\t电子邮件："+showEmail(myCursor);
		    //tv.setText(info);
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
		   //显示电子邮件
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
			Bundle dataBundle = (Bundle)intent.getBundleExtra(Constants.TO_SEND_ACTIVITY);
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
			
		}
	}
	
	
	public void init(){
		
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
				
				//Toast.makeText(SendAirenaoActivity.this, "asd", Toast.LENGTH_LONG).show();
				Intent intent = new Intent();
				intent.setClass(SendAirenaoActivity.this, ContactsListActivity.class);
				startActivityForResult(intent, 24);//24 只是一个requestCode 没有别的意义
				return false;//
				
			}
		});
		//发送
		 btnSendLable.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
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
							//保存数据？？？？？
							
							
							Intent myIntent = new Intent(SendAirenaoActivity.this,MeetingListActivity.class);
							startActivity(myIntent);
						}
						
					})
					.create();
					noticeDialog.show();	
				}
				
				if(ckSendLableWithLink.isChecked()){
					stringLink = getString(R.string.sendLableLink);
				}
				
				smsContent = "";
				smsContent = txtSendLableContent.getText().toString()+ "\n" + stringLink;
				
				getPhoneNumbersOrgetEmail(sendSMS);
				if(smsContent.length() > 140){
					//return;
				}
				if(sendSMS){
					//如果用自己手机发送
					if(ckSendLableUseOwn.isChecked()){
						if(tempPhoneNumbers.size() > 0){
							sendSMSorEmail(sendSMS,!sendWithPc);
						}else{
							//保存数据
						}
					}else{
						//使用后台电脑发送
						if(tempEmailAddress.size() > 0){
							sendSMSorEmail(sendSMS,sendWithPc);
						}else{
							//保存数据
						}
					}
				}else{
					//使用Email发送
					sendSMSorEmail(!sendSMS,sendWithPc);
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
			tempPhoneNumbers = new ArrayList<String>();
			//电话本中的电话
			if(personList != null && personList.size()>0){
				for(int i = 0;i < personList.size();i++){
					oneNumber =  personList.get(i).getPhoneNumber();
					tempPhoneNumbers.add(oneNumber);
				}
			}
			//用户自己输入的电话
			
			String inputedPhoneNumbers = peopleNumbers.getText().toString();
			String[] phoneNumbers = inputedPhoneNumbers.split(";", 0);
			for(int i = 0;i < phoneNumbers.length;i++){
				if(AirenaoUtills.checkPhoneNumber(phoneNumbers[i])){
					tempPhoneNumbers.add(phoneNumbers[i]);
				}
			}
			
			return tempPhoneNumbers;
		}else{
			tempEmailAddress = new ArrayList<String>();
			return tempEmailAddress;
		}
		
	}
	
	/**
	 * 发送信息
	 * @param sendSms
	 */
	public void sendSMSorEmail(final boolean sendSms,
		final boolean sendWithPC){
		showDialog(1);
		threadSendMessage = new Thread(){

			@SuppressWarnings("deprecation")
			@Override
			public void run() {
				if(sendSms){
					if(!sendWithPC){
						//用自己手机发送
						for(int i=0;i<tempPhoneNumbers.size();i++){
							SmsManager mySmsManager = SmsManager.getDefault();
							PendingIntent pendingIntent = PendingIntent.getBroadcast(SendAirenaoActivity.this, 0, new Intent(), 0);
							mySmsManager.sendTextMessage(tempPhoneNumbers.get(i), null, smsContent, pendingIntent, null);
						}
						dismissDialog(1);
					}else{
					   //用电脑发送
						
						dismissDialog(1);
					}
				}else{
					//发送Email
					
					dismissDialog(1);
				}
				
			}
			
		};
		
		threadSendMessage.start();
	}
	/**
	 * 保存数据
	 */
	public void saveData(){
		
	}
	//获得返回的数据
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		
		
		super.onActivityResult(requestCode, resultCode, data);
		if(21 == resultCode){
			names = "";
			String beforeNames = peopleNumbers.getText().toString();
			names = beforeNames;
			personList = data.getParcelableArrayListExtra(Constants.FROMCONTACTSLISTTOSEND);
			if(personList != null && personList.size() > 0){
				for(int i = 0;i < personList.size();i++){
					 
					names += personList.get(i).getName()+";";
				}
				peopleNumbers.setText(names);
			}
		}
		
	}
	
	@Override
	protected Dialog onCreateDialog(int id) {
		ProgressDialog dialog = new ProgressDialog(this);
		dialog.setMessage("正在发送...");
		dialog.setIndeterminate(true);
		dialog.setCancelable(true);
		return dialog;

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
	
}


