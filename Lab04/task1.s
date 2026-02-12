.text
.globl main
main:

factorial:
    addi x10, x0, 4        # n = 4
    addi x6,  x0, 1        # result = 1
    addi x5,  x0, 1        # for comparison: 1 (we want to loop while n >= 1)


loop:
    blt  x10, x5, else     # if n < 1 → exit loop

    mul  x6,  x6,  x10     # result = result * n
    addi x10, x10, -1      # n = n - 1

    j loop                 # repeat

else:
    # factorial result is now in x6

end:
    j end                  # infinite loop 


