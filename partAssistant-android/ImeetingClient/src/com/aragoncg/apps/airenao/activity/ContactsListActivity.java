package com.aragoncg.apps.airenao.activity;

import java.lang.ref.SoftReference;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.app.SearchManager;
import android.content.AsyncQueryHandler;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Resources;
import android.database.CharArrayBuffer;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.net.Uri.Builder;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Parcelable;
import android.preference.PreferenceManager;
import android.provider.Contacts.ContactMethods;
import android.provider.Contacts.People;
import android.provider.Contacts.Phones;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.Photo;
import android.provider.ContactsContract.CommonDataKinds.StructuredPostal;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.Contacts.AggregationSuggestions;
import android.provider.ContactsContract.Data;
import android.provider.ContactsContract.RawContacts;
import android.telephony.PhoneNumberUtils;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AlphabetIndexer;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.QuickContactBadge;
import android.widget.ResourceCursorAdapter;
import android.widget.SectionIndexer;
import android.widget.TextView;
import android.widget.Toast;

import com.aragoncg.apps.airenao.R;
import com.aragoncg.apps.airenao.activity.Collapser.Collapsible;
import com.aragoncg.apps.airenao.constans.Constants;
import com.aragoncg.apps.airenao.model.MyPerson;
import com.aragoncg.apps.airenao.utills.AirenaoUtills;
import com.aragoncg.apps.airenao.utills.ContactsUtils;
import com.aragoncg.apps.airenao.utills.MyAlphabetIndexe;

/**
 * Displays a list of contacts. Usually is embedded into the ContactsActivity.
 */
