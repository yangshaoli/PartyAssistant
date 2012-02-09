package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.drawable.BitmapDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.appmanager.ActivityManager;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;
import com.aragoncg.apps.airenao.utills.Utility;
import com.aragoncg.apps.airenao.weibo.ShareActivity;

public class DetailActivity extends Activity implements OnItemClickListener {

	private int[] resImageArry;
	private String[] resMenuNameArry;
	private static boolean showFlag = true;
	public static boolean showNewFlag;
	private PopupWindow pw = null;
	private ComponentsCache myCache;
	private AirenaoActivity myAirenaoActivity;
	private String getClientsCountUrl;
	private String[] clientCount;
	private String[] newCount = new String[2];
	private MyAdapter adapter;
	private Handler myHandler;
	private boolean loated = false;
	private String partyId = "-1";
	private static final int PROGRESS_GONE = 1;
	private String userId;
	private GridView gridView;
	private String delteUrl;
	private String applyUrl = "";

	private static final int SUCCESS = 0;
	private static final int FAIL = 3;
	private static final int EXCEPTION = 2;
	private static final int MENU_DELETE = 0;
	private static final int MENU_REFRESH = 1;
	private static final int MENU_SHARE = 2;
	private static final int MENU_SETTINT = 3;
	private static final int MENU_EDIT = 4;
	private static final int MSG_ID_DELETE = 4;
	private static final int MSG_ID_REFRESH = 5;
	private ProgressDialog progressDialog;

	List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
	private List<Map<String, Object>> dataList;

	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		ActivityManager.getInstance().addActivity(this);
		setContentView(R.layout.detail_activity_layout);
		// setProgressBarVisibility(true);
		// 获得屏幕的高度
		initMyHandler();
		initBaseData();
		getComponentsCache();
		initFormData();
		dataList = getDataFromServer();
		adapter = new MyAdapter(this);

