package com.aragoncg.airenao.utills;

import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;
//用来调整list显示时的高度
public class Utility {
	
        public static void setListViewHeightBasedOnChildren(ListView listView) { 
            ListAdapter listAdapter = listView.getAdapter();  
            if (listAdapter == null) { 
                // pre-condition 
                return; 
            } 
 
            int totalHeight = 0; 
            for (int i = 0; i < listAdapter.getCount(); i++) { 
                View listItem = listAdapter.getView(i, null, listView); 
                listItem.measure(0, 0); 
                totalHeight += listItem.getMeasuredHeight(); 
            } 
 
            ViewGroup.LayoutParams params = listView.getLayoutParams(); 
            params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1)); 
            listView.setLayoutParams(params); 
        } 
    } 

