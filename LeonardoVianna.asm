assume cs:codigo,ds:dados,es:dados,ss:pilha

CR       EQU    0DH ; constante - codigo ASCII do caractere "carriage return"
LF       EQU    0AH ; constante - codigo ASCII do caractere "line feed"
BACK	 EQU	08H ; constante - BACKSPACE

; definicao do segmento de dados do programa
dados    segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;              STRINGS             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
layout1 	db 		'====  Hyper Eliminator of Hexadecimals - Leonardo Vianna Feiteira - 274721  ====','$'
layout2 	db 		'================================================================================','$'
layout3 	db 		'Histograma com tamanho das palavras (representa no maximo 75 de cada tamanho)','$'
layout4 	db 		' 1 : ','$'
layout5 	db 		' 2 : ','$'
layout6 	db 		' 3 : ','$'
layout7 	db 		' 4 : ','$'
layout8 	db 		' 5 : ','$'
layout9 	db 		' 6 : ','$'
layout10 	db 		'>=7: ','$'
layout11	db		'O arquivo ','$'
layout12	db		' contem ','$'
layout13	db		'caracteres, ','$'
layout14	db		'palavras e ','$'
layout15	db		'linhas.','$'
more		db		'Digite "s" para continuar, ou "n" para encerrar este belo trabalho','$'
more2		db		'		  		Escolha com sabedoria','$'
prompt1		db		'Digite o nome do arquivo:','$'
er_abertura db 		'ERROR 590543: FILE NOT FOUND, PRESS ENTER TO TRY AGAIN','$'
t1		db		'1','$'
t2		db		'2','$'
t3		db		'3','$'
t4		db		'4','$'
t5		db		'5','$'
t6		db		'6','$'
t7		db		'+','$'
asterisco	db		'*','$'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           VARIAVEIS              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
numpalavras	dw		0
convertendo	dw		0
numcaracteres dw	0
numlinhas	dw		0
convertido  dw	    6  dup (?)
linhas_escritas		db		80 dup (?),'$'
variacao	dw		0
tamlimpeza	dw		0
tamescrita	dw		0
tam_1		db		0
tam_2		db		0
tam_3		db		0
tam_4		db		0
tam_5		db		0
tam_6		db		0
tam_7		db		0
tam_7aux  db  0
mlinha		db		0
mcolum		db		0
nome_saida	db		'saida.txt',0
fimlinha 	db  	CR,LF,'$'
fimlinha2  db CR,LF
suposto_arquivo db	36 dup (?),'$'
arquivo_criado db  20 dup(?),'$'
arq_error	dw		0
aux_tam 	dw		0
aux_pal		dw		0
aux_print	db		0
tam_pal_esc  dw    0
handler		dw		(?),'$'
handler2	dw		(?),'$'
buffer_arq	dw		32000 dup (?),fimlinha
zero		dw		0


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
	mov 	cx,0
	mov		dx,offset nome_saida
	mov		ah,3ch
	int		21h
	mov		handler2,ax
loop_escreve:
  call	limpa_variaveis	; limpa variaveis
  call 	clrscr			; limpa a tela
	MOV 	mlinha,0
	MOV 	mcolum,0
	call 	movecursor		            ; move o cursor para 0,0
	call 	insere_arquivo	          ; pede o arquivo para o usuario
	call	abrir_arquivo		          ;	abre o arquivo, se der erro vai pedir para escrever outro arquivo e
                                  ;  vai mostrar o erro na tela esperando o enter
	cmp		arq_error,0               ; verifica se tem erro, se tiver volta pro inicio
	je 		loop_escreve
	call 	le_arquivo		             ; le o conteudo do arquivo, bota no buffer_arq e já mostra na tela
	call 	escreve_12_linhas	           ; escreve 12 linhas
	call 	conta_palavras	            ; conta as palavras
	call 	layout_		                	; mostra o layout
	call 	desenha_stati	               ; faz o histograma
	call 	fechar_arquivo               ; fecha o primeiro arquivo
	call 	tenpercent                   ; escreve o arquivo de saida
	call	espera_enter	               ; espera o enter
	jmp		deseja_mais		               ; pergunta se quer outra vez

final_deseja_ponte:
	jmp fim

loop_inicio_ponte:
	jmp loop_inicio

