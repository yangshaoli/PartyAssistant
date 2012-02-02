package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Color;
import android.text.method.ScrollingMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.model.MyPerson;

public final class ListViewAdapter extends ArrayAdapter<MyPerson> {
	private LayoutInflater mInflater;
	private List<MyPerson> tempList = new ArrayList<MyPerson>();

	ListViewAdapter(Context context, List<MyPerson> result) {
		// Cache the LayoutInflate to avoid asking for a new one each time.
		super(context, R.layout.listview_point, result);
		tempList = result;
		mInflater = LayoutInflater.from(context);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return tempList.size();
	}

	@Override
	public MyPerson getItem(int position) {
		// TODO Auto-generated method stub
		return super.getItem(position);
	}

	@Override
	public int getPosition(MyPerson item) {
		// TODO Auto-generated method stub
		return super.getPosition(item);
	}

	/**
	 * Make a view to hold each row.
	 * 
	 * @see android.widget.ListAdapter#getView(int, android.view.View,
	 *      android.view.ViewGroup)
	 */
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;

		if (convertView == null) {
			convertView = mInflater.inflate(R.layout.listview_point, null);

			// we want to bind data to.
			holder = new ViewHolder();
			holder.txtName = (TextView) convertView.findViewById(R.id.txtName);
			holder.imgRadio = (TextView) convertView
					.findViewById(R.id.imgRadio);
			convertView.setTag(holder);
		} else {
			// Get the ViewHolder back to get fast access to the TextView
			// and the ImageView.
			holder = (ViewHolder) convertView.getTag();
		}

		buildView(holder, position);

		return convertView;
	}

	public void buildView(ViewHolder holder, int position) {

		MyPerson myPerson;

		try {
			myPerson = this.getItem(position);
		} catch (Exception e) {
			return;
		}
		holder.txtName.setText(myPerson.getName());
		holder.imgRadio.setText(myPerson.getPhoneNumber());

	}

	static class ViewHolder {
		TextView txtName;
		TextView imgRadio;
	}

}
