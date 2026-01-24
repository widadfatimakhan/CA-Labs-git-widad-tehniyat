.text
.globl main 
main:

li x19, 5 #f
li x20, 4 #g 
li x21, 3 #h
li x22, 2 #i
li x23, 1 #j 

bne x22, x23, Else #if i != j, go to Else
add x19, x20, x21  #f = g + h
beq x0, x0, Exit #unconditional jump to exit program 
Else: sub x19, x20, x21 #f = g - h

Exit : 
# the code after if/else goes here

end:
j end