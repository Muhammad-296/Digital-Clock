#define F_CPU 1000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

// ---------- LCD PIN DEFINITIONS (MACROS) ----------
#define LCD_DATA_PORT    PORTB
#define LCD_DATA_DDR     DDRB
#define LCD_DATA_PIN     PINB
#define LCD_CMD_PORT     PORTD
#define LCD_CMD_DDR      DDRD
#define LCD_CMD_PIN      PIND
#define LCD_RS           PD0
#define LCD_RW           PD1
#define LCD_EN           PD2

// LCD Command Macros
#define LCD_RS_HIGH()    (LCD_CMD_PORT |= (1<<LCD_RS))
#define LCD_RS_LOW()     (LCD_CMD_PORT &= ~(1<<LCD_RS))
#define LCD_RW_HIGH()    (LCD_CMD_PORT |= (1<<LCD_RW))
#define LCD_RW_LOW()     (LCD_CMD_PORT &= ~(1<<LCD_RW))
#define LCD_EN_HIGH()    (LCD_CMD_PORT |= (1<<LCD_EN))
#define LCD_EN_LOW()     (LCD_CMD_PORT &= ~(1<<LCD_EN))

// ---------- LED AND BUZZER PIN DEFINITIONS (MACROS) ----------
#define LED_GREEN_PIN    PD3
#define LED_RED_PIN      PD4
#define LED_YELLOW_PIN   PD5
#define BUZZER_PIN       PD6

#define LED_GREEN_PORT   PORTD
#define LED_RED_PORT     PORTD
#define LED_YELLOW_PORT  PORTD
#define BUZZER_PORT      PORTD

#define LED_GREEN_DDR    DDRD
#define LED_RED_DDR      DDRD
#define LED_YELLOW_DDR   DDRD
#define BUZZER_DDR       DDRD

// LED Control Macros
#define LED_GREEN_ON()   (LED_GREEN_PORT |= (1<<LED_GREEN_PIN))
#define LED_GREEN_OFF()  (LED_GREEN_PORT &= ~(1<<LED_GREEN_PIN))
#define LED_RED_ON()     (LED_RED_PORT |= (1<<LED_RED_PIN))
#define LED_RED_OFF()    (LED_RED_PORT &= ~(1<<LED_RED_PIN))
#define LED_YELLOW_ON()  (LED_YELLOW_PORT |= (1<<LED_YELLOW_PIN))
#define LED_YELLOW_OFF() (LED_YELLOW_PORT &= ~(1<<LED_YELLOW_PIN))
#define BUZZER_ON()      (BUZZER_PORT |= (1<<BUZZER_PIN))
#define BUZZER_OFF()     (BUZZER_PORT &= ~(1<<BUZZER_PIN))

#define ALL_LEDS_ON()    (PORTD |= ((1<<LED_GREEN_PIN)|(1<<LED_RED_PIN)|(1<<LED_YELLOW_PIN)))
#define ALL_LEDS_OFF()   (PORTD &= ~((1<<LED_GREEN_PIN)|(1<<LED_RED_PIN)|(1<<LED_YELLOW_PIN)))

// ---------- KEYPAD PIN DEFINITIONS (MACROS) ----------
// Rows: PC0-PC3
// Cols: PC4-PC7
#define KEYPAD_PORT      PORTC
#define KEYPAD_DDR       DDRC
#define KEYPAD_PIN       PINC

#define KEYPAD_ROW1      PC0
#define KEYPAD_ROW2      PC1
#define KEYPAD_ROW3      PC2
#define KEYPAD_ROW4      PC3
#define KEYPAD_COL1      PC4
#define KEYPAD_COL2      PC5
#define KEYPAD_COL3      PC6
#define KEYPAD_COL4      PC7

// bit masks
#define KEYPAD_ROWS_MASK  ((1<<KEYPAD_ROW1)|(1<<KEYPAD_ROW2)|(1<<KEYPAD_ROW3)|(1<<KEYPAD_ROW4)) // 0x0F
#define KEYPAD_COLS_MASK  ((1<<KEYPAD_COL1)|(1<<KEYPAD_COL2)|(1<<KEYPAD_COL3)|(1<<KEYPAD_COL4)) // 0xF0

