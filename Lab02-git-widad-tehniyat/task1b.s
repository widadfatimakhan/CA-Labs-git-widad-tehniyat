.text
.globl main 
main:

li x22, 0 #i
li x24, 2 #k
li x25, 0x100 #base address of save

li x8, 2
sw x8, 0(x25) # save[0]
li x8, 4
sw x8, 4(x25) # save[1]
li x8, 8
sw x8, 8(x25) # save[2]
li x8, 12
sw x8, 12(x25) # save[3]

Loop: slli x10, x22, 2 # Temp reg x10 = i * 4
add x10, x10, x25 # x10 = address of save [i]
lw x9, 0(x10) # Temp reg x9 = save [i]
bne x9, x24, Exit # go to Exit if save[i] != k
addi x22, x22, 1 # i=i+1
beq x0, x0, Loop # unconditional jump back to Loop
Exit :

end:
j end