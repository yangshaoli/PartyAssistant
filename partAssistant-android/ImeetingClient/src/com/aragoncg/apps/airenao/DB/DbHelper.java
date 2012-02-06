package com.aragoncg.apps.airenao.DB;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.model.ClientsData;

public class DbHelper {

	private final static String DATABASE_NAME = "activityData.db";
	private final static int DATABASE_VERSION = 1;
	public final static String LAST_TABLE_NAME = "activity_pwd";
	public final static String ACTIVITY_TABLE_NAME = "myActivitys";
	public final static String PARTY_ID = "partyid";
	public final static String FIELD_ID = "_id";
	public final static String FIELD_TITLE_NAME = "name";
	public final static String FIELD_TITLE_TIME = "time";
	public final static String FIELD_TITLE_POSITION = "position";
	public final static String FIELD_TITLE_NUMBER = "number";
	public final static String FIELD_TITLE_CONTENT = "content";
	public final static String FIELD_TITLE_SEND_TYPE = "sendtype";
	public final static String FIELD_TITLE_INVTD = "invitedpeople";
	public final static String FIELD_TITLE_SN_UP = "signup";
	public final static String FIELD_TITLE_NEW_SN_UP = "newsignup";
	public final static String FIELD_TITLE_UN_SN_UP = "unsignup";
	public final static String FIELD_TITLE_NEW_UN_SN_UP = "newunsignup";
	public final static String FIELD_TITLE_UN_JOIN = "unjoin";
	public final static String FLAG_NEW = "flagnew";

	private static DbHelper myDbHelper;
	private static List<Map<String, Object>> listActivity;
	static String time;
	static String position;
	static String number;
	static String content;

	public static final String deleteLastSql = "delete from " + LAST_TABLE_NAME;
	public static final String deleteActivitySql = "delete from "
			+ ACTIVITY_TABLE_NAME;
	public static final String deleteTableAppliedSql = " delete from  "
			+ "appliedClients";
	public static final String deleteTableDoNothingSql = " delete from "
			+ "doNothingClients";
	public static final String deleteTableRefusedSql = " delete from "
			+ "refusedClients";

	public static final String createSql = "Create table " + LAST_TABLE_NAME
			+ "(" + FIELD_ID + " integer primary key autoincrement,"
			+ FIELD_TITLE_TIME + " text, " + FIELD_TITLE_POSITION + " text, "
			+ FIELD_TITLE_NUMBER + " text, " + FIELD_TITLE_CONTENT + " text);";

	public static final String createSql1 = "Create table "
			+ ACTIVITY_TABLE_NAME + "(" + FIELD_ID
			+ " integer primary key autoincrement, " + PARTY_ID + " text, "
			+ FIELD_TITLE_NAME + " text, " + FIELD_TITLE_TIME + " text, "
			+ FIELD_TITLE_POSITION + " text, " + FIELD_TITLE_NUMBER + " text, "
			+ FIELD_TITLE_CONTENT + " text, " + FIELD_TITLE_INVTD + " text, "
			+ FIELD_TITLE_SN_UP + " text, " + FIELD_TITLE_NEW_SN_UP + " text, "
			+ FIELD_TITLE_UN_SN_UP + " text, " + FIELD_TITLE_NEW_UN_SN_UP
			+ " text, " + " type text, " + FIELD_TITLE_UN_JOIN + " text, "
			+ FLAG_NEW + " integer);";
	
	public static final String createTableAppliedSql = "Create table "
			+ "appliedClients" + "(" + FIELD_ID
			+ " integer primary key autoincrement, "+" id text, " + PARTY_ID + " text, "
			+ "name" + " text, " + "phoneNumber" + " text, "
			+ "comment" + " text, " + "isCheck" + " text);";
	public static final String createTableDoNothingSql = "Create table "
			+ "doNothingClients" + "(" + FIELD_ID
			+ " integer primary key autoincrement, "+" id text, " + PARTY_ID + " text, "
			+ "name" + " text, " + "phoneNumber" + " text, "
			+ "comment" + " text, " + "isCheck" + " text);";
	public static final String createTableRefusedSql = "Create table "
			+ "refusedClients" + "(" + FIELD_ID
			+ " integer primary key autoincrement, " +" id text, "+ PARTY_ID + " text, "
			+ "name" + " text, " + "phoneNumber" + " text, "
			+ "comment" + " text, " + "isCheck" + " text);";
	
