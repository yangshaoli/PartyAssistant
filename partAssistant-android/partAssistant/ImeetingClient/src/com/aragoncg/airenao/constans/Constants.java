package com.aragoncg.airenao.constans;

import android.os.Build;

public class Constants {
	public static int MENU_FIRST = 0;
	public static int MENU_SECOND = 1;
	public static int MENU_THIRD = 2;
	/**
	 * used to sort contact
	 */
	public static final String SORT_ORDER = "sort_key asc";
	public static final int SDK_VERSION_8 = 8;
	/**
	 *  Android sdk version.
	 */
	public static final int SDK_VERSION = Integer.parseInt(Build.VERSION.SDK);
	
	public static final String MIME_SMS_ADDRESS = "vnd.android.cursor.item/sms-address";
    public static final String SCHEME_IMTO = "imto";
    
    public static final String SEND_TIME = "sendTime";
    public static final String SEND_POSITION = "sendPosition";
    public static final String SEND_NUMBER =  "sendNumber";
    public static final String SEND_CONTENT = "sendContent";
    
    public static final String TO_SEND_ACTIVITY = "toSendActivity";
    public static final String TO_DETAIL_ACTIVITY = "toDetailActivity";
    
    public static final String ACTIVITY_NAME = "activityName";	
    public static final String ACTIVITY_TIME = "activityTime";
    public static final String ACTIVITY_POSITION = "activityPosition";
    public static final String ACTIVITY_NUMBER = "activityNumber";
    public static final String ACTIVITY_CONTENT = "activityContent";
    public static final String ACTIVITY_INVITED_PEOPLE = "activityInvitedPeople";
    public static final String ACTIVITY_SIGNED_PEOPLE = "activitySignedPeople";
    public static final String ACTIVITY_UNSIGNED_PEOPLE = "activityUnsignedPeople";
    public static final String ACTIVITY_UNJIONED_PEOPLE = "activityUnjionedPeople";
    
    public static final String 	PEOPLE_NAME = "peopelName";
    public static final String 	PEOPLE_NUM = "peopelNum";
    
    
}
