assume cs:codigo,ds:dados,es:dados,ss:pilha

CR       EQU    0DH ; constante - codigo ASCII do caractere "carriage return"
LF       EQU    0AH ; constante - codigo ASCII do caractere "line feed"
BACK	 EQU	08H ; constante - BACKSPACE

; definicao do segmento de dados do programa
dados    segment   ;'======= TRUMP FTW ============== TRUMP FTW ============== TRUMP FTW ============'
layout1 	db 		'======== THE CHORO ES LIBRE ======= PLIM PLIM ========= IM TRYING SO HARD ======','$'
layout2 	db 		'================================================================================','$'
layout3 	db 		'Histograma com tamanho das palavras (representa no maximo 75 de cada tamanho)','$'
layout4 	db 		' 1 : ','$'
layout5 	db 		' 2 : ','$'
layout6 	db 		' 3 : ','$'
tam_1		db		0
tam_2		db		0
tam_3		db		0
tam_4		db		0
tam_5		db		0
tam_6		db		0
tam_7		db		0
mlinha		db		0
mcolum		db		0
layout7 	db 		' 4 : ','$'
layout8 	db 		' 5 : ','$'
layout9 	db 		' 6 : ','$'
layout10 	db 		'>=7: ','$'
prompt1		db		'Escreve ai: ','$'
er_abertura db 		'Abre direito infeliz','$'
pontos		db		'#','$'
fimlinha 	db  	CR,LF,'$'
suposto_arquivo db		80 (?),'$'
arq_error	dw		0
tanks		dw		?
tanks1		dw		?
tanks2		dw		?
tanks3		dw		?
tanks4		dw		?
aux_tam 	dw		0
aux_pal		dw		0
aux_print	db		0
handler		dw		(?),'$'
buffer_arq	dw		80 (?),'$'

dados    ends
; definicao do segmento de pilha do programa
pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends

;---------------- COMEÇA AQUI
codigo segment
inicio:
	mov ax,dados
	mov ds,ax
	mov es,ax
; FIM DA CARGA INICIAL DOS REGISTRADORES
loop_escreve:
	call clrscr
	MOV 	mlinha,0
	MOV 	mcolum,0
	call 	movecursor
	call 	insere_arquivo
	lea 	dx,suposto_arquivo
	call 	escreve
	call	abrir_arquivo
	cmp		arq_error,0
	je 		loop_escreve
	call 	layout_
	call 	le_arquivo
	call 	conta_palavras
	call 	desenha_stati
;	cmp		tam_1,3
;	je		ci
	call 	fim
	
ci:
	lea dx,layout1
	call escreve
	call fim

;################################################	
clrscr proc
    mov ax,0003h
    int 10h 
	
    ret
endp
;################################################
movecursor proc
; MOVE O CURSOR PARA DH,DL
		MOV 	AH,2
		MOV 	AL,0
		MOV 	BH,0
		MOV 	DH,mlinha	; linha
		MOV 	DL,mcolum	; colum
		INT 	10h

	ret
movecursor ENDP
;################################################
Escreve PROC	NEAR


; ESCREVE O QUE ESTIVER EM DX
		mov		ah,9
		INT 	21H     ; Escreve mensagem

	ret
ESCREVE ENDP
;################################################
ReadString PROC    NEAR      
    mov		cx, si
Read:
    mov     ah, 01H
    int     21H                 ; read 1 character
    cmp     al, 13              ; is it return?
    je      Done                ; yes, we are done
    mov     [si], al            ; no, move charater into buffer
    inc     si                  ; increase pointer
    jmp     Read                ; loop back
Done:            
    mov     [si], '$'           ; NULL Terminate string
	mov		ax,	si
	sub		ax, cx
	
    ret      
ReadString ENDP
;################################################
insere_arquivo PROC NEAR
	LEA		dx,prompt1
	call	escreve
    lea     SI, suposto_arquivo             ;Load string into SI
    call    ReadString           ;Get info from keyboard
	
	ret
ENDP
;################################################
abrir_arquivo PROC NEAR

	MOV AH,3DH
	MOV AL,0
	LEA DX,suposto_arquivo
	INT 21H
	JC  erro_de_abertura
	MOV handler,AX
	MOV arq_error,1
	
	ret
erro_de_abertura:
	LEA dx,er_abertura
	mov arq_error,0
	call escreve
	
	ret
ENDP
;################################################
le_arquivo PROC NEAR
	mov si,ax
	mov ah,3fh
	mov bx,handler
	mov	cx,80		; le 80 caracteres
	lea dx,buffer_arq
	int	21h

	ret
