package com.aragoncg.apps.airenao.utills;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.aragoncg.apps.airenao.constans.Constants;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.provider.ContactsContract;
import android.telephony.PhoneNumberUtils;
import android.util.Log;

public class AirenaoUtills {
	/* 校验只为数字 */
	public static String regDigital = "([0-9])+";
	/* 校验电子邮件 */
	public static String regEmail = "^([a-z0-9A-Z]+[-|//.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?//.)+[a-zA-Z]{2,}$ ";
	/*校验电话号码*/
	public static String regPhoneNumber = "^(13|15|18)\\d{9}$";
	
	
	public static List<Activity> activityList = new ArrayList<Activity>();

	/**
	 * 
	 * Method:matchString: TODO(Regular expression matching)
	 * 
	 * @author cuikuangye
	 * @param regEx
	 * @param msg
	 * @return boolean
	 * @Date 2011 2011-11-4
	 * @throws
	 * 
	 */
	public static boolean matchString(final String regEx, final String msg) {
		Pattern p = Pattern.compile(regEx);
		Matcher m = p.matcher(msg);
		boolean result = m.find();
		return result;
	}
	
	/**
	 * 检查网络是否连接
	 * @param ctx
	 * @return
	 */
	public static boolean isNetWorkExist(Context ctx) {
		try {
			ConnectivityManager conManager = (ConnectivityManager) ctx
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			if (conManager.getActiveNetworkInfo() == null
					|| !conManager.getActiveNetworkInfo().isAvailable()) {
				return false;
			} else {
				return true;
			}
		} catch (Exception e) {
			return false;
		}
	}
	
	/**
	 * 比较两个电话号码是否相同
	 * @param phoneNumbers
	 * @param phoneNumber
	 * @return
	 */
	public static boolean phoneNumberCompare(ArrayList<String> phoneNumbers,
			String phoneNumber) {
		for (int i = 0; i < phoneNumbers.size(); i++) {
			String num = phoneNumbers.get(i);
			if (PhoneNumberUtils.compare(num, phoneNumber)) {
				return true;
			}
		}

		return false;
	}

	static int roundToPow2(int n) {
		int orig = n;
		n >>= 1;
		int mask = 0x8000000;
		while (mask != 0 && (n & mask) == 0) {
			mask >>= 1;
		}
		while (mask != 0) {
			n |= mask;
			mask >>= 1;
		}
		n += 1;
		if (n != orig) {
			n <<= 1;
		}
		return n;
	}
	
	/**
	 * 打开系统默认的dialer
	 * @param ctx
	 * @param number
	 */
	public static void openSystemDefaultDialer(Context ctx, String number) {
		try {
			ArrayList<String> cls = new ArrayList<String>();
			// Model: DROIDX Android Version: 2.2.1
			cls.add("com.android.phone.DialtactsActivity");

			// Model: Droid Android Version: 2.2.2
			cls.add("com.android.contacts.DialtactsActivity");

			/**
			 * Model: HTC Incredible S Android Version: 2.3.3 Model: HTC Liberty
			 * Android Version: 2.1-update1 Model: PC36100 Android Version: 2.2
			 **/
			cls.add("com.android.htcdialer.Dialer");

			/**
			 * Model: GT-I9000 Android Version: 2.2.1 Model: GT-S5570 Android
			 * Version: 2.2.1
			 **/
			cls.add("com.sec.android.app.dialertab.DialerTabActivity");

			/**
			 * Model: GT-I9100 Android Version: 2.3.3
			 **/
			cls.add("com.sec.android.app.contacts.PhoneBookTopMenuActivity");

			// sonyericsson
			cls.add("com.sonyericsson.android.socialphonebook.DialerEntryActivity");

			// ZTE
			cls.add("com.zte.smartdialer.DialerApp");
			PackageManager manager = ctx.getPackageManager();
			Intent it = new Intent();
			it.setAction(Intent.ACTION_DIAL);
			List<ResolveInfo> rr = manager.queryIntentActivities(it,
					PackageManager.GET_ACTIVITIES);
			for (ResolveInfo r : rr) {
				if (cls.contains(r.activityInfo.name)) {
					Intent invokeDialer = new Intent();
					invokeDialer.setClassName(
							r.activityInfo.applicationInfo.packageName,
							r.activityInfo.name);
					invokeDialer.setAction(Intent.ACTION_DIAL);
					if (number != null) {
						invokeDialer.setData(Uri.parse("tel:" + number));
					}
					invokeDialer.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
					ctx.startActivity(invokeDialer);
					return;
				}
			}

			Intent invokeFrameworkDialer = new Intent();
			invokeFrameworkDialer.setAction(Intent.ACTION_DIAL);
			if (number != null) {
				invokeFrameworkDialer.setData(Uri.parse("tel:" + number));
			}
			invokeFrameworkDialer.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			ctx.startActivity(invokeFrameworkDialer);
		} catch (Exception e) {
		}
	}

