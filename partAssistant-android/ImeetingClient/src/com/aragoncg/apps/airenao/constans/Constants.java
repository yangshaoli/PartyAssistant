package com.aragoncg.apps.airenao.constans;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
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
    public static final String TO_CREATE_ACTIVITY = "toCreateActivity";
    
    public static final String ACTIVITY_ID = "id";
    public static final String CLIENTS_DATA = "clientsData";
    public static final String ACTIVITY_NAME = "activityName";	
    public static final String ACTIVITY_TIME = "activityTime";
    public static final String ACTIVITY_POSITION = "activityPosition";
    public static final String ACTIVITY_NUMBER = "activityNumber";
    public static final String ACTIVITY_CONTENT = "activityContent";
    public static final String ACTIVITY_INVITED_PEOPLE = "activityInvitedPeople";
    public static final String ACTIVITY_SIGNED_PEOPLE = "activitySignedPeople";
    public static final String ACTIVITY_UNSIGNED_PEOPLE = "activityUnsignedPeople";
    public static final String ACTIVITY_UNJIONED_PEOPLE = "activityUnjionedPeople";
    public static final String ACTIVITY_RECEIVERS = "receivers";
    public static final String EMAIL_SUBJECT = "subject";
    public static final String ACTIVITY_WITH_LINK = "_isapplytips";
    public static final String ACTIVITY_SEND_BYSELF = "_issendbyself";
    public static final String MSG_TYPE = "msgType";
    public static final String ADDRESS_TYPE = "addressType";
    
    
    public static final String 	PEOPLE_NAME = "peopelName";
    public static final String 	PEOPLE_NUM = "peopelNum";
    public static final String  PEOPLE_CONTACTS = "peopleContacts";
    
    public static final String  FROMDETAIL = "fromDetail";
    public static final String 	FROM_PEOPLE_INFO = "fromPeopleInfo";
    public static final String  FROMCONTACTSLISTTOSEND = "from_contactsList_to_send";
    public static final String  IS_FROM_MEETING_LIST = "isFromMeetingList";
    
    public static final String  HENDLER_MESSAGE = "hendMessage";
    
    /**
     * 获取list列表中的数据
     */
    public static final String  URL_GET_DATA = "";
    /**
     * 获取shared Preferences 中的值
     */
    public static final String  AIRENAO_SHARED_DATA = "airenaoSharedData";
    public static final String  AIRENAO_USER_NAME = "airenaoUserName";
    public static final String  AIRENAO_PASSWORD = "airenaoPassword";
    public static final String  AIRENAO_USER_ID = "uid";
    /**
     * database path
     */
    public static final String  DATA_BASE_PATH = "/airenao/databases";
    public static final String  DATA_BASE_NAME = "activityData.db";
    
    public static final String  WHAT_PEOPLE_TAG = "whatPeopleTag";
    
    
    public static final String 	APP_USED_FLAG = "appUsedFlag";
    //表示没有用过
    public static final int  APP_USED_FLAG_Z = 0; 
    //表示用过
    public static final int  APP_USED_FLAG_O = 1; 
    
    
    public  static final int LOGIN_SUCCESS_CASE = 2;
    public  static final int POST_MESSAGE_CASE = 1;
    public  static final int POST_MESSAGE_SUCCESS = 3;
	
    public static final String  TRANSFER_DATA = "TransferData";
    
    //解析 Json 常用数据
    
    public static final String OUT_PUT = "output";
    public static final String STATUS = "status";
    public static final String DESCRIPTION = "description";
    public static final String DATA_SOURCE = "datasource";
    //每页显示的最大条数
    public static final int MAX_NUM_PER_PAGE = 20;
    
    public static final String PARTY_ID = "partyId";
    public static final String ONE_PARTY = "oneParty";
    public static final String CONTENT = "content";
    public static final String START_TIME = "starttime";
    public static final String LOCATION = "location";
    public static final String POEPLE_MAXIMUM = "peopleMaximum";
    public static final String NEED_REFRESH = "refresh";
    
    public static final String IS_SUPER_PRIMARY = "isSuperPrimary";
    public static final String PEOPLE_TAG = "peopleTag";
    public static final String BACK_END_ID = "backendID";
    
    public static final String APPLIED_CLIENT_COUNT = "appliedClientcount";
    public static final String NEW_APPLIED_CLIENT_COUNT = "newAppliedClientcount";
    public static final String DONOTHING_CLIENT_COUNT = "donothingClientcount";
    public static final String REFUSED_CLIENT_COUNT ="refusedClientcount";
    public static final String NEW_REFUSED_CLIENT_COUNT = "newRefusedClientcount";
}