	public static final String dropSql = " DROP TABLE IF EXISTS "
			+ LAST_TABLE_NAME;
	public static final String dropSql1 = " DROP TABLE IF EXISTS "
			+ ACTIVITY_TABLE_NAME;
	public static final String dropTableAppliedSql = " DROP TABLE IF EXISTS "
			+ "appliedClients";
	public static final String dropTableDoNothingSql = " DROP TABLE IF EXISTS "
			+ "doNothingClients";
	public static final String dropTableRefusedSql = " DROP TABLE IF EXISTS "
			+ "refusedClients";
	private DbHelper(Context context) {
		SQLiteDatabase db = openOrCreateDatabase();
		try {
			createTables(db, createSql);
			createTables(db, createSql1);
			createTables(db, createTableAppliedSql);
			createTables(db, createTableDoNothingSql);
			createTables(db, createTableRefusedSql);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			db.close();
		}

	}

	public static DbHelper getInstance(Context context) {
		if (myDbHelper == null) {
			myDbHelper = new DbHelper(context);
			return myDbHelper;
		}
		return null;
	}

	public static void createTables(SQLiteDatabase db, String sql) {
		db.execSQL(sql);
	}

	public static long insert(SQLiteDatabase db, AirenaoActivity airenao) {
		// SQLiteDatabase db=this.getWritableDatabase();
		ContentValues cv = new ContentValues();
		cv.put(FIELD_TITLE_TIME, "" + airenao.getActivityTime());
		cv.put(FIELD_TITLE_POSITION, "" + airenao.getActivityPosition());
		cv.put(FIELD_TITLE_NUMBER, "" + airenao.getPeopleLimitNum());
		cv.put(FIELD_TITLE_CONTENT, "" + airenao.getActivityContent());
		long row = -1;
		try {
			row = db.insert(LAST_TABLE_NAME, null, cv);
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return row;
	}

	public static long insertOneParty(SQLiteDatabase db, AirenaoActivity airenao,
			String tableName) {
		// SQLiteDatabase db=this.getWritableDatabase();
		ContentValues cv = new ContentValues();
		cv.put(PARTY_ID, airenao.getId());
		cv.put(FIELD_TITLE_NAME, airenao.getActivityName());
		cv.put(FIELD_TITLE_TIME, airenao.getActivityTime());
		cv.put(FIELD_TITLE_POSITION, airenao.getActivityPosition());
		cv.put(FIELD_TITLE_NUMBER, airenao.getPeopleLimitNum());
		cv.put(FIELD_TITLE_CONTENT, airenao.getActivityContent());
		cv.put(FIELD_TITLE_INVTD, airenao.getInvitedPeople());
		cv.put(FIELD_TITLE_SN_UP, airenao.getSignUp());
		cv.put(FIELD_TITLE_NEW_SN_UP, airenao.getNewUnSignUP());
		cv.put(FIELD_TITLE_UN_SN_UP, airenao.getUnSignUp());
		cv.put(FIELD_TITLE_NEW_UN_SN_UP, airenao.getNewUnSignUP());
		cv.put(FIELD_TITLE_UN_JOIN, airenao.getUnJoin());
		cv.put(FLAG_NEW, airenao.getFlagNew());

		long row = -1;
		try {
			row = db.insert(tableName, null, cv);
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return row;
	}
	
	/**
	 * 插入数据ClientsData
	 * @param db
	 * @param clientsData
	 * @param tableName
	 * @return
	 */
	public static long insertOneClientData(SQLiteDatabase db, ClientsData clientsData,
			String tableName) {
		ContentValues cv = new ContentValues();
		cv.put("id", clientsData.getId());
		cv.put(PARTY_ID, clientsData.getPartyId());
		cv.put("name", clientsData.getPeopleName());
		cv.put("phoneNumber", clientsData.getPhoneNumber());
		cv.put("comment", clientsData.getComment());
		cv.put("isCheck", clientsData.getIsCheck());

		long row = -1;
		try {
			row = db.insert(tableName, null, cv);
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return row;
	}

	

	public static List<Map<String, Object>> selectActivitys(SQLiteDatabase db) {

		AirenaoActivity airenao = new AirenaoActivity();
		listActivity = new ArrayList<Map<String, Object>>();
		// SQLiteDatabase db = this.getReadableDatabase();
		Cursor cursor = null;
		String sql = "select * from " + ACTIVITY_TABLE_NAME +
															 " order by "+PARTY_ID +" desc";
		try {
			cursor = db.rawQuery(sql, null);
			for (int i = 0; i < cursor.getCount(); i++) {
				if (cursor.moveToNext()) {
					HashMap<String, Object> hashMap = new HashMap<String, Object>();
					String partyId = cursor.getString(cursor
							.getColumnIndex(PARTY_ID));
					time = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_TIME));
					if (time == null) {
						time = "时间待定";
					}
					position = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_POSITION));
					number = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_NUMBER));
					content = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_CONTENT));
					hashMap.put(Constants.PARTY_ID, partyId);
					hashMap.put(Constants.ACTIVITY_NAME, cursor
							.getString(cursor.getColumnIndex(FIELD_TITLE_NAME)));
					hashMap.put(Constants.ACTIVITY_TIME, time);
					hashMap.put(Constants.ACTIVITY_POSITION, position);
					hashMap.put(Constants.ACTIVITY_NUMBER, number);
					hashMap.put(Constants.ACTIVITY_CONTENT, content);
					hashMap.put(Constants.ALL_CLIENT_COUNT,
							cursor.getString(cursor
									.getColumnIndex(FIELD_TITLE_INVTD)));
					hashMap.put(Constants.APPLIED_CLIENT_COUNT,
							cursor.getString(cursor
									.getColumnIndex(FIELD_TITLE_SN_UP)));
					hashMap.put(Constants.NEW_APPLIED_CLIENT_COUNT, cursor
							.getString(cursor
									.getColumnIndex(FIELD_TITLE_NEW_SN_UP)));
					hashMap.put(Constants.DONOTHING_CLIENT_COUNT, cursor
							.getString(cursor
									.getColumnIndex(FIELD_TITLE_UN_JOIN)));
					hashMap.put(Constants.REFUSED_CLIENT_COUNT, cursor
							.getString(cursor
									.getColumnIndex(FIELD_TITLE_UN_SN_UP)));
					hashMap.put(Constants.NEW_REFUSED_CLIENT_COUNT, cursor
							.getString(cursor
									.getColumnIndex(FIELD_TITLE_NEW_UN_SN_UP)));
					hashMap.put(Constants.NEW_FLAG,
							cursor.getString(cursor.getColumnIndex(FLAG_NEW)));
					listActivity.add(hashMap);
				} else {
					listActivity.clear();
				}
			}

		} catch (Exception e) {
			e.printStackTrace();

		} finally {
			if (cursor != null) {
				cursor.close();
			}
			db.close();

		}

		return listActivity;
	}
	
	/**
	 * 通过partyId返回一个ClientsData的集合
	 * @param db
	 * @param tableName
	 * @param partyId
	 * @return
	 */
	public static List<ClientsData> selectClientData(SQLiteDatabase db,String tableName,String partyId){
		ArrayList<ClientsData> clientsList = new ArrayList<ClientsData>();
		
		String sql = "select * from "+tableName+" where "+PARTY_ID+"='"+partyId+"'";
		Cursor cursor = null;
		cursor = db.rawQuery(sql, null);
		if(cursor.getCount()<1){
			return clientsList;
		}else{
			//cursor.moveToFirst();
			while(cursor.moveToNext()){
				ClientsData clientsData = new ClientsData();
				clientsData.setId(cursor.getString(cursor.getColumnIndex("id")));
				clientsData.setPartyId(cursor.getString(cursor.getColumnIndex(PARTY_ID)));
				clientsData.setPeopleName(cursor.getString(cursor.getColumnIndex("name")));
				clientsData.setPhoneNumber(cursor.getString(cursor.getColumnIndex("phoneNumber")));
				clientsData.setComment(cursor.getString(cursor.getColumnIndex("comment")));
				clientsData.setIsCheck(cursor.getString(cursor.getColumnIndex("isCheck")));
				clientsList.add(clientsData);
			}
			
			if(cursor!=null){
				cursor.close();
			}
			return clientsList;
		}
		
	}
	
	public static AirenaoActivity selectOneParty(SQLiteDatabase db,String partyId){
		AirenaoActivity oneParty = new AirenaoActivity();
		String sql = "select * from " + ACTIVITY_TABLE_NAME +" where "+PARTY_ID+" ='"+partyId+"'";
		Cursor cursor = null;
		cursor = db.rawQuery(sql, null);
		if(cursor.getCount()<1){
			return null;
		}else{
			cursor.moveToFirst();
			String appliedClientCount = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_SN_UP));
			String donothingClientcount = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_UN_JOIN));
			String refusedClientCount = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_UN_SN_UP));
			String allClientCount = String.valueOf(Integer.valueOf(appliedClientCount) + Integer.valueOf(donothingClientcount) +Integer.valueOf(refusedClientCount));
			oneParty.setInvitedPeople(allClientCount);
			oneParty.setSignUp(appliedClientCount);
			oneParty.setUnSignUp(donothingClientcount);
			oneParty.setUnJoin(refusedClientCount);
		}
		return oneParty;
	}
	
	public static AirenaoActivity select(SQLiteDatabase db) {
		AirenaoActivity airenao = new AirenaoActivity();
		// SQLiteDatabase db = this.getReadableDatabase();
		Cursor cursor = null;
		String sql = "select * from " + LAST_TABLE_NAME;
		try {
			cursor = db.rawQuery(sql, null);
			if (cursor.moveToNext()) {
				time = cursor
						.getString(cursor.getColumnIndex(FIELD_TITLE_TIME));
				position = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_POSITION));
				number = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_NUMBER));
				content = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_CONTENT));

				airenao.setActivityTime(time);
				airenao.setActivityPosition(position);
				airenao.setPeopleLimitNum(number);
				airenao.setActivityContent(content);
			} else {
				airenao = null;
			}
		} catch (Exception e) {
			e.printStackTrace();

		} finally {
			if (cursor != null) {
				cursor.close();
			}
			// db.close();

		}

		return airenao;
	}

	public static void delete(SQLiteDatabase db, String sql) {

		// SQLiteDatabase db=this.getWritableDatabase();
		try {

			db.execSQL(sql);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public static SQLiteDatabase openOrCreateDatabase() {
		SQLiteDatabase database = null;
		try {
			/*String fpath = android.os.Environment.getExternalStorageDirectory()
					.getAbsolutePath() + Constants.DATA_BASE_PATH;*/
			String fpath = android.os.Environment.getDataDirectory()
					.getAbsolutePath()+Constants.DATA_BASE_PATH;
			fpath = fpath + "/";
			File fpathDir = new File(fpath);
			File dbFile = new File(fpath + Constants.DATA_BASE_NAME);
			if (!fpathDir.exists()) { // 判断目录是否存在
				fpathDir.mkdirs(); // 创建目录
			}
			if (!dbFile.exists()) { // 判断文件是否存在
				try {
					dbFile.createNewFile(); // 创建文件
				} catch (Exception e) {
					e.printStackTrace();
				}

			}
			database = SQLiteDatabase.openOrCreateDatabase(dbFile, null);
			return database;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return database;
	}

	public static void close(SQLiteDatabase db) {
		db.close();
	}

}
