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
gambiarra	db		'                                                                                ','$'
more		db		'Digite "s" para continuar, ou "n" para encerrar este belo trabalho','$'
more2		db		'		  		Escolha com sabedoria','$'
layout11	db		'O arquivo              contem       caracteres,      palavras e     linhas.','$'
asterisco	db		'*','$'
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
er_abertura db 		'Arquivo nao encontrada hehe','$'
t1		db		'1','$'
t2		db		'2','$'
t3		db		'3','$'
t4		db		'4','$'
t5		db		'5','$'
t6		db		'6','$'
t7		db		'+','$'

fimlinha 	db  	CR,LF,'$'
suposto_arquivo db	64 (?),'$'
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
buffer_arq	dw		32000 dup (?),fimlinha

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
loop_inicio:
	call	limpa_variaveis	; limpa variaveis
	call 	clrscr			; limpa a tela
loop_escreve:
	MOV 	mlinha,0
	MOV 	mcolum,0
	call 	movecursor		; move o cursor para 0,0
	call 	insere_arquivo	; pede o arquivo para o usuario
	call	abrir_arquivo		;	abre o arquivo, se der erro vai pedir para escrever outro arquivo e vai mostrar o erro na tela esperando o enter
	cmp		arq_error,0
	je 		loop_inicio
	call 	le_arquivo		; le o conteudo do arquivo, bota no buffer_arq e já mostra na tela
	call 	gambiarra_		; limpa a parte inutil do texto na tela
	call 	layout_			; mostra o layout
	call 	conta_palavras	; conta as palavras
	call 	desenha_stati	; faz o histograma
	call 	fechar_arquivo
	call	espera_enter	; espera o enter
	jmp		deseja_mais		; pergunta se quer outra vez
	call 	fim
	
deseja_mais:
	call	clrscr		; limpa a tela e escreve posicionando as mensagens
	mov		mlinha,10	; fica uma mensagem na tela até digitar s, ou n
	mov		mcolum,5
	call	movecursor
	lea		dx,more
	call	escreve
	mov		mlinha,11
	mov		mcolum,5
	call	movecursor
	lea		dx,more2
	call	escreve
	mov 	ah,8      ; le sem ecoar
	int    	21h       ; caracter no AL
	cmp    	al,115	; se for "s", termina a espera
	je     	loop_inicio
	cmp		al,110	; se for "n", acaba com o programa
	je		final_deseja
	jmp		deseja_mais
final_deseja:
	call	fim
	
;################################################
limpa_variaveis	PROC NEAR
	mov	tam_1,0
	mov	tam_2,0
	mov	tam_3,0
	mov	tam_4,0
	mov	tam_5,0
	mov	tam_6,0
	mov	tam_7,0
	mov	aux_pal,0
	mov	aux_print,0
	mov	aux_tam,0
limpa_buffer:		; carrega o tamanho do buffer e o endereço
	MOV	cx,32000	; faz um for limpando tudo :D
	lea	si,buffer_arq
	limpa_buffer_in:
	mov	[si],0
	dec cx
	inc	si
	cmp cx,0
	je	final_limpa
	jmp limpa_buffer_in
final_limpa:
	ret
ENDP
;################################################
gambiarra_ PROC NEAR
	mov mcolum,0
	mov mlinha,15
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,16
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,17
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,18
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,19
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,20
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,21
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,22
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,23
	call movecursor
	lea dx,gambiarra
	call escreve
	mov mcolum,0
	mov mlinha,24
	call movecursor
	lea dx,gambiarra
	call escreve
	
	ret
endp

;################################################	
clrscr proc near
    mov ax,0003h
    int 10h 
	
    ret
endp
;################################################
movecursor proc near
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
LeString PROC    NEAR      
    mov		cx, si
Read:
    mov     ah, 01H
    int     21H                 ; Le até ser "13" e devolve no buffer
    cmp     al, 13              ;
    je      Done                
    mov     [si], al           
    inc     si                  
    jmp     Read                
Done:            
    mov     [si], '$'           ; Bota $ como terminação
	mov		ax,	si
	sub		ax, cx
	
    ret      
