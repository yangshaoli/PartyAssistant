package com.aragoncg.airenao.DB;

import java.util.List;

import com.aragoncg.airenao.model.AirenaoActivity;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

public class DbHelper extends SQLiteOpenHelper {

	 private final static String DATABASE_NAME="activity_db";
	    private final static int DATABASE_VERSION=1;
	    private final static String TABLE_NAME="activity_pwd";
	    public final static String FIELD_ID="_id"; 
	    public final static String FIELD_TITLE_TIME = "time";
	    public final static String FIELD_TITLE_POSITION = "position"; 
	    public final static String FIELD_TITLE_NUMBER = "number";
	    public final static String FIELD_TITLE_CONTENT = "content";	
	    private static DbHelper myDbHelper;
	    
	    String time;
	    String position;
	    String number;
	    String content;
	    
	   private DbHelper(Context context)
	    {
	        super(context, DATABASE_NAME,null, DATABASE_VERSION);
	    }
	    
	   public static DbHelper getInstance(Context context){
		   if(myDbHelper == null){
			   return new DbHelper(context);
		   }
		   return myDbHelper;
	   }

	@Override
	public void onCreate(SQLiteDatabase db) {

		 String sql="Create table "+TABLE_NAME+"("+FIELD_ID+" integer primary key autoincrement,"
			        +FIELD_TITLE_TIME+" text, "+ FIELD_TITLE_POSITION+ " text, " + FIELD_TITLE_NUMBER+" text, "+FIELD_TITLE_CONTENT+" text);";
			        db.execSQL(sql);
			        

	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

		 String sql=" DROP TABLE IF EXISTS "+TABLE_NAME;
	        db.execSQL(sql);
	        onCreate(db);

	}
	
	 public long insert()
	    {
	        SQLiteDatabase db=this.getWritableDatabase();
	        ContentValues cv=new ContentValues(); 
	        cv.put(FIELD_TITLE_TIME, "");
	        cv.put(FIELD_TITLE_POSITION, "");
	        cv.put(FIELD_TITLE_NUMBER, "");
	        cv.put(FIELD_TITLE_CONTENT, "");
	        long row = -1;
	        try{ row=db.insert(TABLE_NAME, null, cv);
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
	        String sql = "update " + TABLE_NAME + " set "+FIELD_TITLE_TIME+" =?,"+FIELD_TITLE_POSITION+"=?,"+FIELD_TITLE_NUMBER+"=?,"+FIELD_TITLE_CONTENT+"=? where personid=0";
	        try{db.execSQL(sql,paramters);
	        }catch(SQLException e){
	        	e.printStackTrace();
	        }
	        
	    }
	    
	 public AirenaoActivity select()
	    {	
		 	AirenaoActivity airenao = new AirenaoActivity();
	        SQLiteDatabase db=this.getReadableDatabase();
	        String sql = "select * from "+TABLE_NAME+" where _id=0";    
	        Cursor cursor = db.rawQuery(sql, null);
	        int count = cursor.getCount();
	        if (cursor.getCount() > 0)
	        {
	        	time = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_TIME));
	        	position = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_POSITION));
	        	number = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_NUMBER));
	        	content = cursor.getString(cursor.getColumnIndex(FIELD_TITLE_CONTENT));
	        	airenao.setActivityTime(time);
	        	airenao.setActivityPosition(position);
	        	airenao.setPeopleLimitNum(Integer.valueOf(number));
	        	airenao.setActivityContent(content);
	        }
	        return airenao;
	    }
}
