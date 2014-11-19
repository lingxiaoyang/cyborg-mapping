/*
   Feature extractor for Cyborg 3D Gold joystick.

   Positions only.

   (c) 2014 Ling-Xiao Yang
*/

public class CustomFeatureExtractor {
  0 => int isExtracting;
  1 => int isOK;
  15 => int numFeats;  // button 0~9, axis 10~13, hat 14
  1 => int isFirst;
  new float[numFeats] @=> float features[]; //store computed features in this array
  50::ms => dur defaultRate => dur rate; //optionally change

  fun void setup() {
    0 => isExtracting;
    1 => isOK;
    new float[numFeats] @=> float features[];
    for (0 => int i; i < features.cap(); i++) {
      0 => features[i];
    }
    defaultRate => rate;
  }

  fun void setup(int n) {
    setup();
    if (n != numFeats) {
      0 => isOK;
      <<< "Error: Chuck & GUI don't agree on the number of features!">>>;
    }
  }

  fun float[] getFeatures() {
    return features;
  }

  fun int numFeatures() {
    return numFeats;
  }

  fun void extract() {
    1 => isExtracting;
    if (isFirst) {
      spork ~getInput();
      0 => isFirst;
      while (true) {
        rate => now;
      }
    }
  }

  fun void stop() {
    0 => isExtracting;
  }

  fun void check() {
    while (true) {
      <<< "Features are: ", features>>>;
      .1::second => now;
    }
  }

  fun void getInput() {
    // the device number to open
    0 => int deviceNum;

    HidIn hi;
    HidMsg msg;
    // open joystick
    if( !hi.openJoystick( deviceNum ) ) {
      <<< "ERROR OPENING JOYSTICK">>>;
      me.exit();
    }
    // successful! print name of device
    <<< "joystick '", hi.name(), "' ready" >>>;

    while( true ) {
      hi => now;

      while( hi.recv( msg ) ) {
          // joystick axis motion
        if( msg.isAxisMotion() ) {
          msg.axisPosition => features[10 + msg.which];
        }
        // joystick button down
        else if( msg.isButtonDown() && msg.which < 10 ) {
          1 => features[msg.which];
        }
        // joystick button up
        else if( msg.isButtonUp() && msg.which < 10) {
          0 => features[msg.which];
        }
        // joystick hat/POV switch/d-pad motion
        else if( msg.isHatMotion() ) {
          msg.idata => features[14];
        }
      } //while receive message
    } //while true
  } //end function

  fun string[] getFeatureNamesArray() {
    string s[numFeats];
    "Button 0" => s[0];
    "Button 1" => s[1];
    "Button 2" => s[2];
    "Button 3" => s[3];
    "Button 4" => s[4];
    "Button 5" => s[5];
    "Button 6" => s[6];
    "Button 7" => s[7];
    "Button 8" => s[8];
    "Button 9" => s[9];
    "Axis 0" => s[10];
    "Axis 1" => s[11];
    "Axis 2" => s[12];
    "Axis 3" => s[13];
    "Hat" => s[14];
    return s;
  }
} //end class
