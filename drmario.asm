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
ADDR_PRE_DSPL:
    .word 0x10009000
ADDR_STORAGE_BOARD:
    .word 0x1000a000
    
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

# Game colours
RED:
    .word 0xff0000
REDISH:
    .word 0xff747c
YELLOW:
    .word 0xffff00
YELLOWISH:
    .word 0xffee8c
BLUE:
    .word 0x3944BC
BLUEISH:
    .word 0x1e90FF
WHITE:
    .word 0xffffff
BLACK:
    .word 0x000000


# Drawing colours
BROWN:
    .word 0x964b00
SKIN:
    .word 0xe0ac69
GREY:
    .word 0xaaaaaa

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
    jal store_border

    # Generate 4 new viruses
    addi $a0, $zero, 4
    jal generate_viruses

    start_new_pill:
        # Draw the pill
        jal generate_new_pill

    
    li $s6, 600                 # Load mario animation
    
    starting_loop:
        # 3. Draw the screen
        jal clear_the_pre_dspl
        jal load_pre_dspl
        jal draw_mario
        jal draw_pill
    
    	jal draw_the_screen
    
        # Mario animation
        addi $s6, $s6, -16
        bge $s6, $zero, skip_reset_mario_animation
        li $s6, 600             # reset mario animation to 0
        li $s0, 9              # X co-ord pill
        li $s1, 14               # Y co-ord pill
        
        j game_loop
        skip_reset_mario_animation:

        # Sleep
        li $v0 32       # Code to sleep
        li $a0 9       # 1000ms / 120 = 9ms
        syscall         # Sleep for 1/60 seconds

        j starting_loop


game_loop:
    # 1a. Check if key has been pressed
    lw $t0 ADDR_KBRD                # Load the root keyboard address
    lw $t1 0($t0)                   # Load the first word at the root keyboard address
    beq $t1 1 keyboard_input        # If first word == 1: key is pressed
    done_keyboard_input:            # return here after keyboard input

    # 2a. Check for collisions
    # Reset the current game board
 

	# 2b. Update locations (capsules)

       



	# 3. Draw the screen
    jal clear_the_pre_dspl
    jal load_pre_dspl
    jal draw_mario
    jal draw_pill

	jal draw_the_screen

    # INCREASE ANIMATION COUNTERS
    # Virus animation
    addi $s7, $s7, -1
    bge $s7, $zero, skip_reset_virus_animation
    li $s7, 90
    skip_reset_virus_animation:




	# 4. Sleep
    li $v0 32       # Code to sleep
    li $a0 9       # 1000ms / 120 = 9ms
    syscall         # Sleep for 1/60 seconds
    
    # 5. Go back to Step 1
    j game_loop


##############################################################################
# Functions
##############################################################################
######################################
# line_four_check
######################################
# line_four_check:
#     # start function
#     addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
#     sw $ra, 0($sp)              # store $ra on the stack

#     li $t0, 6       # first X co-ord to check
#     li $t1, 14      # first Y co-ord to check
#     li $t9, 13      # last X co-ord to check
#     li $t9, 29      # last Y co-ord to check

#     check_point_loop:
    




#         j check_point_loop 

#     # end function
#     lw $ra, 0($sp)              # restore $ra from the stack
#     addi $sp, $sp, 4            # move the stack pointer to the new top element
#     jr $ra 
        
    


######################################
# generate_viruses
# $a0 = num_viruses
######################################
generate_viruses:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    
    move $t1, $a0                       # start the counter with number of viruses to draw
    
    generate_one_virus:    
        jal generate_virus_location
        move $t2, $v0           # store the X co-ord
        move $t3, $v1           # store the Y co-ord
        
        jal generate_virus_colour       # returns a0 filled with one of 3 colours
        
        # draw the virus on storage board
        move $a2, $a0           # pass the colour as input
        move $a0, $t2           # pass the X co-ord input
        move $a1, $t3           # pass the Y co-ord input
        jal store_pixel     
        
        addi $t1, $t1, -1               # decrease the viruses to draw counter by 1
        beq $t1, $zero, done_generating_viruses
        # Else more than 0 viruses left to draw so loop
        j generate_one_virus
    
    done_generating_viruses:     
    # end function
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 
 
        
######################################
# generate_virus_location
######################################
generate_virus_location:
    #generate X coord for virus, value from 0, 8
    li $v0 , 42
    li $a0 , 0
    li $a1 , 8 
    syscall
    addi $t9, $a0, 6    # save X co-ord value, offset by where the pillbox is, temporarily into t9
    
    #generate Y coord for virus, value from 0, 16
    li $v0 , 42
    li $a0 , 0
    li $a1 , 14 
    syscall
    addi $v1, $a0, 16   # save Y co-ord value, offset by where the pillbox is plus 2
    
    move $v0, $t9       # restore X co-oord output
    jr $ra  # return
    

