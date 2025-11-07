# This program reads a comma-separated list of up to 6 items
# removing duplicates and then builds a new string without said duplicates
# - parse        		: splits str into item1..item6, into array (len: nb_items)
# - equals_str		: compares two strings (v0=1 equal, 0 otherwise)
# - build_new_arr 	: constructs new_array without dupes (len: new_nb_items)
# - build_string  	: joins new_items into final_str "a, b, c"
# - print_without_dup 	: runs above functions and prints final_str
# - main 		: lets user input str, processes it, print final_str, ask user if want to repeat

.data
item1: .space 100
item2: .space 100
item3: .space 100
item4: .space 100
item5: .space 100
item6: .space 100
array: .word item1, item2, item3, item4, item5, item6
nb_items: .word 0

new_item1: .space 100
new_item2: .space 100
new_item3: .space 100
new_item4: .space 100
new_item5: .space 100
new_item6: .space 100
new_array: .word new_item1, new_item2, new_item3, new_item4, new_item5, new_item6
new_nb_items: .word 0

final_str: .space 150

str: .space 605 # 605 because 99*6 + 2*5 + 1 ('\0') (worst case of how big string can be)
msg1: .asciiz "\nPlease enter your string: "
msg2: .asciiz "\nYour string with duplicates removed is: "
msg3: .asciiz "\nDo you want to do this again? Y/N: "

.text
main:
loop:
    # first prompt
    la $a0, msg1
    li $v0, 4
    syscall

    # user input
    la $a0, str
    li $a1, 605
    li $v0, 8
    syscall

    # second prompt
    la $a0, msg2
    li $v0, 4
    syscall

    la $a0, str
    jal print_without_dup

    # third prompt
    la $a0, msg3
    li $v0, 4
    syscall

    # read the char
    li $v0, 12
    syscall
    move $t0, $v0

    li $t1, 'Y'
    beq $t0, $t1, clear
    li $t1, 'y'
    beq $t0, $t1, clear

    # exit 
    li $v0, 10
    syscall

clear:
    li $v0, 12
    syscall
    li $t2, '\n'
    bne $v0, $t2, clear
    j loop

# splits input i.e. "hello, world, foo, world" into item1..itemN
# parse(char* arr)
parse: 
    addiu $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp) 
    sw $s1, 8($sp)  
    sw $s2, 12($sp) 
    sw $s3, 16($sp) 
    sw $s4, 20($sp) 

    # init 
    move $s0, $a0 # source ptr
    la $s1, array # &a[0] 
    move $s2, $s1 # running ptr to $a[i]
    lw $s1, 0($s2) # arr[0] itemN buffer
    li $s3, 0 # char count
    li $s4, 0 # nb_items / item index

parse_loop:
    lbu $t0, 0($s0)
    # end of string
    beq $t0, $0, parse_eos
    # new word 
    li $t1, ','
    beq $t0, $t1, parse_split
    # skip
    li $t1, ' '
    beq $t0, $t1, parse_increment
    li $t1, '\n'
    beq $t0, $t1, parse_increment
    # writing byte into itemN
    sb $t0, 0($s1)
    addiu $s1, $s1, 1 
    addiu $s3, $s3, 1 # char index
    j parse_increment

# finish loading itemN in b/c comma found
parse_split:
    beq $s3, $0, parse_increment # no item to add
    # append nul-terminator to item
    sb $0, 0($s1) # terminate curr item
    addiu $s4, $s4, 1 #nb_items++
    # adv &a[i] 
    addiu $s2, $s2, 4
    lw $s1, 0($s2)
    li $s3, 0 # char_count = 0 again

parse_increment:
    addiu $s0, $s0, 1 
    j parse_loop

# eos = end of string
parse_eos:
    beq $s3, $0, parse_exit # no item to add
    sb $0, 0($s1) 
    addiu $s4, $s4, 1


parse_exit:
    la $t0, nb_items
    sw $s4, 0($t0)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addiu $sp, $sp, 24
    jr $ra

