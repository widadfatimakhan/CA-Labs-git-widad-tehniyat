.text
.globl main 
main:
li x20, 3          # x = 3
li x22, 4          # b = 4
li x23, 5          # c = 5

# Comparing x (x20) against constants to find the right branch
li x5, 1
beq x20, x5, case_add     # if x == 1, go to addition

li x5, 2
beq x20, x5, case_sub     # if x == 2, go to subtraction

li x5, 3
beq x20, x5, case_mul     # if x == 3, go to multiplication

li x5, 4
beq x20, x5, case_div     # if x == 4, go to division

## if no matches were found
li x21, 0          # set a = 0
j Exit   

case_add:
    add x21, x22, x23     # a = b + c
    j Exit      

case_sub:
    sub x21, x22, x23     # a = b - c
    j Exit       

case_mul:
    slli x21, x22, 1      # a = b * 2
    j Exit       

case_div:
    srli x21, x22, 1      # a = b / 2
    j Exit       

Exit:
end:
j end  