deseja_mais:
  mov 	ah,3eh                   ; fecha o arquivo de saida
  mov 	bx,handler2
  int 	21h

	call	clrscr		              ; limpa a tela e escreve posicionando as mensagens
	mov		mlinha,10	              ; fica uma mensagem na tela até digitar s, ou n
	mov		mcolum,5
	call	movecursor

	lea		dx,more                 ; escreve para perguntar se quer mais
	call	escreve
	mov		mlinha,11
	mov		mcolum,5
	call	movecursor
	lea		dx,more2
	call	escreve

	mov 	ah,8                     ; le sem ecoar
	int    	21h                     ; caracter no AL

	cmp    	al,115                 	; se for "s", termina a espera
	je     	loop_inicio_ponte

	cmp		al,110                	; se for "n", acaba com o programa
	je		final_deseja

	jmp		deseja_mais
final_deseja:
	call	fim

;==========================================================
;          Limpa todas as variáveis do programa           ;
;==========================================================
limpa_variaveis	PROC NEAR	; limpa todas as variveis
	mov	tam_1,0
	mov	tam_2,0
	mov	tam_3,0
	mov	tam_4,0
	mov	tam_5,0
	mov	tam_6,0
	mov	tam_7,0
  mov tam_7aux,0
  mov tam_pal_esc,0
  mov arq_error,0
	mov	aux_pal,0
	mov	aux_print,0
	mov	aux_tam,0
	mov numcaracteres,0
	mov numlinhas,0
	mov numpalavras,0
	mov convertendo,0

	mov tamlimpeza,80
	lea	ax,linhas_escritas
	call limpa_linhas

  mov tamlimpeza,32000
  lea ax,buffer_arq
  call limpa_linhas

  mov tamlimpeza,6
  lea ax,convertido
  call limpa_linhas

  mov tamlimpeza,0
	ret
ENDP

;==========================================================
;  Recebe um ARRAY e o TAMLIMPEZA e limpa esse array      ;
;==========================================================
limpa_linhas	PROC NEAR	; Recebe um array e o tamanho do array e limpa com 0
	mov	cx,tamlimpeza
	mov si,ax
	limpa_linhas_in:
		mov	[si],word ptr 0
		dec	cx
		inc	si
		cmp	cx,0
		je	final_limpa_linhas
		jmp limpa_linhas_in
final_limpa_linhas:
	ret
ENDP
;==========================================================
;            Limpa a tela no puro S.T.Y.L.E.              ;
;==========================================================
clrscr proc near    ; Função retirada da internet para limpar o visor com menos comando
    mov ax,0003h
    int 10h

    ret
endp

;=================================================================
; Recebe o endereço no SI e devolve em tamescrita o seu tamanho  ;
;=================================================================
func_tam proc near  ; Recebe o endereço de algum array em SI e devolve o tamanho em tam escrita
  mov tamescrita,0
  loop_tam:
    mov ax,[si]
    cmp ax,0
    je fim_tam
    cmp ax,'$'
    je fim_tam
    cmp ax,CR
    je fim_tam
    inc si
    inc tamescrita
    jmp loop_tam
  fim_tam:
    ret
ENDP

;==========================================================
;            Move o cursor para o mlinha e mcolum          ;
;==========================================================
movecursor proc near	; move o cursor para mlinha e mcolum
		MOV 	AH,2
		MOV 	AL,0
		MOV 	BH,0
		MOV 	DH,mlinha	; linha
		MOV 	DL,mcolum	; colum
		INT 	10h
	ret
movecursor ENDP

;==========================================================
;            Escreve o que estiver no DX na tela          ;
;==========================================================
Escreve PROC	NEAR
; ESCREVE O QUE ESTIVER EM DX
		mov		ah,9
		INT 	21H     ; Escreve mensagem
	ret
ESCREVE ENDP

;==========================================================
;         Escreve no arquivo o que estiver no dx          ;
;==========================================================
escreve_arquivo proc near
	mov 	ah,40h
	mov		bx,handler2
	mov		cx,tamescrita
	int		21h
	ret
endp

;==========================================================
;                 Pula linha no arquivo                   ;
;==========================================================
pula_linha proc near
	mov ah,40h
	mov bx,handler2
	mov cx,2
	lea dx,fimlinha2
	int 21h
	ret
endp

;=============================================================
; Le o string como input do usuario e coloca ".txt" no final ;
;=============================================================
LeString PROC    NEAR      		; Lê um string no cmd com o backspace já aplicado
    mov		cx, si