######################################
# generate_virus_colour
######################################
generate_virus_colour:
    #generate random value from 0, 2
    li $v0 , 42
    li $a0 , 0
    li $a1 , 3
    syscall

    # Set the value of $a0, to a colour based on the value of $a0
    beq $a0, 0, set_col_redish
    beq $a0, 1, set_col_yellowish
    beq $a0, 2, set_col_blueish

    set_col_redish:
        lw $a0, REDISH
        jr $ra

    set_col_yellowish:
        lw $a0, YELLOWISH
        jr $ra

    set_col_blueish:
        lw $a0, BLUEISH
        jr $ra
        
        

######################################
# keyboard_input
######################################
keyboard_input:
    lw $a0 4($t0)               # Load the second word from keyboardx`
    
    beq $a0 0x71 quit_game      # If second word == Q: quit game
    
    # beq $a0 0x61 move_left      # If second word == A: move left
    beq $a0 0x6a move_left      # If second word == J: move left
    
    # beq $a0 0x64 move_right     # If second word == D: move right
    beq $a0 0x6c move_right     # If second word == L: move right

    # beq $a0 0x73 move_down      # If second word == S: move down
    beq $a0 0x6b move_down     # If second word == K: move down
    
    # beq $a0 0x77 rotate         # If second word == W: rotate
    beq $a0 0x7a rotate         # If second word == Z: rotate
    
    j done_keyboard_input              # otherwise input is bad


######################################
# quit_game
######################################
quit_game:
    li $v0 10
    syscall


######################################
# is_clear
# $a0 = X co-ord to check
# $a1 = Y co-ord to check
######################################
is_clear:
    lw $t0, ADDR_PRE_DSPL

    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $s0 by 4)
    add $t0, $t0, $a0           # Shift accessed address to x co-ord to check

    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $s1 by 128)
    add $t0, $t0, $a1           # Shift accessed address to Y co-ord to check

    lw $t1, 0($t0)              # Load byte into $t1 to check pre display 
    lw $t2, BLACK               # Load BLACK to compare against

    beq $t1, $t2, is_clear_TRUE            # If $t1 == $t2, the position is clear

    # otherwise is_clear_False
    li $v0, 0                   # Otherwise, set $v0 to 0 (not clear)
    jr $ra                      # Return from function
    
    is_clear_TRUE:  
    li $v0, 1                   # Set $v0 to 1 (clear)
    jr $ra                      # Return from function


######################################
# move_left
######################################
move_left:
    # Check if space left of pill A is clear
    addi $a0, $s0, -1       # Set input to be the current X pos -1
    move $a1, $s1           # Compare same Y co-ord
    jal is_clear
    beq $v0, $zero, done_keyboard_input     # don't move left since not clear

    beq $s2, $zero, left_good_to_move       # branch if not vertical so vertical check can be skipped
        # Check if space left of pill B is clear
        addi $a0, $s0, -1           # Set input to be the current X pos -1
        addi $a1, $s1, -1           # Compare same Y co-ord
        jal is_clear
        beq $v0, $zero, done_keyboard_input     # don't move left since not clear

    left_good_to_move:
        addi $s0 $s0 -1         # Decrease the current X pos by 1
        j done_keyboard_input


######################################
# move_right
######################################
move_right:
    bne $s2, $zero, right_vertical_check
        # else right horizontal check
        # Check if space right of pill B is clear
        addi $a0, $s0, 2        # Set input to be the current X pos +2
        move $a1, $s1           # Compare same Y co-ord
        jal is_clear
        beq $v0, $zero, done_keyboard_input     # don't move right since not clear

        j right_good_to_move

    right_vertical_check:
        # Check if space right of pill A is clear
        addi $a0, $s0, 1            # Set input to be the current X pos -1
        move $a1, $s1               # Compare same Y co-ord
        jal is_clear
        beq $v0, $zero, done_keyboard_input     # don't move right since not clear

        # Check if space right of pill B is clear
        addi $a0, $s0, 1            # Set input to be the current X pos -1
        addi $a1, $s1, -1           # Compare same Y co-ord
        jal is_clear
        beq $v0, $zero, done_keyboard_input     # don't move right since not clear

    right_good_to_move:
        addi $s0 $s0 1         # Increase the current X pos by 1
        j done_keyboard_input


