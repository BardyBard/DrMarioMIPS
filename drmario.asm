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
    .word 0xc8f902
BLUE:
    .word 0x3944BC
BLUEISH:
    .word 0x1e90FF
WHITE:
    .word 0xffffff
BLACK:
    .word 0x000000
BLACKISH:
    .word 0x000001


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
SECOND_PILL_A_COLOUR:
    .word 0x000000
SECOND_PILL_B_COLOUR:
    .word 0x000000

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # clear memory
    li $a0, 0
    li $a1, 0
    li $a2, 32
    li $a3, 32
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $zero, 0($sp)              # store $ra on the stack
    jal store_rect



    # Initialize the game
    jal store_border

    # Generate 4 new viruses
    addi $a0, $zero, 4
    jal generate_viruses
    jal store_new_pill
    jal load_pre_dspl

    start_new_pill:
        # Draw the pill

        jal generate_new_pill

    li $s5, 0                   # set pause to false
    li $s6, 600                 # Load mario animation
    li $s7, 300                 # Load main animation
    
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
        jal store_new_pill

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

    bne $s5, $zero, paused

    # 2a. Check for collisions
    # Reset the current game board
 

	# 2b. Update locations (capsules)
    # check for 4 in a row
    jal combo_check
    jal gravity_check
    

	# 3. Draw the screen
    jal clear_the_pre_dspl
    jal load_pre_dspl
    jal draw_mario
    jal draw_viruses
    jal draw_pill

	jal draw_the_screen

    # INCREASE ANIMATION COUNTERS
    # Virus animation
    addi $s7, $s7, -10
    bge $s7, $zero, skip_reset_game_animation
    li $s7, 800
    jal move_down
    skip_reset_game_animation:


    paused:
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
# game_over
######################################
game_over:
    # draw red border
    li $a0, 15          # set X
    li $a1, 14          # set Y
    li $a2, 17           # set  width
    li $a3, 12           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, RED        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    # draw black backround
    li $a0, 16          # set X
    li $a1, 15          # set Y
    li $a2, 15           # set  width
    li $a3, 10           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, BLACK        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    # draw G 
    li $a0, 16          # set X
    li $a1, 15          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 17          # set X
    li $a1, 16          # set Y
    jal draw_pixel
    li $a0, 18          # set X
    li $a1, 16          # set Y
    jal draw_pixel
    li $a0, 17          # set X
    li $a1, 17         # set Y
    jal draw_pixel

    # draw A
    li $a0, 20          # set X
    li $a1, 15          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 21          # set X
    li $a1, 16          # set Y
    jal draw_pixel
    li $a0, 21          # set X
    li $a1, 18          # set Y
    jal draw_pixel

    # draw M
    li $a0, 24          # set X
    li $a1, 15          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 25          # set X
    li $a1, 18         # set Y
    jal draw_pixel

    # draw E
    li $a0, 28          # set X
    li $a1, 15          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 30          # set X
    li $a1, 16          # set Y
    jal draw_pixel
    li $a0, 29          # set X
    li $a1, 17          # set Y
    jal draw_pixel
    li $a0, 30          # set X
    li $a1, 17         # set Y
    jal draw_pixel

    # draw O 
    li $a0, 16          # set X
    li $a1, 21          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 17          # set X
    li $a1, 22          # set Y
    jal draw_pixel
    li $a0, 17          # set X
    li $a1, 23          # set Y
    jal draw_pixel

    # draw V
    li $a0, 20          # set X
    li $a1, 21          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 21          # set X
    li $a1, 21          # set Y
    jal draw_pixel
    li $a0, 21          # set X
    li $a1, 22          # set Y
    jal draw_pixel
    li $a0, 21          # set X
    li $a1, 23         # set Y
    jal draw_pixel

    # draw E
    li $a0, 24          # set X
    li $a1, 21          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE       # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 26          # set X
    li $a1, 22          # set Y
    jal draw_pixel
    li $a0, 25          # set X
    li $a1, 23          # set Y
    jal draw_pixel
    li $a0, 26          # set X
    li $a1, 23         # set Y
    jal draw_pixel

    # draw R
    li $a0, 28          # set X
    li $a1, 21          # set Y
    li $a2, 3           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4   # move stack pointer
    lw $t0, WHITE        # get colour
    sw $t0, 0($sp)      # store colour on stack
    jal draw_rect

    lw $a2, BLACK       # set  width
    li $a0, 30          # set X
    li $a1, 23          # set Y
    jal draw_pixel
    li $a0, 29          # set X
    li $a1, 24          # set Y
    jal draw_pixel

    jal draw_the_screen
    li $s5, 1
    j paused
    
    li $v0, 10                  # exit the program gracefully
    syscall                     # (so it doesn't continue into the draw_rect function again)


