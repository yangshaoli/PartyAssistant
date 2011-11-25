package com.aragoncg.apps.airenao.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;

public class RegisterActivity extends Activity {
	private String userNameReg;
	private String pass1Reg;
	private String pass2Reg;
	private boolean checked = false;
	private EditText pass1 ;
	private EditText pass2 ;
	private EditText userName;
	private Context myContext;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		 requestWindowFeature(Window.FEATURE_NO_TITLE);
		  AirenaoUtills.activityList.add(this);
	        setContentView(R.layout.register_layout);
	      
	        myContext = getBaseContext();
	        getTheWedgit(); 
	        
	      
	       

		
	}
	/**
	 * 
	 *   Method:getTheWedgit:
	 *   TODO(获得所有的组件并添加事件)
	 *   @author   cuikuangye   
	 *   void 
	 *   @Date	 2011	2011-11-7		am 10:45:46   
	 *   @throws 
	 *
	 */
	public void getTheWedgit(){
		 pass1 = (EditText)findViewById(R.id.reg_pass1);
		 pass2 =(EditText)findViewById(R.id.reg_pass2);
		 userName = (EditText)findViewById(R.id.reg_user_name);
		CheckBox myCheckBox = (CheckBox)findViewById(R.id.CheckBox);
		Button saveBtn = (Button)findViewById(R.id.appect);
		Button exitBtn = (Button)findViewById(R.id.exit);
		
		//获得内容或添加事件
				
		checked = myCheckBox.isChecked();
		//校验用户名
		
		userName.setOnFocusChangeListener(new OnFocusChangeListener() {
			
			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				
				if(!userName.hasFocus()){
					userNameReg = userName.getText().toString();
					//用户名校验
					/*boolean isDigital = AirenaoUtills.matchString(AirenaoUtills.regDigital, userNameReg);
					boolean isEmail = AirenaoUtills.matchString(AirenaoUtills.regEmail, userNameReg);
					if(!isEmail && !isDigital){
						Toast.makeText(RegisterActivity.this, R., duration)
					}*/
					if("".equals(userNameReg)){
						Toast.makeText(RegisterActivity.this,R.string.user_name_check, Toast.LENGTH_LONG).show();
						return;
					}
				}
				
			}
		});
		
		saveBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				userNameReg = userName.getText().toString();
				if(userNameReg == null || userNameReg.equals("") ){
					Toast.makeText(RegisterActivity.this, R.string.user_name_check, Toast.LENGTH_SHORT).show();
					return;
				}
				pass1Reg = pass1.getText().toString();
				pass2Reg = pass2.getText().toString();
				if(pass1Reg.length() < 6){
					Toast.makeText(RegisterActivity.this, R.string.pass_tip1, Toast.LENGTH_SHORT).show();
					return;
				}
				if("".equals(pass1Reg)){
					Toast.makeText(RegisterActivity.this, R.string.pass_tip, Toast.LENGTH_SHORT).show();
					return;
				}
				if("".equals(pass2Reg)){
					Toast.makeText(RegisterActivity.this, R.string.pass_tip2, Toast.LENGTH_SHORT).show();
					return;
				}
				if(!pass1Reg.equals(pass2Reg)){
					Toast.makeText(RegisterActivity.this, R.string.pass_tip3, Toast.LENGTH_LONG).show();
					return;
				}
				
				//用户名有了，密码有了，就可以自动登录了
				if(checked){
					/*
					 * 保存用户名和密码
					 * 
					 */
					 SharedPreferences mySharedPreferences = AirenaoUtills.getMySharedPreferences(myContext);
					 Editor editor = mySharedPreferences.edit();
					 editor.putString(Constants.AIRENAO_USER_NAME, userNameReg);
					 editor.putString(Constants.AIRENAO_PASSWORD, pass1Reg);
					 editor.commit();
					 
				        
					/**
					 * 
					 * 开启线程去登录
					 */
					Intent intent = new Intent(RegisterActivity.this,MeetingListActivity.class);
					startActivity(intent);
				}else{
					AlertDialog aDig =new AlertDialog.Builder(RegisterActivity.this)
					.setMessage(R.string.alert_message)
					.create();
					aDig.show();
					return;
				}
				
			}
		});
		exitBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				userName.setText("");
				pass1.setText("");
				pass2.setText("");
				checked = true;
				
			}
		});
		
	}
}
