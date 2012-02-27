package com.aragoncg.apps.airenao.activity;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Color;
import android.os.Bundle;
import android.provider.ContactsContract.Contacts;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.AdapterView;
import android.widget.CursorAdapter;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.SDKimp.MyMultiAutoCompleteTextView;

public class PlaceSearch extends Activity implements OnClickListener {

	MyMultiAutoCompleteTextView txtSendReciever;
	ImageButton imageButton;
	Cursor cursor;
	SQLiteDatabase db;
	public static String  placeName = "";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		getWindow().requestFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.palce_serach);
		this.setTitle("地点选择");
		this.setTitleColor(Color.RED);
		txtSendReciever = (MyMultiAutoCompleteTextView) findViewById(R.id.txtSendReciever);
		imageButton = (ImageButton) findViewById(R.id.btnSendReciever);
		imageButton.setOnClickListener(this);
		db = DbHelper.openOrCreateDatabase();
		DbHelper.createTables(db, DbHelper.createPlaceSql);
		final ContentApdater adapter = new ContentApdater(this, cursor);
		txtSendReciever.setAdapter(adapter);
		txtSendReciever
				.setTokenizer(new MyMultiAutoCompleteTextView.CommaTokenizer());
		txtSendReciever.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_UP) {
					String string = txtSendReciever.getText().toString();
					if ("".equals(string)) {
						cursor = DbHelper.selectPlace(db,
								DbHelper.PLACE_TABLE_NAME, "");
					}
					txtSendReciever.setSelection(string.length());
				}
				return false;
			}
		});

		txtSendReciever.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// 将游标定位到要显示数据的行
				Cursor myCursor = adapter.getCursor();
				myCursor.moveToPosition(position);
				int Index = myCursor
						.getColumnIndexOrThrow(DbHelper.FIELD_TITLE_PLACE);
				int tempcount = myCursor.getColumnIndexOrThrow(DbHelper.FIELD_TITLE_ITEMCOUNT);
				int itemCount = myCursor.getInt(tempcount);
				itemCount++;
				int tempId = myCursor.getColumnIndexOrThrow(DbHelper.FIELD_ID);
				int fieldId = myCursor.getInt(tempId);
