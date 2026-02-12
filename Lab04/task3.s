.text
.globl bubble

bubble:

    # Initialize array in memory
    li x10, 0x100           # x10 = base address of array

    addi x5, x0, 1
    sw   x5, 0(x10)

    addi x5, x0, 2
    sw   x5, 4(x10)

    addi x5, x0, 3
    sw   x5, 8(x10)

    addi x5, x0, 4
    sw   x5, 12(x10)

    addi x5, x0, 5
    sw   x5, 16(x10)

    addi x11, x0, 5          # len = 5

    # stack setup
    addi sp, sp, -32
    sw   x1, 28(sp)
    sw   x8, 24(sp)
    sw   x9, 20(sp)
    sw   x18,16(sp)
    sw   x19,12(sp)

    addi x8, x10, 0          # x8 = array base
    addi x9, x11, 0          # x9 = len

    beq  x8, x0, exit
    beq  x9, x0, exit

    addi x18, x0, 0          # i = 0



outer_loop:
    bge  x18, x9, exit

    addi x19, x18, 0         # j = i


inner_loop:
    bge  x19, x9, next_i

    # address of a[i]
    slli x5, x18, 2
    add  x5, x8, x5
    lw   x6, 0(x5)

    # address of a[j]
    slli x7, x19, 2
    add  x7, x8, x7
    lw   x28, 0(x7)

    ##if (a[i] < a[j])
    bge  x6, x28, skip_swap

    # swap
    sw   x28, 0(x5)
    sw   x6,  0(x7)

skip_swap:
    addi x19, x19, 1
    j inner_loop

next_i:
    addi x18, x18, 1
    j outer_loop


exit:
    # stack restore and return
    lw   x1, 28(sp)
    lw   x8, 24(sp)
    lw   x9, 20(sp)
    lw   x18,16(sp)
    lw   x19,12(sp)
    addi sp, sp, 32
    jalr x0, 0(x1)

