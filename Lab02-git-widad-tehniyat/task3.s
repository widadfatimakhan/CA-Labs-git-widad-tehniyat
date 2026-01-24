.text
.globl main 
main:
li x1, 10 #loop upper index 
li x22, 0 #i
li x23, 0 #sum
li x2, 0 #counter

Loop1:
sw x22, 0x200(x2) # a[i] = i
addi x22, x22, 1 # i++
addi x2, x2, 4 # i * 4 for the array
blt x22, x1, Loop1 # looping if i < 10

li x2, 0 # counter reset
li x22, 0 # i reset 

Loop2:
lw x24, 0x200(x2) # a[i] = i
add x23, x24, x23 # sum = sum + 1
addi x22, x22, 1 # i++
addi x2, x2, 4 #counter increment 
blt x22, x1, Loop2 # looping if i < 10

end:
j end   