Ler:
    mov     ah, 01H
    int     21H                 ; Le até ser "13" e devolve no buffer
    cmp     al, 13
    je      Done
	cmp		al, 08
	je		backspace
    mov     [si], al
    inc     si
    jmp     Ler
backspace:
	mov ah, 02h
	mov dl, 20h                   ; Bota um espaço em branco na tela
	int 21h
	mov dl, 08h                   ; volta pq o cursor avançou novamente
	int 21h
	dec si
	mov [si],word ptr 0
	jmp	Ler
Done:
	mov  [si],word ptr '$'
	lea		si,suposto_arquivo
	jmp		loop_ponto
	incrementacao:
		inc 	si
	loop_ponto:			              ; verifica se tem o ".txt" no final
		mov		cx,[si]
		cmp		cl,'.'
		je		digitou_ponto
		cmp		cx,'$'
		jne		incrementacao
		mov 	[si],word ptr '.'
		inc		si
		mov 	[si],word ptr 't'
		inc		si
		mov 	[si],word ptr 'x'
		inc		si
		mov 	[si],word ptr 't'
		inc		si
		mov     [si],word ptr '$'           ; Bota $ como terminação
digitou_ponto:
    ret
LeString ENDP

;==========================================================
;          Pede o Arquivo para o usuario escrever         ;
;==========================================================
insere_arquivo PROC NEAR					    ; Recebe em suposto_arquivo o que sair do LeString
	lea ax,suposto_arquivo
	mov	tamlimpeza,36
	call limpa_linhas
	LEA		dx,prompt1
	call	escreve
    lea     SI, suposto_arquivo       ; Load no endereço da string a ser escrita
    call    LeString          				; Le
	ret
ENDP


;==========================================================
;     Converte um número ASCII e coloca em CONVERTIDO     ;
;==========================================================
; Função retira por parte da internet e adaptada ao programa
; http://stackoverflow.com/questions/9113772/assembly-numbers-to-ascii
converte_asci PROC NEAR		; Converte na hora ordem o ascii
	mov ax, convertendo     ; numero a ser convertido
    mov cx, 10         		; divisor
    xor bx, bx         		; conta os digitos

divide:
    xor dx, dx
    div cx             	  ; dx = resto
    push dx               ; da push no dx para inverter a ordem
    inc bx
    test ax, ax       	  ; Se ax for 0 acaba
    jnz divide


    mov cx, bx            ; da pop p terminar de inverte e carrega no buffer escolhido
    lea si, convertido    ; DS:SI points to string buffer
proximo:
    pop ax
    add al, '0'           ; converte p ascii
    mov [si], al          ; escreve no buffer
    inc si
    loop proximo
	inc si
	mov [si],word ptr '$'
ret
ENDP

;==========================================================
;             Espera um ENTER ser digitado                 ;
;==========================================================
espera_enter PROC NEAR	   ; espera um enter
	mov    ah,8              ; le sem ecoar
	int    21h               ; caracter no AL
	cmp    al,13             ; se ENTER, termina a espera
	je     fim_enter
	jmp espera_enter
fim_enter:
	ret
ENDP

;==========================================================
; Abre o arquivo e faz a consistência do nome do arquivo  ;
;==========================================================
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

;==========================================================
;       Le o arquivo e coloca em buffer (buffer_arq)      ;
;==========================================================
le_arquivo PROC NEAR
	mov si,ax			; le o arquivo e bota em um buffer
	mov ah,3fh
	mov bx,handler
	mov	cx,32000		; le 32000 caracteres
	lea dx,buffer_arq
	int	21h
	MOV numcaracteres,AX
	ret
ENDP

;==========================================================
; Fecha o primeiro arquivo (o outro é fechado manualmente);
;==========================================================
fechar_arquivo	PROC NEAR	; fecha o arquivo
	MOV AH,3EH
	MOV BX,handler
	INT 21H

	ret
endp