LeString ENDP
;################################################
insere_arquivo PROC NEAR
	LEA		dx,prompt1
	call	escreve
    lea     SI, suposto_arquivo             ; Pega uma string escrita
    call    LeString          			; Le
	
	ret
ENDP
;################################################
espera_enter PROC NEAR
	mov    ah,8      ; le sem ecoar
	int    21h       ; caracter no AL
	cmp    al,13 ; se ENTER, termina a espera
	je     fim_enter
	jmp espera_enter
fim_enter:
	ret
ENDP
;################################################
abrir_arquivo PROC NEAR
	MOV AH,3DH			; abre o arquivo e filtra o erro mandando escrever de novo
	MOV AL,0
	LEA DX,suposto_arquivo
	INT 21H
	JC  erro_de_abertura
	MOV handler,AX
	MOV arq_error,1
	
	ret
erro_de_abertura:
	mov arq_error,0
	mov mcolum,0
	mov	mlinha,1
	call movecursor
	lea dx,er_abertura
	call escreve
	call espera_enter
	
	ret
ENDP
;################################################
le_arquivo PROC NEAR
	mov si,ax			; le o arquivo e bota em um buffer
	mov ah,3fh
	mov bx,handler
	mov	cx,32000		; le 32000 caracteres
	lea dx,buffer_arq
	int	21h
	mov mlinha,2
	mov mcolum,0
	call movecursor		; escreve o arquivo aonde devia escrever
	lea dx,buffer_arq
	call escreve
	
	ret
ENDP
;################################################
fechar_arquivo	PROC NEAR
	MOV AH,3EH
	MOV BX,handler
	INT 21H
	
	ret
endp
;################################################
desenha_stati proc near
	desenha_um:			; Vai ver se existe o tamanho da letra X, se tiver faz um loop desenhando # no seu lugar, se não pula para o próximo
		CMP	tam_1,0			; E caso passe os 75 caracteres, pula para o próximo tamanho escrevendo asterisco na coluna 79
		je	desenha_dois	; Todos os outros são a mesma coisa
		MOV	cl,tam_1
		MOV mcolum,5
				desenha_um_in:
					CMP	cl,0
					je	desenha_dois
					mov mlinha,18
					CMP mcolum,80
					je	desenha_dois_asterisco
					call movecursor
					lea dx,t1
					call escreve
					inc mcolum
					dec cl
					jmp desenha_um_in
			
	desenha_dois_asterisco:
		mov mcolum,79
		call movecursor
		lea dx,asterisco
		call escreve
	desenha_dois:
		CMP	tam_2,0
		je	desenha_tres
		MOV	cl,tam_2
		MOV mcolum,5
				desenha_dois_in:
					CMP	cl,0
					je	desenha_tres
					mov mlinha,19
					CMP mcolum,80
					je	desenha_tres_asterisco
					call movecursor
					lea dx,t2
					call escreve
					inc mcolum
					dec cl
					jmp desenha_dois_in
	
	desenha_tres_asterisco:
		mov mcolum,79
		call movecursor
		lea dx,asterisco
		call escreve
	desenha_tres:
	CMP	tam_3,0
	je	desenha_quatro
		MOV	cl,tam_3
		MOV mcolum,5
				desenha_tres_in:
					CMP	cl,0
					je	desenha_quatro
					mov mlinha,20
					CMP mcolum,80
					je	desenha_quatro_asterisco
					call movecursor
					lea dx,t3
					call escreve
					inc mcolum
					dec cl
					jmp desenha_tres_in
	
	desenha_quatro_asterisco:
		mov mcolum,79
		call movecursor
		lea dx,asterisco
		call escreve
	desenha_quatro:
	CMP	tam_4,0
	je	desenha_cinco
	MOV	cl,tam_4
	MOV mcolum,5
				desenha_quatro_in:
					CMP	cl,0
					je	desenha_cinco
					mov mlinha,21
					CMP mcolum,80
					je	desenha_cinco_asterisco
					call movecursor
					lea dx,t4
					call escreve
					inc mcolum
					dec cl
					jmp desenha_quatro_in
	
	desenha_cinco_asterisco:
		mov mcolum,79
		call movecursor
		lea dx,asterisco
		call escreve
	desenha_cinco:
	CMP	tam_5,0
	je	desenha_seis
	MOV	cl,tam_5
	MOV mcolum,5
				desenha_cinco_in:
					CMP	cl,0
					je	desenha_seis
					mov mlinha,22
					CMP mcolum,80
					je	desenha_seis_asterisco
					call movecursor
					lea dx,t5
					call escreve
					inc mcolum
					dec cl
					jmp desenha_cinco_in
			
	desenha_seis_asterisco:
		mov mcolum,79
		call movecursor
		lea dx,asterisco
		call escreve
	desenha_seis:
	CMP	tam_6,0
	je	desenha_sete
	MOV	cl,tam_6
	MOV mcolum,5
				desenha_seis_in:
					CMP	cl,0
					je	desenha_sete
					mov mlinha,23
					CMP mcolum,80
					je	desenha_sete_asterisco
					call movecursor
					lea dx,t6
					call escreve
					inc mcolum
					dec cl
					jmp desenha_seis_in
			
	desenha_sete_asterisco:
		mov mcolum,79
		call movecursor
		lea dx,asterisco
		call escreve
	desenha_sete:
	CMP	tam_7,0
	je	final_desenho
	MOV	cl,tam_7
	MOV mcolum,5
		desenha_sete_in:
					CMP	cl,0
					je	final_desenho
					mov mlinha,24
					CMP mcolum,80
					je	final_desenho_asterisco
					call movecursor
					lea dx,t7
					call escreve
					inc mcolum
					dec cl
					jmp desenha_sete_in
					
	final_desenho_asterisco:
		mov	mlinha,23
		mov mcolum,79				; WHYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
		call movecursor
		lea dx,asterisco
		call escreve
		mov mlinha,0
		mov mcolum,0
		call movecursor
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
		je 	acabou_palavra
		CMP cl,9
		je acabou_palavra
		CMP	cl,0		; 0 = nada
		je 	final_contagem_extra
		CMP cl,CR
		je	acabou_palavra
		CMP	cl,LF
		JE	acabou_palavra
		inc bx
		inc aux_tam
		jmp inicio_contagem
			acabou_palavra:
				inc bx
				CMP aux_tam,0
				je	conta_palavras_in
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
			tam2:
				INC	tam_2
				jmp conta_palavras_in
			tam3:
				INC	tam_3
				jmp conta_palavras_in
			tam4:
				INC	tam_4
				jmp conta_palavras_in
