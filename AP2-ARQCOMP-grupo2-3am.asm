// Diego Gode Bonani 202401000711 - TA
// Tiago Oliveira Macedo 202401583537 - TA
// Caio Cavalcanti Salom�o de Souza 202401285731 - TA
// Marcelle Lohane 202402726056 - TA
// Caio Domingues Azevedo 202403191156 - TA
// Bruno Bittencourt Cheuqer - 202402627309 - TA
// Eduardo Jacob Pontes 202402824058 - TA

;============================== CRIA��O DA TABELA DE CARACTERES ASCII =========================================================================

inicio:
	; Inicializa��o da posi��o
	ldi r30, 0x00           ; Carrega a parte baixa de posicao (endere�o 0x200)
	ldi r31, 0x02           ; Carrega a parte alta de posicao (endere�o 0x200)
    ; Armazenar mai�sculas (A-Z)
    ldi r16, 0x41        ; Carrega o c�digo ASCII de 'A' (0x41)
armazenar_maiusculas:
    st Z, r16            ; Armazena o caractere na posi��o apontada por Z (r30:r31)
    inc r30              ; Incrementa a parte baixa da posi��o (r30)
    cpi r16, 0x5A        ; Compara com 'Z' (0x5A)
    breq armazenar_minusculas ; Se for 'Z', vai para armazenar as min�sculas
    inc r16              ; Incrementa o c�digo ASCII para o pr�ximo caractere
    rjmp armazenar_maiusculas ; Volta para armazenar o pr�ximo caractere

armazenar_minusculas:
    ldi r16, 0x61        ; Carrega o c�digo ASCII de 'a' (0x61)

armazenar_minusculas_loop:
    st Z, r16              ; Armazena o caractere na posi��o apontada por Z (r30:r31)
    inc r30                ; Incrementa a parte baixa da posi��o
    cpi r16, 0x7A          ; Compara com 'z' (0x7A)
    breq armazenar_digitos ; Se for 'z', vai para armazenar os d�gitos
    inc r16                ; Incrementa o c�digo ASCII para o pr�ximo caractere
    rjmp armazenar_minusculas_loop ; Volta para armazenar o pr�ximo caractere

armazenar_digitos:
    ldi r16, 0x30        ; Carrega o c�digo ASCII de '0' (0x30)

armazenar_digitos_loop:
    st Z, r16              ; Armazena o caractere na posi��o apontada por Z (r30:r31)
    inc r30                ; Incrementa a parte baixa da posi��o
    cpi r16, 0x39          ; Compara com '9' (0x39)
    breq armazenar_espaco  ; Se for '9', vai para armazenar o espa�o
    inc r16                ; Incrementa o c�digo ASCII para o pr�ximo caractere
    rjmp armazenar_digitos_loop ; Volta para armazenar o pr�ximo caractere

armazenar_espaco:
    ldi r16, 0x20        ; Carrega o c�digo ASCII do espa�o (0x20)
    st Z, r16            ; Armazena o espa�o na posi��o
    inc r30              ; Incrementa a parte baixa da posi��o

armazenar_esc:
    ldi r16, 0x1B        ; Carrega o c�digo ASCII do comando <ESC> (0x1B)
    st Z, r16            ; Armazena o comando <ESC> na posi��o

;============================== CRIA��O DA TABELA DE CARACTERES ASCII =========================================================================

;============================== PARTE 2,3 e 4 INPUTS USANDO I\O =========================================================================

inicio_parte2:
	clr r16          ; R16 como 0 para configurar os pinos como entrada
	out DDRD, r16    ; Configura todos os pinos de PORTD como entrada
	ldi r18,0xFF     ; R16 como FF para configurar os pinos como sa�da
	out DDRC, r18    ; Configura todos os pinos de PORTC como sa�da
	out DDRB, r18    ; Configura todos os pinos de PORTB como sa�da
	rjmp loop_funcao

; Inicia a parte onde se espera um input para executar uma fun��o

loop_funcao:
    ; Inicializa��o
    in r17, PIND            ; Ler a entrada da porta de dados (exemplo de PIND)
    cpi r17, 0x1C           ; Comparar a entrada com 0x1C
    breq start_read         ; Se n�o for 0x1C, continua esperando
	cpi r17, 0x1D
	breq start_count
	cpi r17, 0x1E
	breq start_same
	cpi r17, 0x1F
	breq criaTabelaF
	rjmp loop_funcao


;============================== ARMAZENAMENTO DAS SEQUENCIAS DE CARACTERES =========================================================================

start_read:
	ldi r30, 0x00        ; Endere�o de mem�ria inicial (0x300)
    ldi r31, 0x03        ; Ponteiro alto para o endere�o de mem�ria (0x300)

