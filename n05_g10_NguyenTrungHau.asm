#Final project: project 5
#Nguyen Trung Hau - Group 10

.data
	infix: 
		.space 1000
	postfix: 
		.space 1000
	stack: 
		.space 1000
	msg_input:
		.asciiz "Enter infix expression\n(note) Input expression only contains (,),+,-,*,/\n Integer number in range 0-99:"
	newline: 
		.asciiz "\n"
	msg_out_postfix: 
		.asciiz "Postfix is: "
	msg_out_result: 
		.asciiz "Result is: "
	msg_out_infix: 
		.asciiz "Infix is: "
	msg_ask_continue:
		.asciiz "Do you want to continue?"
	msg_div0:
		.asciiz "Error! Exp div 0"
	msg_error2:
		.asciiz "less ')'"
	msg_error3:
		.asciiz "less '('"
.text
start:
input:
	# get infix
	li $v0, 54				#input dialog string
 	la $a0, msg_input			#address of msg_input
 	la $a1, infix				#input buffer
 	la $a2, 1000				#maximum length input
 	syscall 
 	bnez $a1,input				#check emptyset
 	
	#print "Infix is: "
	la $a0, msg_out_infix
	li $v0, 4
	syscall
	
#print infix to screen
	la $a0, infix
	li $v0, 4
	syscall

#--------------------------------------------------------------------------------
#Convert to postfix
#Algorithm:
#	Scan the infix expression from left to right.
#	If the scanned character is an operand, output it.
#	Else,
#	If the precedence of the scanned operator is greater than the precedence of the operator in the stack (or the stack is empty or the stack contains a ‘(‘ ), push it.
#	Else, Pop all the operators from the stack which are greater than or equal to in precedence than that of the scanned operator. 
#       After doing that Push the scanned operator to the stack. (If you encounter parenthesis while popping then stop there and push the scanned operator in the stack.)
#	If the scanned character is an ‘(‘, push it to the stack.
#	If the scanned character is an ‘)’, pop the stack and output it until a ‘(‘ is encountered, and discard both the parenthesis.
#	Repeat above steps until infix expression is scanned.
# $s1: addr of infix
# $t5: addr of postfix
# $t6: addr of stack
# $s2: operator '+'
# $s3: operator '-'
# $s4: operator '*'
# $s5: operator '/'
# $s6 : counter, i
#
#
#--------------------------------------------------------------------------------
	li $s6, -1 				# infix string counter i
	li $s7, -1 				# stack counter j
	li $t7, -1 				# postfix counter k
	li $s2, '+'
        li $s3, '-'
        li $s4, '*'
        li $s5, '/'
while_scan:
        la $s1, infix  				#s = $s1
        la $t5, postfix 			#postfix = $t5
        la $t6, stack 				#stack = $t6
	addi $s6, $s6, 1 			# i++
	
	# get value of s[i]
	add $s1, $s1, $s6
	lb $t1, 0($s1)				# t1 = value of s[i]
	
	# if buffer[i] is a operator or bracket
	beq $t1, '+', operator # '+'
	nop
	beq $t1, '-', operator # '-'
	nop
	beq $t1, '*', operator # '*'
	nop
	beq $t1, '/', operator # '/'
	nop
	beq $t1, '\n', newline_space #newline_space # '\n'
	nop
	beq $t1, ' ', newline_space  #newline_space # ' '
	nop
	beq $t1, '(', open_bracket	# push '(' to stack
	nop
	beq $t1, ')', close_bracket	
	nop
	
	beq $t1, $zero, end_while_scan
	nop
	
	# else buffer[i] is a number  
	# push number to postfix
	addi $t7, $t7, 1
	add $t5, $t5, $t7
	
	sb $t1, 0($t5)

	lb $a0, 1($s1)
	
	jal check_number
	# if is number
	beq $v0, 1, newline_space
	nop
	
add_space:
	add $t1, $zero, 32
	sb $t1, 1($t5)
	addi $t7, $t7, 1
#
	j newline_space
	nop
operator:
	# add to stack ...
	# if stack is empty
	beq $s7, -1, push_to_stack
	nop
	
	# take value of the operator at the top of the stack
	add $t6, $t6, $s7
	lb $t2, 0($t6) 				# t2 = value of stack[top]
	
	# check if t2 = '('
	beq $t2,'(', push_to_stack
	# check t1 precedence
	beq $t1, $s2, encode_t1
	nop
	beq $t1, $s3, encode_t1
	nop
	
	li $t3, 2
	
	j check_t2
	nop
		
encode_t1:
	li $t3, 1
	
# check t2 precedence
check_t2:
	beq $t2, $s2, encode_t2
	nop
	beq $t2, $s3, encode_t2
	nop
	
	li $t4, 2	
	
	j compare_precedence
	nop
	
	
encode_t2:
	li $t4, 1	

