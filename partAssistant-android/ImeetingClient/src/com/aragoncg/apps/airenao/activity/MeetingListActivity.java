package com.aragoncg.apps.airenao.activity;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnCreateContextMenuListener;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;

public class MeetingListActivity extends ListActivity implements
		OnScrollListener {

	private List<Map<String, Object>> mData;
	private MyAdapter myDaAdapter;
	
	private ImageButton btnAddOneActivity;
	private LayoutInflater layoutInflater;
	private View footerView;
	private Thread mThread;
	private Runnable firstLoadDataThread;
	private Handler handler;
	private Context mContext;
	private ListView myListView;
	List<Map<String, Object>> list;
	private String partyListUrl;
	private Button btnRefresh;
	private String userName="";
	private String userId="";
	private int page = 1;
	private String status;
	private String description;
	private JSONObject dataSource;
	private JSONArray myJsonArray;
	private Handler postHandler;
	
	public static final String PAGE = "page";
	public static final String PARTY_LIST = "partyList";
	public static final String PARTY_ID = "partyId";
	public static final String POEPLE_MAXMUM = "peopleMaximum";
	public static final String PARTY_DESCRIPTION = "description";
	public static final String PARTY_START_TIME = "starttime";
	public static final String PARTY_LOCATION = "location";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.activity_list);
		AirenaoUtills.activityList.add(this);
		
		mContext = getBaseContext()
				;
		Intent intent = getIntent();
		mData = getData(intent);
		dismissDialog(1);
		myDaAdapter = new MyAdapter(this);
		setListAdapter(myDaAdapter);
		init();
		myListView = getListView();
		myListView.addFooterView(footerView);
		myListView.setOnScrollListener(this);
		// get the ListView and add item on long press menu
		getListView().setOnCreateContextMenuListener(
				new OnCreateContextMenuListener() {

					@Override
					public void onCreateContextMenu(ContextMenu menu, View v,
							ContextMenuInfo menuInfo) {

						menu.setHeaderTitle(getString(R.string.operate));
						menu.add(0, Constants.MENU_FIRST, Constants.MENU_FIRST,
								getString(R.string.delete));
						// menu.add(0, Constants.MENU_SECOND,
						// Constants.MENU_SECOND, getString(R.string.copy));
						menu.add(0, Constants.MENU_THIRD, Constants.MENU_THIRD,
								getString(R.string.share));

					}
				});

		btnAddOneActivity = (ImageButton) findViewById(R.id.btnAddOneActivity);
		btnAddOneActivity.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {

				Intent mIntent = new Intent(MeetingListActivity.this,
						CreateActivity.class);
				startActivity(mIntent);
			}
		});
		//处理刷新事件
		setButtonRefresh();
	}
	
	public void setButtonRefresh(){
		btnRefresh = (Button)findViewById(R.id.btnRefresh);
		btnRefresh.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
			}
		});
	}
	//对footerView的处理
	private void init() {

		layoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		footerView = layoutInflater.inflate(R.layout.load_layout, null);
		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 1:
					if (myDaAdapter.count <= 20) {
						myDaAdapter.count += 7;
						int currentPage = myDaAdapter.count / 7;
						// Toast.makeText(getApplicationContext(),"第" +
						// currentPage + "页", Toast.LENGTH_LONG).show();
					} else {
						myListView.removeFooterView(footerView);
						Toast.makeText(getApplicationContext(), "恰面网提示底了！",
								Toast.LENGTH_LONG).show();
					}
					// 重新刷新Listview的adapter里面数据
					myDaAdapter.notifyDataSetChanged();
					break;
				default:
					break;
				}
			}

		};

	}

	// every item's menu
	@Override
	public boolean onContextItemSelected(MenuItem item) {

		AdapterView.AdapterContextMenuInfo menuInfo;
		menuInfo = (AdapterView.AdapterContextMenuInfo) item.getMenuInfo();
		int menuItemId = item.getItemId();
		int listItemId = menuInfo.position;
		System.out.println("点击了长按菜单里面的第" + item.getItemId() + "个项目" + "地址是："
				+ menuInfo.position);
		switch (menuItemId) {
		case 0:// delete the data of "listItemId"

			AlertDialog dilog = new AlertDialog.Builder(
					MeetingListActivity.this)
					.setTitle(getString(R.string.delete))
					.setIcon(android.R.drawable.ic_delete)
					// .setView(view);
					.create();
			dilog.show();
			/*
			 * 2、某活动右边的按钮: 点击后，弹出“复制"、"删除"、"分享”这三个选项，并选择“删除”按钮
			 * 3、删除时，给出删除确认提示“删除不可恢复，是否确认删除？”， 并分别给出3个按钮“删除并提示客户”、“直接删除”、“取消”
			 * 单击“删除并通知受邀人”，则系统自动发送一封邮件或短信（"尊敬的某某，某年某月某日某时某地点举办的某某活动已取消。"）
			 * 给所有受邀人然后再执行删除动作，按邮件还是短信方式发送依据“发送方式” 单击“直接删除”则不发送提示给客户
			 * 单击“取消”：取消删除动作
			 */
			// 先显示对话框再做删除操作
			removeActivity(listItemId);
			break;
		case 1:// copy the data of "listItemId"

			AirenaoActivity copyOneActivity = new AirenaoActivity();
			copyOneActivity.setActivityName((String) (mData.get(listItemId)
					.get(Constants.ACTIVITY_NAME)));
			copyOneActivity.setActivityTime((String) (mData.get(listItemId)
					.get(Constants.ACTIVITY_TIME)));
			copyOneActivity.setActivityPosition((String) (mData.get(listItemId)
					.get(Constants.ACTIVITY_POSITION)));
			if ((String) (mData.get(listItemId).get(Constants.ACTIVITY_NUMBER)) != null)
				copyOneActivity.setPeopleLimitNum(Integer
						.valueOf((String) (mData.get(listItemId)
								.get(Constants.ACTIVITY_NUMBER))));
			copyOneActivity.setActivityContent((String) (mData.get(listItemId)
					.get(Constants.ACTIVITY_CONTENT)));
			// 进入“创建活动”页面
			startActivity(new Intent(MeetingListActivity.this,
					ImeetingClientActivity.class));
			break;
		case 2:// share the data of "listItemId"
			/*
	        		 * 
	        		 */
			break;
		}
		return super.onContextItemSelected(item);

	}

	// 重写onListItemClick但是ListView条目事件
	@Override
	protected void onListItemClick(ListView listView, View v, int position,
			long id) {

		super.onListItemClick(listView, v, position, id);
		System.out.println("id = " + id);
		System.out.println("position = " + position);

		// 活动对象的数据组合
		HashMap<String, Object> dataHashMap = (HashMap<String, Object>) mData
				.get(position);
		AirenaoActivity airenaoData = new AirenaoActivity();
		airenaoData.setActivityName((String) dataHashMap
				.get(Constants.ACTIVITY_NAME));
		airenaoData.setActivityTime((String) dataHashMap
				.get(Constants.ACTIVITY_TIME));
		airenaoData.setActivityPosition((String) dataHashMap
				.get(Constants.ACTIVITY_POSITION));
		airenaoData.setActivityContent((String) dataHashMap
				.get(Constants.ACTIVITY_CONTENT));
		if("".equals(dataHashMap
				.get(Constants.ACTIVITY_NUMBER))){
			airenaoData.setPeopleLimitNum(100000);
		}else{
			airenaoData.setPeopleLimitNum(Integer.valueOf((String) dataHashMap
					.get(Constants.ACTIVITY_NUMBER)));
		}
		
		
		/*
		 * 点击活动列表中的一项，进入到活动详情当中 跳转到具体活动Activity 中
		 */
		Intent intent = new Intent(getString(R.string.to_detail_activity));
		intent.putExtra(Constants.TO_DETAIL_ACTIVITY, airenaoData);

		startActivity(intent);
		
	}

	/**
	 * 
	 * Method:getData TODO(获得数据)
	 * 
	 * @author cuikuangye
	 * @return privateList<Map<String,Object>>
	 * @Date 2011-11-5 am 10:00:00
	 * @throws
	 * 
	 */
	private List<Map<String, Object>> getData(Intent data) {
		postHandler = new Handler(){

			@Override
			public void handleMessage(Message msg) {
				switch(msg.what){
				 case Constants.POST_MESSAGE_CASE:{
					 String message = msg.getData().getString(Constants.HENDLER_MESSAGE);
					 AlertDialog aDig = new AlertDialog.Builder(
								MeetingListActivity.this).setMessage(
										message).create();
						aDig.show();
				 }
				}
				super.handleMessage(msg);
			}
			
		};
		SharedPreferences mySharedPreferences = AirenaoUtills.getMySharedPreferences(MeetingListActivity.this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME, null);
		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);
		
		// 在map装配的时候，一个活动的所有属性全部装配
		//先从本地获得数据，如果数据为空那么在从后台取数据
		 showDialog(1);
		if (list == null) {
			list = new ArrayList<Map<String, Object>>();
		}
		list = getDataFromServer();
		if(list.size()>0){
			return list;
		}else{
			if (firstLoadDataThread == null) {
				firstLoadDataThread = new Runnable() {

					@Override
					public void run() {
						// 配置url
						partyListUrl = getString(R.string.partyListUrl);
						partyListUrl = partyListUrl + userId + "/" + page + "/";
						HttpHelper myHttpHelper = new HttpHelper();
						String dataResult = myHttpHelper.performGet(partyListUrl, MeetingListActivity.this);
						dataResult = AirenaoUtills.linkResult(dataResult);
						analyzeJson(dataResult);
						
					}
				};
				postHandler.post(firstLoadDataThread);
				return list;
			}
			
			return list;
		}

	}
	/**
	 * 获得本地数据
	 */
	public List<Map<String, Object>> getDataFromServer(){
		SQLiteDatabase db = DbHelper.openDatabase();
		return (ArrayList<Map<String, Object>>) DbHelper.selectActivitys(db); 
	}
	/**
	 * 
	 * ClassName:ViewHolder Function: TODO all the Component Reason: TODO ADD
	 * REASON
	 * 
	 * @author cuikuangye
	 * @version MeetingListActivity
	 * @Date 2011 2011-11-5 am 10:20:08
	 * @see
	 * 
	 */
	public final class ViewHolder {

		public TextView activityName;

		public TextView activityTime;

		public TextView activityContent;

	}

	/**
	 * 
	 * ClassName:MyAdapter Function: TODO delimit my adapter
	 * 
	 * @author cuikuangye
	 * @version MeetingListActivity
	 * @Date 2011 2011-11-5 am 10:10:29
	 * @see
	 * 
	 */
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

				convertView = mInflater.inflate(R.layout.activity_property,
						null);

				holder.activityName = (TextView) convertView
						.findViewById(R.id.activity_name);

				holder.activityTime = (TextView) convertView
						.findViewById(R.id.activity_time);

				holder.activityContent = (TextView) convertView
						.findViewById(R.id.activity_content);

				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();

			}

			holder.activityName.setText((String) mData.get(position).get(
					Constants.ACTIVITY_NAME));
			holder.activityTime.setText((String) mData.get(position).get(
					Constants.ACTIVITY_TIME));
			holder.activityContent.setText((String) mData.get(position).get(
					Constants.ACTIVITY_CONTENT));

			return convertView;

		}
	}

	/**
	 * 
	 * Method:removeActivity:(delete one Activity data)
	 * 
	 * @author cuikuangye
	 * 
	 */
	public void removeActivity(int itemId) {
		mData.remove(itemId);
		myDaAdapter.notifyDataSetChanged();
		myDaAdapter.notifyDataSetInvalidated();
	}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {

	}

	@Override
	public void onScroll(AbsListView view, int firstVisibleItem,
			int visibleItemCount, int totalItemCount) {
		if (firstVisibleItem + visibleItemCount == totalItemCount) {
			// 开线程去下载网络数据
			if (mThread == null || !mThread.isAlive()) {
				mThread = new Thread() {
					@Override
					public void run() {
						try {
							if (myDaAdapter.getCount() <= 20) {
								// 这里放你网络数据请求的方法，我在这里用线程休眠5秒方法来处理
								page += 1;
								partyListUrl = getString(R.string.partyListUrl) + userId + "/" + page +"/";
								HttpHelper myHttpHelper = new HttpHelper();
								String dataResult = myHttpHelper.performGet(partyListUrl, MeetingListActivity.this);
								dataResult = AirenaoUtills.linkResult(dataResult);
								analyzeJson(dataResult);
							}
							Thread.sleep(5000);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
						Message message = new Message();
						message.what = 1;
						handler.sendMessage(message);
					}
				};
				mThread.start();
			}
		}

	}

	@Override
	protected Dialog onCreateDialog(int id) {
		ProgressDialog dialog = new ProgressDialog(this);
		dialog.setMessage(getString(R.string.loadAirenao));
		dialog.setIndeterminate(true);
		dialog.setCancelable(true);
		return dialog;

	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {

		if (keyCode == KeyEvent.KEYCODE_BACK) {
			AlertDialog noticeDialog = new AlertDialog.Builder(
					MeetingListActivity.this)
					.setCancelable(true)
					.setTitle(R.string.sendLableTitle)
					.setMessage(R.string.exitMessage)
					.setNegativeButton(
							R.string.btn_cancle,
							new android.content.DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {

								}
							})
					.setPositiveButton(
							R.string.btn_ok,
							new android.content.DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									AirenaoUtills.exitClient(mContext);

								}

							}).create();
			noticeDialog.show();

		}
		return false;
	}
	/**
	 * 解析Json 	
	 */
	public void analyzeJson(String result) {
		SQLiteDatabase db = DbHelper.openDatabase();

		try {
			JSONObject output = new JSONObject(result)
					.getJSONObject(Constants.OUT_PUT);
			status = output.getString(Constants.STATUS);
			description = output.getString(Constants.DESCRIPTION);
		if("ok".equals(status)){
			dataSource = output.getJSONObject(Constants.DATA_SOURCE);
			page = Integer.valueOf(dataSource.getString(PAGE));
			myJsonArray = dataSource.getJSONArray(PARTY_LIST);
			for (int i = 0; myJsonArray.length() > 0; i++) {
				JSONObject tempActivity = myJsonArray.getJSONObject(i);
				list.add(organizeMap(tempActivity));
				try {
					DbHelper.insert(db, organizeOneActivity(tempActivity),
							DbHelper.ACTIVITY_TABLE_NAME);
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					db.close();
				}
			}
		}else{
			Message message = new Message();
			message.what = Constants.POST_MESSAGE_CASE;
			Bundle bundle = new Bundle();
			bundle.putString(Constants.HENDLER_MESSAGE, description);
			message.setData(bundle);
			postHandler.sendMessage(message);
		}
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 将Json解析出来的数据装到MAP
	 * @param data
	 * @return
	 */
	public HashMap<String, Object> organizeMap(JSONObject data){
		HashMap<String, Object> map = new HashMap<String, Object>();
		try {
			map.put(Constants.ACTIVITY_NAME, data.getString(PARTY_DESCRIPTION).substring(0, 6));
			map.put(Constants.ACTIVITY_TIME, data.getString(PARTY_START_TIME));
			map.put(Constants.ACTIVITY_POSITION, data.getString(PARTY_LOCATION));//data.getString()
			map.put(Constants.ACTIVITY_CONTENT, data.getString(PARTY_DESCRIPTION));
			map.put(Constants.ACTIVITY_NUMBER, data.getString(POEPLE_MAXMUM));
		} catch (JSONException e) {
			
			e.printStackTrace();
		}
		
		return map;
	}
	/**
	 * 封装一个活动
	 * @param data
	 * @return
	 */
	public AirenaoActivity organizeOneActivity(JSONObject data){
		AirenaoActivity myActivity = new AirenaoActivity();
		try {
			myActivity.setActivityName(data.getString(description.substring(0, 6)));
			myActivity.setActivityTime(data.getString(PARTY_START_TIME));
			myActivity.setActivityPosition(data.getString(PARTY_LOCATION));//data.getString()
			myActivity.setActivityContent(data.getString(PARTY_DESCRIPTION));
			if(data.getString(POEPLE_MAXMUM)!= null && !"".equals(data.getString(POEPLE_MAXMUM))){
				myActivity.setPeopleLimitNum(Integer.valueOf(data.getString(POEPLE_MAXMUM)));
			}
			
		} catch (JSONException e) {
			
			e.printStackTrace();
		}
		
		return myActivity;
	}
}
