package com.aragoncg.apps.airenao.appmanager;

import java.util.LinkedList;
import java.util.List;

import android.app.Activity;
import android.app.Application;

public class ActivityManager extends Application {
	private static ActivityManager myActivityManager;
	private List<Activity>  activitiesList = new LinkedList<Activity>();
	
	public ActivityManager(){
		
	}
	
	public static ActivityManager getInstance(){
		if(myActivityManager==null){
			myActivityManager = new ActivityManager();
		}
		return myActivityManager;
	}
	
	public void addActivity(Activity activity){
		activitiesList.add(activity);
	}
	
	public void exit(){
		for(Activity oneActivity:activitiesList){
			oneActivity.finish();
		}
		//System.exit(0);
	}
}