@SuppressWarnings("deprecation")
public class ContactsListActivity extends ListActivity implements
		View.OnCreateContextMenuListener, View.OnClickListener {

	public static class JoinContactActivity extends ContactsListActivity {

	}

	private static final String TAG = "ContactsListActivity";

	private static final boolean ENABLE_ACTION_ICON_OVERLAYS = true;

	private static final String LIST_STATE_KEY = "liststate";
	private static final String FOCUS_KEY = "focused";

	static final int MENU_ITEM_VIEW_CONTACT = 1;
	static final int MENU_ITEM_CALL = 2;
	static final int MENU_ITEM_EDIT_BEFORE_CALL = 3;
	static final int MENU_ITEM_SEND_SMS = 4;
	static final int MENU_ITEM_SEND_IM = 5;
	static final int MENU_ITEM_EDIT = 6;
	static final int MENU_ITEM_DELETE = 7;
	static final int MENU_ITEM_TOGGLE_STAR = 8;
	static final int MENU_ITEM_SHARE = 9;
	public List<String> list1 = new ArrayList<String>();
	private static final int SUBACTIVITY_NEW_CONTACT = 1;
	private static final int SUBACTIVITY_VIEW_CONTACT = 2;
	private static final int SUBACTIVITY_DISPLAY_GROUP = 3;

	private boolean isShow = false;
	private Runnable dataLoading;
	private ListView list;
	private MyPerson bindPerson;
	private int tempCount = 0;
	public static int allcount = 0;
	public int m = 0;

	/**
	 * The action for the join contact activity.
	 * <p>
	 * Input: extra field {@link #EXTRA_AGGREGATE_ID} is the aggregate ID.
	 * 
	 * TODO: move to {@link ContactsContract}.
	 */
	public static final String JOIN_AGGREGATE = "com.android.contacts.action.JOIN_AGGREGATE";

	/**
	 * Used with {@link #JOIN_AGGREGATE} to give it the target for aggregation.
	 * <p>
	 * Type: LONG
	 */
	public static final String EXTRA_AGGREGATE_ID = "com.android.contacts.action.AGGREGATE_ID";

	public static Map<Integer, Boolean> isSelected;
	public static Map<Integer, MyPerson> personMap;

	/**
	 * Used with {@link #JOIN_AGGREGATE} to give it the name of the aggregation
	 * target.
	 * <p>
	 * Type: STRING
	 */
	@Deprecated
	public static final String EXTRA_AGGREGATE_NAME = "com.android.contacts.action.AGGREGATE_NAME";

	public static final String AUTHORITIES_FILTER_KEY = "authorities";

	/** Mask for picker mode */
	static final int MODE_MASK_PICKER = 0x80000000;
	/** Mask for no presence mode */
	static final int MODE_MASK_NO_PRESENCE = 0x40000000;
	/** Mask for enabling list filtering */
	static final int MODE_MASK_NO_FILTER = 0x20000000;
	/** Mask for having a "create new contact" header in the list */
	static final int MODE_MASK_CREATE_NEW = 0x10000000;
	/** Mask for showing photos in the list */
	static final int MODE_MASK_SHOW_PHOTOS = 0x08000000;
	/**
	 * Mask for hiding additional information e.g. primary phone number in the
	 * list
	 */
	static final int MODE_MASK_NO_DATA = 0x04000000;
	/** Mask for showing a call button in the list */
	static final int MODE_MASK_SHOW_CALL_BUTTON = 0x02000000;
	/** Mask for showing a diff call button in the list */
	static final int MODE_MASK_SHOW_DIFF_CALL_BUTTON = 0x03000000;
	/** Mask to disable quickcontact (images will show as normal images) */
	static final int MODE_MASK_DISABLE_QUIKCCONTACT = 0x01000000;
	/** Mask to show the total number of contacts at the top */
	static final int MODE_MASK_SHOW_NUMBER_OF_CONTACTS = 0x00800000;

	/** Unknown mode */
	static final int MODE_UNKNOWN = 0;
	/** Default mode */
	public static final int MODE_DEFAULT = -2 | MODE_MASK_SHOW_PHOTOS
			| MODE_MASK_SHOW_NUMBER_OF_CONTACTS;
	static final int MODE_PICK_EMAIL = -3;
	/** Custom mode */
	static final int MODE_CUSTOM = 8;
	/** Show all starred contacts */
	static final int MODE_STARRED = 20 | MODE_MASK_SHOW_PHOTOS;
	/** Show frequently contacted contacts */
	static final int MODE_FREQUENT = 30 | MODE_MASK_SHOW_PHOTOS;
	/** Show starred and the frequent */
	public static final int MODE_STREQUENT = 35 | MODE_MASK_SHOW_PHOTOS
			| MODE_MASK_SHOW_CALL_BUTTON;
	/** Show all contacts and pick them when clicking */
	static final int MODE_PICK_CONTACT = 40 | MODE_MASK_PICKER
			| MODE_MASK_SHOW_PHOTOS | MODE_MASK_DISABLE_QUIKCCONTACT;
	/** Show all contacts as well as the option to create a new one */
	static final int MODE_PICK_OR_CREATE_CONTACT = 42 | MODE_MASK_PICKER
			| MODE_MASK_CREATE_NEW | MODE_MASK_SHOW_PHOTOS
			| MODE_MASK_DISABLE_QUIKCCONTACT;
	/** Show all people through the legacy provider and pick them when clicking */
	static final int MODE_LEGACY_PICK_PERSON = 43 | MODE_MASK_PICKER
			| MODE_MASK_SHOW_PHOTOS | MODE_MASK_DISABLE_QUIKCCONTACT;
	/**
	 * Show all people through the legacy provider as well as the option to
	 * create a new one
	 */
	static final int MODE_LEGACY_PICK_OR_CREATE_PERSON = 44 | MODE_MASK_PICKER
			| MODE_MASK_CREATE_NEW | MODE_MASK_SHOW_PHOTOS
			| MODE_MASK_DISABLE_QUIKCCONTACT;
	/**
	 * Show all contacts and pick them when clicking, and allow creating a new
	 * contact
	 */
	static final int MODE_INSERT_OR_EDIT_CONTACT = 45 | MODE_MASK_PICKER
			| MODE_MASK_CREATE_NEW;
	/** Show all phone numbers and pick them when clicking */
	static final int MODE_PICK_PHONE = 50 | MODE_MASK_PICKER
			| MODE_MASK_NO_PRESENCE;
	/**
	 * Show all phone numbers through the legacy provider and pick them when
	 * clicking
	 */
	static final int MODE_LEGACY_PICK_PHONE = 51 | MODE_MASK_PICKER
			| MODE_MASK_NO_PRESENCE | MODE_MASK_NO_FILTER;
	/** Show all postal addresses and pick them when clicking */
	static final int MODE_PICK_POSTAL = 55 | MODE_MASK_PICKER
			| MODE_MASK_NO_PRESENCE | MODE_MASK_NO_FILTER;
	/** Show all postal addresses and pick them when clicking */
	static final int MODE_LEGACY_PICK_POSTAL = 56 | MODE_MASK_PICKER
			| MODE_MASK_NO_PRESENCE | MODE_MASK_NO_FILTER;
	static final int MODE_GROUP = 57 | MODE_MASK_SHOW_PHOTOS;
	/** Run a search query */
	static final int MODE_QUERY = 60 | MODE_MASK_NO_FILTER
			| MODE_MASK_SHOW_NUMBER_OF_CONTACTS;
	/** Run a search query in PICK mode, but that still launches to VIEW */
	static final int MODE_QUERY_PICK_TO_VIEW = 65 | MODE_MASK_NO_FILTER
			| MODE_MASK_PICKER;

	/** Show join suggestions followed by an A-Z list */
	static final int MODE_JOIN_CONTACT = 70 | MODE_MASK_PICKER
			| MODE_MASK_NO_PRESENCE | MODE_MASK_NO_DATA | MODE_MASK_SHOW_PHOTOS
			| MODE_MASK_DISABLE_QUIKCCONTACT;

	/** Maximum number of suggestions shown for joining aggregates */
	static final int MAX_SUGGESTIONS = 4;

	static final String NAME_COLUMN = Contacts.DISPLAY_NAME;
	// static final String SORT_STRING = People.SORT_STRING;

	static final String[] CONTACTS_SUMMARY_PROJECTION = new String[] {
			Contacts._ID, // 0
			Contacts.DISPLAY_NAME, // 1
			Contacts.STARRED, // 2
			Contacts.TIMES_CONTACTED, // 3
			Contacts.CONTACT_PRESENCE, // 4
			Contacts.PHOTO_ID, // 5
			Contacts.LOOKUP_KEY, // 6
			Contacts.HAS_PHONE_NUMBER // 7
	};
	static final String[] CONTACTS_OLD_PROJECTION = new String[] {
			android.provider.Contacts.Phones.PERSON_ID,
			android.provider.Contacts.Phones.DISPLAY_NAME,
			android.provider.Contacts.Phones.NUMBER,

	};

	static final String[] CONTACTS_EMAIAL = new String[] {
			ContactsContract.CommonDataKinds.Email.CONTACT_ID,
			ContactsContract.CommonDataKinds.Email.DISPLAY_NAME,
			ContactsContract.CommonDataKinds.Email.DATA, };

	static final String[] CONTACTS_SUMMARY_PROJECTION_FROM_EMAIL = new String[] {
			Contacts._ID, // 0
			Contacts.DISPLAY_NAME, // 1
			Contacts.STARRED, // 2
			Contacts.TIMES_CONTACTED, // 3
			Contacts.CONTACT_PRESENCE, // 4
			Contacts.PHOTO_ID, // 5
			Contacts.LOOKUP_KEY, // 6
	// email lookup doesn't included HAS_PHONE_NUMBER OR LOOKUP_KEY in
	// projection
	};
	static final int SUMMARY_ID_COLUMN_INDEX = 0;
	static final int SUMMARY_NAME_COLUMN_INDEX = 1;
	static final int SUMMARY_STARRED_COLUMN_INDEX = 2;
	static final int SUMMARY_TIMES_CONTACTED_COLUMN_INDEX = 3;
	static final int SUMMARY_PRESENCE_STATUS_COLUMN_INDEX = 4;
	static final int SUMMARY_PHOTO_ID_COLUMN_INDEX = 5;
	static final int SUMMARY_LOOKUP_KEY = 6;
	static final int SUMMARY_HAS_PHONE_COLUMN_INDEX = 7;

	static final String[] PHONES_PROJECTION = new String[] { Phone._ID, // 0
			Phone.TYPE, // 1
			Phone.LABEL, // 2
			Phone.NUMBER, // 3
			Phone.DISPLAY_NAME, // 4
			Phone.CONTACT_ID, // 5
	};

	static final int PHONE_ID_COLUMN_INDEX = 0;
	static final int PHONE_TYPE_COLUMN_INDEX = 1;
	static final int PHONE_LABEL_COLUMN_INDEX = 2;
	static final int PHONE_NUMBER_COLUMN_INDEX = 3;
	static final int PHONE_DISPLAY_NAME_COLUMN_INDEX = 4;
	static final int PHONE_CONTACT_ID_COLUMN_INDEX = 5;

	static final String[] POSTALS_PROJECTION = new String[] {
			StructuredPostal._ID, // 0
			StructuredPostal.TYPE, // 1
			StructuredPostal.LABEL, // 2
			StructuredPostal.DATA, // 3
			StructuredPostal.DISPLAY_NAME, // 4
	};
	static final String[] RAW_CONTACTS_PROJECTION = new String[] {
			RawContacts._ID, // 0
			RawContacts.CONTACT_ID, // 1
			RawContacts.ACCOUNT_TYPE, // 2
	};

	static final int POSTAL_ID_COLUMN_INDEX = 0;
	static final int POSTAL_TYPE_COLUMN_INDEX = 1;
	static final int POSTAL_LABEL_COLUMN_INDEX = 2;
	static final int POSTAL_ADDRESS_COLUMN_INDEX = 3;
	static final int POSTAL_DISPLAY_NAME_COLUMN_INDEX = 4;

	private static final int QUERY_TOKEN = 42;

	static final String KEY_PICKER_MODE = "picker_mode";

	private ContactItemListAdapter mAdapter;

	public static int mMode = MODE_DEFAULT;

	private QueryHandler mQueryHandler;
	private boolean mJustCreated;
	private Uri mSelectedContactUri;

	// private boolean mDisplayAll;
	private boolean mDisplayOnlyPhones;
	private int intentCount;
	private Uri mGroupUri;

	private long mQueryAggregateId;

	/**
	 * Used to keep track of the scroll state of the list.
	 */
	private Parcelable mListState = null;
	private boolean mListHasFocus;

	private int mScrollState;

	/**
	 * Internal query type when in mode {@link #MODE_QUERY_PICK_TO_VIEW}.
	 */
	private int mQueryMode = QUERY_MODE_NONE;

	private static final int QUERY_MODE_NONE = -1;
	private static final int QUERY_MODE_MAILTO = 1;
	private static final int QUERY_MODE_TEL = 2;

	/**
	 * Data to use when in mode {@link #MODE_QUERY_PICK_TO_VIEW}. Usually
	 * provided by scheme-specific part of incoming {@link Intent#getData()}.
	 */
	private String mQueryData;

	private static final String CLAUSE_ONLY_VISIBLE = Contacts.IN_VISIBLE_GROUP
			+ "=1";
	private static final String CLAUSE_ONLY_PHONES = Contacts.HAS_PHONE_NUMBER
			+ "=1";

	/**
	 * In the {@link #MODE_JOIN} determines whether we display a list item with
	 * the label "Show all contacts" or actually show all contacts
	 */
	@SuppressWarnings( { "JavadocReference" })
	private boolean mJoinModeShowAllContacts;

	/**
	 * The ID of the special item described above.
	 */
	private static final long JOIN_MODE_SHOW_ALL_CONTACTS_ID = -2;

	// Uri matcher for contact id
	private static final int CONTACTS_ID = 1001;

	private static ExecutorService sImageFetchThreadPool;

	private EditText edtSearch;
	private Button btnOk;
	private Button btnCancle;
	private Button btnAll;
	private Button btnPrivew;
	private Button btnFrequent;
	private Handler myHandler;
	private List<MyPerson> choosedData;
	private MyPerson tempPerson;
	private Intent personIntent;
	private static final int MODE_EMAIL = -1;
	private String input = "";
	private ArrayList<String> phoneNumbers;
	private ImageButton btnSwitch;
	private String personId;
	private String personName;
	private List personPhoneNumbers;
	private String personPhoneNumber;
	private static String alreadyExistNumbers;
	private String clickPersonId;
	private String clickPersonName;
	private String clickPersonPhoneNumber;
	private String bindPersonId;
	private String bindPersonName;
	private String bindPersonPhoneNumber;
	private int count = 0;
	public static boolean firstEnter = false;

	private static List<MyPerson> transPersons = new ArrayList<MyPerson>();
	// 用来统计被选中的电话
	private static List<MyPerson> positions;
	private static List<MyPerson> tempPositions = new ArrayList<MyPerson>();
	public static List<MyPerson> exchangeList = new ArrayList<MyPerson>();
	private HashMap<String, SearchInfo> searchInfo = new HashMap<String, SearchInfo>();

	private class DeleteClickListener implements
			DialogInterface.OnClickListener {
		public void onClick(DialogInterface dialog, int which) {
			getContentResolver().delete(mSelectedContactUri, null, null);

		}
	}

	@Override
	protected void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		// Allow the title to be set to a custom String using an extra on the
		// intent
		this.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
		this.getWindow().clearFlags(
				WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
		this.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
		getWindow().setSoftInputMode(
				WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

		setContentView(R.layout.contacts_list_content);
		if (SendAirenaoActivity.createNew) {
			tempPositions.clear();
			SendAirenaoActivity.createNew = false;
		}

		Intent it = this.getIntent();
		String transPersonName;
		String transPersonPhoneNumber;
		mMode = it.getIntExtra("mode", MODE_DEFAULT);
		alreadyExistNumbers = it.getStringExtra("AlreadyExistNumbers");
		mDisplayOnlyPhones = false;
		// Setup the UI
		list = getListView();
		list.setItemsCanFocus(false);
		list.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
		// Tell list view to not show dividers. We'll do it ourself so that we
		// can *not* show
		// them when an A-Z headers is visible.
		// list.setDividerHeight(0);
		list.setFocusable(true);
		// list.setOnCreateContextMenuListener(this);
		if ((mMode & MODE_MASK_NO_FILTER) != MODE_MASK_NO_FILTER) {
			list.setTextFilterEnabled(true);
		}

		// Set the proper empty string
		setEmptyText();

		mAdapter = new ContactItemListAdapter(this);
		setListAdapter(mAdapter);
		getListView().setOnScrollListener(mAdapter);

		// We manually save/restore the listview state
		list.setSaveEnabled(false);

		mQueryHandler = new QueryHandler(this);
		mJustCreated = true;
		getListView().setTextFilterEnabled(false);

		choosedData = new ArrayList<MyPerson>();
		// 添加按钮事件

		// 获得之前存在的电话
		if (alreadyExistNumbers != null) {
			String[] allContacts = alreadyExistNumbers.split("\\,", 0);

			int index = -1;
			if (allContacts.length > 0) {
				transPersons.clear();
				count = 0;
				SharedPreferences pre = PreferenceManager
				.getDefaultSharedPreferences(getApplicationContext());
				String nickname = pre.getString("warning_nickname", "");
				for (int i = 0; i < allContacts.length; i++) {

					if (allContacts[i].equals("")) {
						continue;
					} else {
						transPersonPhoneNumber = allContacts[i];
						index = allContacts[i].indexOf("<");
						if (index > -1) {
							transPersonName = allContacts[i]
									.substring(0, index);
							transPersonPhoneNumber = allContacts[i].substring(
									index + 1, allContacts[i].length() - 1);
						} else {
							transPersonName = "";
							transPersonPhoneNumber = allContacts[i];
						}
						if (AirenaoUtills
								.checkPhoneNumber(transPersonPhoneNumber)) {
							if (!transPersonName.equals("佚名") && !nickname.equals(transPersonName)) {
								count++;
								intentCount++;
							}
							transPersons.add(new MyPerson(transPersonName,
									transPersonPhoneNumber));
						}
					}

				}

			}
			alreadyExistNumbers = null;
		}

		btnOk = (Button) findViewById(R.id.btnAdd);
		btnOk.setText("确定" + "(" + count + ")");
		intentCount = count;
		btnPrivew = (Button) findViewById(R.id.btnCancle);
		btnAll = (Button) findViewById(R.id.btnAll);
		btnAll.setEnabled(false);
		myHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case 0:
					break;
				}
				super.handleMessage(msg);
			}

		};
		btnFrequent = (Button) findViewById(R.id.btnFrequent);

		btnAll.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				btnAll.setEnabled(false);
				// transPersons.clear();
				btnFrequent.setEnabled(true);
				tempPositions.clear();
				tempPositions.addAll(positions);
				mMode = MODE_DEFAULT;
				startQuery();
			}
		});
		btnFrequent.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				btnAll.setEnabled(true);
				// transPersons.clear();
				btnFrequent.setEnabled(false);
				tempPositions.clear();
				tempPositions.addAll(positions);
				mMode = MODE_FREQUENT;
				startQuery();
			}
		});
		btnOk.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// 查找所有的电话，在封装返回
				// 开启一个loadingBar
				showDialog(1);
				dataLoading = new Runnable() {

					@Override
					public void run() {

						for (MyPerson onePerson : positions) {
							personId = onePerson.getId();
							personName = onePerson.getName();
							personPhoneNumber = onePerson.getPhoneNumber();
							tempPerson = new MyPerson(personId, personName,
									personPhoneNumber);

							choosedData.add(tempPerson);
						}
						List<MyPerson> deleteList = deleteSameEntity(choosedData);
						if (SendAirenaoActivity.staticData.size() != 0) {
							for (int i = 0; i < deleteList.size(); i++) {
								boolean flag = false;
								for (int j = 0; j < SendAirenaoActivity.staticData
										.size(); j++) {
									if (deleteList.get(i).getName().equals(
											SendAirenaoActivity.staticData.get(
													j).getName())) {
										flag = true;
									}
								}
								if (!flag) {
									SendAirenaoActivity.staticData
											.add(deleteList.get(i));
								}
							}
						} else {
							SendAirenaoActivity.staticData = deleteList;
						}

						personIntent = new Intent();
						personIntent.putParcelableArrayListExtra(
								Constants.FROMCONTACTSLISTTOSEND,
								(ArrayList<? extends Parcelable>) deleteList);
						positions.clear();
						tempPositions.clear();
						tempCount = 0;
						setResult(21, personIntent);// 21只是一个返回的结果代码
						finish();

					}
				};
				myHandler.post(dataLoading);
			}
		});
		btnPrivew.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// SendAirenaoActivity.staticData.clear();
				choosedData.clear();
				for (MyPerson onePerson : positions) {
					personId = onePerson.getId();
					personName = onePerson.getName();
					personPhoneNumber = onePerson.getPhoneNumber();
					tempPerson = new MyPerson(personId, personName,
							personPhoneNumber);

					choosedData.add(tempPerson);
				}
				List<MyPerson> deleteList = deleteSameEntity(choosedData);

				if (SendAirenaoActivity.staticData.size() != 0) {
					for (int i = 0; i < deleteList.size(); i++) {
						boolean flag = false;
						for (int j = 0; j < SendAirenaoActivity.staticData
								.size(); j++) {
							if (deleteList.get(i).getName().equals(
									SendAirenaoActivity.staticData.get(j)
											.getName())) {
								flag = true;
							}
						}
						if (!flag) {
							SendAirenaoActivity.staticData.add(deleteList
									.get(i));
						}
					}
				} else {

					for (int i = 0; i < deleteList.size(); i++) {
						MyPerson myPerson = deleteList.get(i);
						SendAirenaoActivity.staticData.add(myPerson);
					}

					for (int i = 0; i < SendAirenaoActivity.staticData.size(); i++) {
						MyPerson myPerson = SendAirenaoActivity.staticData
								.get(i);
						exchangeList.add(myPerson);
						firstEnter = true;
					}
				}

				Intent intent = new Intent(getApplicationContext(),
						PreviewActivity.class);
				startActivity(intent);
				finish();
			}
		});

		btnSwitch = (ImageButton) findViewById(R.id.button_dismiss_kb);
		btnSwitch.setEnabled(false);

		setEditSearchListenner();
	}

	/**
	 * 配置输入框的搜索事件
	 */
	public void setEditSearchListenner() {
		if (edtSearch == null) {
			edtSearch = (EditText) findViewById(R.id.input_search_query);
		}

		edtSearch.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence arg0, int start, int before,
					int count) {
				if (mMode == MODE_DEFAULT || mMode == MODE_PICK_CONTACT
						|| mMode == MODE_FREQUENT) {
					mMode = MODE_PICK_CONTACT;
				}
				if (mMode == MODE_EMAIL || mMode == MODE_PICK_EMAIL
						|| mMode == MODE_FREQUENT) {
					mMode = MODE_PICK_EMAIL;
				}
				ContactsListActivity.this.mAdapter.changeCursor(null);
				ContactsListActivity.this.mAdapter.notifyDataSetChanged();
				input = edtSearch.getText().toString();
				if (input.equals(arg0.toString().trim())) {
					if (searchInfo.containsKey(input)
							&& !searchInfo.get(input).isFinished()) {
						return;
					}
				}

				input = arg0.toString().trim();

				if (input.length() == 0) {
					if (mMode == MODE_PICK_CONTACT) {
						mMode = MODE_DEFAULT;
					}
					if (mMode == MODE_PICK_EMAIL) {
						mMode = MODE_EMAIL;
					}
					startQuery();
					return;

				}

				startQuery();

				if (input.length() != 1) {
					searchInfo.put(input, new SearchInfo(input, true));
				} else {
					searchInfo.put(input, new SearchInfo(input, false));
				}

			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub

			}

			@Override
			public void afterTextChanged(Editable s) {
				// TODO Auto-generated method stub

			}

		});

	}

	/** {@inheritDoc} */
	public void onClick(View v) {
		return;
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		// TODO Auto-generated method stub
		super.onWindowFocusChanged(hasFocus);
		if (hasFocus) {
			// Hide soft keyboard, if visible.
			InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			inputMethodManager.hideSoftInputFromWindow(getListView()
					.getWindowToken(), 0);
		}
	}

	private void setEmptyText() {
		if (mMode == MODE_JOIN_CONTACT) {
			return;
		}

		TextView empty = (TextView) findViewById(R.id.emptyText);
		int gravity = Gravity.NO_GRAVITY;

		if (mDisplayOnlyPhones) {
			empty.setText(getText(R.string.noContactsWithPhoneNumbers)
					.toString());
			gravity = Gravity.CENTER;
		} else if (mMode == MODE_STREQUENT || mMode == MODE_STARRED) {
			empty.setText(getText(R.string.noFavoritesHelpText).toString());
		} else if (mMode == MODE_QUERY) {
			empty.setText(getText(R.string.noMatchingContacts).toString());
		} else {
		}
		empty.setGravity(gravity);
	}

	/**
	 * Sets the mode when the request is for "default"
	 */
	private void setDefaultMode() {

	}

	@Override
	protected void onResume() {
		super.onResume();

		Intent it = this.getIntent();
		mMode = it.getIntExtra("mode", MODE_DEFAULT);

		// QueryRunThread queryRunThread = new QueryRunThread();
		// queryRunThread.execute();
		// Force cache to reload so we don't show stale photos.
		if (mAdapter.mBitmapCache != null) {
			mAdapter.mBitmapCache.clear();
		}

		mScrollState = OnScrollListener.SCROLL_STATE_IDLE;
		boolean runQuery = true;
		Activity parent = getParent();

		// Do this before setting the filter. The filter thread relies
		// on some state that is initialized in setDefaultMode
		if (mMode == MODE_DEFAULT) {

			// If we're in default mode we need to possibly reset the mode due
			// to a change
			// in the preferences activity while we weren't running
			setDefaultMode();
		}

		if (mJustCreated && runQuery) {
			// We need to start a query here the first time the activity is
			// launched, as long
			// as we aren't doing a filter.
			startQuery();

		}
		mJustCreated = false;

	}

	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	protected void onRestart() {
		super.onRestart();

		// The cursor was killed off in onStop(), so we need to get a new one
		// here
		// We do not perform the query if a filter is set on the list because
		// the
		// filter will cause the query to happen anyway
		if (TextUtils.isEmpty(getListView().getTextFilter())) {
			startQuery();

		} else {
			// Run the filtered query on the adapter
			((ContactItemListAdapter) getListAdapter()).onContentChanged();
		}
	}

	@Override
	protected void onSaveInstanceState(Bundle icicle) {
		super.onSaveInstanceState(icicle);
		// Save list state in the bundle so we can restore it after the
		// QueryHandler has run
		icicle.putParcelable(LIST_STATE_KEY, getListView()
				.onSaveInstanceState());
		icicle.putBoolean(FOCUS_KEY, getListView().hasFocus());
	}

	@Override
	protected void onRestoreInstanceState(Bundle icicle) {
		super.onRestoreInstanceState(icicle);
		// Retrieve list state. This will be applied after the QueryHandler has
		// run
		mListState = icicle.getParcelable(LIST_STATE_KEY);
		mListHasFocus = icicle.getBoolean(FOCUS_KEY);
	}

	@Override
	protected void onStop() {
		super.onStop();

		// We don't want the list to display the empty state, since when we
		// resume it will still
		// be there and show up while the new query is happening. After the
		// async query finished
		// in response to onRestart() setLoading(false) will be called.
		mAdapter.setLoading(true);
		mAdapter.setSuggestionsCursor(null);
		mAdapter.changeCursor(null);
		mAdapter.clearImageFetching();

		if (mMode == MODE_QUERY) {
			// Make sure the search box is closed
			SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
			searchManager.stopSearch();
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);

		// If Contacts was invoked by another Activity simply as a way of
		// picking a contact, don't show the options menu
		if ((mMode & MODE_MASK_PICKER) == MODE_MASK_PICKER) {
			return false;
		}

		MenuInflater inflater = getMenuInflater();
		// inflater.inflate(R.menu.list, menu);
		return true;
	}

	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		// final boolean defaultMode = (mMode == MODE_DEFAULT);
		// menu.findItem(R.id.menu_display_groups).setVisible(defaultMode);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {

		/*
		 * case R.id.menu_add: { if (Constants.SDK_VERSION < 5) { final Intent
		 * intent = new Intent(Intent.ACTION_INSERT, People.CONTENT_URI);
		 * startActivity(intent); } else { final Intent intent = new
		 * Intent(Intent.ACTION_INSERT, Contacts.CONTENT_URI);
		 * startActivity(intent); } return true; }
		 */
		}
		return false;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (requestCode) {
		case SUBACTIVITY_NEW_CONTACT:
			// if (resultCode == RESULT_OK) {
			// returnPickerResult(null, data
			// .getStringExtra(Intent.EXTRA_SHORTCUT_NAME), data
			// .getData(), 0);
			// }
			break;

		case SUBACTIVITY_VIEW_CONTACT:
			if (resultCode == RESULT_OK) {
				mAdapter.notifyDataSetChanged();
				list.requestFocusFromTouch();
			}
			break;

		case SUBACTIVITY_DISPLAY_GROUP:
			// Mark as just created so we re-run the view query
			mJustCreated = true;
			break;
		}
	}

	@Override
	public void onCreateContextMenu(ContextMenu menu, View view,
			ContextMenuInfo menuInfo) {
		// If Contacts was invoked by another Activity simply as a way of
		// picking a contact, don't show the context menu
		if ((mMode & MODE_MASK_PICKER) == MODE_MASK_PICKER) {
			return;
		}

		AdapterView.AdapterContextMenuInfo info;
		try {
			info = (AdapterView.AdapterContextMenuInfo) menuInfo;
		} catch (ClassCastException e) {
			Log.e(TAG, "bad menuInfo", e);
			return;
		}

		Cursor cursor = (Cursor) getListAdapter().getItem(info.position);
		if (cursor == null) {
			// For some reason the requested item isn't available, do nothing
			return;
		}
		long id = info.id;
		Uri contactUri;
		long rawContactId;
		Uri rawContactUri;
		long phoneId = 0;

		contactUri = ContentUris.withAppendedId(Contacts.CONTENT_URI, id);
		rawContactId = ContactsUtils.queryForRawContactId(getContentResolver(),
				id);
		rawContactUri = ContentUris.withAppendedId(RawContacts.CONTENT_URI,
				rawContactId);

		// Setup the menu header
		menu.setHeaderTitle(cursor.getString(SUMMARY_NAME_COLUMN_INDEX));

		// View contact details

		if (cursor.getInt(SUMMARY_HAS_PHONE_COLUMN_INDEX) != 0) {
			// Calling contact
			menu.add(0, MENU_ITEM_CALL, 0, getString(R.string.menu_call));
			// Send SMS item
			menu
					.add(0, MENU_ITEM_SEND_SMS, 0,
							getString(R.string.menu_sendSMS));
		}

		// Star toggling

		int starState = cursor.getInt(SUMMARY_STARRED_COLUMN_INDEX);

		int hasNumber = cursor.getInt(SUMMARY_HAS_PHONE_COLUMN_INDEX);
		if (hasNumber == 1) {
			if (starState == 0) {
				menu.add(0, MENU_ITEM_TOGGLE_STAR, 0, R.string.menu_addStar);
			} else {
				menu.add(0, MENU_ITEM_TOGGLE_STAR, 0, R.string.menu_removeStar);
			}

		}

		// Contact editing
		menu.add(0, MENU_ITEM_EDIT, 0, R.string.menu_editContact).setIntent(
				new Intent(Intent.ACTION_EDIT, rawContactUri));
		menu.add(0, MENU_ITEM_DELETE, 0, R.string.menu_deleteContact)
				.setIntent(new Intent(Intent.ACTION_DELETE, rawContactUri));
	}

	@Override
	public boolean onContextItemSelected(MenuItem item) {
		AdapterView.AdapterContextMenuInfo info;
		try {
			info = (AdapterView.AdapterContextMenuInfo) item.getMenuInfo();
		} catch (ClassCastException e) {
			Log.e(TAG, "bad menuInfo", e);
			return false;
		}

		Cursor cursor = (Cursor) getListAdapter().getItem(info.position);
		switch (item.getItemId()) {
		case MENU_ITEM_TOGGLE_STAR: {
			// Toggle the star
			ContentValues values = new ContentValues(1);
			values.put(Contacts.STARRED, cursor
					.getInt(SUMMARY_STARRED_COLUMN_INDEX) == 0 ? 1 : 0);
			final Uri selectedUri = this.getContactUri(info.position);
			getContentResolver().update(selectedUri, values, null, null);
			return true;
		}

		case MENU_ITEM_CALL: {
			callContact(cursor);
			return true;
		}

		case MENU_ITEM_SEND_SMS: {
			smsContact(cursor);
			return true;
		}

		case MENU_ITEM_DELETE: {
			mSelectedContactUri = getContactUri(info.position);
			doContactDelete();
			return true;
		}

		}

		return super.onContextItemSelected(item);
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		switch (keyCode) {
		case KeyEvent.KEYCODE_CALL: {
			if (callSelection()) {
				return true;
			}
			break;
		}
		case KeyEvent.KEYCODE_BACK:
			positions.clear();
			tempPositions.clear();
			tempCount = 0;
			allcount = tempCount;
			finish();
			break;
		}

		return super.onKeyDown(keyCode, event);
	}

	@Override
	protected void onDestroy() {
		count = 0;
		tempCount = 0;
		super.onDestroy();

	}

	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		// Hide soft keyboard, if visible
		// transPersons.clear();

		InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		inputMethodManager.hideSoftInputFromWindow(getListView()
				.getWindowToken(), 0);

		ContactListItemCache cache = (ContactListItemCache) v.getTag();
		clickPersonName = cache.nameView.getText().toString();
		clickPersonId = cache.idView.getText().toString();
		clickPersonPhoneNumber = cache.labelView.getText().toString();
		if (mMode == MODE_PICK_CONTACT || mMode == MODE_FREQUENT) {
			position = position + 1;
		}
		MyPerson onePerson = personMap.get(position);
		Log.i("p", personMap.hashCode() + "click");
		boolean isCheckedNow = onePerson.isChecked();

		if (!isCheckedNow) {
			int size = personMap.get(position).getNumbers().size();
			if (size > 1) {
				SharedPreferences msp = AirenaoUtills
						.getMySharedPreferences(ContactsListActivity.this);

				for (int i = 0; i < size; i++) {
					String phone = personMap.get(position).getNumbers().get(i);
					String mark = msp.getString(clickPersonPhoneNumber, "");
					if (Constants.IS_SUPER_PRIMARY != mark) {
						continue;

					} else {
						isShow = true;

						personMap.get(position).setChecked(!isCheckedNow);
						MyPerson person = new MyPerson(clickPersonId,
								clickPersonName, clickPersonPhoneNumber);
						person.setChecked(!isCheckedNow);
						positions.add(person);
						tempCount++;
					}
				}
				if (!isShow) {
					// Display dialog to choose a number to call.
					PhoneDisambigDialog phoneDialog = new PhoneDisambigDialog(
							ContactsListActivity.this, null, false, personMap
									.get(position).getNumbers(), position,
							clickPersonName);
					isShow = false;
					phoneDialog.show();
				}
			} else {

				tempCount++;
				personMap.get(position).setChecked(!isCheckedNow);
				MyPerson person = new MyPerson(clickPersonId, clickPersonName,
						clickPersonPhoneNumber);
				person.setChecked(!isCheckedNow);
				positions.add(new MyPerson(clickPersonId, clickPersonName,
						clickPersonPhoneNumber));
			}
		} else {

			personMap.get(position).setChecked(false);
			if (isCheckedNow) {

				for (int i = 0; i < positions.size(); i++) {
					String collectionPersonId = positions.get(i).getId();
					if (!collectionPersonId.equals(clickPersonId)) {
						continue;
					} else {
						MyPerson myPerson = positions.get(i);
						positions.remove(i);

						for (int k = 0; k < SendAirenaoActivity.staticData
								.size(); k++) {
							if (myPerson.getName().equals(
									SendAirenaoActivity.staticData.get(k)
											.getName())) {
								SendAirenaoActivity.staticData.remove(k);
								break;
							}
						}
					}
					tempCount--;
				}
			}

			else {
				positions.add(new MyPerson(clickPersonId, clickPersonName,
						clickPersonPhoneNumber));
				tempCount++;
			}

			Log.i("pos", "weizhi:" + position);
			// 变化按钮中的统计数字

			/*
			 * tempPositions.clear(); tempPositions.addAll(positions);
			 */

		}
		int showCount = tempCount + count;
		btnOk.setText(getString(R.string.btn_ok) + "(" + showCount + ")");
		mAdapter.notifyDataSetChanged();
		list.requestFocusFromTouch();
	}

	/**
	 * Prompt the user before deleting the given {@link Contacts} entry.
	 */
	protected void doContactDelete() {
		try {
			new AlertDialog.Builder(this).setTitle(
					R.string.deleteConfirmation_title).setIcon(
					android.R.drawable.ic_dialog_alert).setMessage(
					R.string.deleteConfirmation).setNegativeButton(
					android.R.string.cancel, null).setPositiveButton(
					android.R.string.ok, new DeleteClickListener()).show();
		} catch (Exception e) {

		}
	}

	/**
	 * Generates a phone number shortcut icon. Adds an overlay describing the
	 * type of the phone number, and if there is a photo also adds the call
	 * action icon.
	 * 
	 * @param contactId
	 *            The person the phone number belongs to
	 * @param type
	 *            The type of the phone number
	 * @param actionResId
	 *            The ID for the action resource
	 * @return The bitmap for the icon
	 */
	private Bitmap generatePhoneNumberIcon(long contactId, int type,
			int actionResId) {
		final Resources r = getResources();
		boolean drawPhoneOverlay = true;
		final float scaleDensity = getResources().getDisplayMetrics().scaledDensity;

		Bitmap photo = loadContactPhoto(contactId, null);
		if (photo == null) {
			// If there isn't a photo use the generic phone action icon instead
			Bitmap phoneIcon = getPhoneActionIcon(r, actionResId);
			if (phoneIcon != null) {
				photo = phoneIcon;
				drawPhoneOverlay = false;
			} else {
				return null;
			}
		}

		// Setup the drawing classes
		int iconSize = (int) r.getDimension(android.R.dimen.app_icon_size);
		Bitmap icon = Bitmap.createBitmap(iconSize, iconSize,
				Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(icon);

		// Copy in the photo
		Paint photoPaint = new Paint();
		photoPaint.setDither(true);
		photoPaint.setFilterBitmap(true);
		Rect src = new Rect(0, 0, photo.getWidth(), photo.getHeight());
		Rect dst = new Rect(0, 0, iconSize, iconSize);
		canvas.drawBitmap(photo, src, dst, photoPaint);

		// Create an overlay for the phone number type
		String overlay = null;
		switch (type) {
		case Phone.TYPE_HOME:
			overlay = getString(R.string.type_short_home);
			break;

		case Phone.TYPE_MOBILE:
			overlay = getString(R.string.type_short_mobile);
			break;

		case Phone.TYPE_WORK:
			overlay = getString(R.string.type_short_work);
			break;

		case Phone.TYPE_PAGER:
			overlay = getString(R.string.type_short_pager);
			break;

		case Phone.TYPE_OTHER:
			overlay = getString(R.string.type_short_other);
			break;
		}
		if (overlay != null) {
			Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG
					| Paint.DEV_KERN_TEXT_FLAG);
			textPaint.setTextSize(20.0f * scaleDensity);
			textPaint.setTypeface(Typeface.DEFAULT_BOLD);
			textPaint.setColor(r.getColor(R.color.textColorIconOverlay));
			textPaint.setShadowLayer(3f, 1, 1, r
					.getColor(R.color.textColorIconOverlayShadow));
			canvas.drawText(overlay, 2 * scaleDensity, 16 * scaleDensity,
					textPaint);
		}

		// Draw the phone action icon as an overlay
		if (ENABLE_ACTION_ICON_OVERLAYS && drawPhoneOverlay) {
			Bitmap phoneIcon = getPhoneActionIcon(r, actionResId);
			if (phoneIcon != null) {
				src.set(0, 0, phoneIcon.getWidth(), phoneIcon.getHeight());
				int iconWidth = icon.getWidth();
				dst.set(iconWidth - ((int) (20 * scaleDensity)), -1, iconWidth,
						((int) (19 * scaleDensity)));
				canvas.drawBitmap(phoneIcon, src, dst, photoPaint);
			}
		}

		return icon;
	}

	/**
	 * Returns the icon for the phone call action.
	 * 
	 * @param r
	 *            The resources to load the icon from
	 * @param resId
	 *            The resource ID to load
	 * @return the icon for the phone call action
	 */
	private Bitmap getPhoneActionIcon(Resources r, int resId) {
		Drawable phoneIcon = r.getDrawable(resId);
		if (phoneIcon instanceof BitmapDrawable) {
			BitmapDrawable bd = (BitmapDrawable) phoneIcon;
			return bd.getBitmap();
		} else {
			return null;
		}
	}

	Uri getUriToQuery() {
		switch (mMode) {
		case MODE_JOIN_CONTACT:
			return getJoinSuggestionsUri(null);
		case MODE_FREQUENT:
		case MODE_STARRED:
		case MODE_DEFAULT:
		case MODE_INSERT_OR_EDIT_CONTACT:
		case MODE_CUSTOM:
		case MODE_PICK_OR_CREATE_CONTACT: {
			return Contacts.CONTENT_URI;
			// return android.provider.Contacts.Phones.CONTENT_URI;
		}
		case MODE_EMAIL:
			return ContactsContract.CommonDataKinds.Email.CONTENT_URI;
		case MODE_PICK_CONTACT:
			return Uri.withAppendedPath(
					ContactsContract.Contacts.CONTENT_FILTER_URI, Uri
							.encode(input));
		case MODE_PICK_EMAIL:
			return Uri.withAppendedPath(
					ContactsContract.CommonDataKinds.Email.CONTENT_FILTER_URI,
					Uri.encode(input));
		case MODE_STREQUENT: {
			return Contacts.CONTENT_STREQUENT_URI;
		}
		case MODE_LEGACY_PICK_PERSON:
		case MODE_LEGACY_PICK_OR_CREATE_PERSON: {
			return People.CONTENT_URI;
		}
		case MODE_PICK_PHONE: {
			return Phone.CONTENT_URI;
		}
		case MODE_LEGACY_PICK_PHONE: {
			return Phones.CONTENT_URI;
		}
		case MODE_PICK_POSTAL: {
			return StructuredPostal.CONTENT_URI;
		}
		case MODE_LEGACY_PICK_POSTAL: {
			return ContactMethods.CONTENT_URI;
		}
		case MODE_QUERY_PICK_TO_VIEW: {
			if (mQueryMode == QUERY_MODE_MAILTO) {
				return Uri.withAppendedPath(Email.CONTENT_FILTER_URI, Uri
						.encode(mQueryData));
			} else if (mQueryMode == QUERY_MODE_TEL) {
				return Uri.withAppendedPath(Phone.CONTENT_FILTER_URI, Uri
						.encode(mQueryData));
			}
		}
		case MODE_QUERY: {
			return getContactFilterUri(mQueryData);
		}
		case MODE_GROUP: {
			return mGroupUri;
		}
		default: {
			throw new IllegalStateException(
					"Can't generate URI: Unsupported Mode.");
		}
		}
	}

	/**
	 * Build the {@link Contacts#CONTENT_LOOKUP_URI} for the given
	 * {@link ListView} position, using {@link #mAdapter}.
	 */
	private Uri getContactUri(int position) {
		if (position == ListView.INVALID_POSITION) {
			throw new IllegalArgumentException("Position not in list bounds");
		}

		final Cursor cursor = (Cursor) mAdapter.getItem(position);

		final long contactId = cursor.getLong(SUMMARY_ID_COLUMN_INDEX);
		final String lookupKey = cursor.getString(SUMMARY_LOOKUP_KEY);
		return Contacts.getLookupUri(contactId, lookupKey);

	}

	/**
	 * Build the {@link Uri} for the given {@link ListView} position, which can
	 * be used as result when in {@link #MODE_MASK_PICKER} mode.
	 */
	private Uri getSelectedUri(int position) {
		if (position == ListView.INVALID_POSITION) {
			throw new IllegalArgumentException("Position not in list bounds");
		}

		final long id = mAdapter.getItemId(position);
		switch (mMode) {
		case MODE_LEGACY_PICK_PERSON:
		case MODE_LEGACY_PICK_OR_CREATE_PERSON: {
			return ContentUris.withAppendedId(People.CONTENT_URI, id);
		}
		case MODE_PICK_PHONE: {
			return ContentUris.withAppendedId(Data.CONTENT_URI, id);
		}
		case MODE_LEGACY_PICK_PHONE: {
			return ContentUris.withAppendedId(Phones.CONTENT_URI, id);
		}
		case MODE_PICK_POSTAL: {
			return ContentUris.withAppendedId(Data.CONTENT_URI, id);
		}
		case MODE_LEGACY_PICK_POSTAL: {
			return ContentUris.withAppendedId(ContactMethods.CONTENT_URI, id);
		}
		default: {
			return getContactUri(position);
		}
		}
	}

	String[] getProjectionForQuery() {
		switch (mMode) {
		case MODE_JOIN_CONTACT:
		case MODE_STREQUENT:
		case MODE_FREQUENT:
		case MODE_STARRED:
		case MODE_QUERY:
		case MODE_DEFAULT:
		case MODE_INSERT_OR_EDIT_CONTACT:
		case MODE_GROUP:
		case MODE_PICK_OR_CREATE_CONTACT: {

			return CONTACTS_SUMMARY_PROJECTION;
		}
		case MODE_PICK_CONTACT:
			return null;
		case MODE_EMAIL:
			return CONTACTS_SUMMARY_PROJECTION_FROM_EMAIL;
		case MODE_PICK_PHONE: {
			return PHONES_PROJECTION;
		}
		case MODE_PICK_EMAIL:
			return null;
		case MODE_PICK_POSTAL: {
			return POSTALS_PROJECTION;
		}
		case MODE_QUERY_PICK_TO_VIEW: {
			if (mQueryMode == QUERY_MODE_MAILTO) {
				return CONTACTS_SUMMARY_PROJECTION_FROM_EMAIL;
			} else if (mQueryMode == QUERY_MODE_TEL) {
				return PHONES_PROJECTION;
			}
			break;
		}
		}

		// Default to normal aggregate projection
		return CONTACTS_SUMMARY_PROJECTION;
	}

	private Bitmap loadContactPhoto(long contactId,
			BitmapFactory.Options options) {
		Cursor cursor = null;
		Bitmap bm = null;
		try {
			Uri contactUri = ContentUris.withAppendedId(Contacts.CONTENT_URI,
					contactId);
			Uri photoUri = Uri.withAppendedPath(contactUri,
					Contacts.Photo.CONTENT_DIRECTORY);
			cursor = getContentResolver().query(photoUri,
					new String[] { Photo.PHOTO }, null, null, null);
			if (cursor != null && cursor.moveToFirst()) {
				bm = ContactsUtils.loadContactPhoto(cursor, 0, options);
			}
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
		return bm;
	}

	/**
	 * Return the selection arguments for a default query based on
	 * {@link #mDisplayAll} and {@link #mDisplayOnlyPhones} flags.
	 */
	@SuppressWarnings( { "JavadocReference" })
	private String getContactSelection() {
		if (mDisplayOnlyPhones) {
			return CLAUSE_ONLY_VISIBLE + "=1" + " AND " + CLAUSE_ONLY_PHONES;
		} else {
			return CLAUSE_ONLY_VISIBLE + "=1" + " AND " + CLAUSE_ONLY_PHONES;
		}
	}

	private Uri getContactFilterUri(String filter) {
		if (!TextUtils.isEmpty(filter)) {
			return Uri.withAppendedPath(Contacts.CONTENT_FILTER_URI, Uri
					.encode(filter));
		} else {
			return Contacts.CONTENT_URI;
		}
	}

	private Uri getPeopleFilterUri(String filter) {
		if (!TextUtils.isEmpty(filter)) {
			return Uri.withAppendedPath(People.CONTENT_FILTER_URI, Uri
					.encode(filter));
		} else {
			return People.CONTENT_URI;
		}
	}

	private Uri getJoinSuggestionsUri(String filter) {
		Builder builder = Contacts.CONTENT_URI.buildUpon();
		builder.appendEncodedPath(String.valueOf(mQueryAggregateId));
		builder.appendEncodedPath(AggregationSuggestions.CONTENT_DIRECTORY);
		if (!TextUtils.isEmpty(filter)) {
			builder.appendEncodedPath(Uri.encode(filter));
		}
		builder.appendQueryParameter("limit", String.valueOf(MAX_SUGGESTIONS));
		return builder.build();
	}

	/**
	 * 排序的方式
	 * 
	 * @param projectionType
	 * @return
	 */
	private static String getSortOrder(String[] projectionType) {
		/*
		 * if (Locale.getDefault().equals(Locale.JAPAN) && projectionType ==
		 * AGGREGATES_PRIMARY_PHONE_PROJECTION) { return SORT_STRING + " ASC"; }
		 * else { return NAME_COLUMN + " COLLATE LOCALIZED ASC"; }
		 */
		if (Constants.SDK_VERSION < Constants.SDK_VERSION_8) {
			return NAME_COLUMN + " COLLATE LOCALIZED ASC";
		} else {
			return Constants.SORT_ORDER;
		}
	}

	void startQuery() {
		mAdapter.setLoading(true);

		// Cancel any pending queries
		mQueryHandler.cancelOperation(QUERY_TOKEN);
		mQueryHandler.setLoadingJoinSuggestions(false);

		String[] projection = getProjectionForQuery();
		// String callingPackage = getCallingPackage();
		// uri
		Uri uri = getUriToQuery();
		// if (!TextUtils.isEmpty(callingPackage)) {
		// uri = uri.buildUpon().appendQueryParameter(
		// ContactsContract.AUTHORITY, callingPackage).build();
		// }
		// Kick off the new query
		switch (mMode) {
		case MODE_GROUP:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection,
					getContactSelection(), null, getSortOrder(projection));
			break;

		case MODE_DEFAULT:
		case MODE_PICK_OR_CREATE_CONTACT:
		case MODE_INSERT_OR_EDIT_CONTACT:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection,
					getContactSelection(), null, getSortOrder(projection));
			break;
		case MODE_EMAIL:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, getSortOrder(projection));
			break;
		case MODE_PICK_CONTACT:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection,
					getContactSelection(), null,
					ContactsContract.Contacts.TIMES_CONTACTED + ", "
							+ ContactsContract.Contacts.STARRED + ", "
							+ ContactsContract.Contacts.DISPLAY_NAME + " DESC");
			break;
		case MODE_PICK_EMAIL:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, ContactsContract.Contacts.TIMES_CONTACTED + ", "
							+ ContactsContract.Contacts.STARRED + ", "
							+ ContactsContract.Contacts.DISPLAY_NAME + " DESC");
		case MODE_LEGACY_PICK_PERSON:
		case MODE_LEGACY_PICK_OR_CREATE_PERSON:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, getSortOrder(projection));
			break;

		case MODE_QUERY: {
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, getSortOrder(projection));
			break;
		}

		case MODE_QUERY_PICK_TO_VIEW: {
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, getSortOrder(projection));
			break;
		}

		case MODE_STARRED:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection,
					Contacts.STARRED + "=1", null, getSortOrder(projection));
			break;

		case MODE_FREQUENT:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection,
					Contacts.TIMES_CONTACTED + " > 0", null,
					getSortOrder(projection));
			break;

		case MODE_STREQUENT:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, null);
			break;

		case MODE_PICK_PHONE:
		case MODE_LEGACY_PICK_PHONE:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, getSortOrder(projection));
			break;

		case MODE_PICK_POSTAL:
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, getSortOrder(projection));
			break;

		case MODE_JOIN_CONTACT:
			mQueryHandler.setLoadingJoinSuggestions(true);
			mQueryHandler.startQuery(QUERY_TOKEN, null, uri, projection, null,
					null, null);
			break;
		}
	}

	/**
	 * Called from a background thread to do the filter and return the resulting
	 * cursor.
	 * 
	 * @param filter
	 *            the text that was entered to filter on
	 * @return a cursor with the results of the filter
	 */
	Cursor doFilter(String filter) {
		final ContentResolver resolver = getContentResolver();

		String[] projection = getProjectionForQuery();

		switch (mMode) {
		case MODE_DEFAULT:
		case MODE_PICK_CONTACT:
		case MODE_PICK_OR_CREATE_CONTACT:
		case MODE_INSERT_OR_EDIT_CONTACT: {
			return resolver.query(getContactFilterUri(filter), projection,
					getContactSelection(), null, getSortOrder(projection));
		}

		case MODE_LEGACY_PICK_PERSON:
		case MODE_LEGACY_PICK_OR_CREATE_PERSON: {
			return resolver.query(getPeopleFilterUri(filter), projection, null,
					null, getSortOrder(projection));
		}

		case MODE_STARRED: {
			return resolver.query(getContactFilterUri(filter), projection,
					Contacts.STARRED + "=1", null, getSortOrder(projection));
		}

		case MODE_FREQUENT: {
			return resolver.query(getContactFilterUri(filter), projection,
					Contacts.TIMES_CONTACTED + " > 0", null,
					Contacts.TIMES_CONTACTED + " DESC, "
							+ getSortOrder(projection));
		}

		case MODE_STREQUENT: {
			Uri uri;
			if (!TextUtils.isEmpty(filter)) {
				uri = Uri.withAppendedPath(
						Contacts.CONTENT_STREQUENT_FILTER_URI, Uri
								.encode(filter));
			} else {
				uri = Contacts.CONTENT_STREQUENT_URI;
			}
			return resolver.query(uri, projection, null, null, null);
		}

		case MODE_PICK_PHONE: {
			Uri uri = getUriToQuery();
			if (!TextUtils.isEmpty(filter)) {
				uri = Uri.withAppendedPath(Phone.CONTENT_FILTER_URI, Uri
						.encode(filter));
			}
			return resolver.query(uri, projection, null, null,
					getSortOrder(projection));
		}

		case MODE_LEGACY_PICK_PHONE: {
			// TODO: Support filtering here (bug 2092503)
			break;
		}

		case MODE_JOIN_CONTACT: {

			// We are on a background thread. Run queries one after the other
			// synchronously
			Cursor cursor = resolver.query(getJoinSuggestionsUri(filter),
					projection, null, null, null);
			mAdapter.setSuggestionsCursor(cursor);
			mJoinModeShowAllContacts = false;
			return resolver.query(getContactFilterUri(filter), projection,
					Contacts._ID + " != " + mQueryAggregateId + " AND "
							+ CLAUSE_ONLY_VISIBLE, null,
					getSortOrder(projection));
		}
		}
		throw new UnsupportedOperationException(
				"filtering not allowed in mode " + mMode);
	}

	private Cursor getShowAllContactsLabelCursor(String[] projection) {
		MatrixCursor matrixCursor = new MatrixCursor(projection);
		Object[] row = new Object[projection.length];
		// The only columns we care about is the id
		row[SUMMARY_ID_COLUMN_INDEX] = JOIN_MODE_SHOW_ALL_CONTACTS_ID;
		matrixCursor.addRow(row);
		return matrixCursor;
	}

	/**
	 * Calls the currently selected list item.
	 * 
	 * @return true if the call was initiated, false otherwise
	 */
	boolean callSelection() {
		ListView list = getListView();
		if (list.hasFocus()) {
			Cursor cursor = (Cursor) list.getSelectedItem();
			return callContact(cursor);
		}
		return false;
	}

	boolean callContact(Cursor cursor) {
		return callOrSmsContact(cursor, false /* call */);
	}

	boolean smsContact(Cursor cursor) {
		return callOrSmsContact(cursor, true /* sms */);
	}

	/**
	 * Calls the contact which the cursor is point to.
	 * 
	 * @return true if the call was initiated, false otherwise
	 */
	boolean callOrSmsContact(Cursor cursor, boolean sendSms) {
		if (cursor != null) {
			boolean hasPhone = cursor.getInt(SUMMARY_HAS_PHONE_COLUMN_INDEX) != 0;
			if (!hasPhone) {
				// There is no phone number.
				signalError();
				return false;
			}

			String phone = null;
			Cursor phonesCursor = null;
			phonesCursor = queryPhoneNumbers(cursor
					.getLong(SUMMARY_ID_COLUMN_INDEX));
			if (phonesCursor == null || phonesCursor.getCount() == 0) {
				// No valid number
				signalError();
				return false;
			} else if (phonesCursor.getCount() == 1) {
				// only one number, call it.
				phone = phonesCursor.getString(phonesCursor
						.getColumnIndex(Phone.NUMBER));

			} else {
				phonesCursor.moveToPosition(-1);
				while (phonesCursor.moveToNext()) {
					if (phonesCursor.getInt(phonesCursor
							.getColumnIndex(Phone.IS_SUPER_PRIMARY)) != 0) {
						// Found super primary, call it.
						phone = phonesCursor.getString(phonesCursor
								.getColumnIndex(Phone.NUMBER));
						break;
					}
				}
			}

			if (phone == null) {
				// // Display dialog to choose a number to call.
				// PhoneDisambigDialog phoneDialog = new PhoneDisambigDialog(
				// this, phonesCursor, sendSms, null);
				// phoneDialog.show();
			} else {
				if (sendSms) {
					ContactsUtils.initiateSms(this, phone);
				} else {
					ContactsUtils.initiateCall(this, phone);
				}
			}
			return true;
		}

		return false;
	}

	private Cursor queryContactMes(long contactId) {
		Cursor c = null;
		Uri baseUri = ContentUris.withAppendedId(Contacts.CONTENT_URI,
				contactId);
		Uri dataUri = Uri.withAppendedPath(baseUri,
				Contacts.Data.CONTENT_DIRECTORY);

		c = getContentResolver().query(dataUri, null, null, null, null);

		if (c != null && c.moveToFirst()) {
			return c;
		}
		return null;
	}

	private Cursor queryPhoneNumbers(long contactId) {
		Cursor c = null;
		Uri baseUri = ContentUris.withAppendedId(Contacts.CONTENT_URI,
				contactId);
		Uri dataUri = Uri.withAppendedPath(baseUri,
				Contacts.Data.CONTENT_DIRECTORY);

		c = getContentResolver()
				.query(
						dataUri,
						new String[] { Phone._ID, Phone.NUMBER,
								Phone.IS_SUPER_PRIMARY }, Data.MIMETYPE + "=?",
						new String[] { Phone.CONTENT_ITEM_TYPE }, null);

		if (c != null && c.moveToFirst()) {
			return c;
		}
		return null;
	}

	/**
	 * Signal an error to the user.
	 */
	void signalError() {
		// TODO play an error beep or something...
	}

	Cursor getItemForView(View view) {
		ListView listView = getListView();
		int index = listView.getPositionForView(view);
		if (index < 0) {
			return null;
		}
		return (Cursor) listView.getAdapter().getItem(index);
	}

	// ** this class to get the date
	private static class QueryHandler extends AsyncQueryHandler {
		protected final WeakReference<ContactsListActivity> mActivity;
		protected boolean mLoadingJoinSuggestions = false;

		public QueryHandler(Context context) {
			super(context.getContentResolver());
			mActivity = new WeakReference<ContactsListActivity>(
					(ContactsListActivity) context);
		}

		public void setLoadingJoinSuggestions(boolean flag) {
			mLoadingJoinSuggestions = flag;
		}

		@Override
		// ** onQueryComplete is one of QueryHander's method
		protected void onQueryComplete(int token, Object cookie, Cursor cursor) {

			final ContactsListActivity activity = mActivity.get();
			if (activity != null && !activity.isFinishing()) {

				// Whenever we get a suggestions cursor, we need to immediately
				// kick off
				// another query for the complete list of contacts
				// 初始化

				int count = cursor.getCount();
				personMap = new HashMap<Integer, MyPerson>();
				positions = new ArrayList<MyPerson>();

				for (int i = 1; i <= count; i++) {
					personMap.put(i, new MyPerson());
					// positions.add(-1);
				}
				if (mMode == MODE_FREQUENT || mMode == MODE_DEFAULT) {
					positions.clear();
					positions.addAll(tempPositions);
				}

				if (cursor != null && mLoadingJoinSuggestions) {
					mLoadingJoinSuggestions = false;

					if (cursor.getCount() > 0) {
						activity.mAdapter.setSuggestionsCursor(cursor);
					} else {
						cursor.close();
						activity.mAdapter.setSuggestionsCursor(null);
					}

					if (activity.mAdapter.mSuggestionsCursorCount == 0
							|| !activity.mJoinModeShowAllContacts) {

						Uri uri = activity
								.getContactFilterUri(activity.mQueryData);
						String[] pro = CONTACTS_SUMMARY_PROJECTION;
						String clause = Contacts._ID + " != "
								+ activity.mQueryAggregateId + " AND "
								+ CLAUSE_ONLY_VISIBLE;
						startQuery(QUERY_TOKEN, null, uri, pro, clause, null,
								getSortOrder(CONTACTS_SUMMARY_PROJECTION));
						return;
					}

					cursor = activity
							.getShowAllContactsLabelCursor(CONTACTS_SUMMARY_PROJECTION);
				}

				activity.mAdapter.setLoading(false);
				activity.getListView().clearTextFilter();
				activity.mAdapter.changeCursor(cursor);

				// Now that the cursor is populated again, it's possible to
				// restore the list state
				if (activity.mListState != null) {
					activity.getListView().onRestoreInstanceState(
							activity.mListState);
					if (activity.mListHasFocus) {
						activity.getListView().requestFocus();
					}
					activity.mListHasFocus = false;
					activity.mListState = null;
				}

			} else {
				cursor.close();
			}
		}
	}

	final static class ContactListItemCache {
		public View header;
		public TextView headerText;
		public View divider, verDivider;
		public TextView nameView;
		public ImageView callButton;
		public CharArrayBuffer nameBuffer = new CharArrayBuffer(128);
		public TextView labelView;
		public CharArrayBuffer labelBuffer = new CharArrayBuffer(128);
		public TextView idView;
		public CharArrayBuffer dataBuffer = new CharArrayBuffer(128);
		public ImageView presenceView;
		public ImageView nonQuickContactPhotoView;
		public QuickContactBadge photoView;
		public CheckBox checkBox;

	}

	final static class PhotoInfo {
		public int position;
		public long photoId;

		public PhotoInfo(int position, long photoId) {
			this.position = position;
			this.photoId = photoId;
		}

		public QuickContactBadge photoView;
	}

	private final class ContactItemListAdapter extends ResourceCursorAdapter
			implements SectionIndexer, OnScrollListener {
		private SectionIndexer mIndexer;
		private String mAlphabet;
		private boolean mLoading = true;
		private CharSequence mUnknownNameText;
		private boolean mDisplayPhotos = true;
		private boolean mDisplayCallButton = true;
		private boolean mDisplayAdditionalData = true;
		private HashMap<Long, SoftReference<Bitmap>> mBitmapCache = null;
		private int mFrequentSeparatorPos = ListView.INVALID_POSITION;
		private boolean mDisplaySectionHeaders = false;
		private int[] mSectionPositions;
		private Cursor mSuggestionsCursor;
		private int mSuggestionsCursorCount;
		private HashSet<ImageView> mItemsMissingImages = null;
		private ImageFetchHandler mHandler;
		private ImageDbFetcher mImageFetcher;
		private static final int FETCH_IMAGE_MSG = 1;

		public ContactItemListAdapter(Context context) {
			super(context, R.layout.contacts_list_item, null, false);

			mHandler = new ImageFetchHandler();

			mAlphabet = context.getString(R.string.fast_scroll_alphabet);

			mUnknownNameText = context.getText(android.R.string.unknownName);

			switch (mMode) {
			case MODE_LEGACY_PICK_POSTAL:
			case MODE_PICK_POSTAL:
				mDisplaySectionHeaders = false;
				break;
			case MODE_LEGACY_PICK_PHONE:
			case MODE_PICK_PHONE:
				mDisplaySectionHeaders = false;
				break;
			default:
				break;
			}

			// Do not display the second line of text if in a specific SEARCH
			// query mode, usually for
			// matching a specific E-mail or phone number. Any contact details
			// shown would be identical, and columns might not even be present
			// in the returned cursor.
			if (mQueryMode != QUERY_MODE_NONE) {
				mDisplayAdditionalData = false;
			}

			if ((mMode & MODE_MASK_NO_DATA) == MODE_MASK_NO_DATA) {
				mDisplayAdditionalData = false;
			}

			if ((mMode & MODE_MASK_SHOW_CALL_BUTTON) == MODE_MASK_SHOW_CALL_BUTTON) {
				mDisplayCallButton = true;
			}

			/*
			 * if ((mMode & MODE_MASK_SHOW_PHOTOS) == MODE_MASK_SHOW_PHOTOS) {
			 * mDisplayPhotos = true;
			 * setViewResource(R.layout.contacts_list_item_photo); mBitmapCache
			 * = new HashMap<Long, SoftReference<Bitmap>>(); mItemsMissingImages
			 * = new HashSet<ImageView>(); }
			 */

			if (mMode == MODE_STREQUENT || mMode == MODE_FREQUENT) {
				mDisplaySectionHeaders = false;
			}
		}

		private class ImageFetchHandler extends Handler {

			@Override
			public void handleMessage(Message message) {
				if (ContactsListActivity.this.isFinishing()) {
					return;
				}
				switch (message.what) {
				case FETCH_IMAGE_MSG: {
					final ImageView imageView = (ImageView) message.obj;
					if (imageView == null) {
						break;
					}

					final PhotoInfo info = (PhotoInfo) imageView.getTag();
					if (info == null) {
						break;
					}

					final long photoId = info.photoId;
					if (photoId == 0) {
						break;
					}

					SoftReference<Bitmap> photoRef = mBitmapCache.get(photoId);
					if (photoRef == null) {
						break;
					}
					Bitmap photo = photoRef.get();
					if (photo == null) {
						mBitmapCache.remove(photoId);
						break;
					}

					// Make sure the photoId on this image view has not changed
					// while we were loading the image.
					synchronized (imageView) {
						final PhotoInfo updatedInfo = (PhotoInfo) imageView
								.getTag();
						long currentPhotoId = updatedInfo.photoId;
						if (currentPhotoId == photoId) {
							imageView.setImageBitmap(photo);
							mItemsMissingImages.remove(imageView);
						}
					}
					break;
				}
				}
			}

			public void clearImageFecthing() {
				removeMessages(FETCH_IMAGE_MSG);
			}
		}

		// to get the Photo
		private class ImageDbFetcher implements Runnable {
			long mPhotoId;
			private ImageView mImageView;

			public ImageDbFetcher(long photoId, ImageView imageView) {
				this.mPhotoId = photoId;
				this.mImageView = imageView;
			}

			public void run() {
				if (ContactsListActivity.this.isFinishing()) {
					return;
				}

				if (Thread.currentThread().interrupted()) {
					// shutdown has been called.
					return;
				}
				Bitmap photo = null;
				try {
					photo = AirenaoUtills.loadContactPhoto(getBaseContext(),
							mPhotoId, null);
				} catch (OutOfMemoryError e) {
					// Not enough memory for the photo, do nothing.
				}

				if (photo == null) {
					return;
				}

				mBitmapCache.put(mPhotoId, new SoftReference<Bitmap>(photo));

				if (Thread.currentThread().interrupted()) {
					// shutdown has been called.
					return;
				}

				// Update must happen on UI thread
				Message msg = new Message();
				msg.what = FETCH_IMAGE_MSG;
				msg.obj = mImageView;
				mHandler.sendMessage(msg);
			}
		}

		public void setSuggestionsCursor(Cursor cursor) {
			if (mSuggestionsCursor != null) {
				mSuggestionsCursor.close();
			}
			mSuggestionsCursor = cursor;
			mSuggestionsCursorCount = cursor == null ? 0 : cursor.getCount();
		}

		private SectionIndexer getNewIndexer(Cursor cursor) {
			return new MyAlphabetIndexe(cursor, SUMMARY_NAME_COLUMN_INDEX,
					mAlphabet);
		}

		/**
		 * Callback on the UI thread when the content observer on the backing
		 * cursor fires. Instead of calling requery we need to do an async query
		 * so that the requery doesn't block the UI thread for a long time.
		 */
		@Override
		protected void onContentChanged() {
			CharSequence constraint = getListView().getTextFilter();
			if (!TextUtils.isEmpty(constraint)) {
				// Reset the filter state then start an async filter operation
				Filter filter = getFilter();
				filter.filter(constraint);
			} else {
				// Start an async query
				startQuery();
			}
		}

		public void setLoading(boolean loading) {
			mLoading = loading;
		}

		@Override
		public boolean isEmpty() {
			if ((mMode & MODE_MASK_CREATE_NEW) == MODE_MASK_CREATE_NEW) {
				// This mode mask adds a header and we always want it to show
				// up, even
				// if the list is empty, so always claim the list is not empty.
				return false;
			} else {
				if (mLoading) {
					// We don't want the empty state to show when loading.
					return false;
				} else {
					return super.isEmpty();
				}
			}
		}

		@Override
		public int getItemViewType(int position) {
			if (position == 0
					&& (mMode & MODE_MASK_SHOW_NUMBER_OF_CONTACTS) != 0) {
				return IGNORE_ITEM_VIEW_TYPE;
			}
			if (isShowAllContactsItemPosition(position)) {
				return IGNORE_ITEM_VIEW_TYPE;
			}
			if (getSeparatorId(position) != 0) {
				// We don't want the separator view to be recycled.
				return IGNORE_ITEM_VIEW_TYPE;
			}
			return super.getItemViewType(position);
		}

		@Override
		// ** getView has one action of bindSectionHeader,this method is belong
		// to ContactItemListAdapter
		public View getView(final int position, View convertView,
				ViewGroup parent) {
			// handle the total contacts item
			if (position == 0
					&& (mMode & MODE_MASK_SHOW_NUMBER_OF_CONTACTS) != 0) {
				return new ImageView(ContactsListActivity.this);
			}
			// inflater the layout of ContactItems
			if (isShowAllContactsItemPosition(position)) {
				LayoutInflater inflater = (LayoutInflater) getBaseContext()
						.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				return inflater.inflate(R.layout.contacts_list_show_all_item,
						parent, false);
			}

			// Handle the separator specially including the favorite and
			// frequent
			int separatorId = getSeparatorId(position);
			if (separatorId != 0) {
				LayoutInflater inflater = (LayoutInflater) getBaseContext()
						.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				TextView view = (TextView) inflater.inflate(
						R.layout.list_separator, parent, false);
				view.setText(getString(separatorId));
				return view;
			}

			boolean showingSuggestion;
			Cursor cursor;
			if (mSuggestionsCursorCount != 0
					&& position < mSuggestionsCursorCount + 2) {
				showingSuggestion = true;
				cursor = mSuggestionsCursor;
			} else {
				showingSuggestion = false;
				// in the Adapter class you can get the cursor
				cursor = getCursor();
			}
			// get the realPosition of everyitem
			int realPosition = getRealPosition(position);
			if (!cursor.moveToPosition(realPosition)) {
				throw new IllegalStateException(
						"couldn't move cursor to position " + position);
			}

			View v;
			if (convertView == null) {
				v = newView(getBaseContext(), cursor, parent);
			} else {
				v = convertView;
			}

			// to bindView
			bindView(v, getBaseContext(), cursor);

			// to bind the SectionHeader
			bindSectionHeader(v, realPosition, mDisplaySectionHeaders
					&& !showingSuggestion);
			return v;
		}

		private View getTotalContactCountView(ViewGroup parent) {
			final LayoutInflater inflater = getLayoutInflater();
			TextView totalContacts = (TextView) inflater.inflate(
					R.layout.total_contacts, parent, false);
			totalContacts.setVisibility(View.GONE);
			String text;
			int count = getRealCount();

			if (mMode == MODE_QUERY
					|| !TextUtils.isEmpty(getListView().getTextFilter())) {
				text = getQuantityText(count,
						R.string.listFoundAllContactsZero,
						R.plurals.listFoundAllContacts);
			} else {
				/*
				 * if (mDisplayOnlyPhones) { text = getQuantityText(count,
				 * R.string.listTotalPhoneContactsZero,
				 * R.plurals.listTotalPhoneContacts); } else { text =
				 * getQuantityText(count, R.string.listTotalAllContactsZero,
				 * R.plurals.listTotalAllContacts); }
				 */
			}
			totalContacts.setText("dd");
			return totalContacts;
		}

		// TODO: fix PluralRules to handle zero correctly and use
		// Resources.getQuantityText directly
		private String getQuantityText(int count, int zeroResourceId,
				int pluralResourceId) {
			if (count == 0) {
				return getString(zeroResourceId);
			} else {
				String format = getResources().getQuantityText(
						pluralResourceId, count).toString();
				return String.format(format, count);
			}
		}

		private boolean isShowAllContactsItemPosition(int position) {
			return mMode == MODE_JOIN_CONTACT && mJoinModeShowAllContacts
					&& mSuggestionsCursorCount != 0
					&& position == mSuggestionsCursorCount + 2;
		}

		private int getSeparatorId(int position) {
			int separatorId = 0;
			if (position == mFrequentSeparatorPos) {
				separatorId = R.string.favoritesFrquentSeparator;
			}
			if (mSuggestionsCursorCount != 0) {
				if (position == 0) {
					separatorId = R.string.separatorJoinAggregateSuggestions;
				} else if (position == mSuggestionsCursorCount + 1) {
					separatorId = R.string.separatorJoinAggregateAll;
				}
			}
			return separatorId;
		}

		@Override
		// the View contains every item we called Tag
		public View newView(Context context, Cursor cursor, ViewGroup parent) {
			final View view = super.newView(context, cursor, parent);

			final ContactListItemCache cache = new ContactListItemCache();
			cache.header = view.findViewById(R.id.header);
			cache.headerText = (TextView) view.findViewById(R.id.header_text);
			// cache.divider = view.findViewById(R.id.list_divider);
			cache.verDivider = view.findViewById(R.id.divider);
			cache.nameView = (TextView) view.findViewById(R.id.name);
			// cache.callButton = (ImageView)
			// view.findViewById(R.id.call_button);
			if (cache.callButton != null) {
				cache.callButton.setOnClickListener(ContactsListActivity.this);
			}

			cache.labelView = (TextView) view.findViewById(R.id.label);
			cache.idView = (TextView) view.findViewById(R.id.data);
			// cache.presenceView = (ImageView)
			// view.findViewById(R.id.presence);

			// checkBox
			cache.checkBox = (CheckBox) view.findViewById(R.id.cb);

			view.setTag(cache);

			return view;
		}

		@Override
		// to bind view of every item
		public void bindView(View view, Context context, Cursor cursor) {
			final ContactListItemCache cache = (ContactListItemCache) view
					.getTag();

			TextView dataView = cache.idView;
			TextView labelView = cache.labelView;
			int typeColumnIndex;
			int dataColumnIndex;
			int labelColumnIndex;
			int defaultType;
			int nameColumnIndex;
			boolean displayAdditionalData = mDisplayAdditionalData;
			final int position = cursor.getPosition();
			switch (mMode) {
			case MODE_PICK_PHONE:
			case MODE_LEGACY_PICK_PHONE: {
				nameColumnIndex = PHONE_DISPLAY_NAME_COLUMN_INDEX;
				dataColumnIndex = PHONE_NUMBER_COLUMN_INDEX;
				typeColumnIndex = PHONE_TYPE_COLUMN_INDEX;
				labelColumnIndex = PHONE_LABEL_COLUMN_INDEX;
				defaultType = Phone.TYPE_HOME;
				break;
			}
			case MODE_PICK_POSTAL:
			case MODE_LEGACY_PICK_POSTAL: {
				nameColumnIndex = POSTAL_DISPLAY_NAME_COLUMN_INDEX;
				dataColumnIndex = POSTAL_ADDRESS_COLUMN_INDEX;
				typeColumnIndex = POSTAL_TYPE_COLUMN_INDEX;
				labelColumnIndex = POSTAL_LABEL_COLUMN_INDEX;
				defaultType = StructuredPostal.TYPE_HOME;
				break;
			}
			default: {
				nameColumnIndex = SUMMARY_NAME_COLUMN_INDEX;
				dataColumnIndex = -1;
				typeColumnIndex = -1;
				labelColumnIndex = -1;
				defaultType = Phone.TYPE_HOME;
				// displayAdditionalData = false;
			}
			}

			// Set the name
			if (mMode == MODE_PICK_CONTACT || mMode == MODE_PICK_EMAIL
					|| mMode == MODE_FREQUENT) {
				int columnIndex = cursor.getColumnIndex(Contacts.DISPLAY_NAME);
				cursor.copyStringToBuffer(columnIndex, cache.nameBuffer);
				int size = cache.nameBuffer.sizeCopied;
				if (size != 0) {
					cache.nameView.setText(cache.nameBuffer.data, 0, size);
				} else {
					cache.nameView.setText(mUnknownNameText.toString());
				}
				// 设置ID
				cache.idView.setText(cursor.getString(cursor
						.getColumnIndex(Contacts._ID)));
			} else {
				cursor.copyStringToBuffer(nameColumnIndex, cache.nameBuffer);
				int size = cache.nameBuffer.sizeCopied;
				boolean isTrueLocal = false;
				if (size != 0) {
					cache.nameView.setText(cache.nameBuffer.data, 0, size);
				} else {
					cache.nameView.setText(mUnknownNameText.toString());
				}
				// 设置ID
				cache.idView.setText(cursor.getString(cursor
						.getColumnIndex(Contacts._ID)));
			}

			if (mMode == MODE_FREQUENT || mMode == MODE_DEFAULT) {
				if (positions.size() > 0) {

					for (MyPerson person : positions) {
						bindPersonId = person.getId();
						bindPersonName = person.getName();
						bindPersonPhoneNumber = person.getPhoneNumber();

						if (bindPersonId.equals(cursor.getString(cursor
								.getColumnIndex(Contacts._ID)))) {
							personMap.get(cursor.getPosition() + 1).setId(
									bindPersonId);

							personMap.get(cursor.getPosition() + 1)
									.setPhoneNumber(bindPersonPhoneNumber);

							personMap.get(cursor.getPosition() + 1).setChecked(
									true);
							MyPerson myPerson = personMap.get(cursor
									.getPosition() + 1);

							break;
						}
					}

				}

			}

			// Set the number and first get the number
			String myFinalNum;
			myFinalNum = getMyFinalNumber(cursor);
			if (personMap != null) {
				if (phoneNumbers != null) {
					personMap.get(position + 1).setNumbers(phoneNumbers);
				}
			}
			if (personMap.get(position + 1).getPhoneNumber() != null) {

				cache.labelView.setText(personMap.get(position + 1)
						.getPhoneNumber());

			} else {

				cache.labelView.setText(myFinalNum);
			}

			// 设置已发送的联系人的checkbox
			if (transPersons.size() > 0) {
				for (int i = 0; i < transPersons.size(); i++) {
					bindPerson = transPersons.get(i);
					if (bindPerson.getName().equals(
							cache.nameView.getText().toString())) {
						MyPerson Person = personMap
								.get(cursor.getPosition() + 1);
						if (Person != null) {
							Person.setChecked(true);
							Person = new MyPerson(cache.idView.getText()
									.toString(), cache.nameView.getText()
									.toString(), cache.labelView.getText()
									.toString());
							positions.add(Person);

							transPersons.remove(i);
							Message msg = new Message();
							msg.what = 0;
							Bundle bundle = new Bundle();
							bundle.putString("count", positions.size() + "");
							msg.setData(bundle);
							myHandler.sendMessage(msg);
						}
						break;
					}
				}

			}

			// 设置checkbox
			MyPerson person = personMap.get(cursor.getPosition() + 1);
			if (cache.checkBox != null && person != null) {

				if (person.isChecked()) {
					cache.checkBox.setChecked(true);

				} else {

					cache.checkBox.setChecked(false);
				}

			}

			// Make the call button visible if requested.
			if (false) {
				int pos = cursor.getPosition();
				/*
				 * cache.callButton.setVisibility(View.VISIBLE);
				 * cache.callButton.setTag(pos);
				 */
			} else {
				// cache.callButton.setVisibility(View.INVISIBLE);
			}
			if (mMode != -1) {
				if (cursor.getInt(SUMMARY_HAS_PHONE_COLUMN_INDEX) == 0) {
					// cache.callButton.setVisibility(View.INVISIBLE);
					cache.verDivider.setVisibility(View.INVISIBLE);
				} else {
					// cache.callButton.setVisibility(View.VISIBLE);
					cache.verDivider.setVisibility(View.VISIBLE);
				}
			}

			if (false) {// mDisplayPhotos
				boolean useQuickContact = (mMode & MODE_MASK_DISABLE_QUIKCCONTACT) == 0;

				long photoId = 0;
				if (!cursor.isNull(SUMMARY_PHOTO_ID_COLUMN_INDEX)) {
					photoId = cursor.getLong(SUMMARY_PHOTO_ID_COLUMN_INDEX);
				}

				ImageView viewToUse;
				if (useQuickContact) {
					viewToUse = cache.photoView;
					// Build soft lookup reference
					final long contactId = cursor
							.getLong(SUMMARY_ID_COLUMN_INDEX);
					final String lookupKey = cursor
							.getString(SUMMARY_LOOKUP_KEY);
					// cache.photoView.assignContactUri(Contacts.getLookupUri(
					// contactId, lookupKey));
					// cache.photoView.setVisibility(View.VISIBLE);
					// cache.nonQuickContactPhotoView
					// .setVisibility(View.INVISIBLE);
				} else {
					viewToUse = cache.nonQuickContactPhotoView;
					cache.photoView.setVisibility(View.INVISIBLE);
					cache.nonQuickContactPhotoView.setVisibility(View.VISIBLE);
				}

				// viewToUse.setTag(new PhotoInfo(position, photoId));

				if (photoId == 0) {
					// viewToUse.setImageResource(R.drawable.source_contacts);
				} else {

					Bitmap photo = null;

					// Look for the cached bitmap
					SoftReference<Bitmap> ref = mBitmapCache.get(photoId);
					if (ref != null) {
						photo = ref.get();
						if (photo == null) {
							mBitmapCache.remove(photoId);
						}
					}

					// Bind the photo, or use the fallback no photo resource
					if (photo != null) {
						viewToUse.setImageBitmap(photo);
					} else {
						// Cache miss
						viewToUse.setImageResource(R.drawable.source_contacts);

						// Add it to a set of images that are populated
						// asynchronously.
						mItemsMissingImages.add(viewToUse);

						if (mScrollState != OnScrollListener.SCROLL_STATE_FLING) {

							// Scrolling is idle or slow, go get the image right
							// now.
							sendFetchImageMessage(viewToUse);
						}
					}
				}
			}

			/*
			 * ImageView presenceView = cache.presenceView; if ((mMode &
			 * MODE_MASK_NO_PRESENCE) == 0) { // Set the proper icon (star or
			 * presence or nothing) int serverStatus; if
			 * (!cursor.isNull(SUMMARY_PRESENCE_STATUS_COLUMN_INDEX)) {
			 * serverStatus = cursor
			 * .getInt(SUMMARY_PRESENCE_STATUS_COLUMN_INDEX);
			 * presenceView.setImageResource(Presence
			 * .getPresenceIconResourceId(serverStatus));
			 * presenceView.setVisibility(View.VISIBLE); } else {
			 * presenceView.setVisibility(View.GONE); } } else {
			 * presenceView.setVisibility(View.GONE); }
			 */

			if (!displayAdditionalData) {
				cache.idView.setVisibility(View.GONE);
				cache.labelView.setVisibility(View.VISIBLE);
				return;
			}

			// Set the data.
			/*
			 * cursor.copyStringToBuffer(dataColumnIndex, cache.dataBuffer);
			 * 
			 * size = cache.dataBuffer.sizeCopied; if (size != 0) {
			 * dataView.setText(cache.dataBuffer.data, 0, size);
			 * dataView.setVisibility(View.VISIBLE); } else {
			 * dataView.setVisibility(View.GONE); }
			 * 
			 * // Set the label. if (!cursor.isNull(typeColumnIndex)) {
			 * labelView.setVisibility(View.VISIBLE);
			 * 
			 * final int type = cursor.getInt(typeColumnIndex); final String
			 * label = cursor.getString(labelColumnIndex);
			 * 
			 * if (PhoneTell.sdkVersion < 5) {
			 * labelView.setText(StructuredPostal.getTypeLabel(
			 * context.getResources(), type, label).toString()); } else {
			 * labelView.setText(Phone.getTypeLabel( context.getResources(),
			 * type, label).toString()); } } else { // There is no label, hide
			 * the the view labelView.setVisibility(View.GONE); }
			 */
		}

		public String getMyFinalNumber(Cursor cursor) {
			phoneNumbers = new ArrayList<String>();
			String myNum = "";
			String contactId = cursor.getString(cursor
					.getColumnIndex(ContactsContract.Contacts._ID));
			if (mMode == MODE_DEFAULT || mMode == MODE_PICK_CONTACT
					|| mMode == MODE_FREQUENT) {
				String hasPhone = cursor
						.getString(cursor
								.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER));
				if (hasPhone.equals("1")) {

					// You now have the number so now query it like this

					Cursor phones = getContentResolver().query(
							ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
							null,
							ContactsContract.CommonDataKinds.Phone.CONTACT_ID
									+ " = " + contactId, null, null);

					while (phones.moveToNext()) {
						String phoneNumber = phones
								.getString(phones
										.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
						if (phoneNumber != null) {
							myNum = phoneNumber;
							if (AirenaoUtills.phoneNumberCompare(phoneNumbers,
									phoneNumber)) {
								continue;
							} else {
								phoneNumbers.add(phoneNumber);
							}
						}

						int phoneType = phones
								.getInt(phones
										.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE));

						// 1 == is primary
						String isPrimary = phones
								.getString(phones
										.getColumnIndex(ContactsContract.CommonDataKinds.Phone.IS_SUPER_PRIMARY));
						SharedPreferences msp = AirenaoUtills
								.getMySharedPreferences(ContactsListActivity.this);

						String mark = msp.getString(phoneNumber, "");
						if (Constants.IS_SUPER_PRIMARY.equals(mark)) {
							myNum = phoneNumber;
							phoneNumbers.clear();
							phoneNumbers.add(myNum);
							phones.close();
							return myNum;
						}

					}
					phones.close();
				}
			} else {
				Cursor emailCursor = getContentResolver().query(
						android.provider.Contacts.ContactMethods.CONTENT_URI,
						null, "_id=?", new String[] { contactId }, null);
				if (emailCursor.moveToNext()) {
					String email = emailCursor
							.getString(emailCursor
									.getColumnIndexOrThrow(android.provider.Contacts.ContactMethods.DATA));
					return email;
				}

			}
			return myNum;
		}

		// bindSectionHeader
		private void bindSectionHeader(View view, int position,
				boolean displaySectionHeaders) {
			final ContactListItemCache cache = (ContactListItemCache) view
					.getTag();
			if (!displaySectionHeaders) {
				cache.header.setVisibility(View.GONE);
				// cache.divider.setVisibility(View.VISIBLE);
			} else {
				final int section = getSectionForPosition(position);
				if (getPositionForSection(section) == position) {
					String title = mIndexer.getSections()[section].toString()
							.trim();
					if (!TextUtils.isEmpty(title)) {
						cache.headerText.setText(title.toString());
						cache.header.setVisibility(View.VISIBLE);
					} else {
						cache.header.setVisibility(View.GONE);
					}
				} else {
					cache.header.setVisibility(View.GONE);
				}

				// move the divider for the last item in a section
				if (getPositionForSection(section + 1) - 1 == position) {
					// cache.divider.setVisibility(View.GONE);
				} else {
					// cache.divider.setVisibility(View.VISIBLE);
				}
			}
		}

		@Override
		public void changeCursor(Cursor cursor) {

			// Get the split between starred and frequent items, if the mode is
			// strequent
			mFrequentSeparatorPos = ListView.INVALID_POSITION;
			int cursorCount = 0;
			if (cursor != null && (cursorCount = cursor.getCount()) > 0
					&& mMode == MODE_STREQUENT) {
				cursor.move(-1);
				for (int i = 0; cursor.moveToNext(); i++) {
					int starred = cursor.getInt(SUMMARY_STARRED_COLUMN_INDEX);
					if (starred == 0) {
						if (i > 0) {
							// Only add the separator when there are starred
							// items present
							mFrequentSeparatorPos = i;
						}
						break;
					}
				}
			}

			super.changeCursor(cursor);
			// Update the indexer for the fast scroll widget
			updateIndexer(cursor);

		}

		private void updateIndexer(Cursor cursor) {
			if (mIndexer == null) {
				mIndexer = getNewIndexer(cursor);
			} else {
				if (mIndexer instanceof AlphabetIndexer) {
					((AlphabetIndexer) mIndexer).setCursor(cursor);
				} else {
					mIndexer = getNewIndexer(cursor);
				}
			}

			int sectionCount = mIndexer.getSections().length;
			if (mSectionPositions == null
					|| mSectionPositions.length != sectionCount) {
				mSectionPositions = new int[sectionCount];
			}
			for (int i = 0; i < sectionCount; i++) {
				mSectionPositions[i] = ListView.INVALID_POSITION;
			}
		}

		/**
		 * Run the query on a helper thread. Beware that this code does not run
		 * on the main UI thread!
		 */
		@Override
		public Cursor runQueryOnBackgroundThread(CharSequence constraint) {
			return doFilter(constraint.toString());
		}

		public Object[] getSections() {
			if (mMode == MODE_STARRED) {
				return new String[] { " " };
			} else {
				return mIndexer.getSections();
			}
		}

		public int getPositionForSection(int sectionIndex) {
			if (mMode == MODE_STARRED) {
				return -1;
			}

			if (sectionIndex < 0 || sectionIndex >= mSectionPositions.length) {
				return -1;
			}

			if (mIndexer == null) {
				Cursor cursor = mAdapter.getCursor();
				if (cursor == null) {
					// No cursor, the section doesn't exist so just return 0
					return 0;
				}
				mIndexer = getNewIndexer(cursor);
			}

			int position = mSectionPositions[sectionIndex];
			if (position == ListView.INVALID_POSITION) {
				position = mSectionPositions[sectionIndex] = mIndexer
						.getPositionForSection(sectionIndex);
			}

			return position;
		}

		// huo de gai yuan su de mingzi shuyu nayige zimu
		public int getSectionForPosition(int position) {
			// The current implementations of SectionIndexers (specifically the
			// Japanese indexer)
			// only work in one direction: given a section they can calculate
			// the position.
			// Here we are using that existing functionality to do the reverse
			// mapping. We are
			// performing binary search in the mSectionPositions array, which
			// itself is populated
			// lazily using the "forward" mapping supported by the indexer.

			int start = 0;
			int end = mSectionPositions.length;
			while (start != end) {

				// We are making the binary search slightly asymmetrical,
				// because the
				// user is more likely to be scrolling the list from the top
				// down.
				int pivot = start + (end - start) / 4;

				int value = getPositionForSection(pivot);
				if (value <= position) {
					start = pivot + 1;
				} else {
					end = pivot;
				}
			}

			// The variable "start" cannot be 0, as long as the indexer is
			// implemented properly
			// and actually maps position = 0 to section = 0
			return start - 1;
		}

		@Override
		public boolean areAllItemsEnabled() {
			return mMode != MODE_STARRED
					&& (mMode & MODE_MASK_SHOW_NUMBER_OF_CONTACTS) == 0
					&& mSuggestionsCursorCount == 0;
		}

		@Override
		public boolean isEnabled(int position) {
			if ((mMode & MODE_MASK_SHOW_NUMBER_OF_CONTACTS) != 0) {
				if (position == 0) {
					return false;
				}
				position--;
			}

			if (mSuggestionsCursorCount > 0) {
				return position != 0 && position != mSuggestionsCursorCount + 1;
			}
			return position != mFrequentSeparatorPos;
		}

		@Override
		public int getCount() {
			// if (!mDataValid) {
			// return 0;
			// }
			int superCount = super.getCount();
			if ((mMode & MODE_MASK_SHOW_NUMBER_OF_CONTACTS) != 0
					&& superCount > 0) {
				// We don't want to count this header if it's the only thing
				// visible, so that
				// the empty text will display.
				superCount++;
			}
			if (mSuggestionsCursorCount != 0) {
				// When showing suggestions, we have 2 additional list items:
				// the "Suggestions"
				// and "All contacts" headers.
				return mSuggestionsCursorCount + superCount + 2;
			} else if (mFrequentSeparatorPos != ListView.INVALID_POSITION) {
				// When showing strequent list, we have an additional list item
				// - the separator.
				return superCount + 1;
			} else {
				return superCount;
			}
		}

		/**
		 * Gets the actual count of contacts and excludes all the headers.
		 */
		public int getRealCount() {
			return super.getCount();
		}

		private int getRealPosition(int pos) {
			if ((mMode & MODE_MASK_SHOW_NUMBER_OF_CONTACTS) != 0) {
				pos--;
			}
			if (mSuggestionsCursorCount != 0) {
				// When showing suggestions, we have 2 additional list items:
				// the "Suggestions"
				// and "All contacts" separators.
				if (pos < mSuggestionsCursorCount + 2) {
					// We are in the upper partition (Suggestions). Adjusting
					// for the "Suggestions"
					// separator.
					return pos - 1;
				} else {
					// We are in the lower partition (All contacts). Adjusting
					// for the size
					// of the upper partition plus the two separators.
					return pos - mSuggestionsCursorCount - 2;
				}
			} else if (mFrequentSeparatorPos == ListView.INVALID_POSITION) {
				// No separator, identity map
				return pos;
			} else if (pos <= mFrequentSeparatorPos) {
				// Before or at the separator, identity map
				return pos;
			} else {
				// After the separator, remove 1 from the pos to get the real
				// underlying pos
				return pos - 1;
			}
		}

		@Override
		public Object getItem(int pos) {
			if (mSuggestionsCursorCount != 0 && pos <= mSuggestionsCursorCount) {
				mSuggestionsCursor.moveToPosition(getRealPosition(pos));
				return mSuggestionsCursor;
			} else {
				return super.getItem(getRealPosition(pos));
			}
		}

		@Override
		public long getItemId(int pos) {
			if (mSuggestionsCursorCount != 0
					&& pos < mSuggestionsCursorCount + 2) {
				if (mSuggestionsCursor.moveToPosition(pos - 1)) {
					return mSuggestionsCursor.getLong(0);
				} else {
					return 0;
				}
			}
			return super.getItemId(getRealPosition(pos));
		}

		public void onScroll(AbsListView view, int firstVisibleItem,
				int visibleItemCount, int totalItemCount) {
			// no op
		}

		@Override
		// 动态的加载数据
		public void onScrollStateChanged(AbsListView view, int scrollState) {
			mScrollState = scrollState;
			if (scrollState == OnScrollListener.SCROLL_STATE_FLING) {
				// If we are in a fling, stop loading images.
				clearImageFetching();
			} else if (mDisplayPhotos) {
				// processMissingImageItems(view);
			}

		}

		private void processMissingImageItems(AbsListView view) {
			for (ImageView iv : mItemsMissingImages) {
				sendFetchImageMessage(iv);
			}
		}

		private void sendFetchImageMessage(ImageView view) {
			final PhotoInfo info = (PhotoInfo) view.getTag();
			if (info == null) {
				return;
			}
			final long photoId = info.photoId;
			if (photoId == 0) {
				return;
			}
			mImageFetcher = new ImageDbFetcher(photoId, view);
			synchronized (ContactsListActivity.this) {
				// can't sync on sImageFetchThreadPool.
				if (sImageFetchThreadPool == null) {
					// Don't use more than 3 threads at a time to update. The
					// thread pool will be
					// shared by all contact items.
					sImageFetchThreadPool = Executors.newFixedThreadPool(3);
				}
				sImageFetchThreadPool.execute(mImageFetcher);
			}
		}

		/**
		 * Stop the image fetching for ALL contacts, if one is in progress we'll
		 * not query the database.
		 * 
		 * TODO: move this method to ContactsListActivity, it does not apply to
		 * the current contact.
		 */
		public void clearImageFetching() {
			synchronized (ContactsListActivity.this) {
				if (sImageFetchThreadPool != null) {
					sImageFetchThreadPool.shutdownNow();
					sImageFetchThreadPool = null;
				}
			}

			mHandler.clearImageFecthing();
		}

	}

	/**
	 * 
	 * @param cursor
	 * @param sendSms
	 * @return
	 */
	public MyPerson SmsContact(Cursor cursor, String name) {
		if (cursor != null) {
			boolean hasPhone = cursor.getInt(SUMMARY_HAS_PHONE_COLUMN_INDEX) != 0;
			if (!hasPhone) {
				// There is no phone number.
				signalError();
				return null;
			}

			String phone = null;
			Cursor phonesCursor = null;
			phonesCursor = queryPhoneNumbers(cursor
					.getLong(SUMMARY_ID_COLUMN_INDEX));
			if (phonesCursor == null || phonesCursor.getCount() == 0) {
				// No valid number
				signalError();
				return null;
			} else if (phonesCursor.getCount() == 1) {
				// only one number, call it.
				phone = phonesCursor.getString(phonesCursor
						.getColumnIndex(Phone.NUMBER));

			} else {
				phonesCursor.moveToPosition(-1);
				while (phonesCursor.moveToNext()) {
					if (phonesCursor.getInt(phonesCursor
							.getColumnIndex(Phone.IS_SUPER_PRIMARY)) != 0) {
						// Found super primary, call it.
						phone = phonesCursor.getString(phonesCursor
								.getColumnIndex(Phone.NUMBER));
						break;
					}
				}
			}

			if (phone == null) {
				// Display dialog to choose a number to call.
				// 显示一个提示?????????
				Toast.makeText(ContactsListActivity.this, "该用户没有电话号码",
						Toast.LENGTH_SHORT).show();

				return null;
			} else {
				MyPerson myPerson = new MyPerson();
				myPerson.setName(name);
				myPerson.setPhoneNumber(phone);
				return myPerson;
			}
		}
		return null;
	}

	/**
	 * packge the Email
	 * 
	 * @param cursor
	 * @param name
	 * @return
	 */
	public MyPerson EmailContact(Cursor cursor, String name) {
		String email;
		if (cursor != null) {
			email = showEmail(cursor);
			MyPerson myPerson = new MyPerson();
			myPerson.setName(name);
			myPerson.setEmail(email);
			return myPerson;
		}

		return null;
	}

	/**
	 * show Email
	 * 
	 * @param myCursor
	 * @return
	 */
	public String showEmail(Cursor myCursor) {
		String id = myCursor.getString(myCursor
				.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
		Cursor emailCursor = getContentResolver().query(
				android.provider.Contacts.ContactMethods.CONTENT_URI, null,
				"_id=?", new String[] { id }, null);
		if (emailCursor.moveToNext()) {
			String email = emailCursor.getString(emailCursor
					.getColumnIndexOrThrow("data"));
			return email;
		}
		return null;
	}

	@Override
	protected Dialog onCreateDialog(int id) {
		ProgressDialog dialog = new ProgressDialog(this);
		dialog.setMessage("正在添加...");
		dialog.setIndeterminate(true);
		dialog.setCancelable(true);
		return dialog;

	}

	class SearchInfo {
		public String keyWord;
		public boolean isFinished;

		public SearchInfo(String keyWord, boolean isFinished) {
			this.keyWord = keyWord;
			this.isFinished = isFinished;
		}

		public boolean isFinished() {
			return isFinished;
		}
	}

	/**
	 * Class used for displaying a dialog with a list of phone numbers of which
	 * one will be chosen to make a call or initiate an sms message.
	 */
	public class PhoneDisambigDialog implements
			DialogInterface.OnClickListener, DialogInterface.OnDismissListener,
			CompoundButton.OnCheckedChangeListener {

		private boolean mMakePrimary = false;
		private Context mContext;
		private AlertDialog mDialog;
		private boolean mSendSms;
		private Cursor mPhonesCursor;
		private ListAdapter mPhonesAdapter;
		private ArrayList<PhoneItem> mPhoneItemList;
		private int position;
		/*
		 * private Map<Integer,MyPerson> positions; private Map<Integer,
		 * MyPerson> personMap;
		 */
		private String name;
		private Handler mHandler;

		/*
		 * public PhoneDisambigDialog(Context context, Cursor phonesCursor) {
		 * this(context, phonesCursor, false make call , null); }
		 */
		public PhoneDisambigDialog(Context context, Cursor phonesCursor,
				boolean sendSms, ArrayList phones, int position, String name) {
			mContext = context;
			mSendSms = sendSms;
			mPhonesCursor = phonesCursor;
			this.position = position;
			this.name = name;
			if (mPhonesCursor != null) {
				mPhoneItemList = makePhoneItemsList(phonesCursor);
			} else {
				mPhoneItemList = makePhoneItemsList(phones);
			}
			Collapser.collapseList(mPhoneItemList);

			mPhonesAdapter = new PhonesAdapter(mContext, mPhoneItemList);

			LayoutInflater inflater = (LayoutInflater) mContext
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			View setPrimaryView = inflater.inflate(
					R.layout.set_primary_checkbox, null);
			((CheckBox) setPrimaryView.findViewById(R.id.setPrimary))
					.setOnCheckedChangeListener(this);

			// Need to show disambig dialogue.
			AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(
					mContext).setAdapter(mPhonesAdapter, this).setTitle(
					"请选择电话号码").setView(setPrimaryView);

			mDialog = dialogBuilder.create();
		}

		/**
		 * Show the dialog.
		 */
		public void show() {
			if (mPhoneItemList.size() == 1) {
				// If there is only one after collapse, just select it, and
				// close;

				onClick(mDialog, 0);
			}
			mDialog.show();
		}

		public void onClick(DialogInterface dialog, int which) {
			if (mPhoneItemList.size() > which && which >= 0) {
				PhoneItem phoneItem = mPhoneItemList.get(which);
				long id = phoneItem.id;
				String phone = phoneItem.phoneNumber;
				if (mPhonesCursor != null) {
					if (mMakePrimary) {
						ContentValues values = new ContentValues(1);
						values.put(Data.IS_SUPER_PRIMARY, 1);
						mContext.getContentResolver().update(
								ContentUris
										.withAppendedId(Data.CONTENT_URI, id),
								values, null, null);
					}
				} else {
					if (mMakePrimary) {
						SharedPreferences msp = AirenaoUtills
								.getMySharedPreferences(mContext);
						Editor myEditor = msp.edit();
						myEditor.putString(phone, Constants.IS_SUPER_PRIMARY);
						myEditor.commit();
					}
				}

				// 电话号码phone
				MyPerson person = personMap.get(position);
				Log.i("p", personMap.hashCode() + "click");
				boolean isChecked = person.isChecked();
				personMap.get(position).setChecked(!isChecked);

				positions.add(new MyPerson(clickPersonId, this.name, phone));
				tempCount++;
				int myCount = tempCount + count;
				btnOk.setText(getString(R.string.btn_ok) + "(" + myCount + ")");
				mAdapter.notifyDataSetChanged();
				list.requestFocusFromTouch();
			} else {
				dialog.dismiss();
			}
		}

		public void onCheckedChanged(CompoundButton buttonView,
				boolean isChecked) {
			mMakePrimary = isChecked;
		}

		public void onDismiss(DialogInterface dialog) {
			mPhonesCursor.close();
		}

		private class PhonesAdapter extends ArrayAdapter<PhoneItem> {

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

		private ArrayList<PhoneItem> makePhoneItemsList(ArrayList<String> phones) {
			ArrayList<PhoneItem> phoneList = new ArrayList<PhoneItem>();
			for (int i = 0; i < phones.size(); i++) {
				phoneList.add(new PhoneItem(phones.get(i), i));
			}
			return phoneList;
		}

	}

	// 标记
	public List<MyPerson> deleteSameEntity(List<MyPerson> myPerson) {

		HashSet hashset = new HashSet(myPerson);
		List<MyPerson> relist = new ArrayList<MyPerson>();
		for (int i = 0; i < myPerson.size(); i++) {
			if (hashset.contains(myPerson.get(i))) // contains:该集合不包含指定元素，返回
				// true
				relist.add(myPerson.get(i));
		}
		return relist;
	}
}