// safer row setters: only change row bits (set selected row LOW, others HIGH - assumes active low select)
#define KEYPAD_SET_ROW1() ( KEYPAD_PORT = (KEYPAD_PORT & ~KEYPAD_ROWS_MASK) | 0x0E ) // 0b00001110
#define KEYPAD_SET_ROW2() ( KEYPAD_PORT = (KEYPAD_PORT & ~KEYPAD_ROWS_MASK) | 0x0D ) // 0b00001101
#define KEYPAD_SET_ROW3() ( KEYPAD_PORT = (KEYPAD_PORT & ~KEYPAD_ROWS_MASK) | 0x0B ) // 0b00001011
#define KEYPAD_SET_ROW4() ( KEYPAD_PORT = (KEYPAD_PORT & ~KEYPAD_ROWS_MASK) | 0x07 ) // 0b00000111

#define KEYPAD_READ_COL1()  (!(KEYPAD_PIN & (1<<KEYPAD_COL1)))
#define KEYPAD_READ_COL2()  (!(KEYPAD_PIN & (1<<KEYPAD_COL2)))
#define KEYPAD_READ_COL3()  (!(KEYPAD_PIN & (1<<KEYPAD_COL3)))
#define KEYPAD_READ_COL4()  (!(KEYPAD_PIN & (1<<KEYPAD_COL4)))

// ---------- FUNCTION PROTOTYPES ----------
void LCD_Command(unsigned char cmnd);
void LCD_Char(unsigned char char_data);
void LCD_Init(void);
void LCD_Clear(void);
void LCD_String(char *str);
void LCD_String_xy(char row, char pos, char *str);
void LCD_Print_Center(char *str, uint8_t line);
void LCD_Print_Full_Line(char *str, uint8_t line);
void LCD_PutCharAt(char ch, uint8_t row, uint8_t pos);

char scankey(void);
char keycheck(void);

void timer_init(void);
void update_display(void);
void set_time_12hr(void);
void set_date(void);
void toggle_12hr_mode(void);
void initial_setup(void);
void system_reset(void);

uint8_t is_leap_year(uint16_t year);
uint8_t days_in_month(uint8_t month, uint16_t year);
void advance_date(void);

void buzzer_beep(void);
void buzzer_long_beep(void);

// ---------- GLOBALS ----------
volatile uint8_t hours = 0;
volatile uint8_t minutes = 0;
volatile uint8_t seconds = 0;
volatile uint16_t milliseconds = 0;

uint8_t day = 0;
uint8_t month = 0;
uint16_t year = 0;

uint8_t mode_12hr = 1;  // 1=12hr, 0=24hr
uint8_t display_mode = 0; // 0=time, 1=date

volatile uint8_t tick_flag = 0;
volatile uint8_t second_flag = 0;

const char* month_names[] = {
	"---", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
	"JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
};

// ---------- TIMER INTERRUPT (every ~10ms) ----------
ISR(TIMER0_COMP_vect)
{
	milliseconds += 10;
	tick_flag = 1;
	
	if(milliseconds >= 1000)
	{
		milliseconds = 0;
		seconds++;
		second_flag = 1;
		
		if(seconds >= 60)
		{
			seconds = 0;
			minutes++;
			
			if(minutes >= 60)
			{
				minutes = 0;
				hours++;
				
				if(hours >= 24)
				{
					hours = 0;
					if(day > 0 && month > 0 && year > 0)
					advance_date();
				}
			}
		}
	}
}

