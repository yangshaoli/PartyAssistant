package com.aragoncg.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.View.OnCreateContextMenuListener;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.aragoncg.R;
import com.aragoncg.airenao.constans.Constants;
import com.aragoncg.airenao.model.AirenaoActivity;

public class MeetingListActivity extends ListActivity {

	private List<Map<String, Object>> mData;
	private MyAdapter myDaAdapter;
	private static String ACTIVITY_NAME = "activityName";
	private static String ACTIVITY_TIME = "activityTime";
	private static String ACTIVITY_CONTENT = "activityContent";
	private static String PEOPLE_LIMIT_NUM = "peopleLimitNum";
	private static String ACTIVITY_POSITION = "activityPosition";
	private ImageButton btnAddOneActivity;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		setContentView(R.layout.activity_list);
		
		mData = getData();
		myDaAdapter = new MyAdapter(this);
		setListAdapter(myDaAdapter);
		
		//get the ListView and add item on long press menu
		getListView().setOnCreateContextMenuListener(new OnCreateContextMenuListener() {

			@Override
			public void onCreateContextMenu(ContextMenu menu, View v,
					ContextMenuInfo menuInfo) {
				
				 menu.setHeaderTitle(getString(R.string.operate));
                 menu.add(0, Constants.MENU_FIRST, Constants.MENU_FIRST, getString(R.string.delete));
                 menu.add(0, Constants.MENU_SECOND, Constants.MENU_SECOND, getString(R.string.copy));
                 menu.add(0, Constants.MENU_THIRD, Constants.MENU_THIRD, getString(R.string.share));
				
			}
    });
	    	
