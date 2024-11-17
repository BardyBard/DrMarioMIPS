################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Alexander Magnus, 1009825619
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

# Colours
RED:
    .word 0xff0000
YELLOW:
    .word 0xffff00
BLUE:
    .word 0x0000ff
WHITE:
    .word 0xffffff
BLACK:
    .word 0x000000

##############################################################################
# Mutable Data
##############################################################################


##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    # Setup capsule locations
    li $s0, 0       # capsule X
    li $s1, 0       # capsule Y
    li $s2, 0       # capsule orientation
    li $s3, 0       # capusle A colour
    li $s4, 0       # capsule B colour

    # Draw the border
    jal draw_border

    li $v0, 10                  # exit the program gracefully
    syscall                     # (so it doesn't continue into the draw_rect function again)

    

game_loop:
    # Check if a key has been pressed
    lw $t0, ADDR_KBRD      # Load the address of the keyboard into $t0
    lb $t1, 4($t0)         # Load the key pressed into $t1
    li $t2, 'a'            # Load the ASCII value of 'a' into $t2
    bne $t1, $t2, skip_print # If the key pressed is not 'a', skip printing

    # Print a message to the console
    li $t3, 0xff0000 # $t1 = red
    lw $t4, ADDR_DSPL # $t0 = base address for display
    sw $t3, 0( $t4 ) # paint the first unit (i.e., top−left) red

    skip_print:

    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop


##############################################################################
# Functions
##############################################################################
######################################
# draw_border
######################################
draw_border:
    # store ra
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    # draw left wall
    li $a0, 5       # set X to 5
    li $a1, 13      # set Y to 13
    li $a2, 1       # set border width to 1
    li $a3, 18      # set border height to 18
    jal draw_rect

    # draw right wall
    li $a0, 14       # set X to 14
    li $a1, 13      # set Y to 13
    li $a2, 1       # set border width to 1
    li $a3, 18      # set border height to 18
    jal draw_rect

    # draw bottom wall
    li $a0, 5       # set X to 5
    li $a1, 30      # set Y to 30
    li $a2, 10       # set border width to 10
    li $a3, 1     # set border height to 1
    jal draw_rect

    # draw top left
    li $a0, 5       # set X to 5
    li $a1, 13      # set Y to 13
    li $a2, 4      # set border width to 4
    li $a3, 1      # set border height to 1
    jal draw_rect

    # draw top right
    li $a0, 11       # set X to 5
    li $a1, 13      # set Y to 13
    li $a2, 4      # set border width to 4
    li $a3, 1      # set border height to 1
    jal draw_rect

    # draw left neck of funnel
    li $a0, 8       # set X to 8
    li $a1, 11      # set Y to 11
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    jal draw_rect

    # draw right neck of funnel
    li $a0, 11       # set X to 11
    li $a1, 11      # set Y to 11
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    jal draw_rect

    # draw left top neck of funnel
    li $a0, 7       # set X to 7
    li $a1, 9      # set Y to 9
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    jal draw_rect

    # draw right top neck of funnel
    li $a0, 12       # set X to 12
    li $a1, 9      # set Y to 9
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    jal draw_rect

    # end
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 


######################################
# store_registers
######################################
store_registers:
    # store $t registers
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t3, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t4, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t5, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t6, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t7, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t8, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t9, 0($sp)              

    # store $a registers
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              
    
    jr $ra


######################################
# unstore_registers
######################################
unstore_registers:
    # unstore $a registers
    lw $a3, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a0, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element

    # unstore $t registers
    lw $t9, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t8, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t7, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t6, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t5, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t4, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t3, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t0, 0($sp)              
    addi $sp, $sp, 4            # move the stack pointer to the new top element

    jr $ra


######################################
# draw_line

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = length of line
# $a3 = colour of line
######################################
draw_line:
    lw $a3, WHITE
    lw $t0, ADDR_DSPL           # $t0 = base address for display
    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $t1, $t0, $a1           # Add the Y offset to $t0, store the result in $t1
    add $t1, $t1, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
    # Calculate the final point in the line (start point + length x 4)
    sll $a2, $a2, 2             # Multiply the length by 4
    add $t2, $t1, $a2           # Calculate the address of the final point in the line, store result in $t2.
    
    # Start the loop
    line_start:
        sw $a3, 0($t1)              # Draw a coloured pixel at the current location in the bitmap
        # Loop until the current pixel has reached the final point in the line.
        addi $t1, $t1, 4            # Move the current location to the next pixel
        beq $t1, $t2, line_end      # Break out of the loop when $t1 == $t2
        j line_start
        # End the loop
    line_end:

    # Return to calling program
    jr $ra


######################################
# draw_line

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = width of rectangle
# $a3 = length of rectangle
######################################
draw_rect:
    add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
    row_start:
        # store registers
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $ra, 0($sp)              # store $ra on the stack
        jal store_registers
        
        jal draw_line

        # unstore registers
        jal unstore_registers
        lw $ra, 0($sp)              # restore $ra from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element

        addi $a1, $a1, 1            # move to the next row to draw
        addi $t0, $t0, 1            # increment the row variable by 1
        beq $t0, $a3, row_end       # when the last line has been drawn, break out of the line-drawing loop
        j row_start                 # jump to the start of the line-drawing section
    row_end:
    jr $ra                      # return to the calling program