package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.sqlite.SQLiteDatabase;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.exceptions.MyRuntimeException;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.model.ClientsData;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class PeopleInfoActivity extends Activity implements OnItemClickListener {

	private final static int INVATED_PEOPLE = 0;
	private final static int SIGNED_PEOPLE = 1;
	private final static int UNSIGNED_PEOPLE = 2;
	private final static int UNRESPONSED_PEOPLE = 3;

	private final static int APPLAY_RESULT = 0;

	private final static String TYPE_ALL = "all";
	private final static String TYPE_APPLIED = "applied";
	private final static String TYPE_REFUSED = "refused";
	private final static String TYPE_DONOTHING = "donothing";

	private List<Map<String, Object>> mData;
	private Button btnRefresh;
	private Button reInvated;
	private TextView myTitle;
	private int peopleTag = -1;
	private String partyId = "-1";
	private String getPeopleInfoUrl;
	private String applayUrl;
	private MyAdapter myAdapter;
	private Thread applyThread;
	private String backendID;
	private String action;
	private Handler myHandler;
	private AirenaoActivity myAirenaoActivity;
	private ListView dataListView;
	String name;
	String cValue;
	String clientId;
	Intent transIntent;
	private TextView txtNoData;
	private Runnable tellServiceToChangeFlag;
	private String tableName;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		ActivityManager.getInstance().addActivity(this);

		setContentView(R.layout.invated_people_info_layout);
		Intent myIntent = getIntent();
		getData(myIntent);
		myAdapter = new MyAdapter(this);
		dataListView = (ListView) findViewById(R.id.people_infor_list);
		dataListView.setAdapter(myAdapter);
		dataListView.setOnItemClickListener(this);
		initView();
	}

	public void initView() {
		reInvated = (Button) findViewById(R.id.btnResend);
		myTitle = (TextView) findViewById(R.id.txtPeoPleInfo);
		txtNoData = (TextView) findViewById(R.id.txtNoData);

		if (peopleTag == INVATED_PEOPLE) {
			myTitle.setText(R.string.invited_number);
			reInvated.setText(R.string.sendTip);

			if (mData.size() <= 0) {
				reInvated.setClickable(false);
			}
		}
		if (peopleTag == SIGNED_PEOPLE) {
			myTitle.setText(R.string.signed_number);
			reInvated.setText(R.string.sendTip);
			if (mData.size() <= 0) {
				reInvated.setClickable(false);
			}
		}
		if (peopleTag == UNSIGNED_PEOPLE) {
			myTitle.setText(R.string.unsiged_number);
			if (mData.size() <= 0) {
				reInvated.setClickable(false);
			}
		}
		if (peopleTag == UNRESPONSED_PEOPLE) {
			myTitle.setText(R.string.unjion);
			reInvated.setVisibility(View.INVISIBLE);
			if (mData.size() <= 0) {
				reInvated.setClickable(false);
			}
		}
		// 右上角按钮的事件添加
		reInvated.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				if (mData.size() > 0) {
					Intent intent = new Intent();
					// 封装数据
					myAirenaoActivity.setPeopleList(mData);
					intent.putExtra(Constants.ONE_PARTY, myAirenaoActivity);
					intent.putExtra(Constants.FROM_PEOPLE_INFO, true);
					intent.setClass(PeopleInfoActivity.this,
							SendAirenaoActivity.class);
					startActivity(intent);
				}

			}
		});

		btnRefresh = (Button) findViewById(R.id.btnPeopleLableBack);
		btnRefresh.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				getDataFromServer();

			}
		});
	}
	
	
	

	@Override
	protected void onRestart() {
		getDataFromServer();
		super.onRestart();
	}

	public void getData(Intent intent) {

		applayUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_APPLAY_URL;

		// 加载数据
		mData = new ArrayList<Map<String, Object>>();
		mData.clear();
		myAirenaoActivity = (AirenaoActivity) intent
				.getSerializableExtra(Constants.ONE_PARTY);
		peopleTag = intent.getIntExtra(Constants.WHAT_PEOPLE_TAG, -1);
		SharedPreferences spf = AirenaoUtills
				.getMySharedPreferences(PeopleInfoActivity.this);
		Editor editor = spf.edit();
		editor.putInt(Constants.PEOPLE_TAG, peopleTag);
		editor.commit();
		partyId = intent.getStringExtra(Constants.PARTY_ID);
		getPeopleInfoUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_GET_PEOPLE_INFO_URL;
		if (peopleTag == -1 || "-1".equals(partyId)) {
			throw new MyRuntimeException(PeopleInfoActivity.this,
					getString(R.string.systemMistakeTitle),
					getString(R.string.systemMistake));
		}

		getDataFromServer();

	}

	public void getDataFromServer() {
		
		if(DetailActivity.showNewFlag){
			getChangeFlagRunnable();
			tellServiceToChangeFlag.run();
		}
		
		
		if (peopleTag == INVATED_PEOPLE) {

			AsyncTaskLoad asynTask = new AsyncTaskLoad(this, partyId, TYPE_ALL);
			asynTask.execute(getPeopleInfoUrl);
		}
		if (peopleTag == SIGNED_PEOPLE) {
			// 获得已报名人的信息
			AsyncTaskLoad asynTask = new AsyncTaskLoad(this, partyId,
					TYPE_APPLIED);
			asynTask.execute(getPeopleInfoUrl);
		}
		if (peopleTag == UNSIGNED_PEOPLE) {
			// 获得未报名人的信息
			AsyncTaskLoad asynTask = new AsyncTaskLoad(this, partyId,
					TYPE_DONOTHING);
			asynTask.execute(getPeopleInfoUrl);
		}
		if (peopleTag == UNRESPONSED_PEOPLE) {
			// 获得未参加人的信息
			AsyncTaskLoad asynTask = new AsyncTaskLoad(this, partyId,
					TYPE_REFUSED);
			asynTask.execute(getPeopleInfoUrl);
		}
	}

	public Thread getThread() {
		return new Thread() {

			@Override
			public void run() {
				HttpHelper httpHelper = new HttpHelper();
				HashMap<String, String> map = new HashMap<String, String>();
				map.put("cpID", backendID);
				map.put("cpAction", action);
				String result = httpHelper.performPost(applayUrl, map,
						PeopleInfoActivity.this);
				result = AirenaoUtills.linkResult(result);
				String status;
				String description;
				try {
					JSONObject resultObject = new JSONObject(result);
					status = resultObject.getString(Constants.STATUS);
					description = resultObject.getString(Constants.DESCRIPTION);
					Message message = new Message();
					message.what = APPLAY_RESULT;
					// myHandler.sendMessage(message);
				} catch (JSONException e) {
					e.printStackTrace();
				}

			}

		};

	}
	
	/**
	 * 告诉后台我看过了，不要再显示“新”标志
	 */
	public void getChangeFlagRunnable(){
		tellServiceToChangeFlag = new Runnable() {
			
			@Override
			public void run() {
				String typeName;
				switch(peopleTag){
				 case INVATED_PEOPLE://TYPE_ALL
					 typeName = TYPE_ALL;
					 break;
				 case SIGNED_PEOPLE://TYPE_APPLIED
					 typeName = TYPE_APPLIED;
					 linkService(typeName);
					 break;
				 case UNSIGNED_PEOPLE://TYPE_DONOTHING
					 typeName = TYPE_DONOTHING;
					 linkService(typeName);
					 break;
				 case UNRESPONSED_PEOPLE://TYPE_REFUSED
					 typeName = TYPE_REFUSED;
					 linkService(typeName);
					 break;
				}
				
				
			}
		};
	}
	
	public void linkService(String typeName){
		tellDbToUpdata();
		getPeopleInfoUrl = getPeopleInfoUrl+partyId+"/"+typeName+"/?read=1/";
		HttpHelper httpHelper = new HttpHelper();
		httpHelper.performGet(getPeopleInfoUrl,PeopleInfoActivity.this);
	}
	
	/**
	 * 告诉数据库中的数据要更新，不要在显示数据了
	 */
	public void tellDbToUpdata(){
		ContentValues contentValues = new ContentValues();
		contentValues.put(DbHelper.FIELD_TITLE_NEW_SN_UP, "0");
		contentValues.put(DbHelper.FIELD_TITLE_NEW_UN_SN_UP, "0");
		DbHelper.upData(DbHelper.ACTIVITY_TABLE_NAME, contentValues, partyId);
	}
	
	
	/**
	 * 异步加载数据 --- client count
	 * 
	 * @author cuikuangye
	 * 
	 */
	class AsyncTaskLoad extends AsyncTask<String, Integer, String[]> {
		private String id = "";
		private Context context;
		private String type = "";
		private HashMap<String, String> additionalHeaders;

		public AsyncTaskLoad(Context context, String id, String type) {
			this.context = context;
			this.id = id;
			this.type = type;
		}

		@Override
		protected String[] doInBackground(String... params) {

			
			SQLiteDatabase db = DbHelper.openOrCreateDatabase();
			mData.clear();
			if(TYPE_ALL.equals(type)){
				ArrayList<ClientsData> myList = new ArrayList<ClientsData>();
				myList.addAll((ArrayList<ClientsData>) DbHelper.selectClientData(db, "appliedClients", id));
				myList.addAll((ArrayList<ClientsData>) DbHelper.selectClientData(db, "doNothingClients", id));
				myList.addAll((ArrayList<ClientsData>) DbHelper.selectClientData(db, "refusedClients", id));
				for(int i=0;i<myList.size();i++){
					
					HashMap<String, Object> map = new HashMap<String, Object>();
					map.put(Constants.PEOPLE_NAME, myList.get(i).getPeopleName());
					map.put(Constants.PEOPLE_CONTACTS, myList.get(i).getPhoneNumber());
					map.put(Constants.IS_CHECK, myList.get(i).getIsCheck());
					map.put(Constants.MSG, myList.get(i).getComment());
					map.put(Constants.BACK_END_ID, myList.get(i).getId());
					mData.add(map);
				}
			}
			if(TYPE_APPLIED.equals(type)){
				ArrayList<ClientsData> myList = (ArrayList<ClientsData>) DbHelper.selectClientData(db, "appliedClients", id);
				for(int i=0;i<myList.size();i++){
					
					HashMap<String, Object> map = new HashMap<String, Object>();
					map.put(Constants.PEOPLE_NAME, myList.get(i).getPeopleName());
					map.put(Constants.PEOPLE_CONTACTS, myList.get(i).getPhoneNumber());
					map.put(Constants.IS_CHECK, myList.get(i).getIsCheck());
					map.put(Constants.MSG, myList.get(i).getComment());
					map.put(Constants.BACK_END_ID, myList.get(i).getId());
					mData.add(map);
					tableName = "appliedClients";
				}
			}
			if(TYPE_DONOTHING.equals(type)){
				ArrayList<ClientsData> myList = (ArrayList<ClientsData>) DbHelper.selectClientData(db, "doNothingClients", id);
				for(int i=0;i<myList.size();i++){
					
					HashMap<String, Object> map = new HashMap<String, Object>();
					map.put(Constants.PEOPLE_NAME, myList.get(i).getPeopleName());
					map.put(Constants.PEOPLE_CONTACTS, myList.get(i).getPhoneNumber());
					map.put(Constants.IS_CHECK, myList.get(i).getIsCheck());
					map.put(Constants.MSG, myList.get(i).getComment());
					map.put(Constants.BACK_END_ID, myList.get(i).getId());
					mData.add(map);
					tableName = "doNothingClients";
				}
			}
			if(TYPE_REFUSED.equals(type)){
				ArrayList<ClientsData> myList = (ArrayList<ClientsData>) DbHelper.selectClientData(db, "refusedClients", id);
				for(int i=0;i<myList.size();i++){
					
					HashMap<String, Object> map = new HashMap<String, Object>();
					map.put(Constants.PEOPLE_NAME, myList.get(i).getPeopleName());
					map.put(Constants.PEOPLE_CONTACTS, myList.get(i).getPhoneNumber());
					map.put(Constants.IS_CHECK, myList.get(i).getIsCheck());
					map.put(Constants.BACK_END_ID, myList.get(i).getId());
					map.put(Constants.MSG, myList.get(i).getComment());
					mData.add(map);
					tableName = "refusedClients";
				}
			}
			
			ContentValues contentValues = new ContentValues();
			contentValues.put("isCheck", "true");
			DbHelper.upData(tableName, contentValues,null);
			
			if(db!=null&&db.isOpen()){
				db.close();
			}
			return new String[3];
		}

		@Override
		protected void onProgressUpdate(Integer... values) {

			super.onProgressUpdate(values);
		}

		@Override
		protected void onPostExecute(String[] result) {
			if (mData.size() == 0) {
				txtNoData.setVisibility(View.VISIBLE);
				dataListView.setVisibility(View.GONE);
			} else {
				txtNoData.setVisibility(View.GONE);
			}
			myAdapter.notifyDataSetChanged();
			ProgressBar proBar = (ProgressBar)findViewById(R.id.proBar);
			proBar.setVisibility(View.GONE);
		}

		public void analyzeJson(String result, String type) {
			String status;
			String description;
			String isCheck;
			JSONObject datasource;
			String msg;

			try {
				JSONObject outPut = new JSONObject(result)
						.getJSONObject(Constants.OUT_PUT);
				status = outPut.getString(Constants.STATUS);
				description = outPut.getString(Constants.DESCRIPTION);
				datasource = outPut.getJSONObject(Constants.DATA_SOURCE);
				if ("ok".equals(status)) {
					mData.clear();
					JSONArray jsonArray = datasource.getJSONArray("clientList");
					if (TYPE_ALL.equals(type)) {
						for (int i = 0; i < jsonArray.length(); i++) {
							String cName = jsonArray.getJSONObject(i)
									.getString("cName");
							String cValue = jsonArray.getJSONObject(i)
									.getString("cValue");
							backendID = jsonArray.getJSONObject(i).getString(
									"backendID");
							String myStatus = jsonArray.getJSONObject(i)
									.getString("status");
							isCheck = jsonArray.getJSONObject(i)
									.getString("isCheck");
							msg = jsonArray.getJSONObject(i)
									.getString("msg");
							HashMap<String, Object> map = new HashMap<String, Object>();
							map.put(Constants.PEOPLE_NAME, cName);
							map.put(Constants.PEOPLE_CONTACTS, cValue);
							map.put(Constants.CLIENT_ID, backendID);
							map.put(Constants.STATUS, myStatus);
							map.put(Constants.IS_CHECK, isCheck);
							map.put(Constants.MSG, msg);
							mData.add(map);
						}
					} else {
						for (int i = 0; i < jsonArray.length(); i++) {
							String cName = jsonArray.getJSONObject(i)
									.getString("cName");
							String cValue = jsonArray.getJSONObject(i)
									.getString("cValue");
							backendID = jsonArray.getJSONObject(i).getString(
									"backendID");
							isCheck = jsonArray.getJSONObject(i)
									.getString("isCheck");
							msg = jsonArray.getJSONObject(i)
									.getString("msg");
							HashMap<String, Object> map = new HashMap<String, Object>();
							map.put(Constants.PEOPLE_NAME, cName);
							map.put(Constants.PEOPLE_CONTACTS, cValue);
							map.put(Constants.CLIENT_ID, backendID);
							map.put(Constants.IS_CHECK, isCheck);
							map.put(Constants.MSG, msg);
							mData.add(map);
						}
					}
				}

			} catch (JSONException e) {

				e.printStackTrace();
			}

		}

	}

	/**
	 * item holder
	 * 
	 * @author cuikuangye
	 * 
	 */
	public final class ViewHolder {

		public TextView peopleName;

		public TextView peoPleContacts;

		public Button btnRegister;

		public Button btnUnRegister;
		
		public ImageView newFlag;

	}

	public class MyAdapter extends BaseAdapter {

		private LayoutInflater mInflater;
		public int count;

		public MyAdapter(Context context) {

			this.mInflater = LayoutInflater.from(context);

		}

		@Override
		public int getCount() {
			count = mData.size();
			return count;

		}

		@Override
		public Object getItem(int position) {

			return null;

		}

		@Override
		public long getItemId(int position) {

			return 0;

		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {

			ViewHolder holder = null;

			if (convertView == null) {

				holder = new ViewHolder();

				convertView = mInflater.inflate(R.layout.people_item_property,
						null);

				holder.peopleName = (TextView) convertView
						.findViewById(R.id.people_name);

				holder.peoPleContacts = (TextView) convertView
						.findViewById(R.id.people_contacts);

				holder.btnRegister = (Button) convertView
						.findViewById(R.id.btnPeopleRegister);

				holder.btnUnRegister = (Button) convertView
						.findViewById(R.id.btnPeopleUnRegister);
				
				holder.newFlag = (ImageView) convertView
						.findViewById(R.id.newFlag);
				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();

			}

			bindView(holder, position);

			return convertView;

		}

		public void bindView(final ViewHolder viewHolder, final int position) {
			viewHolder.peopleName.setText((String) mData.get(position).get(
					Constants.PEOPLE_NAME));
			if(peopleTag == SIGNED_PEOPLE || peopleTag == UNRESPONSED_PEOPLE){
				viewHolder.peoPleContacts.setText((String) mData.get(position).get(
						Constants.MSG));
			}else{
				viewHolder.peoPleContacts.setVisibility(View.GONE);
			}
			

			viewHolder.btnRegister.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					action = "apply";
					applyThread = getThread();
					applyThread.start();
					viewHolder.btnRegister.setClickable(false);
					return;
				}
			});

			viewHolder.btnUnRegister.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					action = "";
					applyThread = getThread();
					applyThread.start();
					viewHolder.btnUnRegister.setClickable(false);
					return;
				}
			});
			if (peopleTag == INVATED_PEOPLE) {

			}
			if (peopleTag == SIGNED_PEOPLE) {
				viewHolder.btnRegister.setVisibility(View.GONE);
			}
			if (peopleTag == UNSIGNED_PEOPLE) {
				viewHolder.btnUnRegister.setVisibility(View.GONE);
			}
			if (peopleTag == UNRESPONSED_PEOPLE) {

			}
			
			String flag =  (String) mData.get(position).get(
					Constants.IS_CHECK);
			if("false".equals(flag)){
				viewHolder.newFlag.setVisibility(View.VISIBLE);
			}
			
		}
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		name = (String) mData.get(position).get(Constants.PEOPLE_NAME);
		cValue = (String) mData.get(position).get(Constants.PEOPLE_CONTACTS);
		clientId = (String) mData.get(position).get(Constants.BACK_END_ID);
		transIntent = new Intent(PeopleInfoActivity.this,
				DetailPeopleInfo.class);
		transIntent.putExtra(Constants.PEOPLE_NAME, name);
		transIntent.putExtra(Constants.PEOPLE_CONTACTS, cValue);
		transIntent.putExtra(Constants.PARTY_ID, partyId);
		transIntent.putExtra(Constants.BACK_END_ID, clientId);
		transIntent.putExtra(Constants.LEAVE_MESSAGE, (String) mData.get(position).get(Constants.MSG));
		startActivity(transIntent);
		
	}

}