# returns boolean if two strings are equal (1=true 0=false)
# int equals_str(char* str1, char* str2)
equals_str:
    addiu $sp, $sp, -8
    sw $s0 0($sp)
    sw $s1, 4($sp)

    li $v0, 1 # assume equals until proven wrong

equals_loop:
    lbu $s0, 0($a0)
    lbu $s1, 0($a1)
    bne $s0, $s1, equals_false # check if char1=char2
    beq $s0, $0, equals_exit # end of string occurs
    addiu $a0, $a0, 1
    addiu $a1, $a1, 1
    j equals_loop

equals_false:
    move $v0, $0

equals_exit:
    lw $s0 0($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 8
    jr $ra


# makes new_array full of items from array, but without duplicates 
# (constructs it on a first-appearance basis) 
# build_new_arr()
build_new_arr:
    addiu $sp, $sp, -36
    sw $ra, 0($sp) 
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)

    # init
    la $s0, array # &a[0]
    la $s1, new_array # &na[0]
    lw $s2, nb_items # nb_items
    li $s3, 0 # new_nb_items 
    li $s4, 0 # index i
    lw $s5, 0($s0) # curr = a[0]
    move $s6, $s1 # $na[0] running ptr


bna_outer_loop:
    slt $t0, $s4, $s2 # i < nb_items
    beq $t0, $0, bna_exit
    move $s7, $s1
    li $t0, 0 # j = 0

bna_inner_loop:
    slt $t1, $t0, $s3 # j < new_nb_items
    beq $t1, $0, bna_no_dup

    lw $a1, 0($s7)
    move $a0, $s5
    jal equals_str
    bne $v0, $0, bna_dup # found duplicate

    addiu $s7, $s7, 4 
    addiu $t0, $t0, 1 
    j bna_inner_loop

# duplicate found -> move to next item
bna_dup:
    addiu $s0, $s0, 4 # &arr[i++] next item
    addiu $s4, $s4, 1
    lw $s5, 0($s0)
    j bna_outer_loop

# copy str into new arr bc no dupes
bna_no_dup:
    lw $t2, 0($s6)

# copy until '\0'
bna_copy:
    lbu $t3, 0($s5)
    sb $t3, 0($t2)
    addiu $s5, $s5, 1
    addiu $t2, $t2, 1
    bne $t3, $0, bna_copy

    addiu $s3, $s3, 1
    addiu $s6, $s6, 4
    addiu $s0, $s0, 4
    addiu $s4, $s4, 1
    lw $s5, 0($s0)
    j bna_outer_loop

bna_exit:
    la $t0, new_nb_items
    sw $s3, 0($t0)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    addiu $sp, $sp, 36
    jr $ra

# iterates through strs in new_array, building final_str "new item1, new item2, etc."
# build_string()
build_string:
    addiu $sp, $sp, -16
    sw $ra, 0($sp) 
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    # init 
    la $s0, final_str
    la $s1, new_array
    la $t0, new_nb_items
    lw $s2, 0($t0)
    beq $s2, $0, bs_empty 

# for each item copy until '\0'
bs_item:
    lw $t1, 0($s1)

bs_copy:
    lbu $t0, 0($t1)
    beq $t0, $0, bs_after_copy
    sb $t0, 0($s0)
    addiu $t1, $t1, 1
    addiu $s0, $s0, 1
    j bs_copy

# after copying one item update var accordingly
bs_after_copy:
    addiu $s2, $s2, -1
    bne $s2, $0, bs_split

    sb $0, 0($s0)
    j bs_exit

# write "," to separate items and update accordingly
bs_split:
    li $t2, ','
    sb $t2, 0($s0)
    addiu $s0, $s0, 1
    li $t2, ' '
    sb $t2, 0($s0)
    addiu $s0, $s0, 1

    addiu $s1, $s1, 4
    j bs_item

# no items -> final_str = ""
bs_empty:
    sb $0, 0($s0)

bs_exit:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

# given string -> put items in array -> remove dupes & put in new_array -> produce final_string
# print_without_dup(char* str)
print_without_dup:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    # process described above
    jal parse
    jal build_new_arr
    jal build_string

    # print final_string
    la $a0, final_str
    li $v0, 4
    syscall

    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
