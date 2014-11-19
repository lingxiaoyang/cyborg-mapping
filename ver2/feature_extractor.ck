/*
   Feature extractor for Cyborg 3D Gold joystick.

   Positions only.

   (c) 2014 Ling-Xiao Yang
*/

public class CustomFeatureExtractor {
  0 => int isExtracting;
  1 => int isOK;
  7 => int numFeats;  // button 2, axis 0~3, button 4, button 5
  1 => int isFirst;
  new float[numFeats] @=> float features[]; //store computed features in this array
  50::ms => dur defaultRate => dur rate; //optionally change

  0.0 => float last_x;
  0.0 => float last_y;

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
          msg.axisPosition => features[1 + msg.which];
        }
        // joystick button down
        else if( msg.isButtonDown() && msg.which == 2 ) {
          1 => features[0];
        }
        // joystick button up
        else if( msg.isButtonUp() && msg.which == 2) {
          0 => features[0];
        }
        else if( msg.isButtonDown() && msg.which == 4) {
          1 => features[5];
        }
        else if( msg.isButtonUp() && msg.which == 4) {
          0 => features[5];
        }
        else if( msg.isButtonDown() && msg.which == 5) {
          1 => features[6];
        }
        else if( msg.isButtonUp() && msg.which == 5) {
          0 => features[6];
        }
      } //while receive message
    } //while true
  } //end function

  fun string[] getFeatureNamesArray() {
    new string[numFeats] @=> string s[];
    "Button 2" => s[0];
    "Axis 0" => s[1];
    "Axis 1" => s[2];
    "Axis 2" => s[3];
    "Axis 3" => s[4];
    "Button 4" => s[5];
    "Button 5" => s[6];
    return s;
  }
} //end class
