<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Digital Clock with Date - ATmega32A</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            line-height: 1.6;
            padding: 20px;
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        header {
            background: linear-gradient(135deg, #2d3748 0%, #1a202c 100%);
            color: white;
            padding: 50px 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px);
            background-size: 50px 50px;
            animation: gridMove 20s linear infinite;
        }

        @keyframes gridMove {
            0% { transform: translate(0, 0); }
            100% { transform: translate(50px, 50px); }
        }

        .header-content {
            position: relative;
            z-index: 1;
        }

        .clock-icon {
            font-size: 80px;
            margin-bottom: 20px;
            display: inline-block;
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }

        h1 {
            font-size: 3em;
            margin-bottom: 10px;
            font-weight: 700;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
            margin-top: 10px;
        }

        .content {
            padding: 40px;
        }

        .section {
            margin-bottom: 40px;
            animation: fadeIn 0.6s ease-out;
            animation-fill-mode: both;
        }

        .section:nth-child(1) { animation-delay: 0.1s; }
        .section:nth-child(2) { animation-delay: 0.2s; }
        .section:nth-child(3) { animation-delay: 0.3s; }
        .section:nth-child(4) { animation-delay: 0.4s; }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        h2 {
            font-size: 2em;
            color: #2d3748;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .icon {
            font-size: 1.3em;
            animation: bounce 2s ease-in-out infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-5px); }
        }

        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .feature-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 25px;
            border-radius: 15px;
            color: white;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }

        .feature-card:hover {
            transform: translateY(-5px) scale(1.02);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .feature-card h3 {
            font-size: 1.3em;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .hardware-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .hardware-item {
            background: #f7fafc;
            padding: 20px;
            border-radius: 12px;
            border-left: 4px solid #667eea;
            transition: all 0.3s ease;
        }

        .hardware-item:hover {
            background: #edf2f7;
            transform: translateX(5px);
        }

        .hardware-item h4 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 1.2em;
        }

        .keypad {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            max-width: 400px;
            margin: 20px auto;
            padding: 20px;
            background: #2d3748;
            border-radius: 15px;
        }

        .key {
            aspect-ratio: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: linear-gradient(145deg, #3a4556, #2d3748);
            border-radius: 10px;
            font-weight: bold;
            color: white;
            font-size: 1.5em;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        }

        .key:hover {
            background: linear-gradient(145deg, #667eea, #764ba2);
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(102, 126, 234, 0.4);
        }

        .key-label {
            font-size: 0.4em;
            margin-top: 5px;
            opacity: 0.8;
        }

        .led-indicator {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin: 10px 15px 10px 0;
            padding: 10px 15px;
            background: #f7fafc;
            border-radius: 8px;
        }

        .led {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            animation: blink 2s ease-in-out infinite;
        }

        .led.green {
            background: #48bb78;
            box-shadow: 0 0 20px #48bb78;
        }

        .led.red {
            background: #f56565;
            box-shadow: 0 0 20px #f56565;
            animation-delay: 0.5s;
        }

        .led.yellow {
            background: #ecc94b;
            box-shadow: 0 0 20px #ecc94b;
            animation-delay: 1s;
        }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
        }

        .code-block {
            background: #2d3748;
            color: #e2e8f0;
            padding: 20px;
            border-radius: 10px;
            margin: 15px 0;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
            position: relative;
        }

        .code-block::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 30px;
            background: #1a202c;
            border-radius: 10px 10px 0 0;
        }

        .code-block pre {
            margin-top: 20px;
        }

        .badge {
            display: inline-block;
            padding: 5px 12px;
            background: #667eea;
            color: white;
            border-radius: 20px;
            font-size: 0.85em;
            margin: 5px 5px 5px 0;
            font-weight: 600;
        }

        footer {
            background: #2d3748;
            color: white;
            padding: 30px 40px;
            text-align: center;
        }

        .team {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }

        .team-member {
            background: rgba(255,255,255,0.1);
            padding: 10px 20px;
            border-radius: 25px;
            transition: all 0.3s ease;
        }

        .team-member:hover {
            background: rgba(255,255,255,0.2);
            transform: scale(1.05);
        }

        @media (max-width: 768px) {
            h1 { font-size: 2em; }
            .content { padding: 20px; }
            .keypad { max-width: 100%; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-content">
                <div class="clock-icon">🕐</div>
                <h1>Digital Clock with Date</h1>
                <p class="subtitle">ATmega32A Microcontroller Project</p>
                <div style="margin-top: 20px;">
                    <span class="badge">C Implementation</span>
                    <span class="badge">Assembly Version</span>
                    <span class="badge">1MHz Operation</span>
                </div>
            </div>
        </header>

        <div class="content">
            <div class="section">
                <h2><span class="icon">✨</span> Features</h2>
                <div class="feature-grid">
                    <div class="feature-card">
                        <h3>⏰ Time Formats</h3>
                        <p>User-selectable 12/24 hour display modes with AM/PM indicator</p>
                    </div>
                    <div class="feature-card">
                        <h3>📅 Date Tracking</h3>
                        <p>Full calendar support with automatic leap year detection</p>
                    </div>
                    <div class="feature-card">
                        <h3>⚙️ Interactive Setup</h3>
                        <p>Easy configuration wizard guides you through initial setup</p>
                    </div>
                    <div class="feature-card">
                        <h3>💡 Visual Feedback</h3>
                        <p>RGB LED indicators provide clear system status at a glance</p>
                    </div>
                    <div class="feature-card">
                        <h3>🔊 Audio Alerts</h3>
                        <p>Buzzer confirmation for all keypress interactions</p>
                    </div>
                    <div class="feature-card">
                        <h3>🔄 System Reset</h3>
                        <p>Complete reset capability with safety confirmation dialog</p>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2><span class="icon">🔧</span> Hardware Requirements</h2>
                <div class="hardware-grid">
                    <div class="hardware-item">
                        <h4>🖥️ Microcontroller</h4>
                        <p>ATmega32A @ 1MHz</p>
                    </div>
                    <div class="hardware-item">
                        <h4>📺 Display</h4>
                        <p>16x2 LCD Display<br>
                        <small>Data: PORTB | Control: PORTD</small></p>
                    </div>
                    <div class="hardware-item">
                        <h4>⌨️ Input</h4>
                        <p>4x4 Matrix Keypad<br>
                        <small>Connected to PORTC</small></p>
                    </div>
                    <div class="hardware-item">
                        <h4>💡 Indicators</h4>
                        <p>3x LEDs + Buzzer<br>
                        <small>Green, Red, Yellow LEDs</small></p>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2><span class="icon">⌨️</span> Keypad Layout</h2>
                <div class="keypad">
                    <div class="key">1</div>
                    <div class="key">2</div>
                    <div class="key">3</div>
                    <div class="key">A<span class="key-label">Set Time</span></div>
                    <div class="key">4</div>
                    <div class="key">5</div>
                    <div class="key">6</div>
                    <div class="key">B<span class="key-label">Set Date</span></div>
                    <div class="key">7</div>
                    <div class="key">8</div>
                    <div class="key">9</div>
                    <div class="key">C<span class="key-label">12/24hr</span></div>
                    <div class="key">*<span class="key-label">Backspace</span></div>
                    <div class="key">0</div>
                    <div class="key">#<span class="key-label">Reset</span></div>
                    <div class="key">D<span class="key-label">Toggle</span></div>
                </div>
            </div>

            <div class="section">
                <h2><span class="icon">💡</span> LED Indicators</h2>
                <div>
                    <div class="led-indicator">
                        <div class="led green"></div>
                        <span><strong>Green LED:</strong> Blinks every second</span>
                    </div>
                    <div class="led-indicator">
                        <div class="led yellow"></div>
                        <span><strong>Yellow LED:</strong> Blinks at top of each hour (3 seconds)</span>
                    </div>
                    <div class="led-indicator">
                        <div class="led red"></div>
                        <span><strong>Red LED:</strong> Illuminates in date display mode</span>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2><span class="icon">📱</span> Display Modes</h2>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-top: 20px;">
                    <div style="background: #f7fafc; padding: 20px; border-radius: 12px; border: 2px solid #667eea;">
                        <h3 style="color: #667eea; margin-bottom: 15px;">⏰ Time Mode (Default)</h3>
                        <div style="background: #1a472a; color: #4ade80; padding: 15px; border-radius: 8px; font-family: monospace; font-size: 1.1em;">
                            12:34:56 PM<br>
                            25-11-2025
                        </div>
                    </div>
                    <div style="background: #f7fafc; padding: 20px; border-radius: 12px; border: 2px solid #764ba2;">
                        <h3 style="color: #764ba2; margin-bottom: 15px;">📅 Date Mode</h3>
                        <div style="background: #1a472a; color: #4ade80; padding: 15px; border-radius: 8px; font-family: monospace; font-size: 1.1em;">
                            25-NOV-2025<br>
                            12:34 PM
                        </div>
                    </div>
                </div>
            </div>

            <div class="section">
                <h2><span class="icon">⚡</span> Compilation & Programming</h2>
                
                <h3 style="margin-top: 20px; color: #667eea;">C Version</h3>
                <div class="code-block">
                    <pre>avr-gcc -mmcu=atmega32 -DF_CPU=1000000UL -Os -o clock.elf clock.c
avr-objcopy -O ihex clock.elf clock.hex</pre>
                </div>

                <h3 style="margin-top: 20px; color: #667eea;">Assembly Version</h3>
                <div class="code-block">
                    <pre>avr-as -mmcu=atmega32 -o clock.o clock.asm
avr-ld -o clock.elf clock.o
avr-objcopy -O ihex clock.elf clock.hex</pre>
                </div>

                <h3 style="margin-top: 20px; color: #667eea;">Programming the Device</h3>
                <div class="code-block">
                    <pre>avrdude -c usbasp -p m32 -U flash:w:clock.hex</pre>
                </div>
            </div>

            <div class="section">
                <h2><span class="icon">🎯</span> Technical Highlights</h2>
                <ul style="list-style: none; padding: 0;">
                    <li style="padding: 10px; margin: 5px 0; background: #f7fafc; border-left: 4px solid #48bb78; border-radius: 5px;">✓ Timer0 in CTC mode for precise 10ms interrupts</li>
                    <li style="padding: 10px; margin: 5px 0; background: #f7fafc; border-left: 4px solid #48bb78; border-radius: 5px;">✓ Automatic date advancement at midnight</li>
                    <li style="padding: 10px; margin: 5px 0; background: #f7fafc; border-left: 4px solid #48bb78; border-radius: 5px;">✓ Leap year calculation (2000-2099 range)</li>
                    <li style="padding: 10px; margin: 5px 0; background: #f7fafc; border-left: 4px solid #48bb78; border-radius: 5px;">✓ Debounced keypad scanning</li>
                    <li style="padding: 10px; margin: 5px 0; background: #f7fafc; border-left: 4px solid #48bb78; border-radius: 5px;">✓ Non-volatile time tracking (while powered)</li>
                </ul>
            </div>
        </div>

        <footer>
            <h3 style="margin-bottom: 10px;">📚 Microprocessor Team Mid Project</h3>
            <p style="opacity: 0.9; margin-bottom: 15px;">Developed with passion and precision</p>
            <div class="team">
                <div class="team-member">👨‍💻 Muhammad Ahmed</div>
                <div class="team-member">👨‍💻 Abdullah Adel</div>
                <div class="team-member">👨‍💻 El-Hassan Mohamed</div>
                <div class="team-member">👨‍💻 Saif El-Eslam Abdullah</div>
                <div class="team-member">👨‍💻 Mahmoud Naser</div>
                <div class="team-member">👨‍💻 Yousef Mohamed</div>
            </div>
            <p style="margin-top: 20px; opacity: 0.7;">© 2025 - Built for ATmega32A</p>
        </footer>
    </div>
</body>
</html>
