.text
.globl main
main:
    li x20, 0x100               # x20 = base address (start of array)   

    # array = [10, 20, 30, 40]
    li x5, 10
    sw x5, 0(x20)
    li x5, 20
    sw x5, 4(x20)
    li x5, 30
    sw x5, 8(x20)
    li x5, 40
    sw x5, 12(x20)
    addi x11, x0, 1                # x11 = k = 1 (we want to swap array[0] and array[1])

    jal x1, swap                   # Call swap function

    # Print array[0] after swap
    lw x11, 0(x20)               
    li x10, 1                      # Print Integer code
    ecall

    # Print array[1] after swap
    lw x11, 4(x20)                
    li x10, 1                      # Print Integer code
    ecall

    j Exit
 
    swap:
        slli x12, x11, 2            # x12 = k * 4 (offset)
        add x13, x20, x12           # x13 = address of array[k]

        lw x14, 0(x20)              # Load array[0] into x14
        lw x15, 0(x13)              # Load array[k] into x15

        sw x15, 0(x20)              # Store array[k] into array[0]
        sw x14, 0(x13)              # Store array[0] into array[k]

        jalr x0, 0(x1)              # Return

    Exit:

    
end:
    j end