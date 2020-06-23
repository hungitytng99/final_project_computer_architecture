#Author: Le Huy Van 20176906
#Purpose:Final Project 
.data
strSpace: .space 2000
inputSize: .word 2000
tempSpace: .space 8  #khong gian luu tru khoi 4 byte tam thoi
inputPrompt: .asciiz "\nNhap xau ki tu:\n"
diskDisplay:    .asciiz "\n     Disk1                   Disk2                   Disk3"
frameDisplay:	.asciiz "\n---------------         ---------------         ---------------\n"
space:		.asciiz "         "
leftBorder: 	.asciiz "|     "
rightBorder: 	.asciiz "    |"
inputEmpty:	.asciiz "Nhap vao xau rong.\nNhap lai!"
inputError: 	.asciiz "Do dai xau phai chia het cho 8!\n Nhap lai"
tryAgain: 	.asciiz "Lai nua khong?"
.text
get_string:	#Nhap string
		li $v0,4
		la $a0,inputPrompt
		syscall
		li $v0,8
		la $a0,strSpace
		lw $a1,inputSize
		syscall
		
		
		la $s0,strSpace 
		
										#s0 luu dia chi chuoi nhap vao
get_legnth:	la $a0,strSpace
		li $s1,0 #$s1=length=0
		li $t5,0 #t0=i=0
check_char:	add $t1,$a0,$t5	#t1=a0+t0   #address of String[0]+i
		lb $t2,0($t1)           #t2=string[i]
		beq $t2,10,end_get_length #is null char
		beq $t2,$zero,end_get_length #is null char
		addi $s1,$s1,1 #s1=s1+1 (length=length+1)			#s1 save length
		addi $t5,$t5,1 #t0=t0+1->i=i+1
		j check_char	
end_get_length:	
check_length:	
		li $t1,8
		div $s1,$t1
		mflo $t2
		mfhi $t3
		bne $t3,$zero,invalidInput #Chieu dai ko chia het cho 8 -> nhap lai
		beq $s1,$zero,emptyInput #Chieu dai bang 0 nhap lai
displayFrame:
		li $v0,4
		la $a0,diskDisplay
		syscall
		li $v0,4
		la $a0,frameDisplay
		syscall

RADIA5:				
		# 3 loop 6 khoi
		move $t0,$s0
		addi $t1,$t0,4
		
		li $s6,0		#bien chay de dung dia
		
loop1:
		lw $s2,0($t0)
		lw $s3,0($t1)
		nop
		sw $s2,tempSpace
		jal displayData
		nop
		jal displaySpace
		nop
		sw $s3,tempSpace
		jal displayData
		nop
		jal displaySpace
		nop
		jal displayParity
		nop
		jal nextBlock
		li $a0,'\n'
		li $v0,11
		syscall

loop2:		
		lw $s2,0($t0)
		lw $s3,0($t1)
		nop
		sw $s2,tempSpace
		jal displayData
		nop
		jal displaySpace
		nop
		jal displayParity
		nop
		jal displaySpace
		nop
		sw $s3,tempSpace
		jal displayData
		nop
		jal nextBlock
		nop
		li $a0,'\n'
		li $v0,11
		syscall
loop3:
		lw $s2,0($t0)
		lw $s3,0($t1)
		jal displayParity
		nop
		jal displaySpace
		nop
		nop
		sw $s2,tempSpace
		jal displayData
		nop
		jal displaySpace
		nop
		sw $s3,tempSpace
		jal displayData
		nop
		li $a0,'\n'
		li $v0,11
		syscall
		jal nextBlock
		j loop1

displayData:
		li $v0, 4
		la $a0, leftBorder	# print left border
		syscall
	
		li $v0, 4
		la $a0,tempSpace
		syscall
		li $v0, 4
		la $a0, rightBorder	# print right border
		syscall
		jr $ra

displayParity:
		li $v0,11
		li $a0,'['
		syscall
		syscall
		xor $s4,$s2,$s3
		li $t9,4
loopParity:
		
		ror $s4,$s4,4
		andi $s5,$s4,0xf   #last character  #after andi ->> 0x0000 0000 0000 0000 0000 0000 0000 xxxx
		move $s7,$ra
		jal printChar
		move $ra,$s7
		
		rol $s4,$s4,4
		andi $s5,$s4,0xf   #last character  #after andi ->> 0x0000 0000 0000 0000 0000 0000 0000 xxxx
		move $s7,$ra
		jal printChar
		move $ra,$s7
		
		subi $t9,$t9,1		#bien dem cho 4 vong lap
		beq $t9,0,printEnd	
		ror $s4,$s4,8
		li  $a0,','        #printComma giua 2 hex
		li $v0,11
		syscall
		j loopParity
printEnd:		
		li $v0,11
		li $a0,']'
		syscall
		syscall
		jr $ra
		
printChar:
		slti $t8,$s5,10
		beq $t8,1,isDigit
		
isAlphabe:		
		subi $s5,$s5,10
		addi $s5,$s5,97
		j endPrintChar
isDigit:	
		addi $s5,$s5,48
		j endPrintChar
endPrintChar:
		move $a0,$s5
		li $v0,11
		syscall
		jr $ra
		
displaySpace:
		li $v0, 4
		la $a0, space
		syscall
		jr $ra
nextBlock:
		addi $t0,$t0,8
		addi $t1,$t1,8
		addi $s6,$s6,8
		beq  $s1,$s6,try_again
		nop
		jr $ra

try_again:				#thu lai k
		li $v0, 50
		la $a0, tryAgain
		syscall
		beq $a0, 0, get_string	# if user choose Yes
		nop
		li $v0,10
		syscall 	
	
emptyInput:
		li $v0, 55
		la $a0, inputEmpty
		li $a1, 2
		syscall
		j get_string

invalidInput:
		li $v0, 55
		la $a0, inputError
		li $a1, 2
		syscall
		j get_string
