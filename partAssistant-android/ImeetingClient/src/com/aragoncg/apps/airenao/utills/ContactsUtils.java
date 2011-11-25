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

package com.aragoncg.apps.airenao.utills;


import java.util.ArrayList;
import java.util.List;

import com.aragoncg.apps.airenao.constans.Constants;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.Data;
import android.provider.ContactsContract.RawContacts;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Im;
import android.provider.ContactsContract.CommonDataKinds.Organization;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.Photo;
import android.provider.ContactsContract.CommonDataKinds.StructuredPostal;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;


public class ContactsUtils {
	
	
//    private static final String TAG = "ContactsUtils";
    /**
     * Build the display title for the {@link Data#CONTENT_URI} entry in the
     * provided cursor, assuming the given mimeType.
     */
    public static final CharSequence getDisplayLabel(Context context,
            String mimeType, Cursor cursor) {
        // Try finding the type and label for this mimetype
        int colType;
        int colLabel;

        if (Phone.CONTENT_ITEM_TYPE.equals(mimeType)
                || Constants.MIME_SMS_ADDRESS.equals(mimeType)) {
            // Reset to phone mimetype so we generate a label for SMS case
            mimeType = Phone.CONTENT_ITEM_TYPE;
            colType = cursor.getColumnIndex(Phone.TYPE);
            colLabel = cursor.getColumnIndex(Phone.LABEL);
        } else if (Email.CONTENT_ITEM_TYPE.equals(mimeType)) {
            colType = cursor.getColumnIndex(Email.TYPE);
            colLabel = cursor.getColumnIndex(Email.LABEL);
        } else if (StructuredPostal.CONTENT_ITEM_TYPE.equals(mimeType)) {
            colType = cursor.getColumnIndex(StructuredPostal.TYPE);
            colLabel = cursor.getColumnIndex(StructuredPostal.LABEL);
        } else if (Organization.CONTENT_ITEM_TYPE.equals(mimeType)) {
            colType = cursor.getColumnIndex(Organization.TYPE);
            colLabel = cursor.getColumnIndex(Organization.LABEL);
        } else {
            return null;
        }

        final int type = cursor.getInt(colType);
        final CharSequence label = cursor.getString(colLabel);

        return getDisplayLabel(context, mimeType, type, label);
    }

    public static final CharSequence getDisplayLabel(Context context, String mimetype, int type,
            CharSequence label) {
        CharSequence display = "";
        final int customType;
        final int defaultType;
//      final int arrayResId;

        if (Phone.CONTENT_ITEM_TYPE.equals(mimetype)) {
            defaultType = Phone.TYPE_HOME;
            customType = Phone.TYPE_CUSTOM;
            //arrayResId = com.android.internal.R.array.phoneTypes;
        } else if (Email.CONTENT_ITEM_TYPE.equals(mimetype)) {
            defaultType = Email.TYPE_HOME;
            customType = Email.TYPE_CUSTOM;
            //arrayResId = com.android.internal.R.array.emailAddressTypes;
        } else if (StructuredPostal.CONTENT_ITEM_TYPE.equals(mimetype)) {
            defaultType = StructuredPostal.TYPE_HOME;
            customType = StructuredPostal.TYPE_CUSTOM;
            //arrayResId = com.android.internal.R.array.postalAddressTypes;
        } else if (Organization.CONTENT_ITEM_TYPE.equals(mimetype)) {
            defaultType = Organization.TYPE_WORK;
            customType = Organization.TYPE_CUSTOM;
            //arrayResId = com.android.internal.R.array.organizationTypes;
        } else {
            // Can't return display label for given mimetype.
            return display;
        }

        if (type != customType) {
            CharSequence[] labels = context.getResources().getTextArray(0);
            try {
                display = labels[type - 1];
            } catch (ArrayIndexOutOfBoundsException e) {
                display = labels[defaultType - 1];
            }
        } else {
            if (!TextUtils.isEmpty(label)) {
                display = label;
            }
        }
        return display;
    }

    /**
     * Opens an InputStream for the person's photo and returns the photo as a Bitmap.
     * If the person's photo isn't present returns null.
     *
     * @param aggCursor the Cursor pointing to the data record containing the photo.
     * @param bitmapColumnIndex the column index where the photo Uri is stored.
     * @param options the decoding options, can be set to null
     * @return the photo Bitmap
     */
    public static Bitmap loadContactPhoto(Cursor cursor, int bitmapColumnIndex,
            BitmapFactory.Options options) {
        if (cursor == null) {
            return null;
        }

        byte[] data = cursor.getBlob(bitmapColumnIndex);
        return BitmapFactory.decodeByteArray(data, 0, data.length, options);
    }