read_loop:
; Iniciar a leitura dos caracteres
    in r17, PIND           ; Ler o caractere da porta de entrada
    cpi r17, 0x1B          ; Comparar com o caractere ESC (0x1B)
    breq end_read            ; Se for ESC, finalizar a leitura

    cpi r17, 0x20          ; Comparar com o caractere de espa�o (0x20)
    brge valid_char        ; Se for um caractere v�lido (>= 0x20), processar

    rjmp read_loop         ; Caso contr�rio, ler novamente

valid_char:
    st Z, r17              ; Armazenar o caractere em mem�ria no endere�o apontado por Z
    adiw r30, 1            ; Avan�ar o ponteiro de mem�ria para o pr�ximo byte (r30:r31)
    cpi r31, 0x04          ; Comparar com o endere�o limite 0x400
    brge loop_funcao            ; Se atingir o limite de 0x400, finalizar
    rjmp read_loop         ; Caso contr�rio, continuar a leitura

end_read:
	cpi r31, 0x04          ; Comparar com o endere�o limite 0x400
	breq loop_funcao              ; Caso seja volta ao init
	st Z, r17	           ; Guarda o <ESC> na memoria
	rjmp loop_funcao

;============================== ARMAZENAMENTO DAS SEQUENCIAS DE CARACTERES =========================================================================

;============================== CONTAGEM DE CARACTERES ARMAZENADOS NA SEQUENCIA =========================================================================

start_count:               ; Inicializar o r16 de caracteres
    ldi r18, 0x00          ; Limpar o registrador r18 (r16 de caracteres)
    ldi r30, 0x00          ; Endere�o inicial da mem�ria
    ldi r31, 0x03          ; Ponteiro alto para o endere�o de mem�ria (0x300)

count_loop:
    ld r19, Z              ; Carregar o caractere de mem�ria
    cpi r19, 0x20          ; Comparar com o caractere de espa�o (0x20)
    breq invalid_char        ; Se for um espa�o, terminar a contagem

    cpi r19, 0x1B          ; Comparar com o caractere ESC (0x1B)
    breq end_count       ; Se for ESC, terminar a contagem

    inc r18                ; Incrementar o r16 de caracteres
    adiw r30, 1            ; Avan�ar o ponteiro de mem�ria para o pr�ximo byte (r30:r31)
    cpi r31, 0x04          ; Comparar com o limite de mem�ria (0x400)
    breq end_count        ; Se atingiu o limite, parar a contagem
	rjmp count_loop

invalid_char:
	adiw r30, 1
	rjmp count_loop


end_count:
    ; Armazenar o n�mero de caracteres na mem�ria 0x401
    sts 0x401, r18         ; Armazenar o r16 no endere�o 0x401

    ; Exibir o n�mero de caracteres na porta de sa�da
    out PORTC, r18         ; Supondo que PORTC seja a porta de sa�da
	rjmp loop_funcao

;============================== CONTAGEM DE CARACTERES ARMAZENADOS NA SEQUENCIA =========================================================================

;============================== CONTAGEM DE FREQUENCIA DE UM CARACTER =========================================================================

start_same:                ; Inicializa a fun��o que conta quantas vezes um caracter aparece
	ldi r18, 0x00          ; Limpar o registrador r18 (r16 de caracteres)
    ldi r30, 0x00          ; Endere�o inicial da mem�ria
    ldi r31, 0x03          ; Ponteiro alto para o endere�o de mem�ria (0x300)

same_loop:
	in r20, PIND           ; Ler o caractere da porta de entrada
	cpi r20, 0x20		   ; Checa se o input � um caracter valido
	brlt same_loop         ; Caso n�o seja l� denovo o input

	ld r21, Z

	cpi r21, 0x1B	           ; Comparar com o caractere ESC (0x1B)
	breq end_same

	cp r20, r21
	breq char_same
	adiw r30, 1
	rjmp same_loop

char_same:
	inc r18
	adiw r30, 1
	rjmp same_loop

end_same:
	sts 0x402, r18
	out PORTB, r18
	rjmp loop_funcao

;============================== CONTAGEM DE FREQUENCIA DE UM CARACTER =========================================================================

;============================== TABELA DE FREQUENCIA DE CARACTERERES =========================================================================

criaTabelaF:
    ldi r26, 0x00                  ; Ponteiro X para 0x300 (parte baixa)
    ldi r27, 0x03                  ; Ponteiro X para 0x300 (parte alta)

    ldi r28, 0x03                  ; Ponteiro Y para tabela de frequ�ncias (parte baixa)
    ldi r29, 0x04                  ; Ponteiro Y para tabela de frequ�ncias (parte alta)

    clr r16                   ; r16 geral para frequ�ncias (zerado)
    clr r17                        ; r17iliar para compara��es

contarFrequencias:
	ld r19, x                    ; L� o caractere do endere�o atual de X
	cpi r19, 0x00                ; Fim da tabela de sequ�ncia?
	breq ordenarFrequencias        ; Se sim, v� para a ordena��o

	; Verifica se � um espa�o em branco
	cpi r19, 0x20
	breq proximoCaractere

	; Procura o caractere na tabela de frequ�ncias
	ldi r30, 0x03                  ; Ponteiro Z para tabela de frequ�ncias (parte baixa)
	ldi r31, 0x04                  ; Ponteiro Z para tabela de frequ�ncias (parte alta)