// ---------- MAIN FUNCTION ----------
int main(void)
{
	// Port initialization using macros
	LCD_DATA_DDR = 0xFF;                    // LCD data port (PORTB - all output)
	LCD_CMD_DDR |= (1<<LCD_RS)|(1<<LCD_RW)|(1<<LCD_EN);  // LCD control pins as output
	
	// LEDs and Buzzer as output on PORTD
	LED_GREEN_DDR |= (1<<LED_GREEN_PIN);
	LED_RED_DDR |= (1<<LED_RED_PIN);
	LED_YELLOW_DDR |= (1<<LED_YELLOW_PIN);
	BUZZER_DDR |= (1<<BUZZER_PIN);
	
	// Keypad: Rows as output (PC0-PC3), Columns as input with pull-ups (PC4-PC7)
	// Preserve other PORTC bits by using bitwise ops
	KEYPAD_DDR &= ~KEYPAD_COLS_MASK;          // ensure column pins are inputs
	KEYPAD_DDR |= KEYPAD_ROWS_MASK;           // rows as outputs
	// Set all rows HIGH (idle) and enable pull-ups on columns
	KEYPAD_PORT |= KEYPAD_COLS_MASK;          // enable pull-ups on columns
	KEYPAD_PORT |= KEYPAD_ROWS_MASK;          // set rows HIGH (idle)

	LCD_Init();
	timer_init();
	
	sei(); // Enable interrupts

	// Startup screen
	LCD_Clear();
	LCD_Print_Full_Line("DIGITAL CLOCK", 0);
	LCD_Print_Full_Line("WITH DATE", 1);
	LED_YELLOW_ON();
	LED_GREEN_ON();
	_delay_ms(1200);
	ALL_LEDS_OFF();
	LCD_Clear();

	// Run initial setup automatically at each boot so user can adjust settings
	initial_setup();

	// Show the fresh display after setup
	update_display();
	_delay_ms(500);
	LCD_Clear();

	uint8_t last_second = seconds;
	uint8_t blink_state = 0;
	
	while(1)
	{
		// Update display every second
		if(seconds != last_second)
		{
			last_second = seconds;
			update_display();
			
			// Green LED blinks every second
			blink_state = !blink_state;
			if(blink_state) LED_GREEN_ON();
			else LED_GREEN_OFF();
			
			// Yellow LED blinks at top of hour
			if(minutes == 0 && seconds < 3)
			{
				LED_YELLOW_ON();
			}
			else
			{
				LED_YELLOW_OFF();
			}
		}
		
		// Check for key press
		char key = keycheck();
		if(key != 'a')
		{
			_delay_ms(20); // small debounce
			while(keycheck() != 'a'); // wait release
			buzzer_beep();
			
			switch(key)
			{
				case 'A': set_time_12hr(); break;
				case 'B': set_date(); break;
				case 'C': toggle_12hr_mode(); update_display(); break;
				case 'D':
				display_mode = !display_mode;
				if(display_mode) LED_RED_ON();
				else LED_RED_OFF();
				update_display();
				break;
				case '#': system_reset(); break;
			}
		}
	}
}

// ---------- SYSTEM RESET FUNCTION ----------
void system_reset(void)
{
	cli(); // Disable interrupts

	LCD_Clear();
	LCD_Print_Full_Line("RESET SYSTEM?", 0);
	LCD_Print_Full_Line("A=YES B=CANCEL", 1);

	// Flash all LEDs as warning
	for(uint8_t i=0; i<5; i++)
	{
		ALL_LEDS_ON();
		BUZZER_ON();
		_delay_ms(150);
		ALL_LEDS_OFF();
		BUZZER_OFF();
		_delay_ms(150);
	}

	char confirm;
	do {
		confirm = scankey();
	} while(confirm != 'A' && confirm != 'B');

	if(confirm == 'A')
	{
		buzzer_long_beep();

		LCD_Clear();
		LCD_Print_Full_Line("RESETTING...", 0);
		LED_RED_ON();

		// Reset values to defaults (no EEPROM to clear)
		hours = 0;
		minutes = 0;
		seconds = 0;
		milliseconds = 0;
		day = 0;
		month = 0;
		year = 0;
		mode_12hr = 1;
		display_mode = 0;

		LCD_Clear();
		LCD_Print_Full_Line("RESET COMPLETE!", 0);
		LCD_Print_Full_Line("RESTARTING...", 1);
		ALL_LEDS_ON();
		_delay_ms(1200);
		ALL_LEDS_OFF();

		// Re-run initial setup so user can enter format, time and date
		initial_setup();

		// Show the fresh display after setup
		update_display();

		sei(); // Re-enable interrupts
	}
	else
	{
		LCD_Clear();
		LCD_Print_Full_Line("CANCELLED", 0);
		LED_YELLOW_ON();
		_delay_ms(800);
		LED_YELLOW_OFF();
		LCD_Clear();
		sei(); // Re-enable interrupts
		update_display();
	}
}