;==========================================================
;                 Desenha o Histograma                    ;
;==========================================================
desenha_stati proc near
        ; Vai ver se existe o tamanho da letra X, se tiver faz um loop desenhando # no seu lugar, se não pula para o próximo
      	; E caso passe os 75 caracteres, pula para o próximo tamanho escrevendo asterisco na coluna 79
        ; Todos os outros são a mesma coisa
  desenha_um:
		CMP	tam_1,0
		je	desenha_dois
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
					CMP mcolum,79			; se estiver na posição 79 desenha de outra forma
					je escreve_ultimo
					lea dx,t7
					call escreve
					inc mcolum
					dec cl
					jmp desenha_sete_in

	final_desenho_asterisco:	; Caso aconteça de ter
		mov	mlinha,24
		mov mcolum,79
		call movecursor
		mov ah,0Ah
		mov al,asterisco
		mov cx,1
		int 10h
		jmp final_desenho
	escreve_ultimo:				; escreve o ultimo sem subir
		mov tam_7aux,cl
		mov ah,0Ah
		mov al,t7
		mov cx,1
		int 10h
		mov cl,tam_7aux
		inc mcolum
		dec cl
		jmp desenha_sete_in
	final_desenho:				; desenha novamente o layout para garantir
	call layout_
	mov mlinha,0
	mov mcolum,0
	call movecursor
		ret
ENDP

;=================================================================================================
; Conta o número de palavras de cada tamanho, o número de palavras em geral e o número de linhas ;
;=================================================================================================
conta_palavras proc near		; sempre inicializo a variavel aux_tam com 0 e começo a incrementar ela
								; enquanto não houver um espaço, tab, ou troca de linha
                ; quando houver eu vejo qual o tamanho dela e incremente na variavel do respectivo tamanho
                ; quando é a ultima palavr a("0") vai para uma nova função para terminar após as comparações
    lea	bx,buffer_arq
	conta_palavras_in:
		mov aux_tam,0
	inicio_contagem:
		mov cl,[bx]
		CMP cl,32		; compara com espaço, se for acabou a palavra
		je 	acabou_palavra
		CMP cl,9		; compara com tab
		je acabou_palavra
		CMP	cl,0		; 0 = nada
		je 	final_contagem_extra_ponte
		CMP cl,CR
		je	acabou_palavra_linha_nova
		CMP	cl,LF
		JE	acabou_palavra
		inc bx
		inc aux_tam
		jmp inicio_contagem
			acabou_palavra_linha_nova:
				inc numlinhas
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
				inc numpalavras
				jmp conta_palavras_in
			tam2:
				INC	tam_2
				inc numpalavras
				jmp conta_palavras_in
			tam3:
				INC	tam_3
				inc numpalavras
				jmp conta_palavras_in
			tam4:
				INC	tam_4
				inc numpalavras
				jmp conta_palavras_in
final_contagem_ponte:
	jmp	final_contagem
final_contagem_extra_ponte:
	inc numlinhas
	jmp	final_contagem_extra
			tam5:
				INC	tam_5
				inc numpalavras
				jmp conta_palavras_in
			tam6:
				INC	tam_6
				inc numpalavras
				jmp conta_palavras_in
			tam7:
				INC	tam_7
				inc numpalavras
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
							inc numpalavras
							ret
						tam2_fim:
							INC	tam_2
							inc numpalavras
							ret
						tam3_fim:
							INC	tam_3
							inc numpalavras
							ret
						tam4_fim:
							INC	tam_4
							inc numpalavras
							ret
						tam5_fim:
							INC	tam_5
							inc numpalavras
							ret
						tam6_fim:
							INC	tam_6
							inc numpalavras
							ret
						tam7_fim:
							INC	tam_7
							inc numpalavras
							ret
final_contagem:
	ret
endp

