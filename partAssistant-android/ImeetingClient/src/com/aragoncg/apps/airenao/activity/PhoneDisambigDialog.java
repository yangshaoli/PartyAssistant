/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.aragoncg.apps.airenao.activity;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import android.app.AlertDialog;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.Cursor;
import android.os.Handler;
import android.os.Message;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.Data;
import android.telephony.PhoneNumberUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ListAdapter;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.activity.Collapser.Collapsible;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.MyPerson;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;



/**
 * Class used for displaying a dialog with a list of phone numbers of which one
 * will be chosen to make a call or initiate an sms message.
 */
public class PhoneDisambigDialog implements DialogInterface.OnClickListener,
		DialogInterface.OnDismissListener,
		CompoundButton.OnCheckedChangeListener {

	private boolean mMakePrimary = false;
	private Context mContext;
	private AlertDialog mDialog;
	private boolean mSendSms;
	private Cursor mPhonesCursor;
	private ListAdapter mPhonesAdapter;
	private ArrayList<PhoneItem> mPhoneItemList;
	private int position;
	private Map<Integer,MyPerson> positions;
	private Map<Integer, MyPerson> personMap;
	private String name;
	private Handler mHandler;

	/*public PhoneDisambigDialog(Context context, Cursor phonesCursor) {
		this(context, phonesCursor, false  make call , null);
	}
*/
	public PhoneDisambigDialog(Context context, Cursor phonesCursor,
			boolean sendSms, ArrayList phones,int position, Map<Integer,MyPerson> positions,Map<Integer, MyPerson> personMap,String name,Handler mHandler) {
		mContext = context;
		mSendSms = sendSms;
		mPhonesCursor = phonesCursor;
		this.position = position;
		this.positions = positions;
		this.personMap = personMap;
		this.mHandler = mHandler;
		if (mPhonesCursor != null) {
			mPhoneItemList = makePhoneItemsList(phonesCursor);
		} else {
			mPhoneItemList = makePhoneItemsList(phones);
		}
		Collapser.collapseList(mPhoneItemList);

		mPhonesAdapter = new PhonesAdapter(mContext, mPhoneItemList);

		LayoutInflater inflater = (LayoutInflater) mContext
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View setPrimaryView = inflater.inflate(R.layout.set_primary_checkbox,
				null);
		((CheckBox) setPrimaryView.findViewById(R.id.setPrimary))
				.setOnCheckedChangeListener(this);

		// Need to show disambig dialogue.
		AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(mContext)
				.setAdapter(mPhonesAdapter, this)
				.setTitle("请选择电话号码")
				.setView(setPrimaryView);

		mDialog = dialogBuilder.create();
	}

	/**
	 * Show the dialog.
	 */
	public Map<Integer,MyPerson> show() {
		if (mPhoneItemList.size() == 1) {
			// If there is only one after collapse, just select it, and close;
			
			onClick(mDialog, 0);
		}
		mDialog.show();
		return positions;
	}

	public void onClick(DialogInterface dialog, int which) {
		if (mPhoneItemList.size() > which && which >= 0) {
			PhoneItem phoneItem = mPhoneItemList.get(which);
			long id = phoneItem.id;
			String phone = phoneItem.phoneNumber;
			if(mPhonesCursor != null){
				if (mMakePrimary) {
					ContentValues values = new ContentValues(1);
					values.put(Data.IS_SUPER_PRIMARY, 1);
					mContext.getContentResolver().update(
							ContentUris.withAppendedId(Data.CONTENT_URI, id),
							values, null, null);
				}
			}else {
				if(mMakePrimary){
					SharedPreferences msp = AirenaoUtills.getMySharedPreferences(mContext);
					Editor myEditor = msp.edit();
					myEditor.putString(phone, Constants.IS_SUPER_PRIMARY);
					myEditor.commit();
				}
			}
			
		   //电话号码phone
			MyPerson person = this.personMap.get(position);
			Log.i("p", personMap.hashCode() + "click");
			boolean isChecked = person.isChecked();
			this.personMap.get(position).setChecked(!isChecked);
			if(isChecked){
				positions.remove(Integer.valueOf(position));
			}else{
				positions.put(position,new MyPerson(name,phone));
			}
			Message msg = new Message();
			msg.what = 0;
			mHandler.sendMessage(msg);
		} else {
			dialog.dismiss();
		}
	}

	public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		mMakePrimary = isChecked;
	}

	public void onDismiss(DialogInterface dialog) {
		mPhonesCursor.close();
	}

	private static class PhonesAdapter extends ArrayAdapter<PhoneItem> {

		public PhonesAdapter(Context context, List<PhoneItem> objects) {
			super(context, android.R.layout.simple_dropdown_item_1line,
					android.R.id.text1, objects);
		}
	}

	private class PhoneItem implements Collapsible<PhoneItem> {

		String phoneNumber;
		long id;

		public PhoneItem(String newPhoneNumber, long newId) {
			phoneNumber = newPhoneNumber;
			id = newId;
		}

		public boolean collapseWith(PhoneItem phoneItem) {
			if (!shouldCollapseWith(phoneItem)) {
				return false;
			}
			// Just keep the number and id we already have.
			return true;
		}

		public boolean shouldCollapseWith(PhoneItem phoneItem) {
			if (PhoneNumberUtils.compare(PhoneDisambigDialog.this.mContext,
					phoneNumber, phoneItem.phoneNumber)) {
				return true;
			}
			return false;
		}

		public String toString() {
			return phoneNumber;
		}
	}

	private ArrayList<PhoneItem> makePhoneItemsList(Cursor phonesCursor) {
		ArrayList<PhoneItem> phoneList = new ArrayList<PhoneItem>();

		phonesCursor.moveToPosition(-1);
		while (phonesCursor.moveToNext()) {
			long id = phonesCursor.getLong(phonesCursor
					.getColumnIndex(Data._ID));
			String phone = phonesCursor.getString(phonesCursor
					.getColumnIndex(Phone.NUMBER));
			phoneList.add(new PhoneItem(phone, id));
		}

		return phoneList;
	}

	private ArrayList<PhoneItem> makePhoneItemsList(
			ArrayList<String> phones) {
		ArrayList<PhoneItem> phoneList = new ArrayList<PhoneItem>();
		for (int i = 0; i < phones.size(); i++) {
			phoneList.add(new PhoneItem(phones.get(i), i));
		}
		return phoneList;
	}

}
