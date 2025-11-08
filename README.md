<div align="center">
🕐✨ Digital Clock with Date ✨🕐
ATmega32A Microcontroller Project
<img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=32&duration=2800&pause=2000&color=6366F1&center=true&vCenter=true&width=600&lines=Real-Time+Digital+Clock;Full+Calendar+Support;12%2F24+Hour+Format;Leap+Year+Detection" alt="Typing SVG" />
Show Image
Show Image
Show Image
Show Image
<img src="https://user-images.githubusercontent.com/74038190/212284100-561aa473-3905-4a80-b561-0d28506553ee.gif" width="700">
🎯 A Full-Featured Real-Time Clock with Advanced Date Tracking
⚡ Features • 🔧 Hardware • 📥 Installation • 🎮 Usage • 👥 Team

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🕐 Time Management
- ⏰ **12/24 Hour Format** - User-selectable display mode
- 🔄 **Automatic Updates** - Real-time clock with second precision
- 🌙 **AM/PM Indicator** - Clear time period display in 12hr mode

### 📅 Date Tracking  
- 📆 **Full Calendar** - Complete date tracking (DD-MM-YYYY)
- 🗓️ **Leap Year Support** - Automatic detection (2000-2099)
- 🌍 **Auto Advancement** - Date changes at midnight

</td>
<td width="50%">

### 🎛️ User Interface
- ⚙️ **Setup Wizard** - Interactive initial configuration
- ⌨️ **Keypad Input** - 4x4 matrix with debouncing
- 📺 **Dual Display Modes** - Time-focused or date-focused views

### 🎨 Feedback Systems
- 💡 **RGB LEDs** - Visual status indicators (3 colors)
- 🔊 **Buzzer Alerts** - Audio confirmation for inputs
- 🔴 **Mode Indicators** - LED states show system status

</td>
</tr>
</table>

---

## 🔧 Hardware Requirements

### 🖥️ Microcontroller
```
ATmega32A @ 1MHz
```

### 📺 Display Module
| Component | Connection | Pins |
|-----------|------------|------|
| **16x2 LCD** | 8-bit Parallel | Data: `PB0-PB7` |
| | | Control: `RS=PD0, RW=PD1, EN=PD2` |

### ⌨️ Input Device
| Component | Connection | Pins |
|-----------|------------|------|
| **4x4 Matrix Keypad** | PORTC | Rows: `PC0-PC3` |
| | | Columns: `PC4-PC7` |

### 💡 Output Indicators
| Component | Pin | Function |
|-----------|-----|----------|
| 🟢 **Green LED** | `PD3` | Seconds blink |
| 🔴 **Red LED** | `PD4` | Date display mode |
| 🟡 **Yellow LED** | `PD5` | Hour indicator |
| 🔊 **Buzzer** | `PD6` | Audio feedback |

---

## ⌨️ Keypad Layout & Functions

```
┌─────┬─────┬─────┬─────────────────┐
│  1  │  2  │  3  │  A  Set Time    │
├─────┼─────┼─────┼─────────────────┤
│  4  │  5  │  6  │  B  Set Date    │
├─────┼─────┼─────┼─────────────────┤
│  7  │  8  │  9  │  C  12/24 Mode  │
├─────┼─────┼─────┼─────────────────┤
│  *  │  0  │  #  │  D  Toggle View │
└─────┴─────┴─────┴─────────────────┘
```

### 🎮 Key Functions

| Key | Function | Description |
|-----|----------|-------------|
| **A** | ⏰ Set Time | Enter time with AM/PM selection (12hr mode) |
| **B** | 📅 Set Date | Enter date in DD-MM-YYYY format |
| **C** | 🔄 Toggle Format | Switch between 12-hour and 24-hour display |
| **D** | 📱 Toggle Display | Switch between time mode and date mode |
| **#** | 🔄 System Reset | Complete reset with confirmation dialog |
| **\*** | ⌫ Backspace | Delete last character during input |
| **0-9** | 🔢 Numbers | Numeric input for time and date |

---

## 📱 Display Modes

### 🕐 Time Mode (Default)
```
┌────────────────┐
│ 12:34:56 PM   │  ← Time with seconds
│ 25-11-2025    │  ← Current date
└────────────────┘
```

### 📅 Date Mode
```
┌────────────────┐
│ 25-NOV-2025   │  ← Date with month name
│ 12:34 PM      │  ← Time without seconds
└────────────────┘
```

---

## 💡 LED Indicator States

| LED | State | Meaning |
|-----|-------|---------|
| 🟢 **Green** | Blinks every second | System running / Second counter |
| 🟡 **Yellow** | Blinks for 3 seconds | Top of the hour indicator |
| 🔴 **Red** | Solid ON | Date display mode active |

---

## 🚀 Getting Started

### 📋 Prerequisites

- AVR GCC Toolchain
- AVRDUDE programmer
- USBasp or compatible programmer
- Proteus (for simulation)

### 💾 Installation

#### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/atmega32-digital-clock.git
cd atmega32-digital-clock
```

#### 2️⃣ Compile C Version
```bash
avr-gcc -mmcu=atmega32 -DF_CPU=1000000UL -Os -o clock.elf clock.c
avr-objcopy -O ihex clock.elf clock.hex
```

#### 3️⃣ Compile Assembly Version
```bash
avr-as -mmcu=atmega32 -o clock.o clock.asm
avr-ld -o clock.elf clock.o
avr-objcopy -O ihex clock.elf clock.hex
```

#### 4️⃣ Program the Device
```bash
avrdude -c usbasp -p m32 -U flash:w:clock.hex
```

---

## 🎯 Usage Guide

### 🔧 Initial Setup

On first boot or after system reset:

1. **Select Time Format**
   ```
   Press [C] to toggle between 12hr/24hr format
   ```

2. **Set Current Time**
   ```
   Press [A] → Enter time → Confirm
   (In 12hr mode, select AM/PM)
   ```

3. **Set Current Date**
   ```
   Press [B] → Enter DD-MM-YYYY → Confirm
   ```

4. **System Starts Running** ✅

### 🎮 Daily Operations

- **View Date**: Press `[D]` to toggle to date mode
- **View Time**: Press `[D]` again to return to time mode
- **Change Format**: Press `[C]` to switch 12/24 hour format
- **Adjust Time**: Press `[A]` and enter new time
- **Adjust Date**: Press `[B]` and enter new date
- **Reset System**: Press and hold `[#]`, confirm when prompted

---

## 🛠️ Technical Details

### ⚙️ System Architecture

```
┌─────────────────────────────────────────┐
│           ATmega32A @ 1MHz              │
├─────────────────────────────────────────┤
│ • Timer0: CTC Mode (10ms interrupts)    │
│ • PORTB: LCD Data (8-bit)               │
│ • PORTC: Keypad Matrix                  │
│ • PORTD: LCD Control + LEDs + Buzzer    │
└─────────────────────────────────────────┘
```

### 🔬 Key Features

- ✅ **Timer0 Configuration**: CTC mode for precise 10ms interrupts
- ✅ **Auto Date Advance**: Automatic rollover at midnight
- ✅ **Leap Year Logic**: Accurate calculation for 2000-2099
- ✅ **Keypad Debouncing**: Software debouncing for reliable input
- ✅ **Non-volatile Tracking**: Time persists while powered
- ✅ **Modular Code**: Clean separation of concerns

### 📊 Memory Usage

| Section | C Version | Assembly Version |
|---------|-----------|------------------|
| Program | ~4KB | ~2KB |
| Data | ~256B | ~128B |
| Stack | ~512B | ~256B |

---

## 📁 Project Structure

```
atmega32-digital-clock/
│
├── 📄 README.md              # This file
├── 💻 clock.c                # C implementation
├── ⚙️ clock.asm              # Assembly implementation  
├── 📋 clock.h                # Header definitions
├── 🔧 Makefile               # Build automation
├── 🎨 schematic.pdf          # Hardware schematic
├── 🖼️ simulation.pdsprj     # Proteus simulation
│
├── docs/                     # Documentation
│   ├── 📖 user_manual.md
│   ├── 🔌 hardware_guide.md
│   └── 💡 troubleshooting.md
│
└── examples/                 # Example configurations
    ├── 12hr_mode.c
    └── 24hr_mode.c
```

---

## 🐛 Troubleshooting

<details>
<summary><b>⚠️ LCD not displaying</b></summary>

- Check all connections to PORTB and PORTD
- Verify contrast potentiometer setting
- Ensure 5V power supply is stable
- Check EN pulse timing (might need adjustment for 1MHz)
</details>

<details>
<summary><b>⚠️ Keypad not responding</b></summary>

- Verify PORTC connections (rows and columns)
- Check pull-up resistors on column lines
- Ensure proper debounce delay values
- Test individual keys with multimeter
</details>

<details>
<summary><b>⚠️ Time drifting</b></summary>

- Verify F_CPU is set to 1000000UL
- Check crystal oscillator accuracy
- Ensure Timer0 prescaler is correct (1024)
- Recalibrate OCR0 value if needed
</details>

<details>
<summary><b>⚠️ LEDs not working</b></summary>

- Check PD3, PD4, PD5 connections
- Verify current limiting resistors (220Ω-330Ω)
- Ensure DDR register configuration
- Test with simple blink program
</details>

---

## 🎓 Learning Resources

- 📚 [ATmega32A Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/doc2503.pdf)
- 🎥 [AVR Timer Tutorial](https://www.youtube.com/watch?v=example)
- 📖 [LCD Interfacing Guide](https://www.electronicwings.com/)
- 🔧 [Keypad Matrix Tutorial](https://www.circuitbasics.com/)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is part of a Microprocessor course mid-term project.  
Feel free to use and modify for educational purposes.

---

## 👥 Team

<div align="center">

| 👨‍💻 Developer | 🎯 Role |
|--------------|---------|
| **Muhammad Ahmed** | Lead Developer |
| **Abdullah Adel** | Hardware Designer |
| **El-Hassan Mohamed** | Software Engineer |
| **Saif El-Eslam Abdullah** | Testing & QA |
| **Mahmoud Naser** | Documentation |
| **Yousef Mohamed** | Assembly Optimization |

</div>

---

## 🌟 Acknowledgments

- Thanks to our instructors for guidance
- AVR community for excellent documentation
- Microchip for comprehensive datasheets

---

**⭐ Star this repo if you find it helpful!**

Made with ❤️ by the Microprocessor GP (5&6) Team

</div>

---

## 📊 Project Statistics

![Lines of Code](https://img.shields.io/badge/Lines%20of%20Code-2500%2B-blue)
![Functions](https://img.shields.io/badge/Functions-25%2B-green)
![Commits](https://img.shields.io/badge/Commits-50%2B-orange)
![Contributors](https://img.shields.io/badge/Contributors-6-red)

---

<div align="center">

**[⬆ Back to Top](#-digital-clock-with-date---atmega32a)**

</div>
