import pygame
import mapper

pygame.joystick.init()
pygame.display.init()  # stupid but must init display
j = pygame.joystick.Joystick(0)
j.init()

dev = mapper.device('joystick')
sig_button = dev.add_output('/button', 1, 'i', None, 0, 1)
sig_x = dev.add_output('/x', 1, 'f', None, -1, 1)
sig_y = dev.add_output('/y', 1, 'f', None, -1, 1)
sig_yaw = dev.add_output('/yaw', 1, 'f', None, -1, 1)
sig_pitch = dev.add_output('/pitch', 1, 'f', None, -1, 1)

while True:
    dev.poll(50)
    pygame.event.get()
    sig_button.update(j.get_button(2))
    sig_x.update(j.get_axis(0))
    sig_y.update(j.get_axis(1))
    sig_yaw.update(j.get_axis(2))
    sig_pitch.update(j.get_axis(3))
