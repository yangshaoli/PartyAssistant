package com.aragoncg.apps.airenao.activity;

import com.aragoncg.apps.airenao.utills.AirenaoUtills;

import android.app.Activity;
import android.os.Bundle;

public class SettingActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		AirenaoUtills.activityList.add(this);
	}
	
}