		btnAddOneActivity = (ImageButton)findViewById(R.id.btnAddOneActivity);
		btnAddOneActivity.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				
				Intent mIntent = new Intent(MeetingListActivity.this,CreateActivity.class);
				startActivity(mIntent);
			}
		});
	}
	
	//every item's menu 
	@Override
	public boolean onContextItemSelected(MenuItem item) {
		
		 AdapterView.AdapterContextMenuInfo menuInfo;
	        menuInfo =(AdapterView.AdapterContextMenuInfo)item.getMenuInfo();
	        int menuItemId = item.getItemId();
	        int listItemId = menuInfo.position;
	        System.out.println("点击了长按菜单里面的第"+item.getItemId()+"个项目"+"地址是："+menuInfo.position);
	        switch(menuItemId){
	        	case 0://delete the data of "listItemId"
	        		
	        		AlertDialog dilog = new AlertDialog.Builder(MeetingListActivity.this)
	        		.setTitle(getString(R.string.delete))
	        		.setIcon(android.R.drawable.ic_delete)
	        		//.setView(view);
	        		.create();
	        		dilog.show();
	        		/*
	        		 * 2、某活动右边的按钮: 点击后，弹出“复制"、"删除"、"分享”这三个选项，并选择“删除”按钮
                       3、删除时，给出删除确认提示“删除不可恢复，是否确认删除？”， 并分别给出3个按钮“删除并提示客户”、“直接删除”、“取消”
							单击“删除并通知受邀人”，则系统自动发送一封邮件或短信（"尊敬的某某，某年某月某日某时某地点举办的某某活动已取消。"）给所有受邀人然后再执行删除动作，按邮件还是短信方式发送依据“发送方式”
							单击“直接删除”则不发送提示给客户
							单击“取消”：取消删除动作
	        		 */
	        		// 先显示对话框再做删除操作
	        		removeActivity(listItemId);
	        		break;
	        	case 1://copy the data of "listItemId"
	        		
	        		AirenaoActivity copyOneActivity = new AirenaoActivity();
	        		copyOneActivity.setActivityName((String)(mData.get(listItemId).get(this.ACTIVITY_NAME)));
	        		copyOneActivity.setActivityTime((String)(mData.get(listItemId).get(this.ACTIVITY_TIME)));
	        		copyOneActivity.setActivityPosition((String)(mData.get(listItemId).get(this.ACTIVITY_POSITION)));
	        		if((String)(mData.get(listItemId).get(this.PEOPLE_LIMIT_NUM)) != null)
	        		copyOneActivity.setPeopleLimitNum(Integer.valueOf((String)(mData.get(listItemId).get(this.PEOPLE_LIMIT_NUM))));
	        		copyOneActivity.setActivityContent((String)(mData.get(listItemId).get(this.ACTIVITY_CONTENT)));
	        		//进入“创建活动”页面
	        		startActivity(new Intent(MeetingListActivity.this, ImeetingClientActivity.class));
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
	protected void onListItemClick(ListView listView, View v, int position, long id) {

		super.onListItemClick(listView, v, position, id);
		System.out.println("id = " + id);
		System.out.println("position = " + position);
		
		//活动对象的数据组合
		HashMap<String, Object> dataHashMap = (HashMap<String, Object>) mData.get(position);
		AirenaoActivity airenaoData = new AirenaoActivity();
		airenaoData.setActivityName((String)dataHashMap.get(Constants.ACTIVITY_NAME));
		airenaoData.setActivityTime((String)dataHashMap.get(Constants.ACTIVITY_TIME));
		airenaoData.setActivityPosition((String)dataHashMap.get(Constants.ACTIVITY_POSITION));
		airenaoData.setActivityContent((String)dataHashMap.get(Constants.ACTIVITY_CONTENT));
		airenaoData.setInvitedPeople((Integer)dataHashMap.get(Constants.ACTIVITY_INVITED_PEOPLE));
		airenaoData.setPeopleLimitNum((Integer)dataHashMap.get(Constants.ACTIVITY_NUMBER));
		airenaoData.setSignUp((Integer)dataHashMap.get(Constants.ACTIVITY_SIGNED_PEOPLE));
		airenaoData.setUnSignUp((Integer)dataHashMap.get(Constants.ACTIVITY_UNSIGNED_PEOPLE));
		airenaoData.setUnJoin((Integer)dataHashMap.get(Constants.ACTIVITY_UNJIONED_PEOPLE));
		
		
		
		 
		Intent intent = new Intent(getString(R.string.to_detail_activity));
		intent.putExtra(Constants.TO_DETAIL_ACTIVITY, airenaoData);
		
		startActivity(intent);
		/*
		 *  点击活动列表中的一项，进入到活动详情当中 跳转到具体活动Activity 中
		 */
	}
	
	
	/**
	 * 
	 * Method:getData TODO(获得数据)
	 * 
	 * @author cuikuangye
	 * @return privateList<Map<String,Object>>
	 * @Date  2011-11-5 am 10:00:00
	 * @throws
	 * 
	 */
	private List<Map<String, Object>> getData() {
		// 在map装配的时候，一个活动的所有属性全部装配
		
		
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();

		Map<String, Object> map;

		int count = 10;
		for(int i=0;i<count;i++){
			map = new HashMap<String, Object>();
			String a= "活动";
			map.put(Constants.ACTIVITY_NAME,a);
			map.put(Constants.ACTIVITY_TIME,"sad");
			map.put(Constants.ACTIVITY_POSITION,"beijing");
			map.put(Constants.ACTIVITY_CONTENT,"tizuqiu");
			map.put(Constants.ACTIVITY_INVITED_PEOPLE,30);
			map.put(Constants.ACTIVITY_NUMBER,40);
			map.put(Constants.ACTIVITY_SIGNED_PEOPLE,20);
			map.put(Constants.ACTIVITY_UNSIGNED_PEOPLE,10);
			map.put(Constants.ACTIVITY_UNJIONED_PEOPLE,2);
			list.add(map);
			
		}

		return list;

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

		public MyAdapter(Context context) {

			this.mInflater = LayoutInflater.from(context);

		}

		@Override
		public int getCount() {

			return mData.size();

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
	 *   Method:removeActivity:(delete one Activity data)
	 *   @author   cuikuangye
	 *
	 */
	public void removeActivity(int itemId){
		mData.remove(itemId);
		myDaAdapter.notifyDataSetChanged();
		myDaAdapter.notifyDataSetInvalidated();
	}
	
}
