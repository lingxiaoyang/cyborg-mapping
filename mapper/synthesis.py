from pyo import *
import mapper

synth = Server().boot().start()
dev = mapper.device("synthesizer")

snd = SndTable("/Users/lyang/libmapper/cyborg/sound.wav")
env = HannTable()
g = Granulator(snd, env, pitch=1, pos=0, dur=1, grains=24, mul=.5).out()

e = Adsr(attack=2, decay=0, sustain=1, release=2, mul=.1)
e_playing = False
noise = PinkNoise(mul=e).mix(2).out()

def noise_handler(sig, id, val, timetag):
    global e_playing
    if val == 1 and not e_playing:
        e.play()
        e_playing = True
    elif val == 0 and e_playing:
        e.stop()
        e_playing = False
def size_handler(sig, id, val, timetag):
    g.setDur(val / 1000.0)
def pitch_handler(sig, id, val, timetag):
    g.setPitch(val)
def pos_handler(sig, id, val, timetag):
    g.setPos(val)

dev.add_input( '/noise_on', 1, 'i', None, 0, 1, noise_handler)
dev.add_input('/grain_size', 1, 'f', 'ms', 50, 700, size_handler)
dev.add_input('/pitch_shift', 1, 'f', None, 0.1, 3, pitch_handler)
dev.add_input('/pos', 1, 'i', None, 0, snd.getSize(), pos_handler)

while True:
    dev.poll(50)

synth.stop()
