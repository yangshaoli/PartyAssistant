package com.aragoncg.airenao.activity;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.KeyEvent;
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

import com.aragoncg.R;
import com.aragoncg.airenao.DB.DbHelper;
import com.aragoncg.airenao.constans.Constants;
import com.aragoncg.airenao.model.AirenaoActivity;
import com.aragoncg.airenao.utills.AirenaoUtills;

public class CreateActivity extends Activity implements OnClickListener {
	public static final int startTimePicker = 0x7f050004;
	public static final int send_Email = 0x7f05000f;
	public static final int send_SMS = 0x7f05000e;
	public static final int ok = 0x7f050012;
	public static final int cancle = 0x7f050018;
	public static final int nextBtn=0x7f050015;

	private int mYear;
	private int mMonth;
	private int mDay;
	private int mHour;
	private int mMinute;
	private EditText startTimeText;
	private TextView endTimeText;
	private TextView positionText;
	private TextView peopleLimitNum;
	private TextView activityDescText;
	private boolean firstSetTime = true;
	private boolean sendSmsOrnot = true;
	private String activityTime;
	private String position;
	private String limitNum;
	private String activityDes;
	private List<AirenaoActivity> activitys;
	
	private Button btnSendSMS;
	private Button btnSendEmail;
	
	private Thread dbThread;
	private Thread saveDataThread;
	private DbHelper myDbHelper;
	private boolean isOk = false;
	
	

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		
		setContentView(R.layout.create_activity);
		activitys = new ArrayList<AirenaoActivity>() ;
		setWidgetListener();
		getCurrentTime();
		createDbThread(this);
		dbThread.run();
		
		// startTimeBtn.seto
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
		
	    if (keyCode == KeyEvent.KEYCODE_BACK) {  
	    	this.activityTime = this.startTimeText.getText().toString();
	    	this.position = this.positionText.getText().toString();
	    	this.limitNum = this.peopleLimitNum.getText().toString();
	    	this.activityDes = this.activityDescText.toString();
	    	
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
		Button btnOk = (Button) setTimeDialogLayout.findViewById(R.id.ok);
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
	public void setWidgetListener() {
		startTimeText = (EditText) findViewById(R.id.startTimeText);
		positionText = (TextView) findViewById(R.id.positionEditText);
		peopleLimitNum = (TextView) findViewById(R.id.peopleNumEditText);
		
		btnSendSMS = (Button) findViewById(R.id.btnSendSMS);
		btnSendEmail = (Button)findViewById(R.id.btnSendEmail);
		
		btnSendSMS.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
				Bundle dataBundle = new Bundle();
				dataBundle.putString(Constants.SEND_TIME, startTimeText.getText().toString());
				dataBundle.putString(Constants.SEND_POSITION, positionText.getText().toString());
				String myNumber = peopleLimitNum.getText().toString().trim();
				if(myNumber.equals("")){
					myNumber = "0";
				}
				dataBundle.putInt(Constants.SEND_NUMBER,Integer.valueOf(myNumber));
				dataBundle.putString(Constants.SEND_CONTENT, activityDescText.getText().toString());
				
				Intent mIntent = new Intent(CreateActivity.this,SendAirenaoActivity.class);
				mIntent.putExtra(Constants.TO_SEND_ACTIVITY, dataBundle);
				startActivity(mIntent);
				
			}
		});
		
		btnSendEmail.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
				
				
			}
		});
		
		//默认软键盘为数字键
		peopleLimitNum.setInputType(InputType.TYPE_CLASS_NUMBER);
		activityDescText = (TextView) findViewById(R.id.descrEditText);

		startTimeText.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				
				showSetTimeDialog(firstSetTime);
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
				.append(mYear).append("年").append(mMonth + 1).append("月")
				.append(pad(mDay)).append("日").append(pad(mHour)).append("时")
				.append(pad(mMinute)).append("分");
		if (startTimeOrNot == true) {
			startTimeText.setText("0000年00月00日00时00分");
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
		
		if((this.activityDes == null || "".equals(this.activityDes)) &&  (this.position == null
				|| "".equals(this.position)) && (this.limitNum == null || "".equals(this.limitNum))){
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
		if("".equals(this.limitNum)){
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
				myDbHelper = DbHelper.getInstance(context);
				myDbHelper.insert();
				
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
				myDbHelper.update(myList);
			}
			
		};
	}
}