package com.aragoncg.apps.airenao.DB;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.model.ClientsData;

public class DbHelper {

	private final static String DATABASE_NAME = "activityData.db";
	private final static int DATABASE_VERSION = 1;
	public final static String LAST_TABLE_NAME = "activity_pwd";
	public final static String ACTIVITY_TABLE_NAME = "myActivitys";

	public final static String DONOTHING_TABLE_NAME = "doNothingClients";
	public final static String REFUSED_TABLE_NAME = "refusedClients";
	public final static String APPLIED_TABLE_NAME = "appliedClients";

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
			+ APPLIED_TABLE_NAME;
	public static final String deleteTableDoNothingSql = " delete from "
			+ DONOTHING_TABLE_NAME;
	public static final String deleteTableRefusedSql = " delete from "
			+ REFUSED_TABLE_NAME;

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
			+ " integer primary key autoincrement, " + " id text, " + PARTY_ID
			+ " text, " + "name" + " text, " + "phoneNumber" + " text, "
			+ "comment" + " text, " + "isCheck" + " text);";
	public static final String createTableDoNothingSql = "Create table "
			+ "doNothingClients" + "(" + FIELD_ID
			+ " integer primary key autoincrement, " + " id text, " + PARTY_ID
			+ " text, " + "name" + " text, " + "phoneNumber" + " text, "
			+ "comment" + " text, " + "isCheck" + " text);";
	public static final String createTableRefusedSql = "Create table "
			+ "refusedClients" + "(" + FIELD_ID
			+ " integer primary key autoincrement, " + " id text, " + PARTY_ID
			+ " text, " + "name" + " text, " + "phoneNumber" + " text, "
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

