package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.aragoncg.apps.airenao.constans.Constants;

import android.app.Activity;
import android.os.Bundle;
import android.os.Parcelable;

public class AgainInvite extends Activity{
	private List  <Map<String, Object>> mData;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		
		Bundle bundle = getIntent().getExtras();
		String name = bundle.getString(Constants.NAMEANDPHONE);
		System.out.println(DetailActivity.jsonArray.length());
		//int size = getIntent().getExtras().getParcelableArrayList(Constants.AGAINList).size();
		//System.out.println(size);
	}

}