	public static boolean containChineseChar(String name) {
		String regEx = "[\\u4e00-\\u9fa5]";
		return Character.toString(name.charAt(0)).matches(regEx);
	}

	public static boolean isStartEnChar(String name) {
		String regEx = "[a-zA-Z]";
		return Character.toString(name.charAt(0)).matches(regEx);
	}
	
	/**
	 * 获得拼音
	 * @param c
	 * @return
	 */
	public static String getPYChar(char c) {
		String result = "#";
		String regEx = "[0-9]";
		if (Character.toString(c).matches(regEx)) {
			return result;
		}

		byte[] array = new byte[2];
		array = String.valueOf(c).getBytes();

		try {
			array = String.valueOf(c).getBytes("gbk");
		} catch (UnsupportedEncodingException e) {
			return result;
		}

		int i = (short) (array[0] - '\0' + 256) * 256
				+ ((short) (array[1] - '\0' + 256));
		if (i < 0xB0A1)
			return result;
		if (i < 0xB0C5)
			return "A";
		if (i < 0xB2C1)
			return "B";
		if (i < 0xB4EE)
			return "C";
		if (i < 0xB6EA)
			return "D";
		if (i < 0xB7A2)
			return "E";
		if (i < 0xB8C1)
			return "F";
		if (i < 0xB9FE)
			return "G";
		if (i < 0xBBF7)
			return "H";
		if (i < 0xBFA6)
			return "J";
		if (i < 0xC0AC)
			return "K";
		if (i < 0xC2E8)
			return "L";
		if (i < 0xC4C3)
			return "M";
		if (i < 0xC5B6)
			return "N";
		if (i < 0xC5BE)
			return "O";
		if (i < 0xC6DA)
			return "P";
		if (i < 0xC8BB)
			return "Q";
		if (i < 0xC8F6)
			return "R";
		if (i < 0xCBFA)
			return "S";
		if (i < 0xCDDA)
			return "T";
		if (i < 0xCEF4)
			return "W";
		if (i < 0xD1B9)
			return "X";
		if (i < 0xD4D1)
			return "Y";
		if (i < 0xD7FA)
			return "Z";
		return result;
	}
	
	/**
	 * 检查后台的server是否运行，通过输入server name
	 * @param context
	 * @param className
	 * @return
	 */
	public static boolean isServiceRunning(Context context, String className) {

		boolean isRunning = false;

		ActivityManager activityManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);

		List<ActivityManager.RunningServiceInfo> serviceList = activityManager
				.getRunningServices(Integer.MAX_VALUE);

