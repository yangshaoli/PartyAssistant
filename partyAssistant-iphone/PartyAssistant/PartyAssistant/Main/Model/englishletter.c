#define LETTER_START 65
#define LETTER_COUNT 26

static char firstLetterArray[LETTER_COUNT] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

char stringFirstLetter(unsigned short letter)
{
	int index = letter - LETTER_START;
	if (index >= 0 && index <= LETTER_COUNT)
	{
		return firstLetterArray[index];
	}
	else
	{
		return '#';
	}
}
