package com.aragoncg.apps.airenao.activity;

import com.aragoncg.apps.airenao.utills.AirenaoUtills;

import com.aragoncg.apps.airenao.R;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceActivity;

public class SettingActivity extends PreferenceActivity implements Preference.OnPreferenceChangeListener,
Preference.OnPreferenceClickListener {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		AirenaoUtills.activityList.add(this);
		addPreferencesFromResource(R.xml.preference);
	}

	@Override
	public boolean onPreferenceClick(Preference preference) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean onPreferenceChange(Preference preference, Object newValue) {
		// TODO Auto-generated method stub
		return false;
	}
	
}