# compare precedence:
#--------------------------------------------	
# If t4 >= t3 aka preference of t2 >= p.o. t1
# 	pop t2 from stack and move t2 to postfix  
# 	get new top stack do again
# Else, push t1
#--------------------------------------------
compare_precedence:	
	bge  $t4, $t3, greater_or_equal_precedence
	nop
	# else
	j less_than_precedence
	nop
greater_or_equal_precedence:
# pop t2 from stack  and t2 ==> postfix  
# push to stack
	sb $zero, 0($t6)
	addi $s7, $s7, -1  				# stack counter --
	addi $t6, $t6, -1
	la $t5, postfix 				# postfix = $t5
	addi $t7, $t7, 1				# postfix counter ++
	add $t5, $t5, $t7				
	sb $t2, 0($t5)					# store operator in $t2 to post fix expression
	
	j operator
	nop
	
#---------------------------------------------	
less_than_precedence:
# push t1 to stack
	j push_to_stack
	nop
open_bracket:
	j push_to_stack # -> push '(' to stack
close_bracket:
	beq $s7,-1,error3
	la $t6,stack
	add $t6,$t6,$s7
	lb $t8, 0($t6)
	add $s7,$s7,-1
	addi $t6, $t6, -1
	beq $t8, '(', match_bracket
	
	la $t5, postfix 				# postfix = $t5
	addi $t7, $t7, 1				# postfix counter ++
	add $t5, $t5, $t7				
	sb $t8, 0($t5)	
	j close_bracket	# continue loop
match_bracket:		# Discard a pair of matched brackets
	#addi 	$t6, $t6, -1				# Decrement top of Operator offset
	j 	while_scan
push_to_stack:
	la $t6, stack 					# stack = $t6
	addi $s7, $s7, 1  				# stack counter ++
	add $t6, $t6, $s7
	sb $t1, 0($t6)					# store $t1 to stack[top] 
	j while_scan
	nop
newline_space:	
	j while_scan	
	nop
	
#------------------------------------------
end_while_scan:
	addi $s1, $zero, 32 # s1 = ' ' 
	add $t7, $t7, 1
	add $t5, $t5, $t7 
	la $t6, stack
	add $t6, $t6, $s7
	
pop_all_stack:

	lb $t2, 0($t6)			# t2 = value of stack[top] 
	#if stack is empty: end_post_fix
	beq $t2, $zero, end_postfix
	#else 
	sb $zero, 0($t6)
	addi $s7, $s7, -2
	add $t6, $t6, $s7
	
	beq $t2,'(',error2
	sb $t2, 0($t5)
	add $t5, $t5, 1
	
	j pop_all_stack
	nop

end_postfix:
# END POSTFIX
#------------------------------------------------------------------------
# Print postfix
	la $a0, msg_out_postfix
	li $v0, 4
	syscall

	la $a0, postfix
	li $v0, 4
	syscall

	la $a0, newline
	li $v0, 4
	syscall

#----------------------------------------------------------------------------- 
# Calculate the value of the expression
# 1) Create a stack to store operands (or values).
# 2) Scan the given expression and do following for every scanned element.
# …..a) If the element is a number, push it into the stack
# …..b) If the element is a operator, pop operands for the operator from stack. Evaluate the operator and push the result back to the stack
# 3) When the expression is ended, the number in the stack is the final answer
#-----------------------------------------------------------------------------

	li $s7, 0 					# counter
	la $t6, stack 					# stack = $s2

# postfix to stacka
while_postfix_cal:
	la $t5, postfix 				# postfix = $s1
	
	add $t5, $t5, $s7
	lb $t1, 0($t5)					# $t1 = p[i]
	
	# if finish scanning postfix
	beqz $t1 end_while_postfix_cal
	nop
	
	add $a0, $zero, $t1				# $a0 = p[i]
	jal check_number
	nop
	
	#if $v0= 0 -> is operator
	beqz $v0, is_operator
	nop
	
	jal add_number_to_stack
	nop
	
	j continue
	nop
	
is_operator:	
	jal pop
	nop
	
	add $a1, $zero, $v0 				# a1 = stack.pop
	
	jal pop
	nop
	
	add $a0, $zero, $v0 				# a0 = stack.pop
	
	#if is operator	
	add $a2, $zero, $t1 				# operation
	jal calculate
continue:	
	add $s7, $s7, 1 				# counter++
	j while_postfix_cal
	nop
	
#-----------------------------------------------------------------
# Void calculate
# Calculate the number ("a op b")
# a0 : (int) a
# a1 : (int) b
# a2 : operator(op) as character
#-----------------------------------------------------------------
calculate:
	sw $ra, 0($sp)
	li $v0, 0
	beq $t1, '*', cal_case_mul
	nop
	beq $t1, '/', cal_case_div
	nop
	beq $t1, '+', cal_case_add
	nop
	beq $t1, '-', cal_case_sub
	
	cal_case_mul:
		mul $v0, $a0, $a1
		j cal_push
	cal_case_div:
		beqz $a1,error1
		div $a0, $a1
		mflo $v0 # LO: quotient, HI: remainder
		j cal_push
	cal_case_add:
		add $v0, $a0, $a1
		j cal_push
	cal_case_sub:
		sub $v0, $a0, $a1
		j cal_push
		
	cal_push:
		add $a0, $v0, $zero
		jal push
		nop
		lw $ra, 0($sp) 
		jr $ra
		nop