	public static long insertOneParty(SQLiteDatabase db,
			AirenaoActivity airenao, String tableName) {
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
		cv.put(FIELD_TITLE_NEW_SN_UP, airenao.getNewApplied());
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
	 * 
	 * @param db
	 * @param clientsData
	 * @param tableName
	 * @return
	 */
	public static long insertOneClientData(SQLiteDatabase db,
			ClientsData clientsData, String tableName) {
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
		String sql = "select * from " + ACTIVITY_TABLE_NAME + " order by "
				+ PARTY_ID + " desc";
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
					hashMap
							.put(Constants.ACTIVITY_NAME, cursor
									.getString(cursor
											.getColumnIndex(FIELD_TITLE_NAME)));
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
					hashMap.put(Constants.NEW_FLAG, cursor.getString(cursor
							.getColumnIndex(FLAG_NEW)));
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
	 * 
	 * @param db
	 * @param tableName
	 * @param partyId
	 * @return
	 */
	public static List<ClientsData> selectClientData(SQLiteDatabase db,
			String tableName, String partyId) {
		ArrayList<ClientsData> clientsList = new ArrayList<ClientsData>();

		String sql = "select * from " + tableName + " where " + PARTY_ID + "='"
				+ partyId + "'";
		Cursor cursor = null;
		cursor = db.rawQuery(sql, null);
		if (cursor != null) {
			if (cursor.getCount() < 1) {
				return clientsList;
			} else {
				// cursor.moveToFirst();
				while (cursor.moveToNext()) {
					ClientsData clientsData = new ClientsData();
					clientsData.setId(cursor.getString(cursor
							.getColumnIndex("id")));
					clientsData.setPartyId(cursor.getString(cursor
							.getColumnIndex(PARTY_ID)));
					clientsData.setPeopleName(cursor.getString(cursor
							.getColumnIndex("name")));
					clientsData.setPhoneNumber(cursor.getString(cursor
							.getColumnIndex("phoneNumber")));
					clientsData.setComment(cursor.getString(cursor
							.getColumnIndex("comment")));
					clientsData.setIsCheck(cursor.getString(cursor
							.getColumnIndex("isCheck")));
					clientsList.add(clientsData);
				}

				cursor.close();
			}
		}
		return clientsList;

	}

	public static AirenaoActivity selectOneParty(SQLiteDatabase db,
			String partyId) {
		AirenaoActivity oneParty = new AirenaoActivity();
		String sql = "select * from " + ACTIVITY_TABLE_NAME + " where "
				+ PARTY_ID + " ='" + partyId + "'";
		Cursor cursor = null;
		cursor = db.rawQuery(sql, null);
		if (cursor != null) {
			if (cursor.getCount() < 1) {
				return null;
			} else {
				cursor.moveToFirst();
				String newAppliedClientCount = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_NEW_SN_UP));
				String newRefusedClientCount = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_NEW_UN_SN_UP));
				String appliedClientCount = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_SN_UP));
				String donothingClientcount = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_UN_JOIN));
				String refusedClientCount = cursor.getString(cursor
						.getColumnIndex(FIELD_TITLE_UN_SN_UP));
				String allClientCount = String.valueOf(Integer
						.valueOf(appliedClientCount)
						+ Integer.valueOf(donothingClientcount)
						+ Integer.valueOf(refusedClientCount));
				oneParty.setInvitedPeople(allClientCount);
				oneParty.setSignUp(appliedClientCount);
				oneParty.setNewApplied(newAppliedClientCount);
				oneParty.setNewUnSignUP(newRefusedClientCount);
				oneParty.setUnSignUp(donothingClientcount);
				oneParty.setUnJoin(refusedClientCount);
			}
			cursor.close();
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
		// SQLiteDatabase database = null;
		try {
			/*
			 * String fpath =
			 * android.os.Environment.getExternalStorageDirectory()
			 * .getAbsolutePath() + Constants.DATA_BASE_PATH;
			 */
			String fpath = android.os.Environment.getDataDirectory()
					.getAbsolutePath()
					+ Constants.DATA_BASE_PATH;
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
			return SQLiteDatabase.openOrCreateDatabase(dbFile, null);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static boolean insertDetailPeopleInfo(SQLiteDatabase db,
			String tableName, ClientsData clientData) {
		try {
			db.execSQL("INSERT INTO " + tableName + "(" + Constants.ID + ", "
					+ Constants.PARTYID + ", " + Constants.NAME + ", "
					+ Constants.PHONENUMBER + ", " + Constants.COMMENT + ", "
					+ Constants.IS_CHECK + ") VALUES (?,?,?,?,?,?)",
					new String[] { clientData.getId(), clientData.getPartyId(),
							clientData.getPeopleName(),
							clientData.getPhoneNumber(),
							clientData.getComment(), clientData.getIsCheck() });
			return true;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}

	public static ClientsData selectDetailPeopleInfo(SQLiteDatabase db,
			String tableName, String id) {
		try {
			Cursor cursor = null;
			cursor = db.rawQuery("SELECT * FROM " + tableName + " WHERE "
					+ Constants.ID + " = " + id, new String[] {});
			cursor.moveToFirst();
				String sql = "SELECT * FROM " + tableName + " WHERE "
				+ Constants.ID + " = " + id;
				System.out.println(cursor.getCount()+sql);
				
				cursor.getColumnIndex(Constants.PARTYID);
				System.out.println("a"+cursor.getString(cursor.getColumnIndex(Constants.NAME)));
				if (cursor != null) {
					ClientsData clientData = new ClientsData();
					clientData.setId(id);
					clientData.setPartyId(cursor.getString(2));
					clientData.setPeopleName(cursor.getString(3));
					clientData.setPhoneNumber(cursor.getString(4));
					clientData.setComment(cursor.getString(5));
					clientData.setIsCheck(cursor.getString(6));
					cursor.close();
					return clientData;
				}
			
			if (cursor != null) {
				cursor.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static boolean deleteDetailPeopleInfo(SQLiteDatabase db,
			String tableName, String id) {
		try {
			db.execSQL("DELETE FROM " + tableName + " WHERE " + Constants.ID
					+ " = " + id);
			return true;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}

	public static void close(SQLiteDatabase db) {
		db.close();
	}
	
	/**
	 * 更新通过接口
	 * cuiky
	 */
	public static String upData(String tableName, ContentValues contentValues, String whereArg){
		String msg="";
		String[] whereArgs={whereArg};
		SQLiteDatabase db = DbHelper.openOrCreateDatabase();
		if(db!=null){
			try{
				db.update(tableName, contentValues, PARTY_ID+"=?", whereArgs);
			}catch(Exception e){
				msg="数据库异常";
			}finally{
				db.close();
			}
		}else{
			msg="数据库获取异常";
		}
		
		return msg;
	}
	/**
	 * 更新通过数据库
	 * cuiky
	 * @return
	 */
	public static String updataBySql(String tableName,String[] Columns, String whereArg){
		String msg="";
		//update myActivitys set signup = signup+1 , unsignup = unsignup+1 where _id=22

		String sql = "update " + tableName + " set "+Columns[0]+" = "+Columns[0]+"-1,"+Columns[1]+"="+Columns[1]+"+1" + " where "+DbHelper.PARTY_ID+"="+whereArg;
		SQLiteDatabase db = DbHelper.openOrCreateDatabase();
		if(db!=null){
			try{
				db.execSQL(sql);
			}catch(Exception e){
				msg="数据库异常";
			}finally{
				db.close();
			}
		}else{
			msg="数据库获取异常";
		}
		
		return msg;
	}
	
}