######################################
# move_down
######################################
move_down:
    # Check if space below pill A is clear
    move $a0, $s0               # Set input to be the current X pos
    addi $a1, $s1, 1            # Compare Y co-ord +1
    jal is_clear
    beq $v0, $zero, pill_dropped     # don't move down since not clear

    bne $s2, $zero, down_good_to_move       # branch if vertical so horizontal check can be skipped
        # Check if space below pill B is clear
        addi $a0, $s0, 1           # Set input to be the current X pos -1
        addi $a1, $s1, 1           # Compare same Y co-ord
        jal is_clear
        beq $v0, $zero, pill_dropped     # don't move down since not clear

    down_good_to_move:
        addi $s1 $s1 1         # Increase the current Y pos by 1
        j done_keyboard_input


######################################
# rotate
######################################
rotate:
    beq $s2, $zero, set_orientation_to_vertical        # check if rotation is horizontal (0)
        # otherwise rotation is vertical
        # Check if space right of pill A is clear
        addi $a0, $s0, 1                # Set input to be the X pos +1
        move $a1, $s1                   # Compare same Y co-ord
        jal is_clear
        beq $v0, $zero, done_keyboard_input     # don't rotate since not clear
        
        li $s2, 0           # set rotation to horizontal
        move $t0, $s3       # store s3 temporarily
        move $s3, $s4       # swap s4 and s3
        move $s4, $t0       # swap s4 and s3, with stored s3
        
        j done_keyboard_input

    set_orientation_to_vertical:
        # Check if space above pill A is clear
        move $a0, $s0               # Set input to be the current X pos
        addi $a1, $s1, -1           # Compare Y co-ord -1
        jal is_clear
        beq $v0, $zero, done_keyboard_input     # don't rotate since not clear

        li $s2, 1       # set rotation to vertical
        j done_keyboard_input


######################################
# pill_dropped
######################################
pill_dropped:
        # save pill A
        move $a0, $s0           # pass the X co-ord input
        move $a1, $s1           # pass the Y co-ord input
        move $a2, $s3           # pass the colour as input
        jal store_pixel

        beq $s2, $zero, dropped_horizontally
        # Otherwise dropped_vertically
            # save pill B
            move $a0, $s0               # pass the X co-ord input
            addi $a1, $s1, -1           # pass the Y co-ord input
            move $a2, $s4               # pass the colour as input
            jal store_pixel

            j start_new_pill            # end

        dropped_horizontally:
            # save pill B
            addi $a0, $s0, 1            # pass the X co-ord input
            move $a1, $s1               # pass the Y co-ord input
            move $a2, $s4               # pass the colour as input
            jal store_pixel

        j start_new_pill            # end


######################################
# load_pre_dspl
######################################
load_pre_dspl:
    lw $t0 ADDR_STORAGE_BOARD
    lw $t1 ADDR_PRE_DSPL
    li $t2, 1024                # $t2 = length (4096 bytes)
    li $t4, 75                 # value to compare animation counter for viruses
    lw $t9, REDISH               # Get black to compare
    lw $t8, YELLOWISH               # Get black to compare
    lw $t7, BLUEISH               # Get black to compare

    load_storage_loop:
        lw $t3, 0($t0)          # Load byte from ADDR_PRE_DSPL into $t3
        

        # Check virus animation cycle to see if they should be loaded
        blt $s7, $t4, skip_virus_unrendering
        # Check if virus
        beq $t3, $t9, skip_stored
        beq $t3, $t8, skip_stored
        beq $t3, $t7, skip_stored
        skip_virus_unrendering:
        
        sw $t3, 0($t1)          # Store byte into ADDR_DISP

        skip_stored:
        # Increment pointers and decrement counter
        addi $t0, $t0, 4        # Move to next byte in ADDR_PRE_DSPL
        addi $t1, $t1, 4        # Move to next byte in ADDR_DISP
        addi $t2, $t2, -1       # Decrease counter
        
        bne $t2 $zero load_storage_loop   
        
    jr $ra                  # end the copying


