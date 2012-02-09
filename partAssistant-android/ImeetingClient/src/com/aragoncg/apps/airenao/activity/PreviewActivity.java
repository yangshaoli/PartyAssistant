package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Parcelable;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.MyPerson;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;

public class PreviewActivity extends Activity {
	private Intent personIntent;
	private List<MyPerson> list;

	public static List<MyPerson> preList = new ArrayList<MyPerson>();

	private int count;
	private LinearLayout userLayout;
	private TextView userTitle;
	private String userName = "";

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
		this.getWindow().clearFlags(
				WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
		this.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
		getWindow().setSoftInputMode(
				WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

		setContentView(R.layout.activity_preview);
		preList.clear();
		list = getIntent().getParcelableArrayListExtra("ab");
		list.size();
		userLayout = (LinearLayout) findViewById(R.id.userChange);
		userTitle = (TextView) findViewById(R.id.userTitle);
		SharedPreferences mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME,
				null);
		if (!"".equals(userName) && userName != null) {
			userTitle.setText(userName);
		}
		ListView listView = (ListView) findViewById(R.id.listviewId);
		Button button = (Button) findViewById(R.id.btn_finish);
		ListViewAdapter listViewAdapter = new ListViewAdapter(this, list);
		listView.setAdapter(listViewAdapter);

		button.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {

				preList = deleteSameEntity(list);
				SendAirenaoActivity.activityFlag = true;
				finish();
			}
		});
	}

	@Override
	protected void onDestroy() {

		list.clear();
		super.onDestroy();
	}

	public List<MyPerson> deleteSameEntity(List<MyPerson> myPerson) {
		HashSet hashset = new HashSet(myPerson);
		List<MyPerson> relist = new ArrayList<MyPerson>();
		for (int i = 0; i < myPerson.size(); i++) {
			if (hashset.contains(myPerson.get(i))) // contains:该集合不包含指定元素，返回
				relist.add(myPerson.get(i));
		}
		return relist;
	}

}
