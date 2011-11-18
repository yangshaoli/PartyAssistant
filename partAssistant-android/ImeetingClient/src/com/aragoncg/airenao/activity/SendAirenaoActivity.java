package com.aragoncg.airenao.activity;


import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.ImageButton;

import com.aragoncg.R;
import com.aragoncg.airenao.constans.Constants;

public class SendAirenaoActivity extends Activity {
	private ImageButton btnSendReciever;
	private EditText txtSendLableContent;
	private CheckBox ckSendLableWithLink;
	private CheckBox ckSendLableUseOwn;
	private Button btnSendLable;
	private Button btnSendLableRecovery;
	private String stringLink;
	
	private String theTime;
	private String thePosition;
	private int theNumber;
	private String theContent;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.send_airenao_layout);
		Intent dataIntent = getIntent();
		getItentData(dataIntent);
		init();
		 
	}
	
	public void getItentData(Intent intent){
		if(intent != null){
			Bundle dataBundle = (Bundle)intent.getBundleExtra(Constants.TO_SEND_ACTIVITY);
			theTime = dataBundle.getString(Constants.SEND_TIME).trim();
			thePosition = dataBundle.getString(Constants.SEND_POSITION).trim();
			theNumber = dataBundle.getInt(Constants.SEND_NUMBER);
			theContent = dataBundle.getString(Constants.SEND_CONTENT).trim();
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
		
		txtSendLableContent.setText(getString(R.string.txtSendLable));
		ckSendLableWithLink.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			
			@Override
			public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
				if(!isChecked){
					 AlertDialog noticeDialog = new AlertDialog.Builder(SendAirenaoActivity.this)
					.setCancelable(true)
					.setTitle(R.string.sendLableTitle)
					.setMessage(R.string.sendlableNotice)
					.setNegativeButton(R.string.btn_cancle, new OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							
							stringLink = "";
							
						}
					})
					.setPositiveButton(R.string.btn_ok, new OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int which) {
							
						}
					})
					.create();
					 
					 noticeDialog.show();
				}else{
					stringLink = getString(R.string.sendLableLink);
				}
				
			}
		});
		
	}
}