#-----------------------------------------------------------------
#Procedure add_number_to_stack
# @brief get the number and add number to stack at $s2
# @param[in] s3 : counter for postfix string
# @param[in] s1 : postfix string
# @param[in] t1 : current value
#-----------------------------------------------------------------
add_number_to_stack:
	# save $ra
	sw $ra, 0($sp)
	li $v0, 0
	
	while_ants:
		beq $t1, '0', ants_case_0
		nop
		beq $t1, '1', ants_case_1
		nop
		beq $t1, '2', ants_case_2
		nop
		beq $t1, '3', ants_case_3
		nop
		beq $t1, '4', ants_case_4
		nop
		beq $t1, '5', ants_case_5
		nop
		beq $t1, '6', ants_case_6
		nop
		beq $t1, '7', ants_case_7
		nop
		beq $t1, '8', ants_case_8
		nop
		beq $t1, '9', ants_case_9
		nop
		
		ants_case_0:
			j ants_2nd_digit
		ants_case_1:
			addi $v0, $v0, 1	
			j ants_2nd_digit
			nop
		ants_case_2:
			addi $v0, $v0, 2
			j ants_2nd_digit
			nop
		ants_case_3:
			addi $v0, $v0, 3
			j ants_2nd_digit
			nop
		ants_case_4:
			addi $v0, $v0, 4
			j ants_2nd_digit
			nop
		ants_case_5:
			addi $v0, $v0, 5
			j ants_2nd_digit
			nop
		ants_case_6:
			addi $v0, $v0, 6
			j ants_2nd_digit
			nop
		ants_case_7:
			addi $v0, $v0, 7
			j ants_2nd_digit
			nop
		ants_case_8:
			addi $v0, $v0, 8
			j ants_2nd_digit
			nop
		ants_case_9:
			addi $v0, $v0, 9
			j ants_2nd_digit
			nop
		ants_2nd_digit:
			
			add $s7, $s7, 1 			# counter++
			la $t5, postfix 			# $t5 = postfix 
	
			add $t5, $t5, $s7
			lb $t1, 0($t5)
		
			beq $t1, $zero, end_while_ants
			beq $t1, ' ', end_while_ants
			
			mul $v0, $v0, 10
			
			j while_ants
		
	end_while_ants:
		add $a0, $zero, $v0
		jal push
		# get $ra
		lw $ra, 0($sp) 
		jr $ra
		nop
		
		
#-----------------------------------------------------------------
# Void check_number
# if ( s[i] < '0') || ( s[i] > '9') -> false
# else true
# s[i] : $a0
# $v0 : 1 = true; 0 = false
#-----------------------------------------------------------------
check_number:
	li $t8, '0'
	li $t9, '9'
	
	#if s[i] < '0' -> false
	#else if s[i] > '9' -> false
	# else true
	slt $v0, $a0, $t8 #if s[i] < '0' -> $v0 = 1  
	bgtz $v0, check_number_false # if $v0 > 0 ( $v0 = 1) -> false
	
	slt $v0, $t9, $a0 #if '9' < s[i] -> $v0 = 1 
	bgtz $v0, check_number_false # if $v0 > 0 ( $v0 = 1) -> false
	
	#if check number is true 	
	li $v0, 1
	jr $ra
	nop
	
check_number_false:
	li $v0, 0
	jr $ra
	nop


#-----------------------------------------------------------------
#Procedure pop
# @brief pop from stack at $s2
# @param[out] v0 : value to popped
#-----------------------------------------------------------------
pop:
	lw $v0, -4($t6)
	sw $zero, -4($t6)
	add $t6, $t6, -4
	jr $ra
	nop

#-----------------------------------------------------------------
#Procedure push
# @brief push to stack at $s2
# @param[in] a0 : value to push
#-----------------------------------------------------------------
push:
	sw $a0, 0($t6)
	add $t6, $t6, 4
	jr $ra
	nop
	
end_while_postfix_cal:
	# add null to end of stack
	# print postfix
	la $a0, msg_out_result
	li $v0, 4
	syscall
	
	#print result
	jal pop
	add $a0, $zero, $v0 
	li $v0, 1
	syscall
	
	#print newline
	la $a0, newline
	li $v0, 4
	syscall
	
# Ask user to continue or not
ask: 	
 	li $v0, 50	#confirm dialog
 	la $a0, msg_ask_continue
 	syscall
 	
 	beq $a0, 0, start
 	j end
end: 
	li $v0,10
	syscall 
error1:
	li $v0, 50
	la $a0,msg_div0
	syscall
	j start
error2:
	li $v0, 50
	la $a0,msg_error2
	syscall
	j start
error3:
	li $v0, 50
	la $a0,msg_error3
	syscall
	j start