procurarTabela:
	ld r17, z                      ; L� o caractere atual da tabela de frequ�ncias
	cpi r17, 0x00                  ; Tabela vazia ou fim dela?
	breq adicionarNovo             ; Adicione o caractere � tabela

	cp r17, r19                  ; Compara com o caractere atual
	breq incrementarFrequencia     ; Se igual, incremente a frequ�ncia
	adiw r30, 0x02                 ; Avan�a para o pr�ximo caractere na tabela
	rjmp procurarTabela

incrementarFrequencia:
	ldd r17, z+1                   ; Carrega a frequ�ncia
	inc r17                        ; Incrementa
	std z+1, r17                   ; Salva a nova frequ�ncia
	rjmp proximoCaractere

adicionarNovo:
	st z, r19                    ; Armazena o novo caractere
	ldi r17, 0x01                  ; Primeira ocorr�ncia
	std z+1, r17                   ; Armazena a frequ�ncia inicial
	rjmp proximoCaractere

proximoCaractere:
	adiw r26, 0x01                 ; Incrementa o ponteiro X
	rjmp contarFrequencias


ordenarFrequencias:
	ldi r23, 0x0A                ; N�mero de elementos (10)
	clr r17                        ; Flag para monitorar trocas

	bubbleSort:						   ; Bubble Sort � um m�todo de organiza��o de lista que coloca o maior r19 no come�o por meio de sucessivas trocas
		clr r17                        ; Reseta flag de troca
		ldi r30, 0x03                  ; Parte baixa do ponteiro Z
		ldi r31, 0x04                  ; Parte alta do ponteiro Z

	loopOrdenacao:
		ldd r19, z+1                 ; Frequ�ncia atual
		ldd r18, z+3                  ; Pr�xima frequ�ncia
		cp r19, r18                 ; Compara frequ�ncias
		breq checagem
		brlo troca                     ; Se necess�rio, troque

		continuar:
		adiw r30, 0x02                 ; Avan�a para o pr�ximo par
		cp r19, r18
		brne loopOrdenacao             ; Continua o loop

		cpi r19,0x00
		brne loopOrdenacao

		; Se nenhuma troca foi feita, terminamos
		cpi r17,0x00                   ; Verifica se houve troca
		breq fimOrdenacao              ; Se n�o houve troca, fim do sort
		rjmp bubbleSort                ; Caso contr�rio, repita o sort

	troca:
		ld r17, z                     ; Salva caractere atual
		ldd r18, z+2                  ; Salva pr�ximo caractere
		st z, r18                    ; Troca caracteres
		std z+2, r17                   ; Troca caracteres

		ldd r17, z+1                   ; Salva frequ�ncia atual
		ldd r18, z+3                  ; Salva pr�xima frequ�ncia
		std z+1, r18                  ; Troca frequ�ncias
		std z+3, r17                   ; Troca frequ�ncias

		ldi r17, 0x01                  ; Marca que houve troca
		adiw r30, 0x02                 ; Avan�a para o pr�ximo par
		rjmp loopOrdenacao

	checagem:
		cpi r18,0x00
		breq check1
		
		rjmp continuar

		check1:
			cpi r17,0x00
			breq fimOrdenacao
			rjmp bubbleSort
			

	fimOrdenacao:
		ldi r30, 0x03                  ; Parte baixa do ponteiro Z
		ldi r31, 0x04                  ; Parte alta do ponteiro Z
		ldi r17, 0x00				   ; Preparando registrador r17iliar para armazenar 0x00

		limpa:
			; Iniciar processo de limpa, limpar todos os r19es ap�s o d�cimo caractere da tabela
			cpi r23, 0x00
			breq excluir
			rjmp proxr19

			excluir:
				ld r19,z
				cpi r19,0x00
				breq terminar
				st z,r17
				std z+1,r17
				adiw r30, 0x02         ; Avan�a para o pr�ximo par
				rjmp limpa

			proxr19:
				dec r23
				ld r19,z
				cpi r19,0x00
				breq terminar
				adiw r30, 0x02         ; Avan�a para o pr�ximo par
				rjmp limpa
		
		terminar:
			; Limpeza terminada, agora o programa deve exibir cada caractere da tabela na porta de sa�da
			ldi r31,0x04
			ldi r30,0x03

			loopExibir:
				ld r19,z
				cpi r19,0x00
				breq parar
				out portc,r19			; Apresenta o r19 na porta de sa�da
				ldd r19,z+1
				out portc,r19			; Apresenta o r19 na porta de sa�da
				adiw r30, 0x02         ; Avan�a para o pr�ximo par
				rjmp loopExibir

			parar:
				rjmp loop_funcao               ; Volta ao fluxo principal

;============================== TABELA DE FREQUENCIA DE CARACTERERES =========================================================================