		ListView dataListView = (ListView) findViewById(R.id.listDetailLable);
		dataListView.setAdapter(adapter);
		dataListView.setOnItemClickListener(this);
		// 计算列表需要的高度
		Utility.setListViewHeightBasedOnChildren(dataListView);

	}

	public void initMyHandler() {
		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case PROGRESS_GONE: {
					break;
				}
				case SUCCESS:
					if (progressDialog != null) {
						progressDialog.cancel();
					}
					finish();
					break;
				case FAIL:
					Toast.makeText(DetailActivity.this, "保存失败",
							Toast.LENGTH_SHORT);
					break;
				case EXCEPTION:
					if (progressDialog != null) {
						progressDialog.cancel();
					}
					Toast.makeText(DetailActivity.this, "错误，请重试",
							Toast.LENGTH_SHORT);
					break;
				case MSG_ID_DELETE:
					if (progressDialog != null) {
						progressDialog.cancel();
					}
					Toast.makeText(DetailActivity.this, "删除失败",
							Toast.LENGTH_SHORT);
					break;
				case MSG_ID_REFRESH:
					if (progressDialog != null) {
						progressDialog.cancel();
					}
					Toast.makeText(DetailActivity.this, "获得数据失败",
							Toast.LENGTH_SHORT);
				}

				super.handleMessage(msg);
			}

		};
	}

	/**
	 * 生成一些基本的对象
	 */
	private void initBaseData() {
		SharedPreferences mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(DetailActivity.this);
		// userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME,
		// null);
		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);
		applyUrl = mySharedPreferences.getString(partyId, "");
		// 获得组件集合对象
		myCache = new ComponentsCache();
		// 获得menu data
		resImageArry = new int[] { R.drawable.delete_detail,
				R.drawable.btn_synchronize, R.drawable.share_detail,
				R.drawable.btn_setting, R.drawable.menu_edit };
		resMenuNameArry = new String[] { getString(R.string.delete),
				getString(R.string.refresh), getString(R.string.share),
				getString(R.string.btn_setting), getString(R.string.menuEdit) };

		/**
		 * 得到menu的样式属性
		 */
		// 用LayoutInflater把一个view 生成，为的是 获得该view的上得组件资源
		LayoutInflater inflater = (LayoutInflater) this
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		// 这个menu是这个
		View view = inflater.inflate(R.layout.menu_detail, null);
		// 通过 生成的view 获得它的 GridView 组件
		gridView = (GridView) view.findViewById(R.id.menuGridChange);
		//
		gridView.setAdapter(new ImageAdapter(this));

		// 用Popupwindow弹出menu
		pw = new PopupWindow(view, LayoutParams.FILL_PARENT,
				LayoutParams.WRAP_CONTENT);
		pw.setFocusable(true);
		pw.setBackgroundDrawable(new BitmapDrawable());
		pw.setOutsideTouchable(false);
		// 为gridView设置点击事件
		inintPopWindowListenner();

		// 获得list中pass过来的activity对象
		Intent myIntent = getIntent();
		myAirenaoActivity = (AirenaoActivity) myIntent
				.getSerializableExtra(Constants.TO_DETAIL_ACTIVITY);

		if (myAirenaoActivity == null) {
			throw new NullPointerException("没有获得列表中的活动");
		}
		partyId = myAirenaoActivity.getId();
		getClientsCountUrl = Constants.DOMAIN_NAME
				+ Constants.SUB_DOMAIN_GET_CLIENTCOUNT_URL;
	}

	/**
	 * 获得数据
	 * 
	 * @return
	 */
	private List<Map<String, Object>> getDataFromServer() {

		AsyncTaskLoad asynTask = new AsyncTaskLoad(DetailActivity.this, partyId);
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

	public void inintPopWindowListenner() {
		pw.setTouchInterceptor(new OnTouchListener() {

			@Override
			public boolean onTouch(View arg0, MotionEvent arg1) {
				DisplayMetrics dm = new DisplayMetrics();
				int screenHight = dm.heightPixels;
				if (arg1.getY() < (screenHight - gridView.getHeight())) {

					if (pw.isShowing())
						pw.dismiss();
				}

				return false;
			}
		});
		gridView.setOnKeyListener(new OnKeyListener() {

			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				// TODO Auto-generated method stub

				if (keyCode == KeyEvent.KEYCODE_MENU
						&& event.getRepeatCount() == 0 && showFlag == true) {
					if (pw.isShowing())
						pw.dismiss();
				}
				showFlag = true;
				return false;
			}

		});
		gridView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				switch (position) {
				case MENU_DELETE:

					if (pw.isShowing()) {
						pw.dismiss();
						progressDialog = ProgressDialog.show(
								DetailActivity.this, "", "删除中...", true, true);
						// 删除
						delteUrl = Constants.DOMAIN_NAME
								+ Constants.SUB_DOMAIN_DELETE_URL;
						Runnable remove = new Runnable() {

							@Override
							public void run() {
								// 删除
								deleleOnePraty(delteUrl, partyId);
							}
						};
						new Handler().post(remove);
					}
					break;
				case MENU_REFRESH:
					if (pw.isShowing()) {
						pw.dismiss();
						progressDialog = ProgressDialog.show(
								DetailActivity.this, "", "loading...", true,
								true);
						dataList = getDataFromServer();
					}
					break;
				case MENU_SHARE:
					if (pw.isShowing()) {
						pw.dismiss();
						SharedPreferences spf = AirenaoUtills
								.getMySharedPreferences(DetailActivity.this);
						String accessToken = spf.getString(
								WeiBoSplashActivity.EXTRA_ACCESS_TOKEN, null);
						String accessSecret = spf.getString(
								WeiBoSplashActivity.EXTRA_TOKEN_SECRET, null);
						Intent intent2 = new Intent();
						Bundle bundle = new Bundle();
						if (accessToken != null && accessSecret != null) {
							String applyUrl = spf.getString(partyId, null);
							if (applyUrl == null) {
								throw new RuntimeException("获得报名链接错误");
							}
							applyUrl = "我使用@我们爱热闹 发布了一个活动！大家快来报名：" + applyUrl;
							bundle.putString(
									WeiBoSplashActivity.EXTRA_WEIBO_CONTENT,
									applyUrl);
							bundle.putString(
									WeiBoSplashActivity.EXTRA_ACCESS_TOKEN,
									accessToken);
							bundle.putString(
									WeiBoSplashActivity.EXTRA_TOKEN_SECRET,
									accessSecret);
							intent2.putExtras(bundle);
							intent2.setClass(DetailActivity.this,
									ShareActivity.class);
							startActivity(intent2);
						} else {
							intent2.putExtra(Constants.PARTY_ID, partyId);
							intent2.setClass(DetailActivity.this,
									WeiBoSplashActivity.class);
							startActivity(intent2);
						}

					}
					break;
				case MENU_SETTINT:
					if (pw.isShowing()) {
						pw.dismiss();

					}
					break;
				case MENU_EDIT:
					if (pw.isShowing()) {
						pw.dismiss();
						Intent intent = new Intent();
						intent
								.setClass(DetailActivity.this,
										EditActivity.class);

						intent.putExtra(Constants.TO_CREATE_ACTIVITY,
								myAirenaoActivity);
						intent.putExtra(Constants.FROMDETAIL, true);
						startActivity(intent);
						finish();
					}
					break;
				}

			}
		});
	}

	public class ViewHolder {

		public TextView peopleName;

		public ProgressBar progressBar;

		public TextView peopleNum;

		public TextView activityContent;

		public ImageView flagNew;

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

				convertView = mInflater.inflate(
						R.layout.detail_activity_property, null);

				holder.peopleName = (TextView) convertView
						.findViewById(R.id.activity_name);

				holder.progressBar = (ProgressBar) convertView
						.findViewById(R.id.progress_small);
				holder.peopleNum = (TextView) convertView
						.findViewById(R.id.activity_time);

				holder.activityContent = (TextView) convertView
						.findViewById(R.id.activity_content);

				holder.flagNew = (ImageView) convertView
						.findViewById(R.id.flagNew);
				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();
			}

			holder.peopleName.setText(String.valueOf(dataList.get(position)
					.get(Constants.PEOPLE_NAME)));
			holder.peopleNum.setText(String.valueOf(dataList.get(position).get(
					Constants.PEOPLE_NUM)));
			if (loated) {
				holder.progressBar.setVisibility(View.GONE);
			}
			if (dataList.get(position).get("newCount") != null) {
				if ("0".equals(dataList.get(position).get("newCount"))) {
					holder.flagNew.setVisibility(View.INVISIBLE);
				} else {
					holder.flagNew.setVisibility(View.VISIBLE);
				}
			}

			return convertView;

		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// NND, 第一个参数， 必须找个View
		pw.showAtLocation(findViewById(R.id.tv), Gravity.CENTER
				| Gravity.BOTTOM, 0, 0);
		showFlag = false;
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
			linear.setOrientation(LinearLayout.VERTICAL);
			// 定义一个ImageView
			ImageView iv = new ImageView(context);
			iv.setImageBitmap(((BitmapDrawable) context.getResources()
					.getDrawable(resImageArry[arg0])).getBitmap());
			LinearLayout.LayoutParams params0 = new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			params0.gravity = Gravity.CENTER;
			linear.addView(iv, params0);
			// 定义一个TextView
			TextView tv = new TextView(context);
			tv.setText(resMenuNameArry[arg0]);
			LinearLayout.LayoutParams params1 = new LayoutParams(
					LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			params1.gravity = Gravity.CENTER;
			linear.addView(tv, params1);

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
		myCache.btnEdit.setVisibility(View.GONE);
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
		myCache.txtContent.setText(myAirenaoActivity.getActivityContent());
		myCache.btnEdit.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent intent = new Intent();
				intent.setClass(DetailActivity.this, EditActivity.class);

				intent
						.putExtra(Constants.TO_CREATE_ACTIVITY,
								myAirenaoActivity);
				intent.putExtra(Constants.FROMDETAIL, true);
				startActivity(intent);
				finish();
			}
		});
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		// position start from 0;
		ViewHolder viewCach = (ViewHolder) view.getTag();
		showNewFlag = viewCach.flagNew.isShown();
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

	public void startIntentToNextActivity(int position) {
		Intent intent = new Intent(DetailActivity.this,
				PeopleInfoActivity.class);
		intent.putExtra(Constants.WHAT_PEOPLE_TAG, position);
		intent.putExtra(Constants.ONE_PARTY, myAirenaoActivity);
		intent.putExtra(Constants.PARTY_ID, partyId);
		startActivity(intent);
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
		private HashMap<String, String> additionalHeaders;

		public AsyncTaskLoad(Context context, String id) {
			this.context = context;
			this.id = id;
		}

		@Override
		protected String[] doInBackground(String... params) {
			
			String[] results = new String[4];
			SQLiteDatabase db = DbHelper.openOrCreateDatabase();
			AirenaoActivity oneParyActivity ;
			try{oneParyActivity = DbHelper.selectOneParty(db, partyId);
			if(oneParyActivity==null){
				results[0]="0";
				results[1]="0";
				results[2]="0";
				results[3]="0";
				newCount[0]="0";
				newCount[1]="0";
			}else{
				results[0]=oneParyActivity.getInvitedPeople();
				results[1]=oneParyActivity.getSignUp();
				results[2]=oneParyActivity.getUnSignUp();
				results[3]=oneParyActivity.getUnJoin();
				newCount[0]=oneParyActivity.getNewApplied();
				newCount[1]=oneParyActivity.getNewUnSignUP();
			}}catch(Exception e){
				
			}finally{
				if(db!=null){
					db.close();
				}
			}
			
			return results;
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
			map.put("newCount", "0");
			list.add(map);
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.signed_number));
			map.put(Constants.PEOPLE_NUM, clientCount[1]);
			map.put("newCount", newCount[0]);
			list.add(map);
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.unsiged_number));
			map.put(Constants.PEOPLE_NUM, clientCount[2]);
			map.put("newCount", "0");
			list.add(map);
			map = new HashMap<String, Object>();
			map.put(Constants.PEOPLE_NAME, getString(R.string.unjion));
			map.put(Constants.PEOPLE_NUM, clientCount[3]);
			map.put("newCount", newCount[1]);
			list.add(map);
			dataList = list;
			adapter.notifyDataSetChanged();
			Message message = new Message();
			message.what = PROGRESS_GONE;
			myHandler.sendMessage(message);
			loated = true;

		}

		/**
		 * 解析数据
		 * 
		 * @param result
		 */
		public String[] analyzeJson(String result) {
			String[] results = new String[4];
			String status;
			String description;
			JSONObject datasource;
			final String ALL_CLIENT_COUNT = "allClientcount";
			final String NEW_APPLIED_CLIENT_COUNT = "newAppliedClientcount";
			final String DATA_SOURCE = "datasource";
			final String APPLIED_CLIENT_COUNT = "appliedClientcount";
			final String REFUSED_CLENT_COUNT = "refusedClientcount";
			final String NEW_REFUSED_CLENT_COUNT = "newRefusedClientcount";
			final String DONOTHING_CLIENT_COUNT = "donothingClientcount";

			try {
				JSONObject jSonObject = new JSONObject(result)
						.getJSONObject(Constants.OUT_PUT);
				status = jSonObject.getString(Constants.STATUS);
				description = jSonObject.getString(Constants.DESCRIPTION);
				if ("ok".equals(status)) {
					datasource = jSonObject.getJSONObject(DATA_SOURCE);
					String allClientCount = datasource
							.getString(ALL_CLIENT_COUNT);
					String appliedClientCount = datasource
							.getString(APPLIED_CLIENT_COUNT);
					String refusedClientCount = datasource
							.getString(REFUSED_CLENT_COUNT);
					String donothingClientcount = datasource
							.getString(DONOTHING_CLIENT_COUNT);
					newCount[0] = datasource
							.getString(NEW_APPLIED_CLIENT_COUNT);
					newCount[1] = datasource.getString(NEW_REFUSED_CLENT_COUNT);
					results[0] = allClientCount;
					results[1] = appliedClientCount;
					results[2] = donothingClientcount;
					results[3] = refusedClientCount;
					if (progressDialog != null) {
						progressDialog.cancel();
					}
				} else {
					// 返回信息
					myHandler.sendEmptyMessage(MSG_ID_REFRESH);

				}

			} catch (JSONException e) {
				myHandler.sendEmptyMessage(EXCEPTION);
			}
			return results;
		}

	}

	@Override
	protected void onRestart() {
		AsyncTaskLoad asynTask = new AsyncTaskLoad(DetailActivity.this, partyId);
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
		dataList = list;
		adapter.notifyDataSetChanged();
		super.onRestart();
	}

	/**
	 * 删除一个party
	 * 
	 * @param url
	 * @param partyId
	 */
	public void deleleOnePraty(final String url, String partyId) {
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("pID", partyId);
		params.put("uID", userId);
		HttpHelper httpClient = new HttpHelper();
		String status = "";

		String result = httpClient
				.performPost(url, params, DetailActivity.this);
		result = AirenaoUtills.linkResult(result);
		try {
			JSONObject outPut = new JSONObject(result)
					.getJSONObject(Constants.OUT_PUT);
			status = outPut.getString(Constants.STATUS);
			// 删除数据库
			SQLiteDatabase db = DbHelper.openOrCreateDatabase();
			String sql = AirenaoUtills.linkSQL(partyId);
			try {
				DbHelper.delete(db, sql);
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				db.close();
			}
			if ("ok".equals(status)) {
				myHandler.sendEmptyMessage(SUCCESS);
			} else {
				Message msg = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(Constants.DESCRIPTION, "删除失败");
				msg.setData(bundle);
				msg.what = MSG_ID_DELETE;
				myHandler.sendMessage(msg);
			}
		} catch (Exception e) {
			myHandler.sendEmptyMessage(EXCEPTION);
		}
	}

}