;==========================================================
; Função de tamanho infinito // Escreve o arquivo inteiro ;
;==========================================================
tenpercent proc near        ; fica desenhando o layout no arquivo
	mov tamescrita,80
	lea dx,layout1
	call escreve_arquivo
	call pula_linha

	mov tamescrita,80
	lea dx,layout2
	call escreve_arquivo
	call pula_linha

	mov		variacao,0
	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	call	le_proxima_linha
	lea		dx,linhas_escritas
	mov tamescrita,80
	call escreve_arquivo
	call pula_linha

	mov tamescrita,80
	lea dx,layout2
	call escreve_arquivo
	call pula_linha

  mov tamescrita,10
	lea dx,layout11
	call escreve_arquivo

  lea si,suposto_arquivo
  call func_tam
	lea dx,suposto_arquivo
	call escreve_arquivo

  mov tamescrita,8
	lea dx,layout12
	call escreve_arquivo

  mov ax,numcaracteres
  mov convertendo,ax
  call converte_asci
  lea si,convertido
  call func_tam
	lea dx,convertido
	call escreve_arquivo

  lea ax,convertido
  mov	tamlimpeza,5
  call limpa_linhas

  mov tamescrita,12
	lea dx,layout13
	call escreve_arquivo

  mov ax,numpalavras
  mov convertendo,ax
  call converte_asci
  lea si,convertido
  call func_tam
	lea dx,convertido
	call escreve_arquivo

  lea ax,convertido
  mov	tamlimpeza,5
  call limpa_linhas

  mov tamescrita,11
	lea dx,layout14
	call escreve_arquivo

  mov ax,numlinhas
  mov convertendo,ax
  call converte_asci
  lea si,convertido
  call func_tam
	lea dx,convertido
	call escreve_arquivo

  lea ax,convertido
  mov	tamlimpeza,5
  call limpa_linhas

  mov tamescrita,7
	lea dx,layout15
	call escreve_arquivo
  call pula_linha

	mov tamescrita,5
	lea dx,layout4
	call escreve_arquivo
  mov tam_pal_esc,0
  loop_1:                     ; vai escrever até o "tam_pal_esc" for menor que 74, quando for 74
        ; quer dizer que já escreveu 74 vezes e o próximo pode ser o *, então vai pra outro loop
        ; verifica se ele só tem mais 1 letra, se tiver só 1 ele coloca "+", caso tenha mais coloca *
    CMP tam_1,0
    je letra2
    dec tam_1
    mov tamescrita,1
    lea dx,t1
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_1
    jmp loop_1
      maybe_asterisco_1:
        cmp tam_1,0
        je letra2
        dec tam_1
        cmp tam_1,0
        je no_asterisco_1
        mov tamescrita,1
        lea dx,asterisco
        call escreve_arquivo
        jmp letra2
            no_asterisco_1:
              mov tamescrita,1
              lea dx,t1
              call escreve_arquivo
              jmp letra2


  letra2:
  mov tam_pal_esc,0
  call pula_linha
	mov tamescrita,5
	lea dx,layout5
	call escreve_arquivo
  loop_2:
    CMP tam_2,0
    je letra3
    dec tam_2
    mov tamescrita,1
    lea dx,t2
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_2
    jmp loop_2
    maybe_asterisco_2:
      cmp tam_2,0
      je letra3
      dec tam_2
      cmp tam_2,0
      je no_asterisco_2
      mov tamescrita,1
      lea dx,asterisco
      call escreve_arquivo
      jmp letra3
          no_asterisco_2:
            mov tamescrita,1
            lea dx,t2
            call escreve_arquivo
            jmp letra3

  letra3:
  mov tam_pal_esc,0
  call pula_linha
	mov tamescrita,5
	lea dx,layout6
	call escreve_arquivo
  loop_3:
    CMP tam_3,0
    je letra4
    dec tam_3
    mov tamescrita,1
    lea dx,t3
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_3
    jmp loop_3
    maybe_asterisco_3:
      cmp tam_3,0
      je letra4
      dec tam_3
      cmp tam_3,0
      je no_asterisco_3
      mov tamescrita,1
      lea dx,asterisco
      call escreve_arquivo
      jmp letra4
          no_asterisco_3:
            mov tamescrita,1
            lea dx,t3
            call escreve_arquivo
            jmp letra4

  letra4:
  mov tam_pal_esc,0
  call pula_linha
	mov tamescrita,5
	lea dx,layout7
	call escreve_arquivo
  loop_4:
    CMP tam_4,0
    je letra5
    dec tam_4
    mov tamescrita,1
    lea dx,t4
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_4
    jmp loop_4
    maybe_asterisco_4:
      cmp tam_4,0
      je letra5
      dec tam_4
      cmp tam_4,0
      je no_asterisco_4
      mov tamescrita,1
      lea dx,asterisco
      call escreve_arquivo
      jmp letra5
          no_asterisco_4:
            mov tamescrita,1
            lea dx,t4
            call escreve_arquivo
            jmp letra5

  letra5:
  mov tam_pal_esc,0
  call pula_linha
	mov tamescrita,5
	lea dx,layout8
	call escreve_arquivo
  loop_5:
    CMP tam_5,0
    je letra6
    dec tam_5
    mov tamescrita,1
    lea dx,t5
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_5
    jmp loop_5
    maybe_asterisco_5:
      cmp tam_5,0
      je letra6
      dec tam_5
      cmp tam_5,0
      je no_asterisco_5
      mov tamescrita,1
      lea dx,asterisco
      call escreve_arquivo
      jmp letra6
          no_asterisco_5:
            mov tamescrita,1
            lea dx,t5
            call escreve_arquivo
            jmp letra6

  letra6:
  mov tam_pal_esc,0
  call pula_linha
	mov tamescrita,5
	lea dx,layout9
	call escreve_arquivo
  loop_6:
    CMP tam_6,0
    je letra7
    dec tam_6
    mov tamescrita,1
    lea dx,t6
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_6
    jmp loop_6
    maybe_asterisco_6:
      cmp tam_6,0
      je letra7
      dec tam_6
      cmp tam_6,0
      je no_asterisco_6
      mov tamescrita,1
      lea dx,asterisco
      call escreve_arquivo
      jmp letra7
          no_asterisco_6:
            mov tamescrita,1
            lea dx,t6
            call escreve_arquivo
            jmp letra7

  letra7:
  mov tam_pal_esc,0
  call pula_linha
	mov tamescrita,5
	lea dx,layout10
	call escreve_arquivo
  loop_7:
    CMP tam_7,0
    je fim_letras
    dec tam_7
    mov tamescrita,1
    lea dx,t7
    call escreve_arquivo
    inc tam_pal_esc
    cmp tam_pal_esc,74
    je maybe_asterisco_7
    jmp loop_7
    maybe_asterisco_7:
      cmp tam_7,0
      je fim_letras
      dec tam_7
      cmp tam_7,0
      je no_asterisco_7
      mov tamescrita,1
      lea dx,asterisco
      call escreve_arquivo
      jmp fim_letras
          no_asterisco_7:
            mov tamescrita,1
            lea dx,t7
            call escreve_arquivo
            jmp fim_letras

  fim_letras:
  ret
	endp