######################################
# clear_the_pre_dspl
######################################
clear_the_pre_dspl:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    # Draw big black rect
    li $a0, 0       # $a0 = X co-ordinate to draw
    li $a1, 0       # $a1 = Y co-ordinate to draw
    li $a2, 32      # $a2 = width of rectangle
    li $a3, 32      # $a3 = length of rectangle
    # store black as the input colour
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, BLACK           # get black colour
    sw $t0, 0($sp)          # store black colour on stack

    jal draw_rect

    # end function
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 


######################################
# draw_the_screen
######################################
draw_the_screen:
    lw $t0 ADDR_PRE_DSPL
    lw $t1 ADDR_DSPL
    li $t2, 1024         # $t2 = length (4096 bytes)

    copy_board_loop:
        lw $t3, 0($t0)          # Load byte from ADDR_PRE_DSPL into $t3
        sw $t3, 0($t1)          # Store byte into ADDR_DISP

        # Increment pointers and decrement counter
        addi $t0, $t0, 4        # Move to next byte in ADDR_PRE_DSPL
        addi $t1, $t1, 4        # Move to next byte in ADDR_DISP
        addi $t2, $t2, -1       # Decrease counter
        
        bne $t2 $zero copy_board_loop   
        
    jr $ra                  # end the copying


######################################
# draw_pill
######################################
draw_pill:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    lw $t0, ADDR_PRE_DSPL           # $t0 = base address for display
    
    sll $t1, $s0, 2             # Calculate the X offset to add to $t0 (multiply $s0 by 4)
    add $t0, $t0, $t1           # Shift accessed address to x co-ord of pill

    sll $t1, $s1, 7             # Calculate the Y offset to add to $t0 (multiply $s1 by 128)
    add $t0, $t0, $t1           # Shift accessed address to Y co-ord of pill

    sw $s3, 0($t0)              # Draw pill A at the current location in the bitmap
    
    beq $s2, $zero, add_4_to_t0       # If $s2 == 0, jump to add_4
    
    # else $s2 == 1, so subtract 128
    addi $t0, $t0, -128              # Add 128 to $t0
    j post_adding_pill_offset       # jump to end
        
    add_4_to_t0:
        addi $t0, $t0, 4             # Add 4 to $t0
        j post_adding_pill_offset    # Jump to end

    post_adding_pill_offset:
    sw $s4, 0($t0)              # Draw pill B at the current location in the bitmap
    

    # end function
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 


######################################
# generate_pill_colour
######################################
generate_pill_colour:
    #generate random value from 0, 2
    li $v0 , 42
    li $a0 , 0
    li $a1 , 3
    syscall

    # Set the value of $a0, to a colour based on the value of $a0
    beq $a0, 0, set_col_red
    beq $a0, 1, set_col_yellow
    beq $a0, 2, set_col_blue

    set_col_red:
        lw $a0, RED
        jr $ra

    set_col_yellow:
        lw $a0, YELLOW
        jr $ra

    set_col_blue:
        lw $a0, BLUE
        jr $ra        


######################################
# generate_new_pill
######################################
generate_new_pill:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    
    li $s0, 14       # capsule X
    li $s1, 10      # capsule Y
    li $s2, 0       # capsule orientation

    # returns a0 filled with one of 1 colours, overwrites a0
    jal generate_pill_colour
    move $s3, $a0       # sets the colour of capsule A to randomly generated colour

    # returns a0 filled with one of 1 colours, overwrites a0
    jal generate_pill_colour
    move $s4, $a0       # sets the colour of capsula B to a randomly generated colour

    # end function
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 


