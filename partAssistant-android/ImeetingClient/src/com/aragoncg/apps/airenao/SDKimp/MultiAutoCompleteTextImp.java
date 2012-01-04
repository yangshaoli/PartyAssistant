package com.aragoncg.apps.airenao.SDKimp;

import android.content.Context;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.MultiAutoCompleteTextView;
import android.widget.MultiAutoCompleteTextView.Tokenizer;

public class MultiAutoCompleteTextImp extends MultiAutoCompleteTextView {
	private Tokenizer mTokenizer;
	
	public MultiAutoCompleteTextImp(Context context) {
		super(context);
		
	}
	

	public MultiAutoCompleteTextImp(Context context, AttributeSet attrs,
			int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
	}


	public MultiAutoCompleteTextImp(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}


	@Override
	public void replaceText(CharSequence text) {
		super.replaceText(text);
	}
	
	public void setTokenizer(Tokenizer t) {
        mTokenizer = t;
    }
	   /**
     * This simple Tokenizer can be used for lists where the items are
     * separated by a comma and one or more spaces.
     */
    public static class CommaTokenizer implements Tokenizer {
        public int findTokenStart(CharSequence text, int cursor) {
            int i = cursor;

            while (i > 0 && text.charAt(i - 1) != ',') {
                i--;
            }
            while (i < cursor && text.charAt(i) == ' ') {
                i++;
            }

            return i;
        }

        public int findTokenEnd(CharSequence text, int cursor) {
            int i = cursor;
            int len = text.length();

            while (i < len) {
                if (text.charAt(i) == ',') {
                    return i;
                } else {
                    i++;
                }
            }

            return len;
        }

        public CharSequence terminateToken(CharSequence text) {
            int i = text.length();

            while (i > 0 && text.charAt(i - 1) == ' ') {
                i--;
            }

            if (i > 0 && text.charAt(i - 1) == ',') {
                return text;
            } else {
                if (text instanceof Spanned) {
                    SpannableString sp = new SpannableString(text + ", ");
                    TextUtils.copySpansFrom((Spanned) text, 0, text.length(),
                                            Object.class, sp, 0);
                    return sp;
                } else {
                    return text + ", ";
                }
            }
        }
    }
	
}
