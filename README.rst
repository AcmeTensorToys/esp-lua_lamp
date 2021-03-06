#################
Remote Touch Lamp
#################

This somewhat sizable project is a re-implementation of
http://filimin.com/ of sorts.  It speaks MQTT and uses a CAP1188 for
local touch sensing.  Display is via a grid of so-called "NeoPixel" LEDs.

Motivation, pictures, and additional discussion can be found at
http://www.ietfng.org/nwf/ee/purple-lamp.html

Hardware V1
###########

The first reification of this project was made using largely the Adafruit
Feather stack of components, as well as some others.  A complete BoM is:

+------------------------+---------------------------------------------+
| Case                   | https://www.adafruit.com/products/903       |
+------------------------+---------------------------------------------+
| Feed Cable             | https://www.adafruit.com/products/744       |
+------------------------+---------------------------------------------+
| USB female             | https://www.adafruit.com/products/1833      |
+------------------------+---------------------------------------------+
| USB male               | https://www.sparkfun.com/products/10031     |
+------------------------+---------------------------------------------+
| Battery                | https://www.adafruit.com/products/328       |
+------------------------+---------------------------------------------+
| CPU                    | https://www.adafruit.com/products/2821      |
+------------------------+---------------------------------------------+
| LED array              | https://www.adafruit.com/products/2945      |
+------------------------+---------------------------------------------+
| FeatherWing Doubler    | https://www.adafruit.com/products/2890      |
+------------------------+---------------------------------------------+
| CAP1188 breakout board | https://www.adafruit.com/products/1602      |
+------------------------+---------------------------------------------+
| Stacking headers       | https://www.adafruit.com/products/2830      |
+------------------------+---------------------------------------------+
| Female headers         | https://www.adafruit.com/products/2886      |
+------------------------+---------------------------------------------+
| Copper Tape            | https://www.adafruit.com/products/1128      |
+------------------------+---------------------------------------------+
| M/F jumper wires       | https://www.adafruit.com/products/826       |
+------------------------+---------------------------------------------+
| F/F jumper wires       | https://www.adafruit.com/products/266       |
+------------------------+---------------------------------------------+

The suggested configuration of the feather stack (hardly mandatory) is
that the FeatherWing Doubler have two sets of female headers, the RGB array
have male-only headers (downwards, for mating with the Doubler), and that
the ESP8266 have stacking headers in place.  Hookup is then via the exposed
female connectors on the top of the ESP8266 board.  One could, instead,
stack the RGB array atop the ESP8266 and hookup via the Doubler's female
headers, or do away with the Doubler entirely and hook the male pins on the
ESP8266, etc.

Revision 1.1
============

An AND gate (actually, a 7408) was added to gate serial access to the WS2812.
On boot, the ESP8266 emits debugging information to its alternate serial
console, which is also the ws2812 data source (ESP GPIO 2).  This results in
some blindingly bright light when the machine boots or crashes.  The AND gate
effectively prevents the chip from writing to the ws2812 matrix unless another
GPIO (specifically, ESP GPIO 0) is pulled high as well.

The WS2812 LED array from AdaFruit allows for one of many pins to be
selected for the WS2812 input line; as the ESP8266 does not use all of the
possible I/O lines of the Feather design, a free signal (N/C to the ESP8266
Feather Huzzah CPU board) was chosen instead and the AND gate's output
routed back into the stack on this line.  We used the Feather pin immediately
below ADC; that is, the 6th pin from RST to convey this gated signal; on the
Feather NeoPixel board, this is selected by the jumper that sits below and
between the "e" and "a" in the big "feather" silkscreen.

ESP IO
######

The various boards are interfaced as follows:

+--------------+----------------------------------------------------------+
| ESP GPIO Pin | Function                                                 |
+--------------+----------------------------------------------------------+
| 0            | WS2812 AND-gate input (see Revision 1.1, above)          |
+--------------+----------------------------------------------------------+
| 2            | WS2812 serial shift out (to LED array input)             |
+--------------+----------------------------------------------------------+
| 4            | I2C SDA pin (to CAP1188, optional expansion)             |
+--------------+----------------------------------------------------------+
| 5            | I2C SCL pin (to CAP1188, optional expansion)             |
+--------------+----------------------------------------------------------+
| 12           | CAP1188 IRQ (from CAP1188)                               |
+--------------+----------------------------------------------------------+
| 14           | CAP1188 RESET (to CAP1188)                               |
+--------------+----------------------------------------------------------+

If GPIO becomes precious, the CAP1188 IRQ and RESET pins could be moved
behind an I2C IO expander as they are low bandwidth.  (The expander itself
would presumably merit an IRQ pin and the CAP1188 IRQ could be demuxed.)

Theory of Operation
###################

Drawings
########

Drawings are kept in the filesystem and are only loaded on demand, in an
effort to improve exensibility and keep heap usage low.

``init2.lua`` publishes a global function ``loaddrawfn(name)`` which rummages
through the filesystem to load ``draw-${name}.lc``.  These files are
expected to *return a function* which takes, in order,

* a timer, for use in animations.  It is guaranteed that this timer is
  *unregistered* at the time of entry to the drawing functions, so there is
  no need for static images to do so.  The timer will be started after the
  drawing function returns and will be stopped when appropriate by the rest
  of the system.

* a ws2812 framebuffer object into which all drawing should happen.  This
  framebuffer should be closed over in any timer callbacks.

* A color palette array.  Each entry is a string of three, where the bytes
  form the green, red, and blue color values (0-255), as per ws2812 byte
  ordering.  Most drawings will simply use entry 1.

