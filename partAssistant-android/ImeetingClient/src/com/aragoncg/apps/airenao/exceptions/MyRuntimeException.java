package com.aragoncg.apps.airenao.exceptions;

import android.content.Context;


public class MyRuntimeException extends RuntimeException {
	private Context context;
	
	private static final long serialVersionUID = -8565361154291927884L;
		
	
	public MyRuntimeException(Context context,String title, String message) {
		this.context = context;
	}

	
	
}
