package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;
import com.aragoncg.apps.xmpp.service.AndroidPushService;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.preference.PreferenceScreen;
import android.util.Log;
import android.widget.Toast;

public class PersoninfoSetActivity extends PreferenceActivity implements
		Preference.OnPreferenceChangeListener,
		Preference.OnPreferenceClickListener {
	/** Called when the activity is first created. */
	private EditTextPreference number_editPreference;
	private EditTextPreference mail_editPreference;
	private EditTextPreference nickname_editPreference;
	private SharedPreferences pre;
	SharedPreferences mySharedPreferences;
	public Thread registerSecondThread;
	public String uid = "";
	public String nickname = "";
	public String beforeName = "";
	public Handler myHandler;
	private ProgressDialog progressDialog;

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
		mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(PersoninfoSetActivity.this);

		number_editPreference.setSummary(pre
				.getString("warning_phone", "phone"));
		beforeName = mySharedPreferences.getString(Constants.AIRENAO_NICKNAME,
				"nickname");
		nickname = beforeName;
		nickname_editPreference.setSummary(nickname);
		nickname_editPreference.setText(nickname);
		mail_editPreference.setSummary(pre.getString("warning_mail", "mail"));

		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 1:
					if (progressDialog != null)
						progressDialog.dismiss();
					mySharedPreferences.edit().putString(
							Constants.AIRENAO_NICKNAME, nickname).commit();
					nickname_editPreference.setText(mySharedPreferences
							.getString(Constants.AIRENAO_NICKNAME, ""));
					nickname_editPreference.setSummary((mySharedPreferences
							.getString(Constants.AIRENAO_NICKNAME, "")));
					Toast.makeText(getApplicationContext(), "sucess",
							Toast.LENGTH_SHORT).show();
					break;
				case 2:
					if (progressDialog != null)
						progressDialog.dismiss();
					nickname = beforeName;
					Toast.makeText(getApplicationContext(), "fail",
							Toast.LENGTH_SHORT).show();
					break;
				case 3:
					progressDialog = ProgressDialog.show(
							PersoninfoSetActivity.this, "刷新",
							getString(R.string.loadAirenao), true, true);
				}
				super.handleMessage(msg);
			}

		};
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
			// nickname_editPreference.setText(mySharedPreferences.getString(Constants.AIRENAO_NICKNAME,
			// "nickname"));
			// pre.edit().putString("warning_nickname", newValue.toString())
			// .commit();
			// mySharedPreferences.edit().putString(Constants.AIRENAO_NICKNAME,newValue.toString()
			// );
			// nickname_editPreference.setSummary(mySharedPreferences.getString(Constants.AIRENAO_NICKNAME,
			// "nickname"));
			nickname = newValue.toString();
			SharedPreferences mySharedPreferences = AirenaoUtills
					.getMySharedPreferences(PersoninfoSetActivity.this);
			uid = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, "");
			if (!"".equals(uid) && !"".equals(nickname)) {
				Message msg = new Message();
				msg.what = 3;
				myHandler.sendMessage(msg);
				SecondThread();
				registerSecondThread.start();
			}

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

	public void SecondThread() {
		registerSecondThread = new Thread() {

			@Override
			public void run() {
				String saveRegisterUrl = Constants.DOMAIN_NAME
						+ Constants.SUB_DOMAIN_SAVE_NICKNAME_RUL;
				Map<String, String> params = new HashMap<String, String>();
				params.put("uid", uid);
				params.put("nickname", nickname);

				// 后台注册返回的结果
				String result = new HttpHelper().savePerformPost(
						saveRegisterUrl, params, PersoninfoSetActivity.this);
				result = AirenaoUtills.linkResult(result);

				JSONObject jsonObject;
				try {
					jsonObject = new JSONObject(result)
							.getJSONObject(Constants.OUT_PUT);
					String status;
					String description;
					status = jsonObject.getString(Constants.STATUS);
					description = jsonObject.getString(Constants.DESCRIPTION);
					if ("ok".equals(status)) {

						JSONObject jsonObject1 = jsonObject
								.getJSONObject("datasource");
						String tempNickname = jsonObject1.getString("nickname");
						if (tempNickname.equals(nickname)) {
							Message msg = new Message();
							msg.what = 1;
							myHandler.sendMessage(msg);

						}
					} else {
						Message msg = new Message();
						msg.what = 2;
						myHandler.sendMessage(msg);

					}
				} catch (JSONException e) {

					e.printStackTrace();
				}

			}
		};
	}

}