    /**
     * Loads a placeholder photo.
     *
     * @param placeholderImageResource the resource to use for the placeholder image
     * @param context the Context
     * @param options the decoding options, can be set to null
     * @return the placeholder Bitmap.
     */
    public static Bitmap loadPlaceholderPhoto(int placeholderImageResource, Context context,
            BitmapFactory.Options options) {
        if (placeholderImageResource == 0) {
            return null;
        }
        return BitmapFactory.decodeResource(context.getResources(),
                placeholderImageResource, options);
    }

    public static Bitmap loadContactPhoto(Context context, long photoId,
            BitmapFactory.Options options) {
        Cursor photoCursor = null;
        Bitmap photoBm = null;

        try {
            photoCursor = context.getContentResolver().query(
                    ContentUris.withAppendedId(Data.CONTENT_URI, photoId),
                    new String[] { Photo.PHOTO },
                    null, null, null);

            if (photoCursor.moveToFirst() && !photoCursor.isNull(0)) {
                byte[] photoData = photoCursor.getBlob(0);
                photoBm = BitmapFactory.decodeByteArray(photoData, 0,
                        photoData.length, options);
            }
        } finally {
            if (photoCursor != null) {
                photoCursor.close();
            }
        }

        return photoBm;
    }

    /**
     * This looks up the provider name defined in
     * {@link android.provider.Im.ProviderNames} from the predefined IM protocol id.
     * This is used for interacting with the IM application.
     *
     * @param protocol the protocol ID
     * @return the provider name the IM app uses for the given protocol, or null if no
     * provider is defined for the given protocol
     * @hide
     */
    public static String lookupProviderNameFromId(int protocol) {
        switch (protocol) {
            case Im.PROTOCOL_GOOGLE_TALK:
                //return Im.;
            case Im.PROTOCOL_AIM:
                //return ProviderNames.AIM;
            case Im.PROTOCOL_MSN:
                //return ProviderNames.MSN;
            case Im.PROTOCOL_YAHOO:
                //return ProviderNames.YAHOO;
            case Im.PROTOCOL_ICQ:
                //return ProviderNames.ICQ;
            case Im.PROTOCOL_JABBER:
                //return ProviderNames.JABBER;
            case Im.PROTOCOL_SKYPE:
                //return ProviderNames.SKYPE;
            case Im.PROTOCOL_QQ:
                //return ProviderNames.QQ;
        }

        return null;
    }

    /**
     * Build {@link Intent} to launch an action for the given {@link Im} or
     * {@link Email} row. Returns null when missing protocol or data.
     */
    public static Intent buildImIntent(ContentValues values) {
        final boolean isEmail = Email.CONTENT_ITEM_TYPE.equals(values.getAsString(Data.MIMETYPE));

        if (!isEmail && !isProtocolValid(values)) {
            return null;
        }

        final int protocol = isEmail ? Im.PROTOCOL_GOOGLE_TALK : values.getAsInteger(Im.PROTOCOL);

        String host = values.getAsString(Im.CUSTOM_PROTOCOL);
        String data = values.getAsString(isEmail ? Email.DATA : Im.DATA);
        if (protocol != Im.PROTOCOL_CUSTOM) {
            // Try bringing in a well-known host for specific protocols
            host = ContactsUtils.lookupProviderNameFromId(protocol);
        }

        if (!TextUtils.isEmpty(host) && !TextUtils.isEmpty(data)) {
            final String authority = host.toLowerCase();
            final Uri imUri = new Uri.Builder().scheme(Constants.SCHEME_IMTO).authority(
                    authority).appendPath(data).build();
            return new Intent(Intent.ACTION_SENDTO, imUri);
        } else {
            return null;
        }
    }

    private static boolean isProtocolValid(ContentValues values) {
        String protocolString = values.getAsString(Im.PROTOCOL);
        if (protocolString == null) {
            return false;
        }
        try {
            Integer.valueOf(protocolString);
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    public static Intent getPhotoPickIntent() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT, null);
        intent.setType("image/*");
        intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        intent.putExtra("outputX", 96);
        intent.putExtra("outputY", 96);
        intent.putExtra("return-data", true);
        return intent;
    }

    public static long queryForContactId(ContentResolver cr, long rawContactId) {
        Cursor contactIdCursor = null;
        long contactId = -1;
        try {
            contactIdCursor = cr.query(RawContacts.CONTENT_URI,
                    new String[] {RawContacts.CONTACT_ID},
                    RawContacts._ID + "=" + rawContactId, null, null);
            if (contactIdCursor != null && contactIdCursor.moveToFirst()) {
                contactId = contactIdCursor.getLong(0);
            }
        } finally {
            if (contactIdCursor != null) {
                contactIdCursor.close();
            }
        }
        return contactId;
    }

