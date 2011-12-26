package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnTouchListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.TimePicker.OnTimeChangedListener;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class CreateActivity extends Activity implements OnClickListener {
	public static final int startTimePicker = 0x7f050004;
	public static final int send_Email = 0x7f05000f;
	public static final int send_SMS = 0x7f05000e;
	public static final int ok = 0x7f050012;
	public static final int cancle = 0x7f050018;
	public static final int nextBtn=0x7f050015;
	public static final int MENU_SET = 0;
	public static final int MENU_OFF = 1;

	private int mYear;
	private int mMonth;
	private int mDay;
	private int mHour;
	private int mMinute;
	private EditText startTimeText;
	private EditText positionText;
	private TextView peopleLimitNum;
	private TextView activityDescText;
	private TextView userTitle;
	private LinearLayout userLayout;
	private boolean firstSetTime = true;
	private boolean sendSmsOrnot = true;
	private boolean fromDetail = false;
	private String activityTime;
	private String position;
	private String limitNum;
	private String activityDes;
	private List<AirenaoActivity> activitys;
	private AirenaoActivity activityFromDetail;
	private AirenaoActivity activityDb;
	private HashMap<String, String> clientMap;
	
	private Button btnSendSMS;
	private Button btnSendEmail;
	
	private Thread dbThread;
	private Thread saveDataThread;
	private DbHelper myDbHelper;
	private boolean isOk = false;
	private SQLiteDatabase db;
	private AirenaoActivity theLastData;
	private String userName;
	private String passWord;
	private Runnable editSaveRun;
	private Runnable getClientRun;
	private String userId;
	private Handler myHandler;
	private String msgType;
	
	private static final int SUCCESS = 4;
	private static final int FAIL = 3;
	private static final int EXCEPTION = 2;
	private static final int MSG_ID_SUCC = 5;
	private static final int MSG_ID_FAIL = 6;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		
		setContentView(R.layout.create_activity);
		AirenaoUtills.activityList.add(this);
		activitys = new ArrayList<AirenaoActivity>() ;
		Intent intent = getIntent();
		initView();
		getCurrentTime();
		createDbThread(this);
		dbThread.run();
		SQLiteDatabase db = DbHelper.openOrCreateDatabase();
		try{
			DbHelper.delete(db, DbHelper.deleteLastSql);
		}catch(Exception e){
			e.printStackTrace();}
		finally{db.close();}
		if(intent != null){
			initData(intent);
		}
		reSetUI();
		initMyHandler();
		initRunable();
	}
	
	
	public void initRunable(){
		editSaveRun = new Runnable() {
			
			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				String url = getString(R.string.editUrl);
				HashMap<String, String> params = new HashMap<String, String>();
				params.put("partyID", activityFromDetail.getId()+"");
				
				String time = startTimeText.getText().toString();
				if(time==null || "".equals(time)){
					params.put(Constants.START_TIME, "");
				}else{
					params.put(Constants.START_TIME, time+":00");
				}
				
				String positon = positionText.getText().toString();
				if(positon==null || "".equals(positon)){
					params.put(Constants.LOCATION, "");
				}else{
					params.put(Constants.LOCATION, positon);
				}
				
				String myNumber = peopleLimitNum.getText().toString().trim();
				if(myNumber.equals("")){
					params.put(Constants.POEPLE_MAXIMUM, "0");
				}
				params.put(Constants.POEPLE_MAXIMUM, myNumber);
				params.put(Constants.DESCRIPTION, activityDescText.getText().toString());
				params.put("uID", userId);
				//myAirenaoActivity
				String result = httpHelper.performPost(url, params, CreateActivity.this);
				result = AirenaoUtills.linkResult(result);
				try {
					JSONObject output = new JSONObject(result).getJSONObject(Constants.OUT_PUT);
					String status = output.getString(Constants.STATUS);
					String description = output.getString(Constants.DESCRIPTION);
					if("ok".equals(status)){
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(SUCCESS+"", description);
						message.what = SUCCESS;
						message.setData(bundle);
						myHandler.sendMessage(message);
					}
					
					if(!"ok".equals(status)){
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(FAIL+"", description);
						message.what = FAIL;
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
		};
		
		getClientRun = new Runnable() {
			
			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				String url = getString(R.string.getPartyMsg);
				url = url+activityFromDetail.getId()+"/";
				//myAirenaoActivity
				String result = httpHelper.performGet(url, CreateActivity.this);
				result = AirenaoUtills.linkResult(result);
				
				try {
					JSONObject output = new JSONObject(result).getJSONObject(Constants.OUT_PUT);
					String status = output.getString(Constants.STATUS);
					String description = output.getString(Constants.DESCRIPTION);
					if("ok".equals(status)){
						
						clientMap = new HashMap<String, String>();
						JSONObject dataSource = output.getJSONObject("datasource");
						//'_isApplyTips':BOOL,
						//'_isSendBySelf':BOOL
						msgType = dataSource.getString("msgType");
						JSONArray receiverArray = dataSource.getJSONArray("receiverArray");
						JSONObject client;
						for(int i=0;i<receiverArray.length();i++){
							client = receiverArray.getJSONObject(i);
							clientMap.put(client.getString("cName"), client.getString("cVal"));
						}
						String receiverType = dataSource.getString("receiverType");
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(MSG_ID_SUCC+"", description);
						message.what = MSG_ID_SUCC;
						message.setData(bundle);
						myHandler.sendMessage(message);
					}
					
					if(!"ok".equals(status)){
						
						Message message = new Message();
						Bundle bundle = new Bundle();
						bundle.putString(MSG_ID_FAIL+"", description);
						message.what = MSG_ID_FAIL;
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
				
		};
		
	}
	
	@Override
	protected void onResume() {
		
		// TODO Auto-generated method stub
		super.onResume();
		
	}


	@Override
	protected void onPause() {
		
		// TODO Auto-generated method stub
		super.onPause();
		
	}


	@Override
	protected void onDestroy() {
	  if(!isOk){
		    //收集数据
			saveAirenaoActivity();
			//保存数据
			if(activitys.size() > 0){
			saveDataThread(activitys);
			saveDataThread.run();
			activitys.clear();
			}
	  }
		
		super.onDestroy();
		 
	}


	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case startTimePicker:
			showSetTimeDialog(firstSetTime);
			break;
		case nextBtn:
			saveAirenaoActivity();
			break;
		default:
			break;

		}

	}
	
	@Override  
	public boolean onKeyDown(int keyCode, KeyEvent event) {  
		activityDes = activityDescText.getText().toString();
	    if (keyCode == KeyEvent.KEYCODE_BACK) {  
	    	if(fromDetail){
	    		
	    	}else{
	    		if(this.activityDes != null && !"".equals(this.activityDes)){
	    			this.activityTime = this.startTimeText.getText().toString();
			    	this.position = this.positionText.getText().toString();
			    	this.limitNum = this.peopleLimitNum.getText().toString();
			    	this.activityDes = this.activityDescText.getText().toString();
			    	
			    	 AlertDialog noticeDialog = new AlertDialog.Builder(CreateActivity.this)
						.setCancelable(true)
						.setTitle(R.string.sendLableTitle)
						.setMessage(R.string.createToList)
						.setNegativeButton(R.string.btn_cancle, new android.content.DialogInterface.OnClickListener() {
							
							@Override
							public void onClick(DialogInterface dialog, int which) {
								
								
							}
						})
						.setPositiveButton(R.string.btn_ok, new android.content.DialogInterface.OnClickListener(){

							@Override
							public void onClick(DialogInterface dialog, int which) {
								isOk = true;
								Intent myIntent = new Intent(CreateActivity.this,MeetingListActivity.class);
								startActivity(myIntent);
								
							}
							
						})
						.create();
			    	noticeDialog.show();	
			        event.startTracking();  
			        return isOk; 
	    		}
	    		
	    	}
	     
	    }  
	    return super.onKeyDown(keyCode, event);  
	}  
	
	/**
	 * 
	 * Method:showSetTimeDialog: TODO(show set time dialog)
	 * 
	 * @author cuikuangye void
	 * @Date 2011 2011-11-3 pm 12:38:20
	 * @throws
	 * 
	 */
	public void showSetTimeDialog(boolean startTimeOrNot) {
		LinearLayout setTimeDialogLayout = (LinearLayout) this
				.getLayoutInflater().inflate(R.layout.show_time_picker, null);
		final AlertDialog setTimeDialog = new AlertDialog.Builder(
				CreateActivity.this).setCancelable(true)
				.setTitle(R.string.set_time_title)
				.setIcon(R.drawable.time_clock).setView(setTimeDialogLayout)
				.create();
		addSetTimeBtnListener(setTimeDialogLayout, setTimeDialog, firstSetTime);
		setTimeDialog.show();

	}

	/**
	 * 
	 * Method:addSetTimeBtnListener TODO(add set time button listener)
	 * 
	 * @author cuikuangye
	 * @param setTimeDialogLayout
	 *            void
	 * @Date 2011 2011-11-3 pm 5:06:43
	 * @throws
	 * 
	 */
	public void addSetTimeBtnListener(LinearLayout setTimeDialogLayout,
			final AlertDialog setTimeDialog, final boolean startTimeOrNot) {
		final Button btnOk = (Button) setTimeDialogLayout.findViewById(R.id.ok);
		btnOk.setText(getString(R.string.btn_ok));
		DatePicker datePicker = (DatePicker) setTimeDialogLayout
				.findViewById(R.id.datePicker);
		TimePicker timePicker = (TimePicker) setTimeDialogLayout
				.findViewById(R.id.timePicker);
		timePicker.setIs24HourView(true);
		timePicker.setOnTimeChangedListener(new OnTimeChangedListener() {

			public void onTimeChanged(TimePicker view, int hourOfDay, int minute) {

				mHour = hourOfDay;
				mMinute = minute;
				updateDisplay(false);
			}
		});
		datePicker.init(mYear, mMonth, mDay,
				new DatePicker.OnDateChangedListener() {

					@Override
					public void onDateChanged(DatePicker view, int year,
							int monthOfYear, int dayOfMonth) {
						mYear = year;
						mMonth = monthOfYear;
						mDay = dayOfMonth;
						updateDisplay(false);
					}
				});
		btnOk.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				updateDisplay(false);
				setTimeDialog.dismiss();
				
			}
		});

	}

	/**
	 * 
	 * Method:setButtonListenner: TODO(add buttons Listener)
	 * 
	 * @author cuikuangye void
	 * @Date 2011 2011-11-3 pm 1:01:03
	 * @throws
	 * 
	 */
	public void initView() {
		startTimeText = (EditText) findViewById(R.id.startTimeText);
		positionText = (EditText) findViewById(R.id.positionEditText);
		peopleLimitNum = (TextView) findViewById(R.id.peopleNumEditText);
		userLayout = (LinearLayout)findViewById(R.id.userChange);
		userLayout.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				AlertDialog dialog = new AlertDialog.Builder(CreateActivity.this)
				.setTitle(R.string.user_off)
				.setMessage(R.string.user_off_message)
				.setPositiveButton(R.string.btn_ok, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						Intent intent = new Intent();
						intent.setClass(CreateActivity.this, LoginActivity.class);
						startActivity(intent);
					}
				})
				.create();
				dialog.show();
				
			}
		}); 
		btnSendSMS = (Button) findViewById(R.id.btnSendSMS);
		btnSendEmail = (Button)findViewById(R.id.btnSendEmail);
		
		
		
		//默认软键盘为数字键
		peopleLimitNum.setInputType(InputType.TYPE_CLASS_NUMBER);
		activityDescText = (TextView) findViewById(R.id.descrEditText);

		startTimeText.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if(event.getAction() == MotionEvent.ACTION_UP){
					showSetTimeDialog(firstSetTime);
				}
				return false;
				
			}
		});

		positionText.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				position = positionText.getText().toString();
				if (position.length() > 256) {
					Toast.makeText(CreateActivity.this,
							getString(R.string.position_too_lang),
							Toast.LENGTH_LONG).show();
					position = "";
					positionText.setText("");
					positionText.getFocusables(View.FOCUS_FORWARD);
					return;
				}
			}
		});

		peopleLimitNum.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {

				// TODO Auto-generated method stub
				limitNum = peopleLimitNum.getText().toString();
				String regEx = AirenaoUtills.regDigital;
				
				boolean result = AirenaoUtills.matchString(regEx, limitNum);
				if (!limitNum.equals("")) {
					if (!result) {
						Toast.makeText(CreateActivity.this,
								getString(R.string.wrong_num),
								Toast.LENGTH_LONG).show();
						peopleLimitNum.setText("");
						peopleLimitNum.getFocusables(View.FOCUS_FORWARD);
						return;
					}
					if (Integer.valueOf(limitNum) > 1000
							|| Integer.valueOf(limitNum) < 0) {
						Toast.makeText(CreateActivity.this,
								getString(R.string.limit_num),
								Toast.LENGTH_LONG).show();
						peopleLimitNum.setText("");
						peopleLimitNum.getFocusables(View.FOCUS_FORWARD);
						return;
					}

				}
			}
		});
		
		activityDescText.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {

				// TODO Auto-generated method stub
				activityDes = activityDescText.getText().toString();
			}
		});
		
		
	}
	
	
	/**
	 * 
	 * Method:getCurrentTime TODO(获得系统当前的时间)
	 * 
	 * @Date 2011 2011-11-3 pm 5:11:51
	 * @throws
	 * 
	 */
	public void getCurrentTime() {
		final Calendar c = Calendar.getInstance();
		mYear = c.get(Calendar.YEAR);
		mMonth = c.get(Calendar.MONTH);
		mDay = c.get(Calendar.DAY_OF_MONTH);
		mHour = c.get(Calendar.HOUR_OF_DAY);
		mMinute = c.get(Calendar.MINUTE);
		updateDisplay(firstSetTime);
	}

	/**
	 * 
	 * Method:updateDisplay TODO(更新时间)
	 */
	private void updateDisplay( boolean startTimeOrNot) {
		StringBuilder time = new StringBuilder()
				// Month is 0 based so add 1
				.append(mYear).append("-").append(mMonth + 1).append("-")
				.append(pad(mDay)).append(" ").append(pad(mHour)).append(":")
				.append(pad(mMinute)).append("");
		if (startTimeOrNot == true) {
			startTimeText.setText("");
			activityTime = time.toString();

		} else {
			/*
			 * 
			 */
			startTimeText.setText(time);
			activityTime = time.toString();
			this.firstSetTime = false;
		}

	}

	private static String pad(int c) {
		if (c >= 10)
			return String.valueOf(c);
		else
			return "0" + String.valueOf(c);
	}
	
	/**
	 * 
	 *   Method:saveAirenaoActivity:
	 *   TODO(get the Activity demo)
	 *
	 */
	public void saveAirenaoActivity(){
		//获得数据
		activitys.clear();
		activityDes = activityDescText.getText().toString();
		if((this.activityDes == null || "".equals(this.activityDes))){
			activitys.clear();
			
		}else{
			if(this.activityDes == null){
				this.activityDes = "";
			}
			if(this.position == null){
				this.activityDes = "";
			}
		AirenaoActivity tempActivity = new AirenaoActivity();
		if(this.activityDes.length()>8){
			tempActivity.setActivityName(this.activityDes.substring(0, 8));
		}else{
		tempActivity.setActivityName(this.activityDes.trim());
		}
		tempActivity.setActivityTime(this.activityTime);
		tempActivity.setActivityPosition(this.position);
		if(this.limitNum == null || "".equals(this.limitNum)){
			this.limitNum = "0";
		}
		tempActivity.setPeopleLimitNum(Integer.valueOf(limitNum));
		tempActivity.setActivityContent(this.activityDes);
		activitys.add(tempActivity);
		}
	}
	//创建数据库，并插入数据
	public void createDbThread(final Context context){
		dbThread = new Thread(){

			@Override
			public void run() {
				
					DbHelper.getInstance(CreateActivity.this);
			}
		  };
	}
	
	//保存数据
	public void saveDataThread(List<AirenaoActivity> list){
		final List<AirenaoActivity> myList;
		myList = list;
		saveDataThread  = new Thread(){

			@Override
			public void run() {
				db = DbHelper.openOrCreateDatabase();
				//先删除再保存
				try{
					DbHelper.delete(db,DbHelper.deleteLastSql);
					DbHelper.insert(db, myList.get(0));
				}catch(Exception e){
					e.printStackTrace();
				}finally{
					db.close();
				}
				
			}
			
		};
	}
	
	public void initMyHandler(){
		myHandler = new Handler(){

			@Override
			public void handleMessage(Message msg) {
				switch(msg.what){
				 case SUCCESS:
					   
					
					 break;
				 case FAIL:
					 Toast.makeText(CreateActivity.this, "保存失败", Toast.LENGTH_SHORT);
					 break;
				 case EXCEPTION:
					 Toast.makeText(CreateActivity.this, "出现异常", Toast.LENGTH_SHORT);
					 break;
				 case MSG_ID_FAIL:
					 
					 Toast.makeText(CreateActivity.this, (String)msg.getData().get(MSG_ID_FAIL+""), Toast.LENGTH_SHORT);
					 break;
				 case MSG_ID_SUCC:
					 if(msgType.equals("SMS")){
						    Intent mIntent = new Intent(CreateActivity.this,SendAirenaoActivity.class);
						    activityFromDetail.setClients(clientMap);
							mIntent.putExtra("sendWithClients", activityFromDetail);
							mIntent.putExtra("sendWithClientsTag", true);
							mIntent.putExtra("mode", -2);//-2发送短信
							startActivity(mIntent);
					 }else{
						 	Intent mIntent = new Intent(CreateActivity.this,SendAirenaoActivity.class);
						 	activityFromDetail.setClients(clientMap);
							mIntent.putExtra("sendWithClients", activityFromDetail);
							mIntent.putExtra("sendWithClientsTag", true);
							mIntent.putExtra("mode", -1);//-2发送Email
							startActivity(mIntent);
					 }
					 break;
				}
				
				super.handleMessage(msg);
			}
			
		};
	} 
	
	//如果数据是从活动明细转过来的那么就配置数据
	public void initData(Intent intent){
		SharedPreferences mySharedPreferences = AirenaoUtills.getMySharedPreferences(CreateActivity.this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME, null);
		
		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);
		Editor editor = mySharedPreferences.edit();
		editor.putInt(Constants.APP_USED_FLAG, Constants.APP_USED_FLAG_O);
		editor.commit();
		
		activityFromDetail = (AirenaoActivity) intent.getSerializableExtra(Constants.TO_CREATE_ACTIVITY);
		fromDetail = intent.getBooleanExtra(Constants.FROMDETAIL,false);
		activityDb = (AirenaoActivity) intent.getSerializableExtra(Constants.TRANSFER_DATA);
		if(activityDb != null){
			this.startTimeText.setText(activityDb.getActivityTime());
			this.positionText.setText(activityDb.getActivityPosition());
			this.peopleLimitNum.setText(String.valueOf(activityDb.getPeopleLimitNum()));
			this.activityDescText.setText(activityDb.getActivityContent());
		}
		//邀请人的所有电话数据
		if(activityFromDetail != null && fromDetail == true){
			this.startTimeText.setText(activityFromDetail.getActivityTime());
			this.positionText.setText(activityFromDetail.getActivityPosition());
			this.peopleLimitNum.setText(String.valueOf(activityFromDetail.getPeopleLimitNum()));
			this.activityDescText.setText(activityFromDetail.getActivityContent());
		}
		
	}
	
	
	/**
	 * 查询数据库中是否有残存的数据，但并不是用户自己存的
	 * @return
	 */
	public AirenaoActivity getLastAirenaoData(){
		AirenaoActivity airenao = null;
		if(db == null){
			return airenao;
		}else{
			airenao = DbHelper.select(db);
		}
		return airenao;
	}
	
	//要发送的数据
	/**
	 * -2代表发送手机短信
	 * -1代表发送Emial
	 * @param sendTag
	 */
	public void packgeDataToSendAirenaoActivity(int sendTag){
		String content = activityDescText.getText().toString();
		if("".equals(content)){
			Toast.makeText(CreateActivity.this,R.string.send_lable_content_tip , Toast.LENGTH_SHORT).show();
			return;
		}
		Bundle dataBundle = new Bundle();
		
		String time = startTimeText.getText().toString();
		if(time==null || "".equals(time)){
			dataBundle.putString(Constants.SEND_TIME, "");
		}else{
			dataBundle.putString(Constants.SEND_TIME, time);
		}
		
		String positon = positionText.getText().toString();
		if(positon==null || "".equals(positon)){
			dataBundle.putString(Constants.SEND_POSITION, "");
		}else{
			dataBundle.putString(Constants.SEND_POSITION, positon);
		}
		
		String myNumber = peopleLimitNum.getText().toString().trim();
		if(myNumber.equals("")){
			myNumber = "0";
		}
		dataBundle.putInt(Constants.SEND_NUMBER,Integer.valueOf(myNumber));
		
		dataBundle.putString(Constants.SEND_CONTENT, activityDescText.getText().toString());
		
		Intent mIntent = new Intent(CreateActivity.this,SendAirenaoActivity.class);
		mIntent.putExtra(Constants.TO_SEND_ACTIVITY, dataBundle);
		mIntent.putExtra("mode", sendTag);
		startActivity(mIntent);
	}
	
	public void reSetUI(){
		
		
		if(fromDetail){
			btnSendSMS.setText("     保存       ");
			btnSendEmail.setText("保存并发送");
            btnSendSMS.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					//保存
					myHandler.post(editSaveRun);
					Intent intent = new Intent(
							CreateActivity.this,
							MeetingListActivity.class);
					intent.putExtra(Constants.NEED_REFRESH, true);
					startActivity(intent);
				}
			});
			
			btnSendEmail.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					//保存并发送
					myHandler.post(editSaveRun);
					myHandler.post(getClientRun);
					
				}
			});
			
		}else{
			btnSendSMS.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					//-2 发送手机短信
					packgeDataToSendAirenaoActivity(-2);
				}
			});
			
			btnSendEmail.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					//-1 是发送email
					packgeDataToSendAirenaoActivity(-1);
				}
			});
		}
		
		
		userTitle = (TextView)findViewById(R.id.userTitle);
		userTitle.setText(userName);
	}


	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		  menu.add(0, MENU_SET, 0, getString(R.string.btn_setting)); 
		  menu.add(0, MENU_OFF, 0, getString(R.string.user_off)); 
		    
		return super.onCreateOptionsMenu(menu);
	}


	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		  switch (item.getItemId()) { 
		    case MENU_SET: 
		    	AlertDialog settingDialog = new AlertDialog.Builder(CreateActivity.this)
		    	.setTitle(R.string.btn_setting)
		    	.setIcon(R.drawable.settings)
		    	.setItems(R.array.setMenu, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						switch(which){
						 case 0:
							 break;
						 	 
						 case 1:
							 break;
						}
					}
				})
		    	.create();
		    	settingDialog.show();
		        return true; 
		    case MENU_OFF: 
		    	AlertDialog dialog = new AlertDialog.Builder(CreateActivity.this)
				.setTitle(R.string.user_off)
				.setMessage(R.string.user_off_message)
				.setPositiveButton(R.string.btn_ok, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						Intent intent = new Intent();
						intent.setClass(CreateActivity.this, LoginActivity.class);
						startActivity(intent);
					}
				})
				.create();
				dialog.show();
		        return true; 
		  }
		return super.onOptionsItemSelected(item);
	}
	
	
	
	
}