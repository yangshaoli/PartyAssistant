package com.aragoncg.airenao.utills;

import android.database.Cursor;
import android.util.SparseIntArray;
import android.widget.AlphabetIndexer;

public class MyAlphabetIndexe extends AlphabetIndexer {

    /**
     * Cached length of the alphabet array.
     */
    private int mAlphabetLength;

    /**
     * This contains a cache of the computed indices so far. It will get reset whenever
     * the dataset changes or the cursor changes.
     */
    private SparseIntArray mAlphaMap;

    /**
     * Use a collator to compare strings in a localized manner.
     */
    private java.text.Collator mCollator;

    /**
     * The section array converted from the alphabet string.
     */
    private String[] mAlphabetArray;
    
	public MyAlphabetIndexe(Cursor cursor, int sortedColumnIndex,
			CharSequence alphabet) {
		super(cursor, sortedColumnIndex, alphabet);
        mAlphabetLength = alphabet.length();
        mAlphabetArray = new String[mAlphabetLength];
        for (int i = 0; i < mAlphabetLength; i++) {
            mAlphabetArray[i] = Character.toString(mAlphabet.charAt(i));
        }
        mAlphaMap = new SparseIntArray(mAlphabetLength);
    }
	
    /**
     * Performs a binary search or cache lookup to find the first row that
     * matches a given section's starting letter.
     * @param sectionIndex the section to search for
     * @return the row index of the first occurrence, or the nearest next letter.
     * For instance, if searching for "T" and no "T" is found, then the first
     * row starting with "U" or any higher letter is returned. If there is no
     * data following "T" at all, then the list size is returned.
     */
    public   int getPositionForSection(int sectionIndex) {
        final SparseIntArray alphaMap = mAlphaMap;
        final Cursor cursor = mDataCursor;

        if (cursor == null || mAlphabet == null) {
            return 0;
        }

        // Check bounds
        if (sectionIndex <= 0) {
            return 0;
        }
        if (sectionIndex >= mAlphabetLength) {
            sectionIndex = mAlphabetLength - 1;
        }

        int savedCursorPos = cursor.getPosition();

        int count = cursor.getCount();
        int start = 0;
        int end = count;
        int pos;

        char letter = mAlphabet.charAt(sectionIndex);
        String targetLetter = Character.toString(letter);
        int key = letter;
        // Check map
        if (Integer.MIN_VALUE != (pos = alphaMap.get(key, Integer.MIN_VALUE))) {
            // Is it approximate? Using negative value to indicate that it's
            // an approximation and positive value when it is the accurate
            // position.
            if (pos < 0) {
                pos = -pos;
                end = pos;
            } else {
                // Not approximate, this is the confirmed start of section, return it
                return pos;
            }
        }

        // Do we have the position of the previous section?
        if (sectionIndex > 0) {
            int prevLetter =
                    mAlphabet.charAt(sectionIndex - 1);
            int prevLetterPos = alphaMap.get(prevLetter, Integer.MIN_VALUE);
            if (prevLetterPos != Integer.MIN_VALUE) {
                start = Math.abs(prevLetterPos);
            }
        }

        // Now that we have a possibly optimized start and end, let's binary search

        pos = (end + start) / 2;

        while (pos < end) {
            // Get letter at pos
            cursor.moveToPosition(pos);
            String curName = cursor.getString(mColumnIndex);
            if (!AirenaoUtills.isStartEnChar(curName)){
            	
            	curName = AirenaoUtills.getPinYin(String.valueOf(curName.charAt(0)));
            }
            if (curName == null) {
                if (pos == 0) {
                    break;
                } else {
                    pos--;
                    continue;
                }
            }
            int diff = compare(curName, targetLetter);
            if (diff != 0) {
                // TODO: Commenting out approximation code because it doesn't work for certain
                // lists with custom comparators
                // Enter approximation in hash if a better solution doesn't exist
                // String startingLetter = Character.toString(getFirstLetter(curName));
                // int startingLetterKey = startingLetter.charAt(0);
                // int curPos = alphaMap.get(startingLetterKey, Integer.MIN_VALUE);
                // if (curPos == Integer.MIN_VALUE || Math.abs(curPos) > pos) {
                //     Negative pos indicates that it is an approximation
                //     alphaMap.put(startingLetterKey, -pos);
                // }
                // if (mCollator.compare(startingLetter, targetLetter) < 0) {
                if (diff < 0) {
                    start = pos + 1;
                    if (start >= count) {
                        pos = count;
                        break;
                    }
                } else {
                    end = pos;
                }
            } else {
                // They're the same, but that doesn't mean it's the start
                if (start == pos) {
                    // This is it
                    break;
                } else {
                    // Need to go further lower to find the starting row
                    end = pos;
                }
            }
            pos = (start + end) / 2;
        }
        alphaMap.put(key, pos);
        cursor.moveToPosition(savedCursorPos);
        return pos;
    }
    /**
     * Returns the section array constructed from the alphabet provided in the constructor.
     * @return the section array
     */
    public Object[] getSections() {
        return mAlphabetArray;
    }
}
