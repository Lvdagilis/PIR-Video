# PIR-Video
Processing-based video-playback program to play video when movement is detected, and pause when not.
Originally created for a retrospective installation _Timestamps_ (EN: http://www.ndg.lt/exhibitions/present/timestamps.aspx, LT: http://www.ndg.lt/parodos/parodos/laikmenos.aspx) at the National Art Gallery in Vilnius, Lithuania. The program allows the gallery space to quiet down, fall asleep without any viewers, and each work activates as viewers approach the designated areas. 
This version specifically is written for a RaspberryPi using Processing and a cheap PIR sensor, but can be easily adapted for other uses. Please get in touch in case your museum/gallery would like this to be customized for your use case!

<h1>Setup</h1>

#Hardware
0. Connect PIR sensor to Raspberry PI.
	In case you'd like to use the code provided without needing further modifications, use these pins:
		Sensor pin to	GPIO21 
		PWR pin to 	GPIO4
		GND pin to 	GPIO6
	Please note that different PIR sensor have different layouts, so check accordingly. On some PIR sensors the pinout is underneath the fresnel lens (which can be very easily removed and replaced)

#Software
In practice, this should be possible without needing to use Processing for Pi OS, however, between testing on various RaspberryPis with various states of OS (from fresh installs to old hacked ones), the process of getting the video libraries to run at a high framerate, while keeping an easy install process was just too unreliable. Sometimes it worked, sometimes it didn't, even if following the same steps on a fresh install on the same RPi.

1. Install the Processing for Pi OS using Raspberry Pi Imager
1. a. Download Raspberry Pi Imager from https://www.raspberrypi.org/software/
1. b. Download Processing for Pi Image from Processing.org https://pi.processing.org/download/
1. c. In Raspberry Pi Imager: "Choose OS" -> "Use custom" -> select the image you downloaded in step 1.b.
1. d. Select the blank SD card/USB stick you'll be using for the OS install
1. e. "Write"

2. Launch the RaspberryPi

3. Download and copy the PIRVideo files onto the Pi. This tutorial uses /home/pi/GPIOv11 as the location fo the files

4. Add the desired video to /home/pi/PIRVideo/data. By default, the program is set to use a file called "movie.mp4"
4. a. In case you have a different filename (recommend to use .mp4 encoding), you can change the filename in the config.txt

Change timer (optional)
5. If needed, you can change the timer integrated into the program (in testing, the PIR sensor delays were very inaccurate). Enter the desired delay in the first line of config.txt, in milliseconds (ex.: 20s = 20000).

Hide the RPi taskbar (optional)
6. Right-click on taskbar, select "Panel Preferences" -> Advanced -> Properties -> uncheck "Reserve space, and not covered by maximised windows"


Set-up an autostart to launch the program every time the RPI receives power. (optional)
7. Open the terminal and enter the following:programa automatiskai pasileistu kai ijungiamas raspberry, paleidus RPi atidaryti terminal ir vesti sias komandas:

	mkdir /home/pi/.config/autostart
	sudo nano /home/pi/.config/autostart/PIRVideo.desktop

Then, paste the following code:
___________________________
	[Desktop Entry]
	Type=Application
	Name=GPIO
	Exec=processing-java --sketch=/home/pi/PIRVideo --present
_______________________________
After pasting-  ctrl+x -> Y -> enter

8. Restart the Pi



#DEBUG MODE

In case you'd like to test the functionality without having to restart, or manually launch through processing's GUI, you can simply enter the following command into terminal:

	processing-java --sketch=/home/pi/PIRVideo --present

Additionally, pressing 'd' in the sketch will launch a debug mode!

Debug mode info:
motion		Shows whether the PIR is showing as seeing motion (1=motion, 0=no motion)
Playing		Shows whether the video is playing
Delay		If there is currently active movement (i.e. the PIR sees movement, or the delay built-into the PIR from the last movement hasn't passed since last movement) - delay will show the full delay time. Once the PIR sends 0 for motion - the software delay will start counting down, and video should stop at 0
Movie available	If false - means there's frame skipping, file is in an incorrect format, unreadable, or some other issue with this.
Movie time	Shows the current frame - good for checking your performance. High-res videos on the Pi will cause significant FPS drops.
config time	Shows the delay time that's set in the config.txt file
"" movie name	Shows the movie filename set in config.txt, good to check in case you're having issues with Movie Available

The debug was designed to be easy to understand visually from afar (as the installation was meant for large-scale projections with no more than 1080p resolution), so one could troubleshoot from near the projector/sensor, even if they are far from the screen. Hence:

TOP LEFT 	White when motion, fades to black (in time with the delay) once motion is no longer detected 
TOP RIGHT	Video preview
BOTTOM HALF	Debug text, white background when motion = 1, black background when motion = 0. 


