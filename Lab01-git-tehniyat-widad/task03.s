.text
.globl main
main:
li x1, 5
addi x2, x0, 0
addi x1, x2, 32
add x6, x1, x2  
addi x4, x6, -5
sub x7, x1, x4
sub x8, x2, x1
add x9, x7, x8
add x5, x9, x4
add x10, x4, x5 
add x5, x10, x6

end:
j end
