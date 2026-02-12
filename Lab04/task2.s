.text
.globl main

main:
    addi x10, x0, 4        # x10 = 4 (input num)
    jal  x1, factorial     # call factorial

end:
    j end                  # infinite loop to end program


factorial:
    addi sp, sp, -8        # allocate stack space
    sw   x1, 0(sp)         # save return address
    sw   x10, 4(sp)        # save num

    addi x5, x0, 2         # constant 2 for comparison

    blt  x10, x5, base     # if num < 2 → base case

    addi x10, x10, -1      # num = num - 1
    jal  x1, factorial     # recursive call

    lw   x6, 4(sp)         # restore original num
    mul  x10, x6, x10      # num * factorial(num-1)

    j    done

  

base:
    addi x10, x0, 1        # return 1



done:
    lw   x1, 0(sp)         # restore return address
    addi sp, sp, 8         # deallocate stack
    jalr x0, 0(x1)         # return to caller
   
