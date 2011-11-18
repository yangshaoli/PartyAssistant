package com.aragoncg.airenao.activity;



import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.aragoncg.R;
import com.aragoncg.airenao.utills.AirenaoUtills;

public class LoginActivity extends Activity {
	private EditText userNameText;
	private EditText passWordText;
	private Button loginBtn;
	private Button findBackBtn;
	private String userName;
	private String passWord;
	
	
	 @Override
	    public void onCreate(Bundle savedInstanceState) {
	        super.onCreate(savedInstanceState);
	        requestWindowFeature(Window.FEATURE_NO_TITLE);
	        setContentView(R.layout.login);
	        getViewWedgit();
	        
	    }
	 
	 public void getViewWedgit(){
		 userNameText = (EditText)findViewById(R.id.username_edit);
		 passWordText = (EditText)findViewById(R.id.password_edit);
		 loginBtn = (Button)findViewById(R.id.signin_button);
		 findBackBtn = (Button)findViewById(R.id.find_back);
		 loginBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				boolean isEmail;
				userName = userNameText.getText().toString();
				passWord = passWordText.getText().toString();
				if(userName == null || "".equals(userName)){
					Toast.makeText(LoginActivity.this, R.string.user_name_check, Toast.LENGTH_LONG).show();
					return;
				}
				if(userName == null || "".equals(userName)){
					Toast.makeText(LoginActivity.this, R.string.pass_tip, Toast.LENGTH_LONG).show();
					return;
				}
				isEmail = AirenaoUtills.matchString(AirenaoUtills.regEmail, userName);
				if(!isEmail){
					new AlertDialog.Builder(LoginActivity.this)
	                .setIcon(R.drawable.alert_dialog_icon)
	                .setTitle(R.string.error_email)
	                .setNegativeButton(R.string.btn_cancle, new DialogInterface.OnClickListener() {
	                    public void onClick(DialogInterface dialog, int whichButton) {

	                       
	                    }
	                })
	                .create();
					return;
				}
				//启动线程登录？？？？？？？？？？？？？？？
				//做一些检测
			}
		});
		 
		 findBackBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				 LayoutInflater factory = LayoutInflater.from(LoginActivity.this);
		            final View textEntryView = factory.inflate(R.layout.alert_dialog_text_entry, null);
		             new AlertDialog.Builder(LoginActivity.this)
		                .setIcon(R.drawable.alert_dialog_icon)
		                .setTitle(R.string.find_lable_message)
		                .setView(textEntryView)
		                
		                .setPositiveButton(R.string.btn_ok, new DialogInterface.OnClickListener() {
		                    public void onClick(DialogInterface dialog, int whichButton) {
		                    	/*启动线程去发送*/
		                    	//如果是短信
		                    	//如果是email
		                        
		                    }
		                })
		                .setNegativeButton(R.string.btn_cancle, new DialogInterface.OnClickListener() {
		                    public void onClick(DialogInterface dialog, int whichButton) {

		                    }
		                })
		                .create().show();
				
				
			}
		});
	 }
	 
}
