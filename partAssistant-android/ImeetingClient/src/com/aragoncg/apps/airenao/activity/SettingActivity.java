package com.aragoncg.apps.airenao.activity;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

import com.aragoncg.apps.airenao.R;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.widget.Toast;

public class SettingActivity extends PreferenceActivity implements Preference.OnPreferenceChangeListener,
Preference.OnPreferenceClickListener {
	private EditTextPreference edtNickName;
	private String nickName;
	private String userId;
	private Thread saveNickNameTask;
	private Handler myHandler;
	SharedPreferences mySharedPreferences;
	private static final int SAVE_NICK_NAME_OK = 0;
	private static final int SAVE_NICK_NAME_FAIL = 1;
	private static final int SAVE_NICK_NAME_ERROR = 2;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		AirenaoUtills.activityList.add(this);
		addPreferencesFromResource(R.xml.preference);
		initView();
		initHandler();
	}
	
	public void initView(){
		edtNickName = (EditTextPreference) findPreference("warning_nickname");
		edtNickName.setOnPreferenceChangeListener(this);
		edtNickName.setOnPreferenceClickListener(this);
		mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(SettingActivity.this);
		edtNickName.setSummary(mySharedPreferences.getString(Constants.AIRENAO_NICKNAME, "更改您的昵称")); 
	}
	
	public void initHandler(){
		myHandler = new Handler(){

			@Override
			public void handleMessage(Message msg) {
				switch(msg.what){
				  case SAVE_NICK_NAME_OK:
					  mySharedPreferences.edit().putString(
								Constants.AIRENAO_NICKNAME, nickName).commit();
						edtNickName.setSummary((mySharedPreferences
								.getString(Constants.AIRENAO_NICKNAME, "")));
					  Toast.makeText(SettingActivity.this, R.string.setSuccess, 1500).show();
					  break;
				  case SAVE_NICK_NAME_FAIL:
					  Toast.makeText(SettingActivity.this, R.string.setFail, 1500).show();
					  break;
				  case SAVE_NICK_NAME_ERROR:
					  Toast.makeText(SettingActivity.this, R.string.setError, 1500).show();
					  break;
				}
				super.handleMessage(msg);
			}
			
		};
	}
	@Override
	public boolean onPreferenceClick(Preference preference) {
		
		return false;
	}

	@Override
	public boolean onPreferenceChange(Preference preference, Object newValue) {
		if (preference == edtNickName) {
			nickName = newValue.toString();
			SharedPreferences mySharedPreferences = AirenaoUtills
					.getMySharedPreferences(SettingActivity.this);
			userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, "");
			if (!"".equals(userId) && !"".equals(nickName)) {
				createSaveNickNameTask();
				myHandler.post(saveNickNameTask);
			}

			return true;
		}
		return false;
	}
	
	public void createSaveNickNameTask() {
		saveNickNameTask = new Thread() {

			@Override
			public void run() {
				String saveRegisterUrl = Constants.DOMAIN_NAME
						+ Constants.SUB_DOMAIN_SAVE_NICKNAME_RUL;
				Map<String, String> params = new HashMap<String, String>();
				params.put("uid", userId);
				params.put("nickname", nickName);
				String result = new HttpHelper().savePerformPost(
						saveRegisterUrl, params, SettingActivity.this);
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
						myHandler.sendEmptyMessage(SAVE_NICK_NAME_OK);
					} else {
						Message msg = new Message();
						msg.what = SAVE_NICK_NAME_FAIL;
						myHandler.sendMessage(msg);

					}
				} catch (JSONException e) {

					myHandler.sendEmptyMessage(SAVE_NICK_NAME_ERROR);
				}

			}
		};
	}
}
