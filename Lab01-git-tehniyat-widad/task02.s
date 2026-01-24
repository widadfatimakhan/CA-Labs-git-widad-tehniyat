.text
.globl main
main:
li x20, 3
li x21, 1
li x22, 2
li x23, 1

add x5, x20, x21
add x6, x22, x23
sub x19, x5, x6
addi x22, x22, 4
end:
j end