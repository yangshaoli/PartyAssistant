package com.aragoncg.apps.airenao.exceptions;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;

import com.aragoncg.apps.airenao.R;

public class MyRuntimeException extends RuntimeException {
	private Context context;
	
	private static final long serialVersionUID = -8565361154291927884L;
		
	
	public MyRuntimeException(Context context,String title, String message) {
		this.context = context;
	}

	
	
}