;==========================================================
;         Desenha todo o layout exceto o histograma       ;
;==========================================================
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

		MOV mlinha,15
		MOV mcolum,0
		call movecursor
		LEA dx,layout11
		call escreve

		lea	dx,suposto_arquivo
		call escreve

		lea	dx,layout12
		call escreve

		mov ax,numcaracteres    ; converte os numeros para ascii e escreve
		mov convertendo,ax
		call converte_asci
		lea	dx,convertido
		call escreve

		lea ax,convertido     ; limpa o array de convertido para evitar bugs
		mov	tamlimpeza,5
		call limpa_linhas

		lea	dx,layout13
		call escreve

		mov ax,numpalavras
		mov convertendo,ax
		call converte_asci
		lea	dx,convertido
		call escreve

		lea ax,convertido
		mov	tamlimpeza,5
		call limpa_linhas

		lea	dx,layout14
		call escreve

		mov ax,numlinhas
		mov convertendo,ax
		call converte_asci
		lea	dx,convertido
		call escreve

		lea ax,convertido
		mov	tamlimpeza,5
		call limpa_linhas

		lea	dx,layout15
		call escreve
	ret
endp

;==========================================================
; Le a próxima linha do arquivo de acordo com a variação  ;
;==========================================================
le_proxima_linha PROC NEAR		; recebe o arquivo e vai lendo linha por linha
                              ;(a variação é para saber a partir de onde a próxima função tem que ler)
	mov tamlimpeza,80
	lea	ax,linhas_escritas
	call limpa_linhas
	lea	si,buffer_arq
	add si,variacao
	linha_any:
		lea	di,linhas_escritas
		linha_in:
			mov	dl,[si]
			cmp dl,CR
			je	final_linha_cr
			cmp	dl,0
			je	final_linha_end
			mov	[di],dl
			inc	si
			inc di
			inc variacao
			jmp linha_in
		final_linha_cr:
		inc variacao
		inc variacao
		final_linha_end:
			ret
	ENDP

;===========================================
;      Escreve as 12 linhas do layout      ;
;===========================================
escreve_12_linhas PROC NEAR	; escreve as 12 linhas no layout
; Vai alterando a variação e lendo do arquivo a partir dessa variação e colocando na tela

	mov		variacao,0
	call	le_proxima_linha
	mov 	mlinha,2
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,3
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,4
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,5
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,6
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,7
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,8
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,9
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,10
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,11
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,12
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve

	call	le_proxima_linha
	mov 	mlinha,13
	mov 	mcolum,0
	call 	movecursor
	lea		dx,linhas_escritas
	call	escreve
	ret
endp

;==========================================================
;                   Fecha o Programa                      ;
;==========================================================
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