######################################
# gravity_check
######################################
gravity_check:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    li $t0, 0       # current X co-ord to check
    li $t1, 0       # current Y co-ord to check
    li $t9, 7       # last X co-ord to check
    li $t8, 15      # last Y co-ord to check
    lw $t2, ADDR_STORAGE_BOARD
    lw $t3, BLACK
    lw $t5, YELLOWISH
    lw $t6, BLUEISH
    lw $t7, REDISH

    gravity_point_loop:
        addi $a0, $t0, 6        # current X co-ord to check with pillbox offset
        sll $a0, $a0, 2         # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        addi $a1, $t1, 14       # current Y co-ord to check with pillbox offset
        sll $a1, $a1, 7         # Calculate the Y offset to add to $t0 (multiply $a1 by 128)        
        
        add $a0, $a0, $a1       # Combine X and Y pixel location to check into $a0
        add $a0, $a0, $t2       # Find the actual memory location
        lw $a1, 0($a0)          # Load pixel to check

        beq $a1, $t3, skip_gravity_checking         # pixel is black
        beq $a1, $t5, skip_gravity_checking         # pixel is virus
        beq $a1, $t6, skip_gravity_checking         # pixel is virus
        beq $a1, $t7, skip_gravity_checking         # pixel is virus
            # Otherwise pixel is not black So check pixel below to see if its black
            lw $t4, 128($a0)        # load pixel below
            bne $t4, $t3, skip_gravity_checking       # pixel below is not black
                # Otherwise pixel black, so space below is free
                sw $a1, 128($a0)    # store block in space below
                sw $t3, 0($a0)      # store black where pixel used to be
        
        skip_gravity_checking:
        beq $t0, $t9, end_of_row_gravity      # Scanning has reached the end of the row
        j not_end_of_gravity_row
        
        end_of_row_gravity:
            beq $t1, $t8, end_gravity_checking
            addi $t1, $t1, 1        # increment current checked Y co-ord
            li $t0, 0               # reset X co-ord to start of row   
            j gravity_point_loop
        
        not_end_of_gravity_row:
        addi $t0, $t0, 1        # incremend current checked X co-ord
        j gravity_point_loop 
        
    # end function
    end_gravity_checking:
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 

