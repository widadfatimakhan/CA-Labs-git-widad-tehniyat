
.text
.globl main
main:
    addi x10, x0, 12                # Initialize x10 with value 12
    addi x11, x0, 12                # Initialize x11 with value 12 
   
    jal x1, sum                     # Call the sum subroutine, store return address in x1
                                    # Move result from x10 to x11 for output
    addi x11,x10,0 
    li x10,1                        # Load syscall code for print integer into x10
    ecall                           # System call to exit with the loaded exit code
    j exit

    # Subroutine: sum two numbers in x10 and x11, result stored in x10
    sum:
        add x10,x11,x10             # Add x11 and x10, store result in x10
        jalr x0,0(x1)               # Return to caller by jumping to address in x1

    exit:

end:
    j end