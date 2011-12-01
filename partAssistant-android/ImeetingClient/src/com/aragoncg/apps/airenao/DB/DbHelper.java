package com.aragoncg.apps.airenao.DB;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;

import android.app.ListActivity;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class DbHelper extends SQLiteOpenHelper {

	 private final static String DATABASE_NAME="activityData.db";
	    private final static int DATABASE_VERSION=1;
	    public final static String LAST_TABLE_NAME="activity_pwd";
	    public final static String ACTIVITY_TABLE_NAME = "myActivitys";
	    public final static String FIELD_ID="_id"; 
	    public final static String FIELD_TITLE_TIME = "time";
	    public final static String FIELD_TITLE_POSITION = "position"; 
	    public final static String FIELD_TITLE_NUMBER = "number";
	    public final static String FIELD_TITLE_CONTENT = "content";	
	    private static DbHelper myDbHelper;
	    private static List<Map<String, Object>> listActivity;
	    static String time;
	    static String position;
	    static String number;
	    static String content;
	    
	    public static final String deleteLastSql = "delete from "+LAST_TABLE_NAME;
	    public static final String deleteActivitySql = "delete from "+ACTIVITY_TABLE_NAME;
	    
	   private DbHelper(Context context)
	    {
	        super(context, DATABASE_NAME,null, DATABASE_VERSION);
	    }
	    
	   public static DbHelper getInstance(Context context){
		   if(myDbHelper == null){
			   myDbHelper = new DbHelper(context);
			  SQLiteDatabase db =  myDbHelper.getReadableDatabase();
			  db.close();
			    return myDbHelper;
		   }
		   return null;
	   }

	@Override
	public void onCreate(SQLiteDatabase db) {
			
		 String sql="Create table "+LAST_TABLE_NAME+"("+FIELD_ID+" integer primary key autoincrement,"
			        +FIELD_TITLE_TIME+" text, "+ FIELD_TITLE_POSITION+ " text, " + FIELD_TITLE_NUMBER+" text, "+FIELD_TITLE_CONTENT+" text);";
		 
		 String sql1="Create table "+ACTIVITY_TABLE_NAME+"("+FIELD_ID+" integer primary key autoincrement,"
			        +FIELD_TITLE_TIME+" text, "+ FIELD_TITLE_POSITION+ " text, " + FIELD_TITLE_NUMBER+" text, "+FIELD_TITLE_CONTENT+" text);";
		 db.execSQL(sql);
		 db.execSQL(sql1);
			        

	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

		 String sql=" DROP TABLE IF EXISTS "+LAST_TABLE_NAME;
		 String sql1=" DROP TABLE IF EXISTS "+ACTIVITY_TABLE_NAME;
	        db.execSQL(sql);
	        db.execSQL(sql1);
	        onCreate(db);

	}
	
	 public static long insert(SQLiteDatabase db,AirenaoActivity airenao)
	    {
	        //SQLiteDatabase db=this.getWritableDatabase();
	        ContentValues cv=new ContentValues(); 
	        cv.put(FIELD_TITLE_TIME, ""+airenao.getActivityTime());
	        cv.put(FIELD_TITLE_POSITION, ""+airenao.getActivityPosition());
	        cv.put(FIELD_TITLE_NUMBER, ""+airenao.getPeopleLimitNum());
	        cv.put(FIELD_TITLE_CONTENT, ""+airenao.getActivityContent());
	        long row = -1;
	        try{ row=db.insert(LAST_TABLE_NAME, null, cv);
	        }catch(SQLException e){
	        	e.printStackTrace();
	        }
	        
	        return row;
	    }
	 
	 
	 public static long insert(SQLiteDatabase db,AirenaoActivity airenao,String tableName)
	    {
	        //SQLiteDatabase db=this.getWritableDatabase();
	        ContentValues cv=new ContentValues(); 
	        cv.put(FIELD_TITLE_TIME, ""+airenao.getActivityTime());
	        cv.put(FIELD_TITLE_POSITION, ""+airenao.getActivityPosition());
	        cv.put(FIELD_TITLE_NUMBER, ""+airenao.getPeopleLimitNum());
	        cv.put(FIELD_TITLE_CONTENT, ""+airenao.getActivityContent());
	        long row = -1;
	        try{ 
	        	row=db.insert(tableName, null, cv);
	        }catch(SQLException e){
	        	e.printStackTrace();
	        }
	        
	        return row;
	    }
	 
	 public void update(List<AirenaoActivity> list)
	    { 
		 
		    AirenaoActivity myAirenaoActivity = list.get(0);
	        SQLiteDatabase db=this.getWritableDatabase();
	        time = myAirenaoActivity.getActivityTime();
	        position = myAirenaoActivity.getActivityPosition();
	        number = String.valueOf(myAirenaoActivity.getPeopleLimitNum());
	        content = myAirenaoActivity.getActivityContent();
	        String[] paramters = {time,position,number,content};
	        paramters[0] = time;
	        String sql = "update " + LAST_TABLE_NAME + " set "+FIELD_TITLE_TIME+" =?,"+FIELD_TITLE_POSITION+"=?,"+FIELD_TITLE_NUMBER+"=?,"+FIELD_TITLE_CONTENT+"=? where personid=0";
	        try{
	        	db.execSQL(sql,paramters);
	        }catch(SQLException e){
	        	e.printStackTrace();
	        	
	        }finally{
	        	db.close();
	        }
	        
	    }
	 
	 public static List<Map<String, Object>> selectActivitys(SQLiteDatabase db) {
		 
			AirenaoActivity airenao = new AirenaoActivity();
			listActivity = new ArrayList<Map<String,Object>>();
			//SQLiteDatabase db = this.getReadableDatabase();
			Cursor cursor = null;
			String sql = "select * from " + ACTIVITY_TABLE_NAME ;//+ " order by datetime()";
			try {
				cursor = db.rawQuery(sql, null);
					
				if (cursor.moveToNext()) {
					HashMap<String, Object> hashMap = new HashMap<String, Object>();
					time = cursor
							.getString(cursor.getColumnIndex(FIELD_TITLE_TIME));
					position = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_POSITION));
					number = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_NUMBER));
					content = cursor.getString(cursor
							.getColumnIndex(FIELD_TITLE_CONTENT));
					hashMap.put(Constants.ACTIVITY_NAME, content.substring(0, 5));
					hashMap.put(Constants.ACTIVITY_TIME, time);
					hashMap.put(Constants.ACTIVITY_POSITION, position);
					hashMap.put(Constants.ACTIVITY_NUMBER, number);
					hashMap.put(Constants.ACTIVITY_CONTENT, content);
					listActivity.add(hashMap);
				}else{
					listActivity.clear();
				}
				
			} catch (Exception e) {
				e.printStackTrace();
				
			}finally{
				if(cursor!=null){
					cursor.close();
				}
				db.close();
				
			}

			return listActivity;
		}
	 
	public static AirenaoActivity select(SQLiteDatabase db) {
		AirenaoActivity airenao = new AirenaoActivity();
		//SQLiteDatabase db = this.getReadableDatabase();
		Cursor cursor = null;
		String sql = "select * from " + LAST_TABLE_NAME + " where _id=0";
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
				airenao.setPeopleLimitNum(Integer.valueOf(number));
				airenao.setActivityContent(content);
			}else{
				airenao = null;
			}
		} catch (Exception e) {
			e.printStackTrace();
			
		}finally{
			cursor.close();
			//db.close();
			
		}

		return airenao;
	}
	
	public static void delete(SQLiteDatabase db,String sql){
		
		
		//SQLiteDatabase db=this.getWritableDatabase();
		try{
			db.execSQL(sql);
		}catch(Exception e){
			e.printStackTrace();
		}
		
	}
	
	public static SQLiteDatabase openDatabase() {
		SQLiteDatabase database=null;
		try {
			String fpath = android.os.Environment.getDataDirectory()
					.getAbsolutePath()
					+ Constants.DATA_BASE_PATH;
			fpath = fpath + "/" + Constants.DATA_BASE_NAME;
			 database = SQLiteDatabase.openOrCreateDatabase(
					fpath, null);
			return database;
		} catch (Exception e) {
			Log.d("", e.getMessage());
		}
		return database;
	}
	
	public static void close(SQLiteDatabase db) {
		db.close();
	}


}
