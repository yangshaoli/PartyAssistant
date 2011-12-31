package com.aragoncg.apps.airenao.activity;

import android.app.TabActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TabHost;

import com.aragoncg.apps.airenao.R;

/**
 * tab content that launches an activity via
 * {@link android.widget.TabHost.TabSpec#setContent(android.content.Intent)}
 */
public class ImeetingClientActivity extends TabActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		final TabHost tabHost = getTabHost();

		tabHost.addTab(tabHost
				.newTabSpec("createActivity")
				.setIndicator(getString(R.string.create_activity),
						getResources().getDrawable(R.drawable.activitys))
				.setContent(new Intent(this, CreateActivity.class)));

		tabHost.addTab(tabHost
				.newTabSpec("MeetingListActivity")
				.setIndicator(getString(R.string.meeting_list),
						getResources().getDrawable(R.drawable.checklist))
				.setContent(new Intent(this, MeetingListActivity.class)));
		// // This tab sets the intent flag so that it is recreated each time
		// // the tab is clicked.
		// tabHost.addTab(tabHost.newTabSpec("tab3")
		// .setIndicator("destroy")
		// .setContent(new Intent(this, null)
		// .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)));

	}
}
