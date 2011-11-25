package com.aragoncg.apps.airenao.activity;



import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
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
import android.widget.TextView;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.AirenaoActivity;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.Utility;

public class DetailActivity extends Activity implements OnItemClickListener{
	
	private int[] resImageArry;
	private String[] resMenuNameArry;
	private static boolean show_flag = true;
	private PopupWindow pw = null;
	private ComponentsCache myCache;
	private AirenaoActivity myAirenaoActivity;
	
	private List<Map<String,Object>> dataList;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		AirenaoUtills.activityList.add(this);
		setContentView(R.layout.detail_activity_layout);
		
		//获得屏幕的高度
		dataList = getData();
		getComponentsCache();
		initFormData();
		MyAdapter adapter = new MyAdapter(this);
		ListView dataListView = (ListView)findViewById(R.id.listDetailLable);
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
		
		Utility.setListViewHeightBasedOnChildren(dataListView);
		
		
	}
	
	private List<Map<String, Object>> getData() {
		//获得组件集合对象
		myCache = new ComponentsCache();
		//获得menu data
		resImageArry = new int[]{R.drawable.delete_detail,R.drawable.copy_detail,R.drawable.share_detail};
		resMenuNameArry = new String[]{getString(R.string.delete),getString(R.string.copy),getString(R.string.share)};
				
				/**
				 * 得到menu的样式属性
				 */
				//用LayoutInflater把一个view 生成，为的是 获得该view的上得组件资源
				LayoutInflater inflater = (LayoutInflater)this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);  
				//这个menu是这个
				View view = inflater.inflate(R.layout.menu_detail, null);
				//通过 生成的view 获得它的 GridView 组件
				GridView grid1 = (GridView)view.findViewById(R.id.menuGridChange);
				//
				grid1.setAdapter(new ImageAdapter(this));
				
				//用Popupwindow弹出menu
				pw = new PopupWindow(view,LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
				
		//获得list中穿过来的activity对象
			Intent myIntent = getIntent();
		 myAirenaoActivity = (AirenaoActivity) myIntent.getSerializableExtra(Constants.TO_DETAIL_ACTIVITY);
		
		if(myAirenaoActivity == null){
			throw new NullPointerException("没有获得列表中的活动");
		}
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();

		Map<String, Object> map;
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.invited_number)) ;
		map.put(Constants.PEOPLE_NUM, myAirenaoActivity.getInvitedPeople()) ;
		list.add(map);
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.signed_number)) ;
		map.put(Constants.PEOPLE_NUM, myAirenaoActivity.getSignUp()) ;
		list.add(map);
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.unsiged_number)) ;
		map.put(Constants.PEOPLE_NUM, myAirenaoActivity.getUnSignUp()) ;
		list.add(map);
		map = new HashMap<String, Object>();
		map.put(Constants.PEOPLE_NAME, getString(R.string.unjion)) ;
		map.put(Constants.PEOPLE_NUM, myAirenaoActivity.getUnJoin()) ;
		list.add(map);
		return list;

	}
	
	public final class ViewHolder {

		public TextView peopleName;

		public TextView peopleNum;

		public TextView activityContent;

	}
	
	public class MyAdapter extends BaseAdapter {

		private LayoutInflater mInflater;

		public MyAdapter(Context context) {

			this.mInflater = LayoutInflater.from(context);

		}

		@Override
		public int getCount() {

			return dataList.size();

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

				holder.peopleName = (TextView) convertView
						.findViewById(R.id.activity_name);

				holder.peopleNum = (TextView) convertView
						.findViewById(R.id.activity_time);

				holder.activityContent = (TextView) convertView
						.findViewById(R.id.activity_content);

				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();

			}

			holder.peopleName.setText(String.valueOf(dataList.get(position).get(
					Constants.PEOPLE_NAME)));
			holder.peopleNum.setText(String.valueOf(dataList.get(position).get(
					Constants.PEOPLE_NUM)));
			//holder.activityContent.setText("asdfasd");

			return convertView;

		}
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		return super.onOptionsItemSelected(item);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		if(show_flag){
		//NND, 第一个参数， 必须找个View
			pw.showAtLocation(findViewById(R.id.tv), Gravity.CENTER | Gravity.BOTTOM, 0, 0);
			show_flag = false;
		}else{
			show_flag = true;
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
			//动态的定义一个布局管理器，用来放置 图片信息 LinearLayout 也属于View
			LinearLayout linear = new LinearLayout(context);
			LinearLayout.LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			linear.setOrientation(LinearLayout.VERTICAL);
			//定义一个ImageView
			ImageView iv = new ImageView(context);
			iv.setImageBitmap(((BitmapDrawable)context.getResources().getDrawable(resImageArry[arg0])).getBitmap());
			LinearLayout.LayoutParams params2 = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			params2.gravity=Gravity.CENTER;
			linear.addView(iv, params2);
			//定义一个TextView
			TextView tv = new TextView(context);
			tv.setText(resMenuNameArry[arg0]);
			LinearLayout.LayoutParams params3 = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			params3.gravity=Gravity.CENTER;
			linear.addView(tv, params3);
			
			return linear;
		}
	}

	/**
	 * 
	 * ClassName:ComponentsCache
	 * Function: 组件集合
	 * @author   cuikuangye
	 * @version  DetailActivity
	 * @Date	 2011	2011-11-17		pm 7:59:28
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
	
	public void getComponentsCache(){
		myCache.txtTime = (EditText)findViewById(R.id.startTimeText);
		myCache.txtPosition = (EditText)findViewById(R.id.positionEditText);
		myCache.txtNum = (EditText)findViewById(R.id.peopleNumEditText);
		myCache.txtContent = (EditText)findViewById(R.id.descrEditText);
		myCache.btnEdit = (Button)findViewById(R.id.btnDetailEdit);
	}
	
	/**
	 *   Method:initFormData:(......)
	 *   TODO(.....)
	 *   @author   cuikuangye   
	 *   void 
	 *   @Date	 2011	2011-11-18		上午10:14:45   
	 *   @throws 
	 * 
	*/
	public void initFormData(){
		myCache.txtTime.setText(myAirenaoActivity.getActivityTime());
		myCache.txtPosition.setText(myAirenaoActivity.getActivityPosition());
		myCache.txtNum.setText(String.valueOf(myAirenaoActivity.getPeopleLimitNum()));
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
		//position start from 0;
		switch(position){
			case 0:{
				Intent intent = new Intent(DetailActivity.this,InvatedPeopleInfoActivity.class);
				startActivity(intent);
			}
			case 1:{
				
			}
			case 2:{
				
			}
			case 3:{
				
			}
		}
	}
	
	
}
