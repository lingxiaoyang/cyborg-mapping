/*  Simple synth skeleton with 1 continuous & 1 discrete parameter
    To make your own synth, edit everywhere marked TODO below

    Copyright 2011 Rebecca Fiebrink
    http://wekinator.cs.princeton.edu
*/

//The synth always lives in a SynthClass definition
public class SynthClass {

  //Don't change this part: necessary state objects and overall envelope
  OscSend xmit;
  0 => int isSendingParams;
  50::ms => dur rate;
  Envelope e => dac;
  .1::second => e.duration;
  0 => e.target => e.value;
  e.keyOn();

  // parameters
  6 => int numParams;
  float myParams[numParams];

  //TODO: Add your own objects for making sound
  //and patch them together, output to the envelope
  0.0 => myParams[0];
  1.0 => myParams[1];
  0.1 => myParams[2];
  0.0 => myParams[3];
  0.0 => myParams[4];
  0.0 => myParams[5];

  //// recording pipeline
  //new WvOut @=> WvOut @ rec;
  adc => WvOut rec => blackhole;

  //// playing pipeline
  //new SndBuf @=> SndBuf @ snd;
  SndBuf snd => NRev rev => e => Gain playing_gain;
  Noise noise => ADSR noise_env => Gain noise_gain => rev;
  (2::second, 0::second, 1.0, 2::second) => noise_env.set;
  0.03 => noise_gain.gain;
  1 => playing_gain.gain;

  0 => int is_recording;

  "/Users/lyang/libmapper/cyborg/ver2/sound.wav" => string filepath;

  //TODO: Are your parameters discrete (integers) or continuous (real numbers)?
  //This determines the learning algorithms available in the GUI
  fun int[] isDiscreteArray() {
    new int[numParams] @=> int a[]; //a is a temporary array whose length is the number of parameters (2 here)
    1 => a[0]; //1 means this parameter is discrete
    0 => a[1]; //0 means this parameter is continuous (not discrete)
    0 => a[2];
    0 => a[3];
    1 => a[4];
    1 => a[5];
    return a;
  }

  //TODO: If you are using a discrete model, you must specify
  //the number of classes of output (maximum) that you want to learn
  //For example, to learn a "vowel vs. consonant" classifier, you would have 2 classes
  //Or to output a class for each pitch chroma, you would have 12 classes
  //It doesn't matter what number you use for a continuous parameter, since it'll be ignored
  fun int[] getNumClassesArray() {
    new int[numParams] @=> int a[];
    2 => a[0];
    2 => a[4];
    2 => a[5];
    return a;
  }

  //TODO: For each discrete parameter, you must specify
  //whether you just want the integer class label output for each parameter, or whether
  //you want the output to consist of a probability distribution over all classes
  fun int[] useDistributionArray() {
    new int[numParams] @=> int a[];
    0 => a[0]; //Let's not use a distribution (would be 1 otherwise)
    0 => a[4];
    0 => a[5];
    return a;
  }

  //TODO: Give your parameters some names, which will be shown in the GUI
  fun string[] getParamNamesArray() {
    new string[numParams] @=> string s[];
    "noise" => s[0];
    "dur" => s[1];
    "speed" => s[2];
    "pos" => s[3];
    "recording" => s[4];
    "playing" => s[5];
    return s;
  }

  //TODO: Any other setup code that should be called
  //This is called by the main code, only once after initialization, like a constructor
  fun void setup() {
    //Spork things here if necessary, then return.
    spork ~playSound();
  }

  fun void playSound() {
    while (true) {
      if (is_recording == 1) {
        0 => playing_gain.gain;
      } else {
        1 => playing_gain.gain;
        myParams[3] $ int => snd.pos;
      }
      (myParams[1])::ms => now;
    }
  }

  //TODO: This gets called when the model provides us with new parameter values
  //Specify how you want to use them!
  //Want to do error checking here (e.g., that parameters are within the expected range,
  // and that we have the expected number of parameters)
  // Make sure you both use the new params to make sound AND store the values in myParams[].
  fun void setParams(float params[]) {
    if (params.size() >= numParams) {       //always check you have at least as many params as you're expecting

      params[0] => myParams[0];
      if (myParams[0] == 1.0)
        noise_env.keyOn();
      else
        noise_env.keyOff();

      params[1] * 700 + 50 => myParams[1];
      if (myParams[1] > 700)
        700 => myParams[1];
      if (myParams[1] < 50)
        50 => myParams[1];

      params[2] * 3 => myParams[2];
      if (myParams[2] > 3)
        3 => myParams[2];
      if (myParams[2] < 0.1)
        0.1 => myParams[2];
      myParams[2] => snd.rate;

      params[3] * snd.samples() => myParams[3];
      if (myParams[3] < 0)
        0 => myParams[3];

      if (params[4] == 1.0 && myParams[4] == 0.0) {
        //adc =< rec;
        //rec =< blackhole;
        1 => is_recording;
        //new WvOut @=> rec;
        //adc => rec => blackhole;
        filepath => rec.wavFilename;
      }
      params[4] => myParams[4];

      if (params[5] == 1.0 && myParams[5] == 0.0) {
        filepath => rec.closeFile;
        //snd =< rev;
        0 => is_recording;
        //new SndBuf @=> snd;
        filepath => snd.read;
        //snd => rev;
      }
      params[5] => myParams[5];
    }
  }


  /* PROBABLY don't need to change anything below this line ----------------------------*/
  fun int getNumParams() {
    return numParams;
  }

  fun float[] getParams() {
    return myParams;
  }

  //Be quiet! If you want to improve efficiency here, you could also stop
  //other processing
  fun void silent() {
    0 => e.target;
  }

  //Make sound!
  fun void sound() {
    1 => e.target;
  }

  //Received when wekinator wants our params for playalong learning
  fun void startGettingParams(OscSend x, dur r) {
    x @=> xmit;
    r => rate;
    1 => isSendingParams;
    spork ~sendParamsLoop();
  }

  //Send those parameters on at a specified rate
  fun void sendParamsLoop() {
    while (isSendingParams) {
      sendParams();
      rate => now;
    }
  }

  //Received when wekinator wants us to stop sending those playalong params
  fun void stopGettingParams() {
    0 => isSendingParams;
  }

  //Send current parameters directly to Wekinator
  fun void sendParams() {
    "/realValue f" => string ss;
    1 => int i;
    for (1 => i; i < numParams; i++) {
      ss + " f" => ss;
    }
    xmit.startMsg(ss);
    for (0 => i; i < numParams; i++) {
      xmit.addFloat(myParams[i]); //Add all params, each in its own addFloat message.
    }
  }

  //If OSC synth, we need to instruct the synth how to get back to ChucK
  fun void setOscHostAndPort(string h, int p) {
    //no need to do anything, unless you're using an OSC synth like Processing or Max.
  }

}
