package com.aragoncg.apps.airenao.model;

import java.util.ArrayList;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

public class MyPerson implements Parcelable {

	private String name;
	private String phoneNumber;
	private String email;
	private boolean checked;
	private String id;
	private ArrayList<String> numbers;

	public MyPerson() {

	}
	public MyPerson(String name, String phoneNumber) {
		
		this.name = name;
		this.phoneNumber = phoneNumber;
	}
	public MyPerson(String id, String email, String name, String phoneNumber) {
		this.id = id;
		this.email = email;
		this.name = name;
		this.phoneNumber = phoneNumber;
	}

	public MyPerson(String id,String name, String number) {
		this.id = id;
		this.name = name;
		this.phoneNumber = number;
	}
	
	
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public ArrayList<String> getNumbers() {
		return numbers;
	}

	public void setNumbers(ArrayList<String> numbers) {
		this.numbers = numbers;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPhoneNumber() {
		return phoneNumber;
	}

	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}

	public boolean isChecked() {
		return checked;
	}

	public void setChecked(boolean checked) {
		this.checked = checked;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(name);
		dest.writeString(phoneNumber);
		dest.writeString(email);

	}

	public static final Parcelable.Creator<MyPerson> CREATOR = new Creator<MyPerson>() {
		@Override
		public MyPerson createFromParcel(Parcel source) {
			Log.d("person", "createFromParcel");
			MyPerson mPerson = new MyPerson();
			mPerson.name = source.readString();
			mPerson.phoneNumber = source.readString();
			mPerson.email = source.readString();
			return mPerson;
		}

		@Override
		public MyPerson[] newArray(int size) {
			// TODO Auto-generated method stub
			return new MyPerson[size];
		}
	};
}