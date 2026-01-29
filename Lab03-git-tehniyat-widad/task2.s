.text
.globl main
main:
    li x10, 10                       # g
    li x11, 11                       # h
    li x12, 12                       # i         
    li x13, 13                       # j

    jal x1, leaf_example             # Call function

    addi x11, x21, 0                 # Put result into x11 for printing
    li x10, 1                        # Load syscall code 1 (Print Integer) into x10
    ecall

    j Exit

    leaf_example:
        addi sp, sp, -12                 # Allocate stack space
        sw x18, 0(sp)                    # Backup original x18
        sw x19, 4(sp)                    # Backup original x19
        sw x20, 8(sp)                    # Backup original x20

        add x18, x10, x11                # x18 = g + h
        add x19, x12, x13                # x19 = i + j
        sub x20, x18, x19                # x20 = (g + h) - (i + j)

        addi x21, x20, 0                 # Save result to x21 for main

        lw x18, 0(sp)                    # Restore original x18
        lw x19, 4(sp)                    # Restore original x19
        lw x20, 8(sp)                    # Restore original x20
        addi sp, sp, 12                  # Deallocate stack space

        jalr x0, 0(x1)                   # Return to main

    Exit:
 


end:
    j end