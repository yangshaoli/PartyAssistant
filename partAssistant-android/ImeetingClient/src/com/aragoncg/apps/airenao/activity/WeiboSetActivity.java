package com.aragoncg.apps.airenao.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;

public class WeiboSetActivity extends Activity implements OnClickListener{
	private Button btnLogin;
	private String btnTxt;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		ActivityManager.getInstance().addActivity(this);
		setContentView(R.layout.weibo_login);
		
		btnLogin = (Button) findViewById(R.id.btnWeiboLogin);
		btnLogin.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		btnTxt = btnLogin.getText().toString();
		if(getString(R.string.btnLogin).equals(btnTxt)){
			Intent intent = new Intent();
			intent.putExtra("LoginDireDirectly", true);
			intent.setClass(WeiboSetActivity.this,
					WeiBoSplashActivity.class);
			startActivity(intent);
		}else{
			//退出微博
			AlertDialog noticeDialog = new AlertDialog.Builder(
					WeiboSetActivity.this)
					.setCancelable(true)
					.setTitle(R.string.sendLableTitle)
					.setMessage(R.string.exitWeiboMsg)
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
									SharedPreferences spf = AirenaoUtills
											.getMySharedPreferences(WeiboSetActivity.this);
									Editor myEditor = spf.edit();
									myEditor.putString(WeiBoSplashActivity.EXTRA_ACCESS_TOKEN, null);
									myEditor.putString(WeiBoSplashActivity.EXTRA_TOKEN_SECRET, null);
									myEditor.commit();
									btnLogin.setText(R.string.btnLogin);

								}

							}).create();
			noticeDialog.show();
			
		}
		
		
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		if(intent.getBooleanExtra("loginSuccess", false)){
			btnLogin.setText("退出");
		}
	}
	
	
}
