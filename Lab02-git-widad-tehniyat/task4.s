.text
.globl main
main:
    li x5, 5            # a = 5
    li x6, 5            # b = 5
    li x7, 0            # i = 0
    li x10, 0x300       # base address of array D

Loop1:
    bge x7, x5, end     # if i >= a, exit outer loop
    li x29, 0           # j = 0 

Loop2:
    slli x31, x29, 2    # Offset: 4 * j
    add x12, x7, x29    # Calculate: i + j
    add x13, x10, x31   # Address: Base + Offset
    sw x12, 0(x13)      # Store result in D[j]

    addi x29, x29, 1    # j++ 
    blt x29, x6, Loop2  # if j < b, repeat inner loop

next_i:
    addi x7, x7, 1      # i++ 
    j Loop1             # return to outer loop

end:              
    j end             