// ---------- INITIAL SETUP FUNCTION (runs at boot) ----------
void initial_setup(void)
{
	LCD_Clear();
	LCD_Print_Full_Line("INITIAL SETUP", 0);
	LCD_Print_Full_Line("Please Wait...", 1);
	LED_YELLOW_ON();
	LED_RED_ON();
	_delay_ms(900);
	ALL_LEDS_OFF();
	
	// Step 1: Choose time format
	LCD_Clear();
	LCD_Print_Full_Line("SELECT FORMAT:", 0);
	LCD_Print_Full_Line("A=12HR  B=24HR", 1);
	
	char format_key;
	do {
		format_key = scankey();
	} while(format_key != 'A' && format_key != 'B');
	
	buzzer_beep();
	mode_12hr = (format_key == 'A') ? 1 : 0;
	
	LCD_Clear();
	if(mode_12hr)
	LCD_Print_Full_Line("12-HOUR MODE", 0);
	else
	LCD_Print_Full_Line("24-HOUR MODE", 0);
	LCD_Print_Full_Line("SELECTED", 1);
	LED_GREEN_ON();
	_delay_ms(800);
	LED_GREEN_OFF();
	
	// Step 2: Set time
	LCD_Clear();
	LCD_Print_Full_Line("STEP 1 OF 2:", 0);
	LCD_Print_Full_Line("SET TIME", 1);
	_delay_ms(900);
	
	set_time_12hr();
	
	// Step 3: Set date
	LCD_Clear();
	LCD_Print_Full_Line("STEP 2 OF 2:", 0);
	LCD_Print_Full_Line("SET DATE", 1);
	_delay_ms(900);
	
	set_date();
	
	// Setup complete
	LCD_Clear();
	LCD_Print_Full_Line("SETUP COMPLETE!", 0);
	LCD_Print_Full_Line("Starting...", 1);
	ALL_LEDS_ON();
	_delay_ms(1200);
	ALL_LEDS_OFF();
	LCD_Clear();
}

// ---------- TIMER INITIALIZATION ----------
void timer_init(void)
{
	// Timer0 CTC mode for 1MHz clock
	// For ~10ms interrupt: prescaler 64, OCR0 = 155
	TCCR0 = (1<<WGM01)|(1<<CS01)|(1<<CS00); // CTC mode, prescaler 64
	OCR0 = 155;                               // Compare value for ~10ms at 1MHz
	TIMSK |= (1<<OCIE0);                      // Enable Timer0 compare match interrupt
}

// ---------- DATE FUNCTIONS ----------
uint8_t is_leap_year(uint16_t y)
{
	if(y == 0) return 0;
	if(y % 400 == 0) return 1;
	if(y % 100 == 0) return 0;
	if(y % 4 == 0) return 1;
	return 0;
}