These drawing functions should return a table containing the following keys:

+-------------+-----------------------------------------------------------+
| ``ncolors`` | The number of colors taken from the palette, default 1.   |
+-------------+-----------------------------------------------------------+
| ``cccb``    | A callback function for color palette changes;            |
|             | if ``nil`` (default), no notifications will be given and  |
|             | the animation will be restarted on such changes.          |
+-------------+-----------------------------------------------------------+

Returning ``nil`` from the drawing function is equivalent to returning a
table with all defaults (i.e., 1 color, no notification on changes).

``lamp-touch.lua`` (see below) knows the naming scheme used by ``init2.lua``
and so walks the list of files on the system looking for files whose name
matches the Lua regex ``draw-(%w+).lc`` and builds a table of all such
internally.

Touch UI
########

``init2.lua`` hooks the CAP1188 IRQ pin and dispatches to ``lamp-touch.lua``
to handle the user interface.  Once this file is loaded, it *replaces* the
IRQ hook with its own function and unregisters itself (by replacing itself
with ``init2.lua``'s ``ontouch_load`` function) after a timeout of no
interaction from the user.  See ``ontouchdone``.

At present, there are five used touch channels:

* A "blackout" button, which disables drawing to the display and any other
  user interaction until touched again.  This button may be toggled at most
  once per touch; once toggled, the system will not toggle blackout again
  until the touch sensor has been untouched for a timeout (see
  ``touch_db_blackout``).
  
  This provides a crude "debounce" facility and allows
  for things like moving the lamp to a new surface (with new conductive
  properties) by gripping it in a way that touches this sensor and holding
  it on the new surface for some seconds to allow the CAP1188 to
  recalibrate.

* A dim control.  Each press advances the display dimming factor along a
  triangle wave -- that is, dimmer to minimum brightness, then brighter to
  maximum brightness, then dimmer again, etc.  At present, there are 7
  "stops" in each direction.

* Two color-wheel controls.  One advances "quickly", one reverses "slowly"
  and, if both are active, the wheel advances "slowly".

* A shape selector toggle.  This advances through the collections of
  drawings enumerated at the beginning of a touch event.  This interaction
  is rate-limited, so that holding the button will only slowly advance
  through the space of drawings (see ``touch_db_fn``).  Note that releasing
  the button immediately clears the timeout, unlike blackout above.

  Combining this shape selector with the "reverse" color wheel control will
  reverse the shape selection as well.
  
  Each separate touch interaction will reload the list for ease of
  development.


Notes
#####

The lamp has a primitive command interpreter listening on port 23.  Each
command must fit entirely within one TCP packet, a complete and utter abuse
of the protocol, but one that can usually be reasonably achieved.

Useful commands include:

* ``cap calibrate`` to force the CAP1188 to go through a calibration cycle.
  While the module is configured to recalibrate itself periodically
  automatically, one may wish to do so sooner especially if the sensors are
  in a new environment that is just below the threshold of triggering
  automatic recalibration.

* ``diag exec LUA`` will ``pcall(loadstring(LUA))``, providing an emergency
  escape hatch into the Lua interpreter without needing console access

* ``file list`` will enumerate files on the flash

* ``file info`` will show used and free space

* ``file pwrite ...`` can write to the filesystem; don't use it by hand
  unless you're *especially* masochistic.  Use ``host/pushvia.expect`` to
  drive.

* ``file compile FILE`` invokes ``node.compile(FILE)``

* ``file remove FILE`` removes ``FILE``.

* ``diag heap`` will display the number of free heap bytes

NodeMCU modules
===============

Be sure to build the following modules into the firmware:

* ``bit`` -- for I/O port work inside the touch handler
* ``cron`` -- framework usage (e.g. reconnection timers)
* ``crypto`` -- used by the telnet file service for hashing
* ``encoder`` -- used by the telnet file service for base64 work
* ``file`` -- used by the telnet file service
* ``gpio`` -- for the AND gate
* ``i2c`` -- for I/O by the touch handler
* ``mDNS`` -- framework usage
* ``MQTT`` -- yes
* ``net`` -- yes
* ``node`` -- yes
* ``sjson`` -- framework usage
* ``sntp`` -- framework usage
* ``timer`` -- yes
* ``wifi`` -- yes
* ``ws2812`` -- the display itself

Rebuilding the Firmware
=======================

NodeMCU offers many ways to program the firmware, but the simplest way, the
most "with the grain", if you will, is to generate three files:

* The base NodeMCU firmware, which contains the above modules.

* The LFS image, which will contain most of nwf's "core" Lua modules.  See
  ``mklfs.sh``

* The SPIFFS image, containing the lamp's lua, drawings, and
  configuration data.  See ``mkspiffs.sh``

The lamp lua is kept in SPIFFS nominally so that it's easy to tinker without
requiring a full reprogram.  In practice this only sort of works.

Run the various build scripts and then program the board, for example::

    ./core/firm/tools/toolchains/esptool.py write_flash \
     --flash_size 4MB --flash_mode dio --verify \
     0x0      ./core/firm/bin/nodemcu_integer_lamp.bin \
     0x3fc000 ./core/firm/sdk/esp_iot_sdk_v3.0-e4434aa/bin/esp_init_data_default_v05.bin

    ./core/firm/tools/nodemcu-partition.py \
     --flash_size 4MB \
     --lfs_size 131072 --lfs_file _lfs_build/luac.out \
     --spiffs_file spiffs.img