    public static String querySuperPrimaryPhone(ContentResolver cr, long contactId) {
        Cursor c = null;
        String phone = null;
        try {
            Uri baseUri = ContentUris.withAppendedId(Contacts.CONTENT_URI, contactId);
            Uri dataUri = Uri.withAppendedPath(baseUri, Contacts.Data.CONTENT_DIRECTORY);

            c = cr.query(dataUri,
                    new String[] {Phone.NUMBER},
                    Data.MIMETYPE + "=" + Phone.MIMETYPE +
                        " AND " + Data.IS_SUPER_PRIMARY + "=1",
                    null, null);
            if (c != null && c.moveToFirst()) {
                // Just return the first one.
                phone = c.getString(0);
            }
        } finally {
            if (c != null) {
                c.close();
            }
        }
        return phone;
    }

    public static long queryForRawContactId(ContentResolver cr, long contactId) {
        Cursor rawContactIdCursor = null;
        long rawContactId = -1;
        try {
            rawContactIdCursor = cr.query(RawContacts.CONTENT_URI,
                    new String[] {RawContacts._ID},
                    RawContacts.CONTACT_ID + "=" + contactId, null, null);
            if (rawContactIdCursor != null && rawContactIdCursor.moveToFirst()) {
                // Just return the first one.
                rawContactId = rawContactIdCursor.getLong(0);
            }
        } finally {
            if (rawContactIdCursor != null) {
                rawContactIdCursor.close();
            }
        }
        return rawContactId;
    }

    public static ArrayList<Long> queryForAllRawContactIds(ContentResolver cr, long contactId) {
        Cursor rawContactIdCursor = null;
        ArrayList<Long> rawContactIds = new ArrayList<Long>();
        try {
            rawContactIdCursor = cr.query(RawContacts.CONTENT_URI,
                    new String[] {RawContacts._ID},
                    RawContacts.CONTACT_ID + "=" + contactId, null, null);
            if (rawContactIdCursor != null) {
                while (rawContactIdCursor.moveToNext()) {
                    rawContactIds.add(rawContactIdCursor.getLong(0));
                }
            }
        } finally {
            if (rawContactIdCursor != null) {
                rawContactIdCursor.close();
            }
        }
        return rawContactIds;
    }


    /**
     * Utility for creating a standard tab indicator view.
     *
     * @param parent The parent ViewGroup to attach the new view to.
     * @param label The label to display in the tab indicator. If null, not label will be displayed.
     * @param icon The icon to display. If null, no icon will be displayed.
     * @return The tab indicator View.
     */
    public static View createTabIndicatorView(ViewGroup parent, CharSequence label, Drawable icon) {
//        final LayoutInflater inflater = (LayoutInflater)parent.getContext().getSystemService(
//                Context.LAYOUT_INFLATER_SERVICE);
//        final View tabIndicator = inflater.inflate(R.layout.tab_indicator, parent, false);
//        tabIndicator.getBackground().setDither(true);
//
//        final TextView tv = (TextView) tabIndicator.findViewById(R.id.tab_title);
//        tv.setText(label);
//
//        final ImageView iconView = (ImageView) tabIndicator.findViewById(R.id.tab_icon);
//        iconView.setImageDrawable(icon);
//
//        return tabIndicator;
    	return null;
    }

    /**
     * Kick off an intent to initiate a call.
     */
    public static void initiateCall(Context context, CharSequence phoneNumber) {
        Intent intent = new Intent(Intent.ACTION_CALL,
                Uri.fromParts("tel", phoneNumber.toString(), null));
        context.startActivity(intent);
    }

    /**
     * Kick off an intent to initiate an Sms/Mms message.
     */
    public static void initiateSms(Context context, CharSequence phoneNumber) {
        Intent intent = new Intent(Intent.ACTION_SENDTO,
                Uri.fromParts("sms", phoneNumber.toString(), null));
        context.startActivity(intent);
    }
    /**
     * Test if the given {@link CharSequence} contains any graphic characters,
     * first checking {@link TextUtils#isEmpty(CharSequence)} to handle null.
     */
    public static boolean isGraphic(CharSequence str) {
        return !TextUtils.isEmpty(str) && TextUtils.isGraphic(str);
    }
    /**
     * 
     *   Method:GetNumber:(......)
     *   TODO(to revert the 11 phone number)
     *   @author   cuikuangye
     *   @param num
     *   @return   
     *   String 
     *   @Date	 2011	2011-9-13		pm 12:39:52   
     *   @throws 
     *
     */
    public static String GetNumber(String num){
    	  if(num!=null)
    	  {
    	  if (num.startsWith("+86"))
    	        {
    	   num = num.substring(3);
    	        }
    	        else if (num.startsWith("86")){
    	         num = num.substring(2);
    	        } else if (num.startsWith("+")){
    	        	num = num.substring(1);
    	        }
    	  }
    	  else{
    	   num="";
    	  }
    	  return num;
    	}
    

}
