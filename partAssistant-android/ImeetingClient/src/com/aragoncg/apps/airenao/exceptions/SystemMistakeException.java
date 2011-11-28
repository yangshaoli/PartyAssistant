package com.aragoncg.apps.airenao.exceptions;

import java.io.PrintStream;
import java.io.PrintWriter;

import com.aragoncg.apps.airenao.R;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;

public class SystemMistakeException extends Exception {

	private static final long serialVersionUID = 12334577727994L;
	private Context context;
	
	
	
	public SystemMistakeException(Context context, String title, String message) {
		super();
		this.context = context;
		showDialog(title, message);
	}

	@Override
	public Throwable fillInStackTrace() {
		// TODO Auto-generated method stub
		return super.fillInStackTrace();
	}

	@Override
	public String getMessage() {
		// TODO Auto-generated method stub
		return super.getMessage();
	}

	@Override
	public String getLocalizedMessage() {
		// TODO Auto-generated method stub
		return super.getLocalizedMessage();
	}

	@Override
	public StackTraceElement[] getStackTrace() {
		// TODO Auto-generated method stub
		return super.getStackTrace();
	}

	@Override
	public void setStackTrace(StackTraceElement[] trace) {
		// TODO Auto-generated method stub
		super.setStackTrace(trace);
	}

	@Override
	public void printStackTrace() {
		// TODO Auto-generated method stub
		super.printStackTrace();
	}

	@Override
	public void printStackTrace(PrintStream err) {
		// TODO Auto-generated method stub
		super.printStackTrace(err);
	}

	@Override
	public void printStackTrace(PrintWriter err) {
		// TODO Auto-generated method stub
		super.printStackTrace(err);
	}

	@Override
	public String toString() {
		// TODO Auto-generated method stub
		return super.toString();
	}

	@Override
	public Throwable initCause(Throwable throwable) {
		// TODO Auto-generated method stub
		return super.initCause(throwable);
	}

	@Override
	public Throwable getCause() {
		// TODO Auto-generated method stub
		return super.getCause();
	}
	
	
	
	public void showDialog(String title, String message){
		if(context != null){
			AlertDialog alertDialog = new AlertDialog.Builder(context)
			.setTitle(title)
			.setMessage(message)
			.setPositiveButton(R.string.btn_ok, new OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					System.exit(0);
				}
			})
			.create();
			
			alertDialog.show();
		}
	}
	
}
