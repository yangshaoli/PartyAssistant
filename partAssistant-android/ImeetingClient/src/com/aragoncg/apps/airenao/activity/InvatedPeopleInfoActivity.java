package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;

public class InvatedPeopleInfoActivity extends Activity {
	
	private final static int INVATED_PEOPLE = 0;
	private final static int SIGNED_PEOPLE = 1;
	private final static int UNSIGNED_PEOPLE = 2;
	private final static int UNRESPONSED_PEOPLE = 3;
	
	private List<Map<String,Object>> mData;
	private Button btnBack;
	private Button reInvated;
	private TextView myTitle;
	private MyAdapter myAdapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		AirenaoUtills.activityList.add(this);
		setContentView(R.layout.invated_people_info_layout);
		
		getData();
		MyAdapter myAdapter = new MyAdapter(this);
		ListView dataListView = (ListView)findViewById(R.id.people_infor_list);
		dataListView.setAdapter(myAdapter);
		
		
		
		init();
	}
	
	public void init(){
		myTitle = (TextView)findViewById(R.id.txtPeoPleInfo);
		myTitle.setText(R.string.invited_number);
		btnBack = (Button)findViewById(R.id.btnPeopleLableBack);
		btnBack.setVisibility(View.GONE);
	}
	
	
	public void getData(){
		mData = new ArrayList<Map<String,Object>>();
		int count = 10;
		mData.clear();
		for(int i=0;i<count;i++){
			Map map = new HashMap<String, Object>();
			String a= "孙超"+i;
			map.put(Constants.PEOPLE_NAME,a);
			map.put(Constants.PEOPLE_CONTACTS,"sad");
			mData.add(map);
			
		}

		
	}
	/**
	 * item holder
	 * @author cuikuangye
	 *
	 */
	public final class ViewHolder {

		public TextView peopleName;

		public TextView peoPleContacts;

	}
	
	
	public class MyAdapter extends BaseAdapter {

		private LayoutInflater mInflater;
		public int count;

		public MyAdapter(Context context) {

			this.mInflater = LayoutInflater.from(context);

		}

		@Override
		public int getCount() {
			count =  mData.size();
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


				convertView.setTag(holder);

			} else {

				holder = (ViewHolder) convertView.getTag();

			}

			holder.peopleName.setText((String) mData.get(position).get(
					Constants.PEOPLE_NAME));
			holder.peoPleContacts.setText((String) mData.get(position).get(
					Constants.PEOPLE_CONTACTS));

			return convertView;

		}
	}
	
}