######################################
# store_border
######################################
store_border:
    # store ra
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    # store left wall
    li $a0, 5       # set X to 5
    li $a1, 13      # set Y to 13
    li $a2, 1       # set border width to 1
    li $a3, 18      # set border height to 18
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store right wall
    li $a0, 14       # set X to 14
    li $a1, 13      # set Y to 13
    li $a2, 1       # set border width to 1
    li $a3, 18      # set border height to 18
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store bottom wall
    li $a0, 5       # set X to 5
    li $a1, 30      # set Y to 30
    li $a2, 10       # set border width to 10
    li $a3, 1     # set border height to 1
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store top left
    li $a0, 5       # set X to 5
    li $a1, 13      # set Y to 13
    li $a2, 4      # set border width to 4
    li $a3, 1      # set border height to 1
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store top right
    li $a0, 11       # set X to 5
    li $a1, 13      # set Y to 13
    li $a2, 4      # set border width to 4
    li $a3, 1      # set border height to 1
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store left neck of funnel
    li $a0, 8       # set X to 8
    li $a1, 11      # set Y to 11
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store right neck of funnel
    li $a0, 11       # set X to 11
    li $a1, 11      # set Y to 11
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store left top neck of funnel
    li $a0, 7       # set X to 7
    li $a1, 9      # set Y to 9
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

    # store right top neck of funnel
    li $a0, 12       # set X to 12
    li $a1, 9      # set Y to 9
    li $a2, 1      # set border width to 1
    li $a3, 2     # set border height to 2
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get black colour
    sw $t0, 0($sp)          # store black colour on stack
    jal store_rect

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
# store_pixel

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = colour of pixel
######################################
store_pixel:
    lw $a3, ADDR_STORAGE_BOARD  # load drawing onto game board

    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $a3, $a3, $a1           # Add the Y offset to $t0, store the result in $t1
    add $a3, $a3, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
    
    sw $a2, 0($a3)              # Draw a coloured pixel at the current location in the bitmap
    
    # Return to calling program
    jr $ra


######################################
# draw_mario
######################################
draw_mario:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    
    # draw legs
    li $a0, 16      # set X
    li $a1, 12      # set Y
    li $a2, 2       # set width
    li $a3, 2       # set height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, BROWN           # get colour
    sw $t0, 0($sp)          # store colour on stack    
    jal draw_rect

    # draw torso
    li $a0, 16      # set X
    li $a1, 6       # set Y
    li $a2, 2       # set width
    li $a3, 6       # set height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, WHITE           # get colour
    sw $t0, 0($sp)          # store colour on stack    
    jal draw_rect

    # draw head
    li $a0, 15      # set X
    li $a1, 7       # set Y
    li $a2, 3       # set width
    li $a3, 1       # set height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, SKIN           # get colour
    sw $t0, 0($sp)          # store colour on stack
    jal draw_rect

    # draw last head pixel
    li $a0, 17      # X co-ordinate to draw
    li $a1, 6       # Y co-ordinate to draw
    lw $a2, SKIN    # colour of pixel
    jal draw_pixel

    # draw hair
    lw $a2, BROWN   # colour of pixel

    li $a0, 16      # X co-ordinate to draw
    li $a1, 5       # Y co-ordinate to draw
    jal draw_pixel
    li $a0, 17      # X co-ordinate to draw
    li $a1, 5       # Y co-ordinate to draw
    jal draw_pixel
    li $a0, 18      # X co-ordinate to draw
    li $a1, 6       # Y co-ordinate to draw
    jal draw_pixel

    # draw arm
    li $a0, 16      # X co-ordinate to draw
    li $a1, 9       # Y co-ordinate to draw
    lw $a2, GREY    # colour of pixel
    jal draw_pixel
    
    # animate arm
    li $t0, 500
    blt $s6, $t0, mario_second_frame
    # Otherwise in first frame 
        li $a0, 16      # X co-ordinate to draw
        li $a1, 10      # Y co-ordinate to draw
        lw $a2, SKIN    # colour of pixel
        jal draw_pixel
        j mario_end_animation

    mario_second_frame:
    li $t0, 400
    blt $s6, $t0, mario_third_frame
    # Otherwise in second frame 
        li $a0, 15      # X co-ordinate to draw
        li $a1, 9       # Y co-ordinate to draw
        lw $a2, SKIN    # colour of pixel
        jal draw_pixel

        li $s0, 13      # X co-ord pill
        li $s1, 9       # Y co-ord pill
        j mario_end_animation

    mario_third_frame:
    li $t0, 300
    blt $s6, $t0, mario_fourth_frame
    # Otherwise in third frame 
        li $a0, 15      # X co-ordinate to draw
        li $a1, 8       # Y co-ordinate to draw
        lw $a2, SKIN    # colour of pixel
        jal draw_pixel

        li $s0, 13      # X co-ord pill
        li $s1, 7       # Y co-ord pill
        j mario_end_animation

    mario_fourth_frame:
    li $t0, 200
    blt $s6, $t0, mario_fifth_frame
    # Otherwise in fourth or fifth frame (share the same mario position)
        li $a0, 14      # X co-ordinate to draw
        li $a1, 8       # Y co-ordinate to draw
        lw $a2, SKIN    # colour of pixel
        jal draw_pixel
        li $a0, 15      # X co-ordinate to draw
        li $a1, 8       # Y co-ordinate to draw
        lw $a2, WHITE    # colour of pixel
        jal draw_pixel

        li $s0, 11      # X co-ord pill
        li $s1, 7       # Y co-ord pill
        j mario_end_animation

    mario_fifth_frame:
    li $t0, 100
    blt $s6, $t0, mario_sixth_frame
    # Otherwise in fifth frame 
        li $a0, 14      # X co-ordinate to draw
        li $a1, 8       # Y co-ordinate to draw
        lw $a2, SKIN    # colour of pixel
        jal draw_pixel
        li $a0, 15      # X co-ordinate to draw
        li $a1, 8       # Y co-ordinate to draw
        lw $a2, WHITE    # colour of pixel
        jal draw_pixel

        li $s0, 10      # X co-ord pill
        li $s1, 9       # Y co-ord pill
        j mario_end_animation

    mario_sixth_frame:
        li $a0, 15      # X co-ordinate to draw
        li $a1, 9       # Y co-ordinate to draw
        lw $a2, SKIN    # colour of pixel
        jal draw_pixel

        li $s0, 9      # X co-ord pill
        li $s1, 11       # Y co-ord pill

    
    # end function
    mario_end_animation:
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 