######################################
# combo_check
######################################
combo_check:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    li $t0, 0       # current X co-ord to check
    li $t1, 0       # current Y co-ord to check
    li $t9, 7       # last X co-ord to check
    li $t8, 15      # last Y co-ord to check
    lw $t2, ADDR_STORAGE_BOARD
    lw $t3, BLACK

    combo_point_loop:
        addi $a0, $t0, 6        # current X co-ord to check
        sll $a0, $a0, 2         # Calculate the X offset to add to $t0 (multiply $a0 by 4)
        addi $a1, $t1, 14       # current Y co-ord to check
        sll $a1, $a1, 7         # Calculate the Y offset to add to $t0 (multiply $a1 by 128)        
        
        add $a0, $a0, $a1       # Combine X and Y pixel location to check into $a0
        add $a0, $a0, $t2       # Find the actual memory location
        lw $a1, 0($a0)          # Load pixel to check
        beq $a1, $t3, skip_combo_checking       # Make sure its not black
        # Otherwise pixel is not black
        
        li $v0, 1                   # set combo to 1
        jal store_registers
        jal combo_check_right
        jal unstore_registers
        
        li $t4, 4
        bge $v0, $t4, erase_right       # check if combo is more than 4
        j skip_to_vertical_combo
        
        erase_right:
            jal store_registers
            jal combo_erase_right
            jal unstore_registers
            # play success sound
            li $v0 31   # MIDI Code
            li $a0 90   # Note
            li $a1 90   # Duration (ms)
            li $a2 13   # Instrument type
            li $a3 90   # Volumne
            syscall
            j end_combo_checking 

        skip_to_vertical_combo:
            li $v0, 1                   # set combo to 1
            jal store_registers
            jal combo_check_bottom
            jal unstore_registers

        li $t4, 4
        bge $v0, $t4, erase_bottom       # check if combo is more than 4
        j skip_combo_checking

        erase_bottom:
            jal store_registers
            jal combo_erase_bottom
            jal unstore_registers
            # play success sound
            li $v0 31   # MIDI Code
            li $a0 90   # Note
            li $a1 90   # Duration (ms)
            li $a2 13   # Instrument type
            li $a3 90   # Volumne
            syscall
            j end_combo_checking 
        
        
        skip_combo_checking:
        beq $t0, $t9, end_of_row_combo      # Scanning has reached the end of the row
        j not_end_of_combo_row
        
        end_of_row_combo:
            beq $t1, $t8, end_combo_checking
            addi $t1, $t1, 1        # increment current checked Y co-ord
            li $t0, 0               # reset X co-ord to start of row   
            j combo_point_loop
        
        not_end_of_combo_row:
        addi $t0, $t0, 1        # incremend current checked X co-ord
        j combo_point_loop 
        
    # end function
    end_combo_checking:
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 

######################################
# combo_erase_right
# $a0 = memory location to check
# $v0 = number of blocks to erase
######################################
combo_erase_right:
    lw $t0, BLACK
    beq $v0, $zero done_erasing
    
    sw $t0, 0($a0)      # erase square
    addi $a0, $a0, 4    # move to next square
    addi $v0, $v0, -1   # subtract one from counter
    
    j combo_erase_right
    
    done_erasing:
    jr $ra


######################################
# combo_erase_bottom
# $a0 = memory location to check
# $v0 = number of blocks to erase
######################################
combo_erase_bottom:
    lw $t0, BLACK
    beq $v0, $zero done_erasing_bottom
    
    sw $t0, 0($a0)      # erase square
    addi $a0, $a0, 128    # move to next square
    addi $v0, $v0, -1   # subtract one from counter
    
    j combo_erase_bottom
    
    done_erasing_bottom:
    jr $ra


######################################
# combo_check_right
# $a0 = memory location to check
# $a1 = colour to check

# $v0 = return combo number
######################################
combo_check_right:   
    addi $a0, $a0, 4    # go right
    lw $t0, 0($a0)      # load the colour on the right
    
    lw  $t1, YELLOW    
    lw  $t2, YELLOWISH
    beq $a1, $t1, combo_right_yellow
    beq $a1, $t2, combo_right_yellow
    
    lw  $t1, RED    
    lw  $t2, REDISH
    beq $a1, $t1, combo_right_red
    beq $a1, $t2, combo_right_red
    
    lw  $t1, BLUE    
    lw  $t2, BLUEISH
    beq $a1, $t1, combo_right_blue
    beq $a1, $t2, combo_right_blue
    j combo_right_ends
    
    combo_right_yellow:
        beq $t0, $t1 combo_right_continues
        beq $t0, $t2 combo_right_continues
        j combo_right_ends
        
    combo_right_red:
        beq $t0, $t1 combo_right_continues
        beq $t0, $t2 combo_right_continues
        j combo_right_ends
        
    combo_right_blue:
        beq $t0, $t1 combo_right_continues
        beq $t0, $t2 combo_right_continues
        j combo_right_ends
    
    combo_right_continues:
        addi $v0, $v0, 1
        j combo_check_right
    
    combo_right_ends:
    jr $ra 
   