		if (!(serviceList.size() > 0)) {
			return false;
		}
		for (int i = 0; i < serviceList.size(); i++) {
			if (serviceList.get(i).service.getClassName().equals(className) == true) {

				isRunning = true;
				break;
			}
		}
		return isRunning;
	}
	
	/**
	 * 加载contacts的photos
	 * @param context
	 * @param contactId
	 * @param options
	 * @return
	 */
	public static Bitmap loadContactPhoto(Context context, long contactId,
			BitmapFactory.Options options) {
		Cursor cursor = null;
		Bitmap bm = null;
		try {
			Uri contactUri = ContentUris.withAppendedId(
					ContactsContract.Contacts.CONTENT_URI, contactId);
			Uri photoUri = Uri.withAppendedPath(contactUri,
					ContactsContract.Contacts.Photo.CONTENT_DIRECTORY);
			cursor = context
					.getContentResolver()
					.query(photoUri,
							new String[] { ContactsContract.CommonDataKinds.Photo.PHOTO },
							null, null, null);
			if (cursor != null && cursor.moveToFirst()) {
				byte[] data = cursor.getBlob(0);
				bm = BitmapFactory.decodeByteArray(data, 0, data.length,
						options);
			}
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
		return bm;
	}

	/**
	 * @category 查找、删除文件，递归
	 * @param strSrcPath
	 * @param isEnd
	 *            true:以strFilePrefix结尾的文件名，false：文件名字符串中包含strFilePrefx的文件
	 * @param strFilePrefx
	 * @throws Exception
	 */

	public static void delFiles(String strSrcPath, String fileName,
			ArrayList<String> excludeFiles) throws Exception {

		File file = new File(strSrcPath);

		if (!file.isDirectory())
			return;
		File files[] = file.listFiles();
		for (int i = 0; i < files.length; i++) {
			if (files[i].isDirectory())
				delFiles(files[i].getAbsolutePath(), fileName, excludeFiles);
			else {
				if (fileName != null) {

					if (fileName.equals(files[i].getName())) {

						files[i].delete();

					}
				} else if (!excludeFiles.isEmpty()) {

					if (!excludeFiles.contains(files[i].getName())) {

						files[i].delete();

					}
				}

			}

		}
	}

	/**
	 * 
	 * Method:getPinYin: TODO
	 * 
	 * @author cuikuangye
	 * @param word
	 * @return String
	 * @Date 2011 2011-9-20 pm 1:38:55
	 * @throws
	 * 
	 */
	public static String getPinYin(String word) {
		final int[] HanZiCode = { 0xB0A1, 0xB0C5, 0xB2C1, 0xB4EE, 0xB6EA,
				0xB7A2, 0xB8C1, 0xB9FE, 0xBBF7, 0xBFA6, 0xC0AC, 0xC2E8, 0xC4C3,
				0xC5B6, 0xC5BE, 0xC6DA, 0xC8BB, 0xC8F6, 0xCBFA, 0xCDDA, 0xCEF4,
				0xD1B9, 0xD4D1, 0xD8A0 };
		final int LENGTH = HanZiCode.length;

		byte[] byte1;
		char c = 'a' - 1;
		try {
			byte1 = word.getBytes("gb2312");
			if (byte1.length == 2) {
				int codeValue = ((byte1[0] + 256) * 256 + byte1[1] + 256);
				if (codeValue >= HanZiCode[0]
						&& codeValue <= HanZiCode[LENGTH - 1]) {
					for (int i = 0; i < LENGTH; i++) {
						if (codeValue >= HanZiCode[i]) {
							if ((c + 1 == 'i')) {
								c += 2;
							} else if (c + 1 == 'u') {
								c += 3;
							} else {
								c++;
							}
						}
					}
					return c + "";
				}
			}
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}
		return word;

	}
	
	/**
	 *  getMySharedPreferences
	 * @param context
	 * @return
	 */
	public static SharedPreferences getMySharedPreferences(Context context){
		SharedPreferences mySharedPreferences = context.getSharedPreferences(Constants.AIRENAO_SHARED_DATA,Context.MODE_PRIVATE);
		return mySharedPreferences;
	}
	
	/**     * 退出客户端。     *      * @param context 上下文     */
	public static void exitClient(Context context) {
		Log.d("tag", "----- exitClient -----");
		// 关闭所有Activity
		for (int i = 0; i < activityList.size(); i++) {
			if (null != activityList.get(i)) {
				activityList.get(i).finish();
			}
		}
		ActivityManager activityManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		activityManager.restartPackage("com.aragoncg.apps.airenao");
		System.exit(0);
	}
	
	/**
	 * 判定是否是电话号码
	 * @param phoneNumber
	 * @return
	 */
	public static boolean checkPhoneNumber(String phoneNumber){
		if(phoneNumber.matches(regPhoneNumber)){
			return true;
		}
		return false;
	}
	
}
