.text
.globl main

main:
    addi x10, x0, 5        # n = 
    jal  x1, fibonacci     # call fibonacci
end:
    j end                  # infinite loop


# fibonacci(n)
# input  : x10
# output : x10

fibonacci:

    addi sp, sp, -12       # allocate 12 bytes stack
    sw   x1, 0(sp)         # save return address
    sw   x10, 4(sp)        # save n
    sw   x6, 8(sp)         # save temporary register

    # Base case: if n == 0 
    beq  x10, x0, fib_zero

    # Base case: if n == 1 
    addi x5, x0, 1
    beq  x10, x5, fib_one

    # Recursive case 
    addi x10, x10, -1      # n = n - 1
    jal  x1, fibonacci     # call fib(n-1)

    addi x6, x10, 0        # save fib(n-1)

    lw   x10, 4(sp)        # restore original n
    addi x10, x10, -2      # n = n - 2
    jal  x1, fibonacci     # call fib(n-2)

    add  x10, x6, x10      # fib(n-1) + fib(n-2)
    j    done

# Base returns
fib_zero:
    addi x10, x0, 0
    j done

fib_one:
    addi x10, x0, 1

# Function Exit
done:
    lw   x6, 8(sp)         # restore saved registers
    lw   x1, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(x1)