uint8_t days_in_month(uint8_t m, uint16_t y)
{
	const uint8_t days[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	
	if(m == 0 || m > 12) return 31;
	if(m == 2 && is_leap_year(y))
	return 29;
	
	return days[m];
}

void advance_date(void)
{
	day++;
	
	if(day > days_in_month(month, year))
	{
		day = 1;
		month++;
		
		if(month > 12)
		{
			month = 1;
			year++;
		}
	}
}

// ---------- DISPLAY FUNCTIONS ----------
void update_display(void)
{
	char line1[17];
	char line2[17];
	
	if(display_mode == 0)  // Time display mode
	{
		uint8_t disp_hour = hours;
		char am_pm[3] = "  ";
		
		if(mode_12hr)
		{
			if(hours == 0) disp_hour = 12;
			else if(hours > 12) disp_hour = hours - 12;
			
			if(hours < 12) strcpy(am_pm, "AM");
			else strcpy(am_pm, "PM");
			
			// Line 1: TIME HH:MM:SS AM/PM
			snprintf(line1, sizeof(line1), " %02d:%02d:%02d %s  ", disp_hour, minutes, seconds, am_pm);
		}
		else
		{
			// Line 1: TIME HH:MM:SS
			snprintf(line1, sizeof(line1), "   %02d:%02d:%02d    ", hours, minutes, seconds);
		}
		
		// Line 2: DATE DD-MM-YYYY
		if(month == 0 || day == 0 || year == 0)
		snprintf(line2, sizeof(line2), " 00-00-0000     ");
		else
		snprintf(line2, sizeof(line2), " %02d-%02d-%04d   ", day, month, year);
	}
	else  // Date display mode
	{
		// Line 1: DATE DD-MMM-YYYY
		if(month == 0 || day == 0 || year == 0)
		{
			snprintf(line1, sizeof(line1), " 00-000-0000    ");
		}
		else
		{
			snprintf(line1, sizeof(line1), " %02d-%s-%04d  ", day, month_names[month], year);
		}
		
		// Line 2: TIME HH:MM AM/PM
		uint8_t disp_hour = hours;
		char am_pm[3] = "  ";
		
		if(mode_12hr)
		{
			if(hours == 0) disp_hour = 12;
			else if(hours > 12) disp_hour = hours - 12;
			
			if(hours < 12) strcpy(am_pm, "AM");
			else strcpy(am_pm, "PM");
			
			snprintf(line2, sizeof(line2), "   %02d:%02d %s   ", disp_hour, minutes, am_pm);
		}
		else
		{
			snprintf(line2, sizeof(line2), "    %02d:%02d     ", hours, minutes);
		}
	}
	
	LCD_String_xy(0, 0, line1);
	LCD_String_xy(1, 0, line2);
}

// ---------- TIME SETTING (12HR with AM/PM) ----------
void set_time_12hr(void)
{
	cli(); // Disable interrupts while setting
	
	LCD_Clear();
	LCD_Print_Full_Line("SET TIME", 0);
	
	if(mode_12hr)
	LCD_Print_Full_Line("HH:MM:SS AM/PM", 1);
	else
	LCD_Print_Full_Line("HH:MM:SS", 1);
	
	_delay_ms(800);
	
	char input[7];
	uint8_t idx = 0;
	
	// Show template at row 1 starting col 2: "__:__:__"
	LCD_Clear();
	LCD_Print_Full_Line("ENTER TIME:", 0);
	LCD_String_xy(1, 2, "__:__:__");
	
	const uint8_t base_col = 2; // starting column where first digit is shown
	while(idx < 6)
	{
		char key = scankey();
		
		if(key >= '0' && key <= '9')
		{
			// compute column for this digit accounting for ':' separators
			uint8_t sep_before = (idx >= 2 ? 1 : 0) + (idx >= 4 ? 1 : 0);
			uint8_t pos = base_col + idx + sep_before; // 0-based column
			// write digit at row 1 pos
			LCD_PutCharAt(key, 1, pos);
			input[idx++] = key;
		}
		else if(key == '*' && idx > 0)
		{
			// backspace: remove last entered digit, keep separators
			idx--;
			uint8_t sep_before = (idx >= 2 ? 1 : 0) + (idx >= 4 ? 1 : 0);
			uint8_t pos = base_col + idx + sep_before;
			
			// overwrite with underscore to show empty
			LCD_PutCharAt('_', 1, pos);
		}
		// ignore other keys while entering
	}
	
	input[6] = '\0';
	
	// Parse input
	uint8_t input_hour = (input[0]-'0')*10 + (input[1]-'0');
	minutes = (input[2]-'0')*10 + (input[3]-'0');
	seconds = (input[4]-'0')*10 + (input[5]-'0');
	
	// If 12-hour mode, ask for AM/PM
	if(mode_12hr)
	{
		LCD_Clear();
		LCD_Print_Full_Line("SELECT:", 0);
		LCD_Print_Full_Line("A=AM    B=PM", 1);
		
		char ampm_key;
		do {
			ampm_key = scankey();
		} while(ampm_key != 'A' && ampm_key != 'B');
		
		buzzer_beep();
		
		// Convert to 24-hour format
		if(input_hour == 12)
		{
			hours = (ampm_key == 'A') ? 0 : 12;
		}
		else
		{
			hours = (ampm_key == 'A') ? input_hour : (input_hour + 12);
		}
	}
	else
	{
		hours = input_hour;
	}
	
	milliseconds = 0;
	
	if(hours > 23) hours = 23;
	if(minutes > 59) minutes = 59;
	if(seconds > 59) seconds = 59;
	
	LCD_Clear();
	LCD_Print_Full_Line("TIME SET!", 0);
	LED_GREEN_ON();
	LED_YELLOW_ON();
	_delay_ms(800);
	ALL_LEDS_OFF();
	LCD_Clear();
	sei(); // Re-enable interrupts
}

// ---------- DATE SETTING ----------
void set_date(void)
{
	LCD_Clear();
	LCD_Print_Full_Line("SET DATE", 0);
	LCD_Print_Full_Line("DD-MM-YYYY", 1);
	_delay_ms(800);
	
	char input[9];
	uint8_t idx = 0;
	
	// Show template at row 1 starting col 1: "__-__-____"
	LCD_Clear();
	LCD_Print_Full_Line("ENTER DATE:", 0);
	LCD_String_xy(1, 1, "__-__-____");
	
	const uint8_t base_col = 1; // starting column where first digit is shown
	while(idx < 8)
	{
		char key = scankey();
		
		if(key >= '0' && key <= '9')
		{
			// compute column for this digit accounting for '-' separators
			uint8_t sep_before = (idx >= 2 ? 1 : 0) + (idx >= 4 ? 1 : 0);
			uint8_t pos = base_col + idx + sep_before;
			
			// write digit at row 1 pos
			LCD_PutCharAt(key, 1, pos);
			
			input[idx++] = key;
		}
		else if(key == '*' && idx > 0)
		{
			// backspace: remove last entered digit, keep separators
			idx--;
			uint8_t sep_before = (idx >= 2 ? 1 : 0) + (idx >= 4 ? 1 : 0);
			uint8_t pos = base_col + idx + sep_before;
			
			LCD_PutCharAt('_', 1, pos);
		}
		// ignore other keys while entering
	}
	
	input[8] = '\0';
	
	// Parse input
	uint8_t new_day = (input[0]-'0')*10 + (input[1]-'0');
	uint8_t new_month = (input[2]-'0')*10 + (input[3]-'0');
	uint16_t new_year = (input[4]-'0')*1000 + (input[5]-'0')*100 +
	(input[6]-'0')*10 + (input[7]-'0');
	
	// Validate date
	if(new_month >= 1 && new_month <= 12)
	{
		uint8_t max_days = days_in_month(new_month, new_year);
		if(new_day >= 1 && new_day <= max_days && new_year >= 2000 && new_year <= 2099)
		{
			day = new_day;
			month = new_month;
			year = new_year;
			
			LCD_Clear();
			
			if(is_leap_year(year) && month == 2)
			LCD_Print_Full_Line("LEAP YEAR!", 0);
			else
			LCD_Print_Full_Line("DATE SET!", 0);
			
			LED_RED_ON();
			LED_YELLOW_ON();
			_delay_ms(800);
			ALL_LEDS_OFF();
		}
		else
		{
			LCD_Clear();
			LCD_Print_Full_Line("INVALID DATE!", 0);
			_delay_ms(800);
		}
	}
	else
	{
		LCD_Clear();
		LCD_Print_Full_Line("INVALID MONTH!", 0);
		_delay_ms(800);
	}
	
	LCD_Clear();
}

// ---------- MODE TOGGLE ----------
void toggle_12hr_mode(void)
{
	mode_12hr = !mode_12hr;
	
	LCD_Clear();
	if(mode_12hr)
	LCD_Print_Full_Line("12-HOUR MODE", 0);
	else
	LCD_Print_Full_Line("24-HOUR MODE", 0);
	
	LED_YELLOW_ON();
	_delay_ms(600);
	LED_YELLOW_OFF();
	LCD_Clear();
}

// ---------- BUZZER FUNCTIONS ----------
void buzzer_beep(void)
{
	// ~1kHz tone for ~40ms
	for(uint8_t i=0; i<40; i++)
	{
		BUZZER_ON();
		_delay_us(500);
		BUZZER_OFF();
		_delay_us(500);
	}
}

void buzzer_long_beep(void)
{
	// ~1kHz tone for ~200ms
	for(uint8_t i=0; i<200; i++)
	{
		BUZZER_ON();
		_delay_us(500);
		BUZZER_OFF();
		_delay_us(500);
	}
}

// ---------- LCD FUNCTIONS (16x2 Interface) ----------
void LCD_Command(unsigned char cmnd)
{
	LCD_DATA_PORT = cmnd;
	LCD_RS_LOW();           // RS=0 command reg
	LCD_RW_LOW();           // RW=0 Write operation
	LCD_EN_HIGH();          // Enable pulse
	_delay_us(1);
	LCD_EN_LOW();
	_delay_ms(2);
}

void LCD_Char(unsigned char char_data)
{
	LCD_DATA_PORT = char_data;
	LCD_RS_HIGH();          // RS=1 Data reg
	LCD_RW_LOW();           // RW=0 write operation
	LCD_EN_HIGH();          // Enable Pulse
	_delay_us(1);
	LCD_EN_LOW();
	_delay_ms(2);
}

void LCD_Init(void)
{
	LCD_CMD_DDR |= (1<<LCD_RS)|(1<<LCD_RW)|(1<<LCD_EN);  // LCD command pins as output
	LCD_DATA_DDR = 0xFF;                                   // LCD data port as output
	_delay_ms(20);                                         // LCD Power ON delay always >15ms
	
	LCD_Command(0x38);       // Initialization of 16X2 LCD in 8bit mode
	LCD_Command(0x0C);       // Display ON Cursor OFF
	LCD_Command(0x06);       // Auto Increment cursor
	LCD_Command(0x01);       // clear display
	_delay_ms(2);            // Clear display command delay> 1.63 ms
	LCD_Command(0x80);       // Cursor at home position
}

void LCD_Clear(void)
{
	LCD_Command(0x01);  // clear display
	LCD_Command(0x80);  // cursor at home position
}

void LCD_String(char *str)
{
	int i;
	for(i=0; str[i]!=0; i++)
	{
		LCD_Char(str[i]);
	}
}

void LCD_String_xy(char row, char pos, char *str)
{
	if(row == 0 && pos < 16)
	LCD_Command((pos & 0x0F)|0x80);  // Command of first row
	else if(row == 1 && pos < 16)
	LCD_Command((pos & 0x0F)|0xC0);  // Command of second row
	LCD_String(str);
}

void LCD_PutCharAt(char ch, uint8_t row, uint8_t pos)
{
	if(row == 0 && pos < 16)
	LCD_Command((pos & 0x0F)|0x80);
	else if(row == 1 && pos < 16)
	LCD_Command((pos & 0x0F)|0xC0);
	LCD_Char(ch);
}

void LCD_Print_Center(char *str, uint8_t line)
{
	uint8_t len = strlen(str);
	if(len > 16) len = 16;
	uint8_t pos = (16 - len) / 2;
	LCD_String_xy(line, pos, str);
}

void LCD_Print_Full_Line(char *str, uint8_t line)
{
	char buffer[17];
	uint8_t len = strlen(str);
	
	if(len > 16) len = 16;
	
	// Center the text
	uint8_t padding = (16 - len) / 2;
	uint8_t i;
	
	for(i = 0; i < padding; i++)
	buffer[i] = ' ';
	
	for(uint8_t j = 0; j < len; j++, i++)
	buffer[i] = str[j];
	
	while(i < 16)
	buffer[i++] = ' ';
	
	buffer[16] = '\0';
	
	LCD_String_xy(line, 0, buffer);
}

// ---------- KEYPAD FUNCTIONS ----------
// scankey: waits for a stable key press and returns it
char scankey(void)
{
	char k;
	while(1) {
		k = keycheck();
		if(k == 'a') {
			_delay_ms(5);
			continue;
		}
		// confirm stable by short delay and re-sample
		_delay_ms(10);
		if(keycheck() == k) {
			// wait until release
			while(keycheck() == k) _delay_ms(5);
			_delay_ms(10);
			return k;
		}
	}
}

char keycheck(void)
{
	// Row 1 scan
	KEYPAD_SET_ROW1();
	_delay_ms(3);
	if(KEYPAD_READ_COL1()) return '1';
	if(KEYPAD_READ_COL2()) return '2';
	if(KEYPAD_READ_COL3()) return '3';
	if(KEYPAD_READ_COL4()) return 'A';

	// Row 2 scan
	KEYPAD_SET_ROW2();
	_delay_ms(3);
	if(KEYPAD_READ_COL1()) return '4';
	if(KEYPAD_READ_COL2()) return '5';
	if(KEYPAD_READ_COL3()) return '6';
	if(KEYPAD_READ_COL4()) return 'B';

	// Row 3 scan
	KEYPAD_SET_ROW3();
	_delay_ms(3);
	if(KEYPAD_READ_COL1()) return '7';
	if(KEYPAD_READ_COL2()) return '8';
	if(KEYPAD_READ_COL3()) return '9';
	if(KEYPAD_READ_COL4()) return 'C';

	// Row 4 scan
	KEYPAD_SET_ROW4();
	_delay_ms(3);
	if(KEYPAD_READ_COL1()) return '*';
	if(KEYPAD_READ_COL2()) return '0';
	if(KEYPAD_READ_COL3()) return '#';
	if(KEYPAD_READ_COL4()) return 'D';

	// No key
	// set rows idle (all HIGH)
	KEYPAD_PORT |= KEYPAD_ROWS_MASK;
	return 'a';
}
