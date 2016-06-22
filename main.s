.data
SSL:	.word 0, 6, 3			# Score, Size and Lives
HPTP:	.word  37, 24, 37, 25	# Head position (X, Y) and Tail position (X, Y) 0 <= X <= 75, 0 <= Y <= 49
CD: 	.word 1				# Current direction. WASD = 1234
GRID: 	.space 3800			# Number of bytes of a 304x200 pixels grid for the game (76x50 units)
.text	
	jal FILLSCREEN
	jal FILLGAME
	jal INITSNAKE
	
		
	GAMELOOP:
		la $t0, HPTP
		lw $s0, 0($t0)
		lw $s1, 4($t0)
		lw $s2, 8($t0)
		lw $s3, 12($t0)	
		li $s6, 0xFF002800
		la $t0, CD
		lw $s4, 0($t0)		# Current Direction
		
		la $t1,0xFF000000
		lw $t0,0($t1)
		andi $t0,$t0,0x0001		# Le bit de Controle Teclado
   		beq $t0,$zero,PULA   	   	# Se n�o h� tecla pressionada PULA (nao realiza nenhuma acao)
  		lw $v0,4($t1)  			# Tecla lida
  		
		addi $t1, $s6, 8
		mulu $t2, $s0, 4
		addu $t1, $t1, $t2
		mulu $t2, $s1, 1280
		addu $t1, $t1, $t2	# $t1 = address of head
		
		li $t2, 0
		sw $t2, 0($t1)
		sw $t2, 320($t1)
		sw $t2, 640($t1)
		sw $t2, 960($t1)	# Transforms the head into a part of the body (changes the color)
		
		addi $t3, $s6, 8
		mulu $t2, $s2, 4
		addu $t3, $t3, $t2
		mulu $t2, $s3, 1280
		addu $t3, $t3, $t2	# $t1 = address of last piece of body
		
		li $t2, 0xEFEFEFEF
		sw $t2, 0($t3)
		sw $t2, 320($t3)
		sw $t2, 640($t3)
		sw $t2, 960($t3)	# Deletes the last piece of the body
	
	# Testa as teclas e atualiza dados de acordo com elas.
	W:	bne $v0, 119, A
		beq $s4, 3, NOT
		addi $s1, $s1, -1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, -1280
		addi $s4, $zero, 1	# Atualiza direcao atual
		
	A: 	bne $v0,  97, S
		beq $s4, 4, NOT
		addi $s0, $s0, -1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, -4
		addi $s4, $zero, 2	# Atualiza direcao atual
		
	S: 	bne $v0, 115, D
		beq $s4, 1, NOT
		addi $s1, $s1, 1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, 1280
		addi $s4, $zero, 3	# Atualiza direcao atual
		
	D:	bne $v0, 100, NOTNOT
		beq $s4, 2, NOT
		addi $s0, $s0, 1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, 4
		
		addi $s4, $zero, 4	# Atualiza direcao atual
		
		j NOTNOT
		
	PULA: 	j NOT
	
	NOTNOT:
		li $t0, 0x22222222
		sw $t0, 0($t1)
		sw $t0, 320($t1)
		sw $t0, 640($t1)
		sw $t0, 960($t1)	# filling head
		la $t0, HPTP
		sw $s0, 0($t0)
		sw $s1, 4($t0)
		la $t0, CD
		sw $s4, 0($t0)
		li $v0, 0
	
	NOT:
		
		j GAMELOOP
		j END
	
# Fills the screen with the border color
FILLSCREEN:
	li $t1,0xFF012C00
	li $t3,0xFF000000
	li $t2,0x10011342
LOOP: 	beq $t3,$t1,FORA
	sw $t2,0($t3)
	addi $t3,$t3,4
	j LOOP
FORA:	li $t3, 0xFF000000
	li $t2, 0
	sb $t2, 0($t3)
	jr $ra

# Draws the initial snake (size 6)
# There is no problem in using s registers because this function is called in the very beginning of the program
INITSNAKE:
	la $t0, HPTP
	lw $s0, 0($t0)
	lw $s1, 4($t0)
	lw $s2, 8($t0)
	lw $s3, 12($t0)
	li $s4, 0x00000000
	li $s5, 0x22222222
	li $s6, 0xFF002800
	
	addiu $t1, $s6, 8
	mulu $t2, $s0, 4
	addu $t1, $t1, $t2
	mulu $t2, $s1, 1280
	addu $t1, $t1, $t2	# $t1 = address of head
	
	sw $s5, 0($t1)
	sw $s5, 320($t1)
	sw $s5, 640($t1)
	sw $s5, 960($t1)	# filling head
	
	addiu $t1, $s6, 8
	mulu $t2, $s2, 4
	addu $t1, $t1, $t2
	mulu $t2, $s3, 1280
	addu $t1, $t1, $t2	# $t1 = address of aftertail
	li $t3, 0
	la $t4, SSL
	lw $t4, 4($t4)
LOOP3:	beq $t3, $t4, OUTLOOP
	sw $s4, 0($t1)
	sw $s4, 320($t1)
	sw $s4, 640($t1)
	sw $s4, 960($t1)	# filling tail
	addiu $t1, $t1, 960
	addi $t3, $t3, 1
	j LOOP3
OUTLOOP:
	li $t3, 29
	sw $t3, 12($t0)
	jr $ra
	
# Fills the screen with the space where the snake will be allowed to be on.
# There is no problem in using s registers because this function is called in the very beginning of the program
FILLGAME: 
	li $t1,0xFF012200	# End of the grid
	li $s2,0xFF002800	# Start of the grid
	li $s1,0xEFEFEFEF	# Color of the grid
	li $t4,0xFF000000	# Number to subtract so a remainder can be found easier.
	li $t6, 8		# Border offset
	li $t7, 311		# Border offset
LOOP2: 	beq $s2,$t1,FORA2	# Checks if the end is 
	subu $t0, $s2, $t4
	div $t3, $t0, 320	
	mfhi $t3		# Gets X index on the grid.
	slt $t5, $t3, $t6	
	beq $t5, 1, T
	sgt $t5, $t3, $t7
	beq $t5, 1, T		# Checks if the current index is on the border limits.
	sw $s1,0($s2)
T:	addi $s2,$s2,4
	j LOOP2
FORA2:	jr $ra

END:

.ktext
	eret