final_contagem_ponte:
	jmp	final_contagem
			tam5:
				INC	tam_5
				jmp conta_palavras_in
			tam6:
				INC	tam_6
				jmp conta_palavras_in
			tam7:
				INC	tam_7
				jmp conta_palavras_in
						final_contagem_extra:
							CMP aux_tam,0
							je	final_contagem_ponte
							CMP aux_tam,1
							je	tam1_fim
							CMP aux_tam,2
							je	tam2_fim
							CMP aux_tam,3
							je	tam3_fim
							CMP aux_tam,4
							je	tam4_fim
							CMP aux_tam,5
							je	tam5_fim
							CMP aux_tam,6
							je	tam6_fim
							jmp tam7_fim
						tam1_fim:
							inc	tam_1
							ret
						tam2_fim:
							INC	tam_2
							ret
						tam3_fim:
							INC	tam_3
							ret
						tam4_fim:
							INC	tam_4
							ret
						tam5_fim:
							INC	tam_5
							ret
						tam6_fim:
							INC	tam_6
							ret
						tam7_fim:
							INC	tam_7
							ret
final_contagem:		
	ret
endp
;################################################
layout_		proc near	; Desenha o layout bonitinho
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
		
		MOV mlinha,14
		MOV mcolum,0
		call movecursor
		LEA dx,layout2
		call escreve
		
		MOV mlinha,15
		MOV mcolum,0
		call movecursor
		LEA dx,layout11
		call escreve
		
		MOV mlinha,17
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
endp
;################################################
fim:
	call	clrscr		; deixa bonitinho a saida do arquivo
	mov		mlinha,0
	mov		mcolum,0
	call	movecursor
	mov    	ax,4c00h    ; funcao retornar ao DOS no AH
	int    	21h         ; chamada do DOS
codigo ends
		;; ENDEREÇO PARA COMEÇAR O PROGRAMA
		end inicio