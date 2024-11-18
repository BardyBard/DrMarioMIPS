#############################
s0 = X
s1 = Y
s2 = Orientation (0 = x, 1 = y)
s3 = colour of a
s4 = colour of b
#############################


# start function
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $ra, 0($sp)              # store $ra on the stack

# end function
lw $ra, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
jr $ra 