#####################################
# combo_check_bottom
# $a0 = memory location to check
# $a1 = colour to check

# $v0 = return combo number
######################################
combo_check_bottom:   
    addi $a0, $a0, 128    # go bottom
    lw $t0, 0($a0)      # load the colour on the bottom
    
    lw  $t1, YELLOW    
    lw  $t2, YELLOWISH
    beq $a1, $t1, combo_bottom_yellow
    beq $a1, $t2, combo_bottom_yellow
    
    lw  $t1, RED    
    lw  $t2, REDISH
    beq $a1, $t1, combo_bottom_red
    beq $a1, $t2, combo_bottom_red
    
    lw  $t1, BLUE    
    lw  $t2, BLUEISH
    beq $a1, $t1, combo_bottom_blue
    beq $a1, $t2, combo_bottom_blue
    j combo_bottom_ends
    
    combo_bottom_yellow:
        beq $t0, $t1 combo_bottom_continues
        beq $t0, $t2 combo_bottom_continues
        j combo_bottom_ends
        
    combo_bottom_red:
        beq $t0, $t1 combo_bottom_continues
        beq $t0, $t2 combo_bottom_continues
        j combo_bottom_ends
        
    combo_bottom_blue:
        beq $t0, $t1 combo_bottom_continues
        beq $t0, $t2 combo_bottom_continues
        j combo_bottom_ends
    
    combo_bottom_continues:
        addi $v0, $v0, 1
        j combo_check_bottom
    
    combo_bottom_ends:
    jr $ra

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
       
    beq $a0 0x61 move_left      # If second word == A: move left
    # beq $a0 0x6a move_left      # If second word == J: move left
    
    beq $a0 0x64 move_right     # If second word == D: move right
    # beq $a0 0x6c move_right     # If second word == L: move right

    beq $a0 0x73 move_down      # If second word == S: move down
    # beq $a0 0x6b move_down     # If second word == K: move down
    
    beq $a0 0x77 rotate         # If second word == W: rotate
    # beq $a0 0x7a rotate         # If second word == Z: rotate

    beq $a0 0x71 game_over      # If second word == Q: quit game

    beq $a0 0x72 main           # If second word == R: restart game

    beq $a0 0x70 flip_pause           # If second word == P: pause game
    
    j done_keyboard_input              # otherwise input is bad


######################################
# is_clear
# $a0 = X co-ord to check
# $a1 = Y co-ord to check
# $v0 = return (0 = False, not clear)
# $v1 = return colour of pixel, not used if clear as black can be assumed
######################################
is_clear:
    lw $t0, ADDR_PRE_DSPL

    sll $a0, $a0, 2             # Calculate the X offset to add to $t0 (multiply $s0 by 4)
    add $t0, $t0, $a0           # Shift accessed address to x co-ord to check

    sll $a1, $a1, 7             # Calculate the Y offset to add to $t0 (multiply $s1 by 128)
    add $t0, $t0, $a1           # Shift accessed address to Y co-ord to check

    lw $v1, 0($t0)              # Load byte into $v1 to check pre display 
    lw $t2, BLACK               # Load BLACK to compare against

    beq $v1, $t2, is_clear_TRUE            # If $v1 == $t2, the position is clear

    # otherwise is_clear_False
    li $v0, 0                   # Otherwise, set $v0 to 0 (not clear)
    jr $ra                      # Return from function
    
    is_clear_TRUE:  
    li $v0, 1                   # Set $v0 to 1 (clear)
    jr $ra                      # Return from function


