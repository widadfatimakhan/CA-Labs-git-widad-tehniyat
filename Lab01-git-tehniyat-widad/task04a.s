.text
.globl main

main: 
    # Load 0x78786464 manually
    lui x10, 0x78786        # Load upper 20 bits
    addi x10, x10, 0x464    # Add lower 12 bits
    
    # Load 0xA8A81919 manually (Fixing sign extension)
    lui x11, 0xA8A82        # Overshoot by 1 because 0x919 is "negative"
    addi x11, x11, -1767    # Subtract offset to land on 0xA8A81919
    
    # Store registers to memory
    li t0, 0x100            # Base address 1
    sw x10, 0(t0)           # Store 4-byte word
    
    li t1, 0x1F0            # Base address 2
    sw x11, 0(t1)           # Store 4-byte word
    
    # Load back with different widths
    lhu x12, 0(t0)          # Load 2 bytes (unsigned) from 0x100
    lh  x13, 0(t1)          # Load 2 bytes (signed) from 0x1F0
    lb  x14, 0(t1)          # Load 1 byte (signed) from 0x1F0

end:
    j end                   