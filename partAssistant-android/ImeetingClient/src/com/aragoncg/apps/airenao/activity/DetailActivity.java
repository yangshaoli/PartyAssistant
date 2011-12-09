package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;
import com.aragoncg.apps.airenao.utills.Utility;

public class DetailActivity extends Activity implements OnItemClickListener {

	private int[] resImageArry;
	private String[] resMenuNameArry;
	private static boolean showFlag = true;
	private PopupWindow pw = null;
	private ComponentsCache myCache;
	private AirenaoActivity myAirenaoActivity;
	private String getClientsCountUrl;
	private String[] clientCount;
	private MyAdapter adapter;
	private Handler myHandler;
	private boolean loated = false;
	private int partyId = -1;
	private static final int PROGRESS_GONE = 1;
	
	List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
	private List<Map<String, Object>> dataList;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		AirenaoUtills.activityList.add(this);
		setContentView(R.layout.detail_activity_layout);
		//setProgressBarVisibility(true);
		// 获得屏幕的高度
		initMyHandler();
		dataList = getData();
		getComponentsCache();
		initFormData();
		adapter = new MyAdapter(this);
		
		ListView dataListView = (ListView) findViewById(R.id.listDetailLable);
		dataListView.setAdapter(adapter);
		dataListView.setOnItemClickListener(this);
		dataListView.setOnItemSelectedListener(new OnItemSelectedListener() {
		
			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int position, long id) {
				
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {
				// TODO Auto-generated method stub

			}
		});
		//计算列表需要的高度
		Utility.setListViewHeightBasedOnChildren(dataListView);

	}
	
	public void initMyHandler(){
		myHandler = new Handler(){

			@Override
			public void handleMessage(Message msg) {
				switch(msg.what){
				 case PROGRESS_GONE:{
					 int count = adapter.getCount();
						/*for(int i=0;i<count;i++){
							View convertView = adapter.getView(i, null, null);
							ViewHolder holder = (ViewHolder)convertView.getTag();
							holder.progressBar.setVisibility(View.GONE);
							adapter.notifyDataSetChanged();
						}*/
					 break;
				 }
				}
				
				super.handleMessage(msg);
			}
			
		};
	}
	/**
	 * 获得数据
	 * @return
	 */
	private List<Map<String, Object>> getData() {
		// 获得组件集合对象
		myCache = new ComponentsCache();
		// 获得menu data
		resImageArry = new int[] { R.drawable.delete_detail,
				R.drawable.copy_detail, R.drawable.share_detail };
		resMenuNameArry = new String[] { getString(R.string.delete),
				getString(R.string.copy), getString(R.string.share) };

		/**
		 * 得到menu的样式属性
		 */
		// 用LayoutInflater把一个view 生成，为的是 获得该view的上得组件资源
		LayoutInflater inflater = (LayoutInflater) this
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// 这个menu是这个
		View view = inflater.inflate(R.layout.menu_detail, null);
		// 通过 生成的view 获得它的 GridView 组件
		GridView grid1 = (GridView) view.findViewById(R.id.menuGridChange);
		//
		grid1.setAdapter(new ImageAdapter(this));

		// 用Popupwindow弹出menu
		pw = new PopupWindow(view, LayoutParams.FILL_PARENT,
				LayoutParams.WRAP_CONTENT);

		// 获得list中穿过来的activity对象
		Intent myIntent = getIntent();
		myAirenaoActivity = (AirenaoActivity) myIntent
				.getSerializableExtra(Constants.TO_DETAIL_ACTIVITY);

		if (myAirenaoActivity == null) {
			throw new NullPointerException("没有获得列表中的活动");
		}
		partyId = myAirenaoActivity.getId();
		getClientsCountUrl = getString(R.string.getClientsCountUrl);
		AsyncTaskLoad asynTask = new AsyncTaskLoad(DetailActivity.this, partyId+"");
		asynTask.execute(getClientsCountUrl);
		
		Map<String, Object> map;
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.invited_number));
		map.put(Constants.PEOPLE_NUM, "");
		list.add(map);
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.signed_number));
		map.put(Constants.PEOPLE_NUM, "");
		list.add(map);
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.unsiged_number));
		map.put(Constants.PEOPLE_NUM, "");
		list.add(map);
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.unjion));
		map.put(Constants.PEOPLE_NUM, "");
		list.add(map);
		
		
		return list;

	}

	public  class ViewHolder {

		public TextView peopleName;
		
		public ProgressBar progressBar;
		
		public TextView peopleNum;

		public TextView activityContent;

	}

	public class MyAdapter extends BaseAdapter {

		private LayoutInflater mInflater;
		private ProgressBar myProgerssBar;

		public MyAdapter(Context context) {

			this.mInflater = LayoutInflater.from(context);
			
		}

		@Override
		public int getCount() {

			return dataList.size();

		}

		@Override
		public Object getItem(int position) {
			
			return dataList.get(position);
		}

		@Override
		public long getItemId(int position) {

			return position;

		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {

			ViewHolder holder = null;

			if (convertView == null) {

				holder = new ViewHolder();

				convertView = mInflater.inflate(R.layout.detail_activity_property,
						null);

				holder.peopleName = (TextView) convertView
						.findViewById(R.id.activity_name);
				
				holder.progressBar = (ProgressBar)convertView
						.findViewById(R.id.progress_small);
				holder.peopleNum = (TextView) convertView
						.findViewById(R.id.activity_time);
				
				holder.activityContent = (TextView) convertView
						.findViewById(R.id.activity_content);
				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();
			}
			
			holder.peopleName.setText(String.valueOf(dataList.get(position)
					.get(Constants.PEOPLE_NAME)));
			holder.peopleNum.setText(String.valueOf(dataList.get(position).get(
					Constants.PEOPLE_NUM)));
			if(loated){
				holder.progressBar.setVisibility(View.GONE);
			}
			
			return convertView;

		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		return super.onOptionsItemSelected(item);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		if (showFlag) {
			// NND, 第一个参数， 必须找个View
			pw.showAtLocation(findViewById(R.id.tv), Gravity.CENTER
					| Gravity.BOTTOM, 0, 0);
			showFlag = false;
		} else {
			showFlag = true;
			pw.dismiss();
		}

		return false;
	}

	public class ImageAdapter extends BaseAdapter {

		private Context context;

		public ImageAdapter(Context context) {
			this.context = context;
		}

		@Override
		public int getCount() {
			return resImageArry.length;
		}

		@Override
		public Object getItem(int arg0) {
			return resImageArry[arg0];
		}

		@Override
		public long getItemId(int arg0) {
			return arg0;
		}

		@Override
		public View getView(int arg0, View arg1, ViewGroup arg2) {
			// 动态的定义一个布局管理器，用来放置 图片信息 LinearLayout 也属于View
			LinearLayout linear = new LinearLayout(context);
			LinearLayout.LayoutParams params = new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			linear.setOrientation(LinearLayout.VERTICAL);
			// 定义一个ImageView
			ImageView iv = new ImageView(context);
			iv.setImageBitmap(((BitmapDrawable) context.getResources()
					.getDrawable(resImageArry[arg0])).getBitmap());
			LinearLayout.LayoutParams params2 = new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			params2.gravity = Gravity.CENTER;
			linear.addView(iv, params2);
			// 定义一个TextView
			TextView tv = new TextView(context);
			tv.setText(resMenuNameArry[arg0]);
			LinearLayout.LayoutParams params3 = new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			params3.gravity = Gravity.CENTER;
			linear.addView(tv, params3);

			return linear;
		}
	}

	/**
	 * 
	 * ClassName:ComponentsCache Function: 组件集合
	 * 
	 * @author cuikuangye
	 * @version DetailActivity
	 * @Date 2011 2011-11-17 pm 7:59:28
	 * @see
	 * 
	 */
	final static class ComponentsCache {
		public EditText txtTime;
		public EditText txtPosition;
		public EditText txtNum;
		public EditText txtContent;
		public Button btnEdit;
	}

	public void getComponentsCache() {
		myCache.txtTime = (EditText) findViewById(R.id.startTimeText);
		myCache.txtTime.setBackgroundDrawable(null);
		myCache.txtPosition = (EditText) findViewById(R.id.positionEditText);
		myCache.txtPosition.setBackgroundDrawable(null);
		myCache.txtNum = (EditText) findViewById(R.id.peopleNumEditText);
		myCache.txtNum.setBackgroundDrawable(null);
		myCache.txtContent = (EditText) findViewById(R.id.descrEditText);
		myCache.txtContent.setBackgroundDrawable(null);
		myCache.btnEdit = (Button) findViewById(R.id.btnDetailEdit);
	}

	/**
	 * Method:initFormData
	 * 
	 * @author cuikuangye void
	 * @Date 2011 2011-11-18 上午10:14:45
	 * @throws
	 * 
	 */
	public void initFormData() {
		myCache.txtTime.setText(myAirenaoActivity.getActivityTime());
		myCache.txtPosition.setText(myAirenaoActivity.getActivityPosition());
		myCache.txtNum.setText(String.valueOf(myAirenaoActivity
				.getPeopleLimitNum()));
		myCache.txtContent.setText(myAirenaoActivity.getActivityContent());
		myCache.btnEdit.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {

				Intent intent = new Intent();
				intent.setClass(DetailActivity.this, CreateActivity.class);

				intent.putExtra(Constants.TO_CREATE_ACTIVITY, myAirenaoActivity);
				intent.putExtra(Constants.FROMDETAIL, true);
				startActivity(intent);

			}
		});
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		// position start from 0;
		switch (position) {
		case 0: {
			startIntentToNextActivity(position);
			break;
		}
		case 1: {
			startIntentToNextActivity(position);
			break;
		}
		case 2: {
			startIntentToNextActivity(position);
			break;
		}
		case 3: {
			startIntentToNextActivity(position);
			break;
		}
		}
	}
	
	public void startIntentToNextActivity(int position){
		Intent intent = new Intent(DetailActivity.this,
				PeopleInfoActivity.class);
		intent.putExtra(Constants.WHAT_PEOPLE_TAG, position);
		intent.putExtra(Constants.ONE_PARTY, myAirenaoActivity);
		intent.putExtra(Constants.PARTY_ID, partyId);
		startActivity(intent);
	}
	/**
	 * 异步加载数据  --- client count
	 * @author cuikuangye
	 *
	 */
	class AsyncTaskLoad extends AsyncTask<String, Integer, String[]> {
		private String id = "";
		private Context context;
		private HashMap<String, String> additionalHeaders;
		
		public AsyncTaskLoad(Context context,String id) {
			this.context = context;
			this.id = id;
		}

		@Override
		protected String[] doInBackground(String... params) {
			HttpHelper httpHelper = new HttpHelper();
			String result = httpHelper.performGet(params[0]+id+"/", null, null, null, context);
			result = AirenaoUtills.linkResult(result);
			
			return analyzeJson(result);
		}

		@Override
		protected void onProgressUpdate(Integer... values) {
			
			super.onProgressUpdate(values);
		}

		@Override
		protected void onPostExecute(String[] result) {
			clientCount = result;
			
			list.clear();
			Map<String, Object> map;
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.invited_number));
			map.put(Constants.PEOPLE_NUM, clientCount[0]);
			list.add(map);
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.signed_number));
			map.put(Constants.PEOPLE_NUM, clientCount[1]);
			list.add(map);
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.unsiged_number));
			map.put(Constants.PEOPLE_NUM, clientCount[2]);
			list.add(map);
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.unjion));
			map.put(Constants.PEOPLE_NUM, clientCount[3]);
			list.add(map);
			dataList = list;
			Message message = new Message();
			message.what = PROGRESS_GONE;
			myHandler.sendMessage(message);
			loated = true;
			adapter.notifyDataSetChanged();
		}
		/**
		 * 解析数据
		 * @param result
		 */
		public String[] analyzeJson(String result){
			String[] results = new String[4];
			String status;
			String description;
			JSONObject datasource;
			final  String ALL_CLIENT_COUNT = "allClientcount";
			final  String DATA_SOURCE = "datasource";
			final  String APPLIED_CLIENT_COUNT = "appliedClientcount";
			final  String REFUSED_CLENT_COUNT = "refusedClientcount";
			final  String DONOTHING_CLIENT_COUNT = "donothingClientcount";
					
			try {
				JSONObject jSonObject = new JSONObject(result).getJSONObject(Constants.OUT_PUT);
				status = jSonObject.getString(Constants.STATUS);
				description = jSonObject.getString(Constants.DESCRIPTION);
				if("ok".equals(status) && "ok".equals(description)){
					datasource = jSonObject.getJSONObject(DATA_SOURCE);
					String allClientCount = datasource.getString(ALL_CLIENT_COUNT);
					String appliedClientCount = datasource.getString(APPLIED_CLIENT_COUNT);
					String refusedClientCount = datasource.getString(REFUSED_CLENT_COUNT);
					String donothingClientcount = datasource.getString(DONOTHING_CLIENT_COUNT);
					results[0] = allClientCount;
					results[1] = appliedClientCount;
					results[2] = refusedClientCount;
					results[3] = donothingClientcount;
				}else{
					//返回信息
				}
				
			} catch (JSONException e) {
				
				e.printStackTrace();
			}
			return results;
		}
		
	}
}
