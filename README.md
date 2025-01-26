# hello-nes

yet another hello world in 6502 asm for the NES. Heavily inspired by the [Nerdy Nights tutorial](https://nerdy-nights.nes.science/) by Brian Parker which is a great resource if you (like me) are starting on the NES 6502.

On this implementation of the hello world I included a sprites file with one sprite per character and then print character by character.

`hello-world-simple.asm` it's the simplest implementation repeating a ton of code changing only the character, X and Y position. 

`hello-world.asm` uses three maps `txt_string` defines wich sprite corresponds to wich letter and then there's `txt_string_x_axis` and `txt_string_y_axis` wich defines the X and Y position of each character.

## Sprite file

![image](https://github.com/user-attachments/assets/26e13a22-a58e-489e-84b9-55615b1114f5)

## The result

![image](https://github.com/user-attachments/assets/83dc48f8-c17c-4ae1-99a3-d647d5ba4166)


## Tools needed

You only need a compiler and an emulator I used `nesasm` as my compiler and `fceux` as the emulator
