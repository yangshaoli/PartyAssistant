package com.aragoncg.apps.airenao.activity;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.preference.PreferenceScreen;
import android.widget.Toast;

public class PersoninfoSetActivity extends PreferenceActivity implements
		Preference.OnPreferenceChangeListener,
		Preference.OnPreferenceClickListener {
	/** Called when the activity is first created. */
	private EditTextPreference number_editPreference;
	private EditTextPreference mail_editPreference;
	private EditTextPreference nickname_editPreference;
	private SharedPreferences pre;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.addPreferencesFromResource(R.xml.setting);
		ActivityManager.getInstance().addActivity(this);
		number_editPreference = (EditTextPreference) findPreference("warning_phone");
		mail_editPreference = (EditTextPreference) findPreference("warning_mail");
		nickname_editPreference = (EditTextPreference) findPreference("warning_nickname");

		number_editPreference.setOnPreferenceClickListener(this);
		number_editPreference.setOnPreferenceChangeListener(this);
		number_editPreference.setOnPreferenceClickListener(this);
		mail_editPreference.setOnPreferenceChangeListener(this);
		mail_editPreference.setOnPreferenceClickListener(this);
		mail_editPreference.setOnPreferenceChangeListener(this);
		nickname_editPreference.setOnPreferenceChangeListener(this);
		nickname_editPreference.setOnPreferenceClickListener(this);
		nickname_editPreference.setOnPreferenceChangeListener(this);
		pre = PreferenceManager.getDefaultSharedPreferences(this);
		number_editPreference.setSummary(pre
				.getString("warning_phone", "phone"));
		nickname_editPreference.setSummary(pre.getString("warning_nickname",
				"nickname"));
		mail_editPreference.setSummary(pre.getString("warning_mail", "mail"));
	}

	@Override
	public boolean onPreferenceTreeClick(PreferenceScreen preferenceScreen,
			Preference preference) {

		if (preference.getKey().equals("warning_time")) {

		}

		return super.onPreferenceTreeClick(preferenceScreen, preference);
	}

	@Override
	public boolean onPreferenceChange(Preference preference, Object newValue) {

		if (preference == number_editPreference) {

			pre.edit().putString("warning_phone", newValue.toString()).commit();
			number_editPreference.setSummary(newValue.toString());

			return true;
		}
		if (preference == mail_editPreference) {
			pre.edit().putString("warning_mail", newValue.toString()).commit();
			mail_editPreference.setSummary(newValue.toString());

			return true;
		}
		if (preference == nickname_editPreference) {
			pre.edit().putString("warning_nickname", newValue.toString())
					.commit();
			nickname_editPreference.setSummary(newValue.toString());

			return true;
		}
		return false;
	}

	@Override
	public boolean onPreferenceClick(Preference preference) {
		if (preference == number_editPreference) {

		}
		return false;
	}

}