//				int fieldId = myCursor.getColumnIndexOrThrow(DbHelper.FIELD_ID);
//				int primaryId = myCursor.getInt(fieldId);
				
				placeName = myCursor.getString(Index);
				System.out.println(itemCount+"enter"+fieldId);
				boolean flag = DbHelper.updatePlace(db,DbHelper.PLACE_TABLE_NAME,itemCount,fieldId);
				System.out.println(flag);
				// 通过获得的Id去查询电话号码
				txtSendReciever.setText(placeName);
				txtSendReciever.setSelection(placeName.length());
			
			}
		});

	}

	class ContentApdater extends CursorAdapter {
		ContentResolver resolver;
		final String[] CONTACTS_SUMMARY_PROJECTION = new String[] {
				Contacts._ID, // 0
				Contacts.DISPLAY_NAME, // 1
				Contacts.STARRED, // 2
				Contacts.TIMES_CONTACTED, // 3
				Contacts.CONTACT_PRESENCE, // 4
				Contacts.PHOTO_ID, // 5
				Contacts.LOOKUP_KEY, // 6
				Contacts.HAS_PHONE_NUMBER // 7
		};

		// 构造函数
		public ContentApdater(Context context, Cursor c) {
			super(context, c);
			// resolver = context.getContentResolver();
			cursor = DbHelper.selectPlace(db, DbHelper.PLACE_TABLE_NAME, "");
			//System.out.println("first" + cursor.getCount());
		}

		@Override
		// 将信息绑定到控件的方法
		public void bindView(View view, Context context, Cursor cursor) {
			((TextView) view).setText(cursor.getString(cursor
					.getColumnIndexOrThrow(DbHelper.FIELD_TITLE_PLACE)));
			System.out.println(cursor.getString(cursor
					.getColumnIndexOrThrow(DbHelper.FIELD_TITLE_PLACE))
					+ "bindview");
		}

		@Override
		public CharSequence convertToString(Cursor cursor) {
			return cursor.getString(cursor
					.getColumnIndexOrThrow(DbHelper.FIELD_TITLE_PLACE));
		}

		@Override
		// 创建自动绑定选项
		public View newView(Context context, Cursor cursor, ViewGroup parent) {
			final LayoutInflater inflater = LayoutInflater.from(context);
			final TextView tv = (TextView) inflater.inflate(
					android.R.layout.simple_dropdown_item_1line, parent, false);
			tv.setText(cursor.getString(cursor
					.getColumnIndexOrThrow(DbHelper.FIELD_TITLE_PLACE)));
			return tv;
		}

		@Override
		public Cursor runQueryOnBackgroundThread(CharSequence constraint) {
			if (getFilterQueryProvider() != null) {
				return getFilterQueryProvider().runQuery(constraint);
			}
			String where = txtSendReciever.getText().toString();
			if ("".equals(where)) {
				cursor = DbHelper
						.selectPlace(db, DbHelper.PLACE_TABLE_NAME, "");
			} else {
				cursor = DbHelper.selectPlace(db, DbHelper.PLACE_TABLE_NAME,
						where);
			}
			// Cursor cursor = null;

			// cursor = DbHelper.selectPlace(db, DbHelper.PLACE_TABLE_NAME,
			// where);
			// System.out.println(cursor.getCount());

			if (cursor != null) {
				return cursor;
			} else {
				return null;
			}

			// cursor.moveToFirst();
			// while(cursor.moveToNext()){

			// }
			// return null;
			// String tempTxt = txtSendReciever.getText().toString();
			// String tempTxt1 = txtSendReciever.getText().toString();
			// Uri uri = Uri.withAppendedPath(
			// ContactsContract.Contacts.CONTENT_FILTER_URI, Uri
			// .encode(constraint.toString()));
			//
			// Cursor cursor = resolver.query(uri, null,
			// Contacts.IN_VISIBLE_GROUP
			// + "=" + "1 and " + Contacts.HAS_PHONE_NUMBER, null,
			// ContactsContract.Contacts.TIMES_CONTACTED + ", "
			// + ContactsContract.Contacts.STARRED + ", "
			// + ContactsContract.Contacts.DISPLAY_NAME + " DESC");
			//
			// if (tempTxt.contains(",")) {
			// int size1 = tempTxt.lastIndexOf(",");
			// int size = tempTxt.lastIndexOf(",") + 1;
			//
			// tempTxt1 = tempTxt.substring(size).trim();
			//
			// }
			// Cursor cursor1 = resolver.query(
			// ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null,
			// ContactsContract.CommonDataKinds.Phone.NUMBER + " like '"
			// + tempTxt1 + "%" + "'", null, null);
			//
			// if (cursor.getCount() == 0) {
			// judgeCursor = 1;
			// return cursor1;
			// } else {
			// judgeCursor = 0;
			// return cursor;
			// }
			// }
		}
	}

	@Override
	public void onClick(View v) {

		DbHelper.insertPlace(db, DbHelper.PLACE_TABLE_NAME, txtSendReciever
				.getText().toString(),1);
		Intent personIntent = new Intent();
		personIntent.putExtra("nam",txtSendReciever.getText().toString());
		setResult(31, personIntent);// 21只是一个返回的结果代码
		finish();

	}

	@Override
	protected void onDestroy() {
		if(db !=null){
			db.close();
		}
		if(cursor != null){
			cursor.close();
		}
		
//		Intent intent = new Intent(PlaceSearch.this,SendAirenaoActivity.class);
//		intent.putExtra("nam", placeName);
//		startActivity(intent);
		super.onDestroy();
	}

}