######################################
# flip_pause
######################################
flip_pause:
    beq $s5 $zero, set_pause
    move $s5, $zero
    j done_keyboard_input

    set_pause:
    li $s5, 1
    
    # draw pause
    li $a0, 9      # set X
    li $a1, 8      # set Y
    li $a2, 4       # set width
    li $a3, 19       # set height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, GREY           # get colour
    sw $t0, 0($sp)          # store colour on stack    
    jal draw_rect

    li $a0, 20      # set X
    li $a1, 8      # set Y
    li $a2, 4       # set width
    li $a3, 19       # set height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, GREY           # get colour
    sw $t0, 0($sp)          # store colour on stack    
    jal draw_rect

    jal draw_the_screen

    j paused

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
        
        # play rotate sound
        li $v0 31   # MIDI Code
        li $a0 41    # Note
        li $a1 100   # Duration (ms)
        li $a2 127   # Instrument type
        li $a3 90   # Volumne
        
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
        
        li $v0 31   # MIDI Code
        li $a0 50   # Note
        li $a1 90   # Duration (ms)
        li $a2 127   # Instrument type
        li $a3 70   # Volumne
        syscall
        li $v0 31   # MIDI Code
        li $a0 20   # Note
        li $a1 90   # Duration (ms)
        li $a2 127   # Instrument type
        li $a3 70   # Volumne
        syscall
        li $v0 31   # MIDI Code
        li $a0 90   # Note
        li $a1 90   # Duration (ms)
        li $a2 127   # Instrument type
        li $a3 70   # Volumne
        syscall
        
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

    # animation setup
    li $t4, 700                 # value to compare animation counter for viruses
    lw $t9, REDISH               # Get black to compare
    lw $t8, YELLOWISH               # Get black to compare
    lw $t7, BLUEISH               # Get black to compare
    lw $t6, BLACKISH

    li $v0, 1           # Set over state to True

    load_storage_loop:
        lw $t3, 0($t0)          # Load byte from ADDR_PRE_DSPL into $t3    
        sw $t3, 0($t1)          # Store byte into ADDR_DISP


        # Check if virus
        beq $t3, $t9, flicker_virus
        beq $t3, $t8, flicker_virus
        beq $t3, $t7, flicker_virus
        j skip_virus_unrendering

        flicker_virus:
            li $v0, 0               # set game over false
            # Check virus animation cycle to see if they should be loaded
            blt $s7, $t4, skip_virus_unrendering
            sw $t6, 0($t1)          # store blackish


        skip_virus_unrendering:

        # Increment pointers and decrement counter
        addi $t0, $t0, 4        # Move to next byte in ADDR_PRE_DSPL
        addi $t1, $t1, 4        # Move to next byte in ADDR_DISP
        addi $t2, $t2, -1       # Decrease counter
        
        bne $t2 $zero load_storage_loop   
    
    bne $v0, $zero, game_over

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
# store_new_pill
######################################
store_new_pill:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    # returns a0 filled with one of 1 colours, overwrites a0
    jal generate_pill_colour
    move $a2, $a0
    li $a0, 14
    li $a1, 10
    jal store_pixel

    # returns a0 filled with one of 1 colours, overwrites a0
    jal generate_pill_colour
    move $a2, $a0
    li $a0, 15
    li $a1, 10
    jal store_pixel

    # end function
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 