ENDP
;################################################
desenha_stati proc near
	desenha_um:
	CMP	tam_1,0
	je	desenha_dois
		MOV	cl,tam_1
		MOV mcolum,5
		desenha_um_in:
			mov mlinha,18
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_um_in
	desenha_dois:
	CMP	tam_2,0
	je	desenha_tres
		MOV	cl,tam_2
		MOV mcolum,5
		desenha_dois_in:
			mov mlinha,19
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_dois_in
	desenha_tres:
	CMP	tam_3,0
	je	desenha_quatro
		MOV	cl,tam_3
		MOV mcolum,5
		desenha_tres_in:
			mov mlinha,20
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_tres_in
	desenha_quatro:
	CMP	tam_4,0
	je	desenha_cinco
		MOV	cl,tam_4
		MOV mcolum,5
		desenha_quatro_in:
			mov mlinha,21
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_quatro_in
	desenha_cinco:
	CMP	tam_5,0
	je	desenha_seis
		MOV	cl,tam_5
		MOV mcolum,5
		desenha_cinco_in:
			mov mlinha,22
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_cinco_in
	desenha_seis:
	CMP	tam_6,0
	je	desenha_sete
		MOV	cl,tam_6
		MOV mcolum,5
		desenha_seis_in:
			mov mlinha,23
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_seis_in
	desenha_sete:
	CMP	tam_7,0
	je	final_desenho
		MOV	cl,tam_7
		MOV mcolum,5
		desenha_sete_in:
			mov mlinha,24
			call movecursor
			lea dx,pontos
			call escreve
			inc mcolum
			loop desenha_sete_in

	final_desenho:
		ret
ENDP
;################################################
conta_palavras proc near
	
		lea	bx,buffer_arq
	conta_palavras_in:
		mov aux_tam,0
	inicio_contagem:
		mov cl,[bx]
		CMP cl,32		; compara com espaço, se for acabou a palavra 
		je acabou_palavra
		CMP	cl,'$'
		je final_contagem_ponte
		inc bx
		inc aux_tam
		jmp inicio_contagem
	acabou_palavra:
		inc bx
		CMP aux_tam,1
		je	tam1
		CMP aux_tam,2
		je	tam2
		CMP aux_tam,3
		je	tam3
		CMP aux_tam,4
		je	tam4
		CMP aux_tam,5
		je	tam5
		CMP aux_tam,6
		je	tam6
		jmp tam7
			tam1:
				inc	tam_1
				jmp conta_palavras_in
		final_contagem_ponte:
			jmp final_contagem
			tam2:
				INC	tam_2
				jmp conta_palavras_in
			tam3:
				INC	tam_3
				jmp conta_palavras_in
			tam4:
				INC	tam_4
				jmp conta_palavras_in
			tam5:
				INC	tam_5
				jmp conta_palavras_in
			tam6:
				INC	tam_6
				jmp conta_palavras_in
			tam7:
				INC	tam_7
				jmp conta_palavras_in
		final_contagem:		
			ret
endp
;################################################
layout_:
		MOV mlinha,0
		MOV mcolum,0
		call movecursor
		LEA dx,layout1
		call escreve
		
		MOV mlinha,1
		MOV mcolum,0
		call movecursor
		LEA dx,layout2
		call escreve
		
		MOV mlinha,13
		MOV mcolum,0
		call movecursor
		LEA dx,layout2
		call escreve
		
		MOV mlinha,16
		MOV mcolum,0
		call movecursor
		LEA dx,layout3
		call escreve
		
		MOV mlinha,18
		MOV mcolum,0
		call movecursor
		LEA dx,layout4
		call escreve
		
		MOV mlinha,19
		MOV mcolum,0
		call movecursor
		LEA dx,layout5
		call escreve
		
		MOV mlinha,20
		MOV mcolum,0
		call movecursor
		LEA dx,layout6
		call escreve

		MOV mlinha,21
		MOV mcolum,0
		call movecursor
		LEA dx,layout7
		call escreve
		
		MOV mlinha,22
		MOV mcolum,0
		call movecursor
		LEA dx,layout8
		call escreve
		
		MOV mlinha,23
		MOV mcolum,0
		call movecursor
		LEA dx,layout9
		call escreve
		
		MOV mlinha,24
		MOV mcolum,0
		call movecursor
		LEA dx,layout10
		call escreve
	ret
;################################################
fim:
         mov    ax,4c00h           ; funcao retornar ao DOS no AH
         int    21h                ; chamada do DOS
codigo ends
		;; ENDEREÇO PARA COMEÇAR O PROGRAMA
		end inicio