execute iPad tests:

sh buildAndTest.sh

execute iPhone tests:

sh buildAndTestIphone.sh

further test javascript files to be executed should be added in the .sh files. Copy-paste the whole of the last instruments command and change the .js file name.

the choose_sim_device binary is from https://github.com/jonathanpenn/ui-screen-shooter/ and can be set to test more specific devices, like 3.5" iphone, retina etc.

SimulatorReset.txt is an applescript which simulates menu commands in the simulator to reset the simulator content to ensure a fresh install every time.