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
import android.view.Menu;
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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.DB.DbHelper;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.model.ClientsData;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.HttpHelper;
import com.aragoncg.apps.airenao.weibo.ShareActivity;

public class MeetingListActivity extends ListActivity implements
		OnScrollListener {

	private List<Map<String, Object>> mData = new ArrayList<Map<String, Object>>();
	private MyAdapter myDaAdapter;

	private ImageButton btnAddOneActivity;
	private View footerView;
	private Thread mThread;
	private Runnable firstLoadDataThread;
	private Handler handler;
	private Context mContext;
	private ListView myListView;
	List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
	private String partyListUrl;
	private Button btnRefresh;
	private String userName = "";
	private String userId = "";
	private String partyId;
	private int startId = 0;
	private int PAGE_COUNT = 20;
	private String status;
	private String description;
	private JSONObject dataSource;
	private JSONArray myJsonArray;
	private JSONObject clientData;
	private JSONArray appliedClients;
	private JSONArray doNothingClients;
	private JSONArray refusedClients;
	private Handler postHandler;
	private boolean needRefresh;
	private int tempCount;
	private TextView userTitle;
	private LinearLayout userLayout;
	private AlertDialog deleteDilog;
	private int lastItem;
	private int refusedCount = 0;
	private int registeredCount = 0;
	private Dialog progressDialog;
	private boolean separatePage = false;
	private boolean showFlagNew = true;

	public static final String LAST_ID = "lastID";
	private int lastID;
	private static final int MENU_PERSON_INFO = 0;
	private static final int MENU_EXIT = 1;
	public static final String PARTY_LIST = "partyList";
	public static final String PARTY_ID = "partyId";
	public static final String POEPLE_MAXMUM = "peopleMaximum";
	public static final String PARTY_DESCRIPTION = "description";
	public static final String PARTY_START_TIME = "starttime";
	public static final String PARTY_LOCATION = "location";
	public static final int MSG_ID_DELETE = 2;
	public static final int MSG_ID_SCROLL = 1;
	public static final int MENU_SET = 0;
	public static final int SHARE_SET = 3;
	public static final int DELETE_SET = 4;
	public static final int DELETE = 5;

	private String appliedClientcount;
	private String newAppliedClientcount;
	private String donothingClientcount;
	private String refusedClientcount;
	private String newRefusedClientcount;
	private String allClientcount;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.activity_list);
		AirenaoUtills.activityList.add(this);
		mContext = getBaseContext();
		init();
		needRefresh = false;//getIntent().getBooleanExtra(Constants.NEED_REFRESH, true);
		myListView = getListView();
		getData();

		footerView = LayoutInflater.from(this).inflate(R.layout.load_layout,
				null);
		myListView.addFooterView(footerView);
		footerView.setVisibility(View.GONE);
		myDaAdapter = new MyAdapter(this);
		setListAdapter(myDaAdapter);

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
						menu.add(0, Constants.MENU_THIRD, Constants.MENU_THIRD,
								getString(R.string.share));

					}
				});

		btnAddOneActivity = (ImageButton) findViewById(R.id.btnAddOneActivity);
		btnAddOneActivity.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {

				Intent mIntent = new Intent(MeetingListActivity.this,
						SendAirenaoActivity.class);
				startActivity(mIntent);
			}
		});
		// 处理刷新事件
		setButtonRefresh();
	}

	@Override
	protected void onRestart() {
		startId = 0;
		needRefresh = false;
		if (needRefresh) {

			getData();
			/*
			 * myDaAdapter.notifyDataSetChanged();
			 * myListView.requestFocusFromTouch();
			 */
		}
		super.onRestart();
	}

	public void setButtonRefresh() {
		btnRefresh = (Button) findViewById(R.id.btnRefresh);
		btnRefresh.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				progressDialog = ProgressDialog.show(MeetingListActivity.this,
						"刷新", getString(R.string.loadAirenao), true, true);

				list.clear();
				startId = 0;
				postHandler.postDelayed(firstLoadDataThread, 1000);
			}
		});
	}

	// 对footerView的处理
	private void init() {

		firstLoadDataThread = initLoadThread();
		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case MSG_ID_SCROLL:
					footerView.setVisibility(View.GONE);
					// myDaAdapter.notifyDataSetChanged();
					break;
				case MSG_ID_DELETE:
					String message = (String) msg.getData().get(
							Constants.DESCRIPTION);
					Toast.makeText(MeetingListActivity.this, message,
							Toast.LENGTH_SHORT).show();
					break;
				case DELETE:
					myDaAdapter.notifyDataSetChanged();
					myListView.requestFocusFromTouch();
					break;
				default:
					break;
				}
			}

		};

		postHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case Constants.POST_MESSAGE_CASE: {
					String message = msg.getData().getString(
							Constants.HENDLER_MESSAGE);
					AlertDialog aDig = new AlertDialog.Builder(
							MeetingListActivity.this).setMessage(message)
							.create();
					aDig.show();
				}
				case Constants.POST_MESSAGE_SUCCESS: {
					if (progressDialog != null) {
						progressDialog.dismiss();
					}
					myDaAdapter.notifyDataSetChanged();
					myListView.requestFocusFromTouch();
				}
				}

				super.handleMessage(msg);
			}

		};
		SharedPreferences mySharedPreferences = AirenaoUtills
				.getMySharedPreferences(MeetingListActivity.this);
		userName = mySharedPreferences.getString(Constants.AIRENAO_USER_NAME,
				null);
		userId = mySharedPreferences.getString(Constants.AIRENAO_USER_ID, null);
		userTitle = (TextView) findViewById(R.id.userTitle);
		userTitle.setText(userName);
		userLayout = (LinearLayout) findViewById(R.id.userChange);
		userLayout.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				AlertDialog dialog = new AlertDialog.Builder(
						MeetingListActivity.this).setTitle(R.string.user_off)
						.setMessage(R.string.user_off_message)
						.setPositiveButton(R.string.btn_ok,
								new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										finish();
										Intent intent = new Intent();
										intent.setClass(
												MeetingListActivity.this,
												LoginActivity.class);
										startActivity(intent);
									}
								}).create();
				dialog.show();

			}
		});
	}

	// every item's menu
	@Override
	public boolean onContextItemSelected(MenuItem item) {

		AdapterView.AdapterContextMenuInfo menuInfo;
		menuInfo = (AdapterView.AdapterContextMenuInfo) item.getMenuInfo();
		int menuItemId = item.getItemId();
		final int listItemId = menuInfo.position;
		System.out.println("点击了长按菜单里面的第" + item.getItemId() + "个项目" + "地址是："
				+ menuInfo.position);
		switch (menuItemId) {
		case 0:// delete the data of "listItemId"

			deleteDilog = new AlertDialog.Builder(MeetingListActivity.this)
					.setTitle(getString(R.string.deleteMenu)).setIcon(
							android.R.drawable.ic_delete).setItems(
							R.array.deleteMenu,
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									HashMap<String, Object> map = (HashMap<String, Object>) mData
											.get(listItemId);

									final String partyID = (String) map
													.get(Constants.PARTY_ID);
									final String delteUrl = Constants.DOMAIN_NAME + Constants.SUB_DOMAIN_DELETE_URL;
									// userId
									switch (which) {
									case 2:// 删除并提醒

										break;
									case 0: // 直接删除
										Runnable remove = new Runnable() {

											@Override
											public void run() {
												SQLiteDatabase db = null;
												try {
													// 删除后台
													deleleOnePraty(delteUrl,
															partyID);
													// 删除缓存
													removeActivity(listItemId);
													// 删除数据库
													db = DbHelper
															.openOrCreateDatabase();
													String sql = AirenaoUtills
															.linkSQL(partyID
																	+ "");
													DbHelper.delete(db, sql);

													handler
															.sendEmptyMessage(DELETE);
												} catch (Exception e) {
													e.printStackTrace();
												} finally {
													if (db != null) {
														db.close();
													}
												}
											}
										};
										new Handler().post(remove);

										break;
									case 1:// 取消
										deleteDilog.cancel();
										break;

									}

								}
							})
					// .setView(view);
					.create();
			deleteDilog.show();
			/*
			 * 2、某活动右边的按钮: 点击后，弹出“复制"、"删除"、"分享”这三个选项，并选择“删除”按钮
			 * 3、删除时，给出删除确认提示“删除不可恢复，是否确认删除？”， 并分别给出3个按钮“删除并提示客户”、“直接删除”、“取消”
			 * 单击“删除并通知受邀人”，则系统自动发送一封邮件或短信（"尊敬的某某，某年某月某日某时某地点举办的某某活动已取消。"）
			 * 给所有受邀人然后再执行删除动作，按邮件还是短信方式发送依据“发送方式” 单击“直接删除”则不发送提示给客户
			 * 单击“取消”：取消删除动作
			 */
			// 先显示对话框再做删除操作

			break;
		case 1:// copy the data of "listItemId"

			AirenaoActivity copyOneActivity = new AirenaoActivity();
			copyOneActivity.setActivityName((String) (mData.get(listItemId)
					.get(Constants.ACTIVITY_NAME)));
			copyOneActivity.setActivityContent((String) (mData.get(listItemId)
					.get(Constants.ACTIVITY_CONTENT)));
			// 进入“创建活动”页面
			startActivity(new Intent(MeetingListActivity.this,
					ImeetingClientActivity.class));
			break;
		case 2:// share the data of "listItemId"
			HashMap<String, Object> map = (HashMap<String, Object>) mData
					.get(listItemId);
			String partyId = (String) map.get(Constants.PARTY_ID);
			SharedPreferences spf = AirenaoUtills.getMySharedPreferences(this);
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
				bundle.putString(WeiBoSplashActivity.EXTRA_WEIBO_CONTENT,
						applyUrl);
				bundle.putString(WeiBoSplashActivity.EXTRA_ACCESS_TOKEN,
						accessToken);
				bundle.putString(WeiBoSplashActivity.EXTRA_TOKEN_SECRET,
						accessSecret);
				intent2.putExtras(bundle);
				intent2.setClass(this, ShareActivity.class);
				startActivity(intent2);
			} else {
				intent2.putExtra(Constants.PARTY_ID, partyId);
				intent2.setClass(this, WeiBoSplashActivity.class);
				startActivity(intent2);
			}
			break;
		}
		return super.onContextItemSelected(item);

	}

	/**
	 * 删除一个party
	 * 
	 * @param url
	 * @param partyId
	 */
	public void deleleOnePraty(final String url, String partyId) {
		HashMap<String, String> params = new HashMap<String, String>();
		params.put("pID", partyId + "");
		params.put("uID", userId);
		HttpHelper httpClient = new HttpHelper();
		String status = "";
		String description = "";

		String result = httpClient.performPost(url, params,
				MeetingListActivity.this);
		result = AirenaoUtills.linkResult(result);
		try {
			JSONObject outPut = new JSONObject(result)
					.getJSONObject(Constants.OUT_PUT);
			status = outPut.getString(Constants.STATUS);
			description = outPut.getString(Constants.DESCRIPTION);
			if (!"ok".equals(status)) {
				Message msg = new Message();
				Bundle bundle = new Bundle();
				bundle.putString(Constants.DESCRIPTION, description);
				msg.setData(bundle);
				msg.what = MSG_ID_DELETE;
				handler.sendMessage(msg);
			}
		} catch (Exception e) {

			e.printStackTrace();
		}
	}

	// 重写onListItemClick但是ListView条目事件
	@Override
	protected void onListItemClick(ListView listView, View v, int position,
			long id) {

		super.onListItemClick(listView, v, position, id);
		/*
		 * if (v == footerView) { loadRemnantListItem();
		 * listView.setSelection(position - 1); } System.out.println("id = " +
		 * id); System.out.println("position = " + position);
		 */
		// 活动对象的数据组合
		HashMap<String, Object> dataHashMap = (HashMap<String, Object>) mData
				.get(position);
		AirenaoActivity airenaoData = new AirenaoActivity();
		airenaoData.setId((String) dataHashMap.get(Constants.PARTY_ID));
		airenaoData.setActivityName((String) dataHashMap
				.get(Constants.ACTIVITY_NAME));
		airenaoData.setActivityContent((String) dataHashMap
				.get(Constants.ACTIVITY_CONTENT));

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
	private void getData() {

		// 在map装配的时候，一个活动的所有属性全部装配
		// 先从本地获得数据，如果数据为空那么在从后台取数据
		list.clear();
		if (!needRefresh) {
			separatePage = false;
			list = getDataFromServer();
		}

		if (list.size() > 0) {
			mData = list;
		
			if (myDaAdapter != null) {
				myDaAdapter.notifyDataSetChanged();
				myListView.requestFocusFromTouch();
			}
			return;
		} else {
			if (firstLoadDataThread == null) {
				firstLoadDataThread = initLoadThread();
			}
			progressDialog = ProgressDialog.show(MeetingListActivity.this, "",
					"loading...", true, true);
			postHandler.postDelayed(firstLoadDataThread, 1000);
			// return list;
		}

	}

	public Runnable initLoadThread() {
		return new Runnable() {

			@Override
			public void run() {
				// 配置url
				// list.clear();
				partyListUrl = Constants.DOMAIN_NAME
						+ Constants.SUB_DOMAIN_PARTY_LIST_URL;
				partyListUrl = partyListUrl + userId + "/" + startId + "/";
				HttpHelper myHttpHelper = new HttpHelper();
				String dataResult = myHttpHelper.performGet(partyListUrl,
						MeetingListActivity.this);
				dataResult = AirenaoUtills.linkResult(dataResult);
				analyzeJson(dataResult);

			}
		};
	}

	/**
	 * 获得本地数据
	 */
	public List<Map<String, Object>> getDataFromServer() {
		list.clear();
		SQLiteDatabase db = DbHelper.openOrCreateDatabase();
		return (ArrayList<Map<String, Object>>) DbHelper.selectActivitys(db);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.addSubMenu(0, MENU_PERSON_INFO, 0,
				getString(R.string.menuPersonInfo));
		menu.addSubMenu(0, MENU_EXIT, 1, getString(R.string.menuExit));
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case MENU_PERSON_INFO:
			Intent intent = new Intent(this, PersoninfoSetActivity.class);
			startActivity(intent);
			break;
		case MENU_EXIT:
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
			break;
		}
		return super.onOptionsItemSelected(item);
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
		public ImageView activityFlagNew;
		public TextView activityScale;

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

			/*
			 * if(lastItem == position){ return footerView; }
			 */

			ViewHolder holder = null;

			if (convertView == null) {

				holder = new ViewHolder();

				convertView = mInflater.inflate(R.layout.activity_property,
						null);

				holder.activityScale = (TextView) convertView
						.findViewById(R.id.activity_scale);
				holder.activityName = (TextView) convertView
						.findViewById(R.id.activity_name);

				holder.activityFlagNew = (ImageView) convertView
						.findViewById(R.id.flag_new_red);

				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();

			}

			holder.activityName.setText((String) mData.get(position).get(
					Constants.ACTIVITY_NAME));

			allClientcount = (String) mData.get(position).get(
					Constants.ALL_CLIENT_COUNT);
			
			if (allClientcount == null) {
				allClientcount = "0";
			}

			appliedClientcount = (String) mData.get(position).get(
					Constants.APPLIED_CLIENT_COUNT);
			
			if (appliedClientcount == null) {
				appliedClientcount = "0";
			}

			// registeredCount = Integer.valueOf(appliedClientcount);
			
			holder.activityScale.setText(appliedClientcount + "/"
					+ allClientcount);

			if ((newAppliedClientcount!=null && !"0".equals(newAppliedClientcount))
					|| (newRefusedClientcount!=null && !"0".equals(newRefusedClientcount))) {
				showFlagNew = true;
			} else {
				showFlagNew = false;
			}
			if (showFlagNew) {
				holder.activityFlagNew.setVisibility(View.VISIBLE);
			} else {
				holder.activityFlagNew.setVisibility(View.INVISIBLE);
			}
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

		// myDaAdapter.notifyDataSetChanged();
		// myDaAdapter.notifyDataSetInvalidated();
	}

	@Override
	public void onScroll(AbsListView view, int firstVisibleItem,
			int visibleItemCount, int totalItemCount) {

		lastItem = firstVisibleItem + visibleItemCount - 1;

	}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {

		if (lastItem == myDaAdapter.getCount()
				&& scrollState == OnScrollListener.SCROLL_STATE_IDLE) {
			if (tempCount > 0) {
				footerView.setVisibility(View.VISIBLE);
				loadRemnantListItem();
			}

		}
	}

	/**
	 * 加载更多的数据
	 */
	private void loadRemnantListItem() {// 滚到加载余下的数据
		separatePage = true;
		// 开线程去下载网络数据
		if (mThread == null || !mThread.isAlive()) {
			mThread = new Thread() {
				@Override
				public void run() {
					try {
						if (tempCount > 0) {

							// 这里放你网络数据请求的方法，我在这里用线程休眠5秒方法来处理
							startId = lastID;
							partyListUrl = Constants.DOMAIN_NAME
									+ Constants.SUB_DOMAIN_PARTY_LIST_URL
									+ userId + "/" + startId + "/";
							HttpHelper myHttpHelper = new HttpHelper();
							String dataResult = myHttpHelper.performGet(
									partyListUrl, MeetingListActivity.this);
							dataResult = AirenaoUtills.linkResult(dataResult);
							analyzeJson(dataResult);
							// mData.addAll(list);
						}
					} catch (Exception e) {
						e.printStackTrace();
					}
					Message message = new Message();
					message.what = 1;
					handler.sendMessage(message);
				}
			};
			mThread.start();

		}

		// 动态的改变listAdapter.getCount()的返回值
		if ((mData.size() - myDaAdapter.count) / PAGE_COUNT == 0) {
			myDaAdapter.count += ((mData.size() - myDaAdapter.count))
					% PAGE_COUNT;
		}
		// 使用Handler调用listAdapter.notifyDataSetChanged();更新数据
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

		SQLiteDatabase db = DbHelper.openOrCreateDatabase();
		try {
			JSONObject output = new JSONObject(result)
					.getJSONObject(Constants.OUT_PUT);
			status = output.getString(Constants.STATUS);
			description = output.getString(Constants.DESCRIPTION);
			if ("ok".equals(status)) {

				dataSource = output.getJSONObject(Constants.DATA_SOURCE);
				lastID = Integer.valueOf(dataSource.getString(LAST_ID));
				myJsonArray = dataSource.getJSONArray(PARTY_LIST);
				tempCount = myJsonArray.length();
				if (tempCount > 0) {
					if (!separatePage) {
						DbHelper.delete(db, DbHelper.deleteActivitySql);
						DbHelper.delete(db, DbHelper.deleteTableAppliedSql);
						DbHelper.delete(db, DbHelper.deleteTableDoNothingSql);
						DbHelper.delete(db, DbHelper.deleteTableRefusedSql);
					}
				}
				for (int i = 0; i < myJsonArray.length(); i++) {
					JSONObject tempActivity = myJsonArray.getJSONObject(i);
					list.add(organizeMap(tempActivity));


					appliedClients = tempActivity
							.getJSONArray("appliedClients");
					doNothingClients = tempActivity
							.getJSONArray("donothingClients");
					refusedClients = tempActivity
							.getJSONArray("refusedClients");
					try {
						if (appliedClients.length() > 0) {
							for (int a = 0; a < appliedClients.length(); a++) {
								clientData = (JSONObject)appliedClients.getJSONObject(a);
								DbHelper.insertOneClientData(db,
										organizeOneClientData(clientData),
										"appliedClients");
							}
						}
						if (doNothingClients.length() > 0) {
							for (int d = 0; d < doNothingClients.length(); d++) {
								clientData = (JSONObject)doNothingClients.getJSONObject(d);
								DbHelper.insertOneClientData(db,
										organizeOneClientData(clientData),
										"doNothingClients");
							}
						}
						if (refusedClients.length() > 0) {
							for (int r = 0; r < refusedClients.length(); r++) {
								clientData = (JSONObject)refusedClients.getJSONObject(r);
								DbHelper.insertOneClientData(db,
										organizeOneClientData(clientData),
										"refusedClients");
							}
						}

						DbHelper.insertOneParty(db,
								organizeOneActivity(tempActivity),
								DbHelper.ACTIVITY_TABLE_NAME);

					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				mData = list;
				Message message = new Message();
				message.what = Constants.POST_MESSAGE_SUCCESS;
				Bundle bundle = new Bundle();
				bundle.putString(Constants.HENDLER_MESSAGE, description);
				message.setData(bundle);
				postHandler.sendMessage(message);
			} else {
				Message message = new Message();
				message.what = Constants.POST_MESSAGE_CASE;
				Bundle bundle = new Bundle();
				bundle.putString(Constants.HENDLER_MESSAGE, description);
				message.setData(bundle);
				postHandler.sendMessage(message);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		} finally {
			if (db != null) {
				db.close();
			}
		}

	}

	/**
	 * 将Json解析出来的数据装到MAP
	 * 
	 * @param data
	 * @return
	 */
	public HashMap<String, Object> organizeMap(JSONObject data) {
		try {
			JSONObject clientsData = data.getJSONObject(Constants.CLIENTS_DATA);
			appliedClientcount = clientsData
					.getString(Constants.APPLIED_CLIENT_COUNT);
			newAppliedClientcount = clientsData
					.getString(Constants.NEW_APPLIED_CLIENT_COUNT);
			donothingClientcount = clientsData
					.getString(Constants.DONOTHING_CLIENT_COUNT);
			refusedClientcount = clientsData
					.getString(Constants.REFUSED_CLIENT_COUNT);
			newRefusedClientcount = clientsData
					.getString(Constants.NEW_REFUSED_CLIENT_COUNT);

		} catch (JSONException e1) {

			e1.printStackTrace();
		}

		HashMap<String, Object> map = new HashMap<String, Object>();

		try {
			description = data.getString(PARTY_DESCRIPTION);
			partyId =  data.get(PARTY_ID)+"";
			map.put(Constants.PARTY_ID, partyId );
			if (description.length() < 22) {
				map.put(Constants.ACTIVITY_NAME, description);
			} else {
				map.put(Constants.ACTIVITY_NAME, description.substring(0, 22)
						+ "...");
			}
			map.put(Constants.ALL_CLIENT_COUNT, allClientcount);
			map.put(Constants.APPLIED_CLIENT_COUNT, appliedClientcount);
			map.put(Constants.NEW_APPLIED_CLIENT_COUNT, newAppliedClientcount);
			map.put(Constants.DONOTHING_CLIENT_COUNT, donothingClientcount);
			map.put(Constants.REFUSED_CLIENT_COUNT, refusedClientcount);
			map.put(Constants.NEW_REFUSED_CLIENT_COUNT, newRefusedClientcount);
			map.put(Constants.ACTIVITY_CONTENT, description);
		} catch (JSONException e) {

			e.printStackTrace();
		}

		return map;
	}

	/**
	 * 封装一个活动
	 * 
	 * @param data
	 * @return
	 */
	
	public AirenaoActivity organizeOneActivity(JSONObject data) {
		AirenaoActivity myActivity = new AirenaoActivity();
		try {
			
			myActivity.setId(partyId);
			
			allClientcount = String.valueOf(data.getJSONArray("appliedClients").length() + data.getJSONArray("donothingClients").length()+data.getJSONArray("refusedClients").length());
			String content = data.getString(PARTY_DESCRIPTION);
			if (content.length() > 22) {
				myActivity.setActivityName(content.substring(0, 22) + "...");
			} else {
				myActivity.setActivityName(content);
			}

			myActivity.setActivityContent(content);
			myActivity.setInvitedPeople(allClientcount);
			myActivity.setSignUp(appliedClientcount);
			myActivity.setNewUnSignUP(newAppliedClientcount);
			myActivity.setUnJoin(donothingClientcount);
			myActivity.setUnSignUp(refusedClientcount);
			myActivity.setNewUnSignUP(newRefusedClientcount);

		} catch (JSONException e) {

			e.printStackTrace();
		}

		return myActivity;
	}

	/**
	 * 封装一个ClientData
	 * 	 * 
	 * @param data
	 * @return
	 */
	public ClientsData organizeOneClientData(JSONObject data) {
		ClientsData clientsData = new ClientsData();
		try {
			clientsData.setPartyId(partyId);
			clientsData.setId(data.getString("id"));
			clientsData.setPeopleName(data.getString("name"));
			clientsData.setPhoneNumber(data.getString("number"));
			clientsData.setComment(data.getString("comment"));
			clientsData.setIsCheck(data.getString("isCheck"));

		} catch (JSONException e) {

			e.printStackTrace();
		}

		return clientsData;
	}

}