######################################
# draw_pixel

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = colour of pixel
######################################
draw_pixel:
    lw $a3, ADDR_PRE_DSPL          # load drawing onto game board

    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $a3, $a3, $a1           # Add the Y offset to $t0, store the result in $t1
    add $a3, $a3, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
    
    sw $a2, 0($a3)              # Draw a coloured pixel at the current location in the bitmap
    
    # Return to calling program
    jr $ra
    
    
######################################
# draw_line

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = length of line
# $a3 = colour of line
######################################
draw_line:
    lw $t0, ADDR_PRE_DSPL           # $t0 = base address for display
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
# draw_rect

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = width of rectangle
# $a3 = length of rectangle
# 0($sp) = colour of rectangle
######################################
draw_rect:
    lw $t9, 0($sp)              # load colour from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element

    add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
    row_start:
        # store registers
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $ra, 0($sp)              # store $ra on the stack
        jal store_registers
        
        move $a3, $t9
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


######################################
# store_line

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = length of line
# $a3 = colour of line
######################################
store_line:
    lw $t0, ADDR_STORAGE_BOARD  # $t0 = base address for display
    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $a1 by 128)
    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $a0 by 4)
    add $t1, $t0, $a1           # Add the Y offset to $t0, store the result in $t1
    add $t1, $t1, $a0           # Add the X offset to $t2 ($t2 now has the starting location of the line in bitmap memory)
    # Calculate the final point in the line (start point + length x 4)
    sll $a2, $a2, 2             # Multiply the length by 4
    add $t2, $t1, $a2           # Calculate the address of the final point in the line, store result in $t2.
    
    # Start the loop
    line_store_start:
        sw $a3, 0($t1)              # store a coloured pixel at the current location in the bitmap
        # Loop until the current pixel has reached the final point in the line.
        addi $t1, $t1, 4            # Move the current location to the next pixel
        beq $t1, $t2, line_store_end      # Break out of the loop when $t1 == $t2
        j line_store_start
        # End the loop
    line_store_end:

    # Return to calling program
    jr $ra


######################################
# store_rect

# $a0 = X co-ordinate to draw
# $a1 = Y co-ordinate to draw
# $a2 = width of rectangle
# $a3 = length of rectangle
# 0($sp) = colour of rectangle
######################################
store_rect:
    lw $t9, 0($sp)              # load colour from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element

    add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
    row_store_start:
        # store registers
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
        sw $ra, 0($sp)              # store $ra on the stack
        jal store_registers
        
        move $a3, $t9
        jal store_line

        # unstore registers
        jal unstore_registers
        lw $ra, 0($sp)              # restore $ra from the stack
        addi $sp, $sp, 4            # move the stack pointer to the new top element

        addi $a1, $a1, 1            # move to the next row to store
        addi $t0, $t0, 1            # increment the row variable by 1
        beq $t0, $a3, row_store_end       # when the last line has been stored, break out of the line-storing loop
        j row_store_start                 # jump to the start of the line-storing section
    row_store_end:
    jr $ra                      # return to the calling program