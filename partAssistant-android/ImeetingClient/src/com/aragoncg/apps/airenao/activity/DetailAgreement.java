package com.aragoncg.apps.airenao.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;

public class DetailAgreement extends Activity implements OnClickListener {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.detail_agreement);
		this.setTitle("关于协议");
		this.setTitleColor(Color.RED);
		TextView tv = (TextView) findViewById(R.id.emptyText);
		Button bt = (Button) findViewById(R.id.btnagree);
		bt.setOnClickListener(this);
		tv.setText("爱热闹服务涉及到的产品的所有权以及相关软件的知识产权归华美汉盛软件公司所有");
		tv.setTextColor(Color.RED);
		tv.setTextSize(24);
	}

	@Override
	public void onClick(View v) {
		Intent intent = new Intent();
		setResult(41, intent);
		finish();

	}

}
