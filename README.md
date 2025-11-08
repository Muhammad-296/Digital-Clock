# Digital Clock with Date - ATmega32A

A full-featured digital clock with date tracking, implemented for the ATmega32A microcontroller in both C and Assembly languages.

## Features

- **12/24 Hour Time Format** - User-selectable display mode
- **Date Tracking** - Full calendar support with leap year detection
- **Interactive Setup** - Initial configuration wizard on boot
- **Visual Feedback** - RGB LED indicators for system status
- **Audio Feedback** - Buzzer for keypress confirmation
- **System Reset** - Complete reset with confirmation dialog

## Hardware Requirements

### Microcontroller
- ATmega32A @ 1MHz

### Display
- 16x2 LCD (8-bit parallel interface)
  - Data: PORTB (PB0-PB7)
  - Control: PORTD (RS=PD0, RW=PD1, EN=PD2)

### Input
- 4x4 Matrix Keypad on PORTC
  - Rows: PC0-PC3
  - Columns: PC4-PC7

### Output Indicators
- Green LED: PD3 (seconds blink)
- Red LED: PD4 (date display mode)
- Yellow LED: PD5 (hour indicator)
- Buzzer: PD6

## Keypad Layout

```
[1] [2] [3] [A] - Set Time
[4] [5] [6] [B] - Set Date
[7] [8] [9] [C] - Toggle 12/24hr Mode
[*] [0] [#] [D] - System Reset / Toggle Display
```

## Key Functions

- **A** - Set Time (with AM/PM selection in 12hr mode)
- **B** - Set Date (DD-MM-YYYY format)
- **C** - Toggle between 12-hour and 24-hour format
- **D** - Toggle between time/date display modes
- **#** - System reset (requires confirmation)
- **\*** - Backspace during input

## Display Modes

### Time Mode (Default)
- Line 1: Time with seconds (HH:MM:SS AM/PM or HH:MM:SS)
- Line 2: Date (DD-MM-YYYY)

### Date Mode
- Line 1: Date with month name (DD-MMM-YYYY)
- Line 2: Time without seconds (HH:MM AM/PM or HH:MM)

## LED Indicators

- **Green LED** - Blinks every second
- **Yellow LED** - Blinks at the top of each hour (3 seconds)
- **Red LED** - Illuminates when in date display mode

## Initial Setup

On first boot or after reset:
1. Select time format (12hr/24hr)
2. Set current time
3. Set current date
4. System starts running

## Implementation Files

- `clock.c` - C implementation with full functionality
- `clock.asm` - Assembly implementation (optimized for 1MHz)

## Technical Details

- Timer0 configured in CTC mode for 10ms interrupts
- Automatic date advancement at midnight
- Leap year calculation (2000-2099 range)
- Debounced keypad scanning
- Non-volatile time tracking (while powered)

## Compilation

### C Version
```bash
avr-gcc -mmcu=atmega32 -DF_CPU=1000000UL -Os -o clock.elf clock.c
avr-objcopy -O ihex clock.elf clock.hex
```

### Assembly Version
```bash
avr-as -mmcu=atmega32 -o clock.o clock.asm
avr-ld -o clock.elf clock.o
avr-objcopy -O ihex clock.elf clock.hex
```

### Programming
```bash
avrdude -c usbasp -p m32 -U flash:w:clock.hex
```

## License

Microprocessor Team Mid Project

## Authors

Muhammad Ahmed

Abdullah Adel

El-Hassan Mohamed

Saif El-Eslam Abdullah

Mahmoud Naser

Yousef Mohamed