######################################
# generate_new_pill
######################################
generate_new_pill:
    # start function
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    # Check if new pill location is clear
    li $a0, 9
    li $a1, 14
    jal is_clear
    beq $v0, $zero, game_over

    li $a0, 10
    li $a1, 14
    jal is_clear
    beq $v0, $zero, game_over

    # load pill
    li $s0, 14       # capsule X
    li $s1, 10      # capsule Y
    li $s2, 0       # capsule orientation
    
    # fetch colour from storage
    li $a0, 14
    li $a1, 10
    jal is_clear
    move $s3, $v1
    #overwrite pill with black
    move $a2, $zero
    li $a0, 14
    li $a1, 10
    jal store_pixel

    li $a0, 15
    li $a1, 10
    jal is_clear
    move $s4, $v1
    #overwrite pill with black
    move $a2, $zero
    li $a0, 15
    li $a1, 10
    jal store_pixel
    
    # end function
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra 


######################################
# draw_viruses
######################################
draw_viruses:
    # store ra
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    li $t7, 200
    li $t8, 600
    li $t6, 400

    # draw blue virus
    li $a0, 17          # set X
    li $a1, 17          # set Y
    li $a2, 4           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, BLUE         # get colour
    sw $t0, 0($sp)          # store colour on stack
    jal store_rect

    li $a0, 18          # set X
    li $a1, 18          # set Y
    move $a2, $zero       # set colour
    jal store_pixel
    ble $s7, $t7, flicker_blue_virus 
    li $a0, 19          # set X
    li $a1, 18          # set Y
    lw $a2, WHITE     # set colour
    jal draw_pixel
    flicker_blue_virus:

    # draw yellow virus
    li $a0, 22          # set X
    li $a1, 22          # set Y
    li $a2, 4           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, YELLOW       # get colour
    sw $t0, 0($sp)          # store colour on stack
    jal store_rect

    li $a0, 22          # set X
    li $a1, 23          # set Y
    move $a2, $zero       # set colour
    jal store_pixel
    li $a0, 24          # set X
    li $a1, 23          # set Y
    move $a2, $zero     # set colour
    jal store_pixel
    bge $s7, $t8, flicker_yellow_virus 
    li $a0, 23          # set X
    li $a1, 24          # set Y
    lw $a2, RED     # set colour
    jal draw_pixel
    flicker_yellow_virus:

    # draw red virus
    li $a0, 24          # set X
    li $a1, 14          # set Y
    li $a2, 4           # set  width
    li $a3, 4           # set  height
    addi $sp, $sp, -4       # move stack pointer
    lw $t0, RED          # get colour
    sw $t0, 0($sp)          # store colour on stack
    jal store_rect

    li $a0, 24          # set X
    li $a1, 15          # set Y
    move $a2, $zero       # set colour
    jal store_pixel
    li $a0, 26          # set X
    li $a1, 15          # set Y
    lw $a2, BLACK     # set colour
    jal store_pixel
    ble $s7, $t6, flicker_red_virus 
    li $a0, 24          # set X
    li $a1, 17          # set Y
    lw $a2, WHITE     # set colour
    jal draw_pixel
    li $a0, 25          # set X
    li $a1, 17          # set Y
    lw $a2, WHITE     # set colour
    jal draw_pixel
    flicker_red_virus:

    # end
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
    
    # start func
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
    row_start:
        jal store_registers
        
        move $a3, $t9
        jal draw_line
        # unstore registers
        
        jal unstore_registers
        
        addi $a1, $a1, 1            # move to the next row to draw
        addi $t0, $t0, 1            # increment the row variable by 1
        beq $t0, $a3, row_end       # when the last line has been drawn, break out of the line-drawing loop
        j row_start                 # jump to the start of the line-drawing section
    row_end:
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
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
    
    # store ra
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    add $t0, $zero, $zero       # create a loop variable with an iniital value of 0
    row_store_start:
        jal store_registers
        
        move $a3, $t9
        jal store_line

        # unstore registers
        jal unstore_registers

        addi $a1, $a1, 1            # move to the next row to store
        addi $t0, $t0, 1            # increment the row variable by 1
        beq $t0, $a3, row_store_end       # when the last line has been stored, break out of the line-storing loop
        j row_store_start                 # jump to the start of the line-storing section
    row_store_end:
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    jr $ra                      # return to the calling program