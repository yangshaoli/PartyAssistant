package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
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
	private boolean flag = false;
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
		userLayout = (LinearLayout) findViewById(R.id.userChange);
		userTitle = (TextView)findViewById(R.id.userTitle);
		SharedPreferences mySharedPreferences = AirenaoUtills
		.getMySharedPreferences(this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME,
		null);
		if(!"".equals(userName) && userName != null){
			userTitle.setText(userName);
		}
		flag = false;
		ListView listView = (ListView) findViewById(R.id.listviewId);
		Button button = (Button) findViewById(R.id.btn_finish);
		list = deleteSameEntity(SendAirenaoActivity.staticData);
		ListViewAdapter listViewAdapter = new ListViewAdapter(this, list);
		listView.setAdapter(listViewAdapter);

		button.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (ContactsListActivity.exchangeList != null) {
					ContactsListActivity.exchangeList.clear();
					for (int i = 0; i < list.size(); i++) {
						MyPerson myPerson = SendAirenaoActivity.staticData
								.get(i);
						ContactsListActivity.exchangeList.add(myPerson);
					}
				}
				SendAirenaoActivity.activityFlag = true;
				flag = true;
				finish();
			}
		});
	}

	@Override
	protected void onDestroy() {
		if (!flag) {
			if (ContactsListActivity.firstEnter) {
				ContactsListActivity.exchangeList.clear();
				SendAirenaoActivity.staticData.clear();
				ContactsListActivity.firstEnter = false;
				super.onDestroy();
				return;
			}
			SendAirenaoActivity.staticData.clear();
			for (int i = 0; i < ContactsListActivity.exchangeList.size(); i++) {
				MyPerson myPerson = ContactsListActivity.exchangeList.get(i);
				SendAirenaoActivity.staticData.add(myPerson);
			}
		}
		if (list != null)
			list.clear();
		super.onDestroy();
	}

	public List<MyPerson> deleteSameEntity(List<MyPerson> myPerson) {

		HashSet hashset = new HashSet(myPerson);
		List<MyPerson> relist = new ArrayList<MyPerson>();
		for (int i = 0; i < myPerson.size(); i++) {
			if (hashset.contains(myPerson.get(i))) // contains:该集合不包含指定元素，返回
				relist.add(myPerson.get(i));
			System.out.println(relist.get(i).getName());
		}
		return relist;
	}

}
