.text
.globl main
main:
    # Base Addresses
    li t0, 0x100      # t0 = Array A (chars)
    li t1, 0x200      # t1 = Array B (shorts)
    li t2, 0x300      # t2 = Array C (ints)

    # Array A (1-byte steps)
    li s0, 1       
    sb s0, 0(t0)    
    li s0, 2
    sb s0, 1(t0)   
    li s0, 3
    sb s0, 2(t0)    
    li s0, 4
    sb s0, 3(t0)      

    # Array B (2-byte steps)
    li s1, 10
    sh s1, 0(t1)    
    li s1, 20
    sh s1, 2(t1)
    li s1, 30
    sh s1, 4(t1)
    li s1, 40
    sh s1, 6(t1)

    # Calculation: c[i] = a[i] + b[i]
    
    # i = 0
    lb  s0, 0(t0)     # Load char (1B)
    lh  s1, 0(t1)     # Load short (2B)
    add s2, s1, s0    # Add them
    sw  s2, 0(t2)     # Store int (4B)

    # i = 1
    lb  s0, 1(t0)     # Offset +1
    lh  s1, 2(t1)     # Offset +2
    add s2, s1, s0
    sw  s2, 4(t2)     # Offset +4

    # i = 2
    lb  s0, 2(t0)     # Offset +2
    lh  s1, 4(t1)     # Offset +4
    add s2, s1, s0
    sw  s2, 8(t2)     # Offset +8

    # i = 3
    lb  s0, 3(t0)     # Offset +3
    lh  s1, 6(t1)     # Offset +6
    add s2, s1, s0
    sw  s2, 12(t2)    # Offset +12

end:
    j end



