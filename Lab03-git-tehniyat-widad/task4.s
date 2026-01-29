.text
.globl main
main:
    # Initialize y[] on the Stack

    # We allocate 16 bytes: 0-7 for y[] (Source), 8-15 for x[] (Destination)
    addi sp, sp, -16 

    li x5, 84                                   # ASCII 'T' (Upper case)
    sb x5, 0(sp)
    li x5, 101                                  # ASCII 'e' (Lower case)
    sb x5, 1(sp)
    li x5, 115                                  # ASCII 's' (Lower case)
    sb x5, 2(sp)
    li x5, 116                                  # ASCII 't' (Lower case)
    sb x5, 3(sp)
    li x5, 0                                    # Null terminator '\0'
    sb x5, 4(sp)

    # Arguments for strcpy
    addi x10, sp, 8                             # x10 = Destination address (x)
    addi x11, sp, 0                             # x11 = Source address (y)
    
    jal x1, strcpy                              # Call strcpy function

    # print x[]
    addi x12, sp, 8                             # Start address of copied string x

    print_loop:
        lb x11, 0(x12)                          # Load current character for printing
        beq x11, x0, done                       # Exit loop if we hit the null terminator
        
        li x10, 11                              # Syscall 11: Print Character
        ecall
        
        addi x12, x12, 1                        # Increment pointer to next character
        j print_loop

    done:
        addi sp, sp, 16                         # restore stack pointer

    Exit:
        j Exit


    # strcpy: Function to copy string from x11 to x10
    strcpy:
        addi sp, sp, -4      
        sw x19, 0(sp) 
        
        li x19, 0                               # i = 0 (loop index)

    copy_loop:
        # Calculate address offsets
        add x5, x11, x19                        # Source address + i
        add x6, x10, x19                        # Destination address + i

        # Transfer byte from y[i] to x[i]
        lb x7, 0(x5)                            # Load byte from y
        sb x7, 0(x6)                            # Store byte into x

        # Termination check
        beq x7, x0, copy_finish                 # Stop loop after null terminator is copied
        
        addi x19, x19, 1                        # Increment index
        j copy_loop

    copy_finish:
        # restore x19 and return to caller
        lw x19, 0(sp)        
        addi sp, sp, 4       
        jalr x0, 0(x1)


end:
    j end