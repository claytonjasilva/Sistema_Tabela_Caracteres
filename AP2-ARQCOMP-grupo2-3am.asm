// Diego Gode Bonani 202401000711 - TA
// Tiago Oliveira Macedo 202401583537 - TA
// Caio Cavalcanti Salomão de Souza 202401285731 - TA
// Marcelle Lohane 202402726056 - TA
// Caio Domingues Azevedo 202403191156 - TA
// Bruno Bittencourt Cheuqer - 202402627309 - TA
// Eduardo Jacob Pontes 202402824058 - TA

;============================== CRIAÇÃO DA TABELA DE CARACTERES ASCII =========================================================================

inicio:
	; Inicialização da posição
	ldi r30, 0x00           ; Carrega a parte baixa de posicao (endereço 0x200)
	ldi r31, 0x02           ; Carrega a parte alta de posicao (endereço 0x200)
    ; Armazenar maiúsculas (A-Z)
    ldi r16, 0x41        ; Carrega o código ASCII de 'A' (0x41)
armazenar_maiusculas:
    st Z, r16            ; Armazena o caractere na posição apontada por Z (r30:r31)
    inc r30              ; Incrementa a parte baixa da posição (r30)
    cpi r16, 0x5A        ; Compara com 'Z' (0x5A)
    breq armazenar_minusculas ; Se for 'Z', vai para armazenar as minúsculas
    inc r16              ; Incrementa o código ASCII para o próximo caractere
    rjmp armazenar_maiusculas ; Volta para armazenar o próximo caractere

armazenar_minusculas:
    ldi r16, 0x61        ; Carrega o código ASCII de 'a' (0x61)

armazenar_minusculas_loop:
    st Z, r16              ; Armazena o caractere na posição apontada por Z (r30:r31)
    inc r30                ; Incrementa a parte baixa da posição
    cpi r16, 0x7A          ; Compara com 'z' (0x7A)
    breq armazenar_digitos ; Se for 'z', vai para armazenar os dígitos
    inc r16                ; Incrementa o código ASCII para o próximo caractere
    rjmp armazenar_minusculas_loop ; Volta para armazenar o próximo caractere

armazenar_digitos:
    ldi r16, 0x30        ; Carrega o código ASCII de '0' (0x30)

armazenar_digitos_loop:
    st Z, r16              ; Armazena o caractere na posição apontada por Z (r30:r31)
    inc r30                ; Incrementa a parte baixa da posição
    cpi r16, 0x39          ; Compara com '9' (0x39)
    breq armazenar_espaco  ; Se for '9', vai para armazenar o espaço
    inc r16                ; Incrementa o código ASCII para o próximo caractere
    rjmp armazenar_digitos_loop ; Volta para armazenar o próximo caractere

armazenar_espaco:
    ldi r16, 0x20        ; Carrega o código ASCII do espaço (0x20)
    st Z, r16            ; Armazena o espaço na posição
    inc r30              ; Incrementa a parte baixa da posição

armazenar_esc:
    ldi r16, 0x1B        ; Carrega o código ASCII do comando <ESC> (0x1B)
    st Z, r16            ; Armazena o comando <ESC> na posição

;============================== CRIAÇÃO DA TABELA DE CARACTERES ASCII =========================================================================

;============================== PARTE 2,3 e 4 INPUTS USANDO I\O =========================================================================

inicio_parte2:
	clr r16          ; R16 como 0 para configurar os pinos como entrada
	out DDRD, r16    ; Configura todos os pinos de PORTD como entrada
	ldi r18,0xFF     ; R16 como FF para configurar os pinos como saída
	out DDRC, r18    ; Configura todos os pinos de PORTC como saída
	out DDRB, r18    ; Configura todos os pinos de PORTB como saída
	rjmp loop_funcao

; Inicia a parte onde se espera um input para executar uma função

loop_funcao:
    ; Inicialização
    in r17, PIND            ; Ler a entrada da porta de dados (exemplo de PIND)
    cpi r17, 0x1C           ; Comparar a entrada com 0x1C
    breq start_read         ; Se não for 0x1C, continua esperando
	cpi r17, 0x1D
	breq start_count
	cpi r17, 0x1E
	breq start_same
	cpi r17, 0x1F
	breq criaTabelaF
	rjmp loop_funcao


;============================== ARMAZENAMENTO DAS SEQUENCIAS DE CARACTERES =========================================================================

start_read:
	ldi r30, 0x00        ; Endereço de memória inicial (0x300)
    ldi r31, 0x03        ; Ponteiro alto para o endereço de memória (0x300)

read_loop:
; Iniciar a leitura dos caracteres
    in r17, PIND           ; Ler o caractere da porta de entrada
    cpi r17, 0x1B          ; Comparar com o caractere ESC (0x1B)
    breq end_read            ; Se for ESC, finalizar a leitura

    cpi r17, 0x20          ; Comparar com o caractere de espaço (0x20)
    brge valid_char        ; Se for um caractere válido (>= 0x20), processar

    rjmp read_loop         ; Caso contrário, ler novamente

valid_char:
    st Z, r17              ; Armazenar o caractere em memória no endereço apontado por Z
    adiw r30, 1            ; Avançar o ponteiro de memória para o próximo byte (r30:r31)
    cpi r31, 0x04          ; Comparar com o endereço limite 0x400
    brge loop_funcao            ; Se atingir o limite de 0x400, finalizar
    rjmp read_loop         ; Caso contrário, continuar a leitura

end_read:
	cpi r31, 0x04          ; Comparar com o endereço limite 0x400
	breq loop_funcao              ; Caso seja volta ao init
	st Z, r17	           ; Guarda o <ESC> na memoria
	rjmp loop_funcao

;============================== ARMAZENAMENTO DAS SEQUENCIAS DE CARACTERES =========================================================================

;============================== CONTAGEM DE CARACTERES ARMAZENADOS NA SEQUENCIA =========================================================================

start_count:               ; Inicializar o r16 de caracteres
    ldi r18, 0x00          ; Limpar o registrador r18 (r16 de caracteres)
    ldi r30, 0x00          ; Endereço inicial da memória
    ldi r31, 0x03          ; Ponteiro alto para o endereço de memória (0x300)

count_loop:
    ld r19, Z              ; Carregar o caractere de memória
    cpi r19, 0x20          ; Comparar com o caractere de espaço (0x20)
    breq invalid_char        ; Se for um espaço, terminar a contagem

    cpi r19, 0x1B          ; Comparar com o caractere ESC (0x1B)
    breq end_count       ; Se for ESC, terminar a contagem

    inc r18                ; Incrementar o r16 de caracteres
    adiw r30, 1            ; Avançar o ponteiro de memória para o próximo byte (r30:r31)
    cpi r31, 0x04          ; Comparar com o limite de memória (0x400)
    breq end_count        ; Se atingiu o limite, parar a contagem
	rjmp count_loop

invalid_char:
	adiw r30, 1
	rjmp count_loop


end_count:
    ; Armazenar o número de caracteres na memória 0x401
    sts 0x401, r18         ; Armazenar o r16 no endereço 0x401

    ; Exibir o número de caracteres na porta de saída
    out PORTC, r18         ; Supondo que PORTC seja a porta de saída
	rjmp loop_funcao

;============================== CONTAGEM DE CARACTERES ARMAZENADOS NA SEQUENCIA =========================================================================

;============================== CONTAGEM DE FREQUENCIA DE UM CARACTER =========================================================================

start_same:                ; Inicializa a função que conta quantas vezes um caracter aparece
	ldi r18, 0x00          ; Limpar o registrador r18 (r16 de caracteres)
    ldi r30, 0x00          ; Endereço inicial da memória
    ldi r31, 0x03          ; Ponteiro alto para o endereço de memória (0x300)

same_loop:
	in r20, PIND           ; Ler o caractere da porta de entrada
	cpi r20, 0x20		   ; Checa se o input é um caracter valido
	brlt same_loop         ; Caso não seja lê denovo o input

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

    ldi r28, 0x03                  ; Ponteiro Y para tabela de frequências (parte baixa)
    ldi r29, 0x04                  ; Ponteiro Y para tabela de frequências (parte alta)

    clr r16                   ; r16 geral para frequências (zerado)
    clr r17                        ; r17iliar para comparações

contarFrequencias:
	ld r19, x                    ; Lê o caractere do endereço atual de X
	cpi r19, 0x00                ; Fim da tabela de sequência?
	breq ordenarFrequencias        ; Se sim, vá para a ordenação

	; Verifica se é um espaço em branco
	cpi r19, 0x20
	breq proximoCaractere

	; Procura o caractere na tabela de frequências
	ldi r30, 0x03                  ; Ponteiro Z para tabela de frequências (parte baixa)
	ldi r31, 0x04                  ; Ponteiro Z para tabela de frequências (parte alta)

procurarTabela:
	ld r17, z                      ; Lê o caractere atual da tabela de frequências
	cpi r17, 0x00                  ; Tabela vazia ou fim dela?
	breq adicionarNovo             ; Adicione o caractere à tabela

	cp r17, r19                  ; Compara com o caractere atual
	breq incrementarFrequencia     ; Se igual, incremente a frequência
	adiw r30, 0x02                 ; Avança para o próximo caractere na tabela
	rjmp procurarTabela

incrementarFrequencia:
	ldd r17, z+1                   ; Carrega a frequência
	inc r17                        ; Incrementa
	std z+1, r17                   ; Salva a nova frequência
	rjmp proximoCaractere

adicionarNovo:
	st z, r19                    ; Armazena o novo caractere
	ldi r17, 0x01                  ; Primeira ocorrência
	std z+1, r17                   ; Armazena a frequência inicial
	rjmp proximoCaractere

proximoCaractere:
	adiw r26, 0x01                 ; Incrementa o ponteiro X
	rjmp contarFrequencias


ordenarFrequencias:
	ldi r23, 0x0A                ; Número de elementos (10)
	clr r17                        ; Flag para monitorar trocas

	bubbleSort:						   ; Bubble Sort é um método de organização de lista que coloca o maior r19 no começo por meio de sucessivas trocas
		clr r17                        ; Reseta flag de troca
		ldi r30, 0x03                  ; Parte baixa do ponteiro Z
		ldi r31, 0x04                  ; Parte alta do ponteiro Z

	loopOrdenacao:
		ldd r19, z+1                 ; Frequência atual
		ldd r18, z+3                  ; Próxima frequência
		cp r19, r18                 ; Compara frequências
		breq checagem
		brlo troca                     ; Se necessário, troque

		continuar:
		adiw r30, 0x02                 ; Avança para o próximo par
		cp r19, r18
		brne loopOrdenacao             ; Continua o loop

		cpi r19,0x00
		brne loopOrdenacao

		; Se nenhuma troca foi feita, terminamos
		cpi r17,0x00                   ; Verifica se houve troca
		breq fimOrdenacao              ; Se não houve troca, fim do sort
		rjmp bubbleSort                ; Caso contrário, repita o sort

	troca:
		ld r17, z                     ; Salva caractere atual
		ldd r18, z+2                  ; Salva próximo caractere
		st z, r18                    ; Troca caracteres
		std z+2, r17                   ; Troca caracteres

		ldd r17, z+1                   ; Salva frequência atual
		ldd r18, z+3                  ; Salva próxima frequência
		std z+1, r18                  ; Troca frequências
		std z+3, r17                   ; Troca frequências

		ldi r17, 0x01                  ; Marca que houve troca
		adiw r30, 0x02                 ; Avança para o próximo par
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
			; Iniciar processo de limpa, limpar todos os r19es após o décimo caractere da tabela
			cpi r23, 0x00
			breq excluir
			rjmp proxr19

			excluir:
				ld r19,z
				cpi r19,0x00
				breq terminar
				st z,r17
				std z+1,r17
				adiw r30, 0x02         ; Avança para o próximo par
				rjmp limpa

			proxr19:
				dec r23
				ld r19,z
				cpi r19,0x00
				breq terminar
				adiw r30, 0x02         ; Avança para o próximo par
				rjmp limpa
		
		terminar:
			; Limpeza terminada, agora o programa deve exibir cada caractere da tabela na porta de saída
			ldi r31,0x04
			ldi r30,0x03

			loopExibir:
				ld r19,z
				cpi r19,0x00
				breq parar
				out portc,r19			; Apresenta o r19 na porta de saída
				ldd r19,z+1
				out portc,r19			; Apresenta o r19 na porta de saída
				adiw r30, 0x02         ; Avança para o próximo par
				rjmp loopExibir

			parar:
				rjmp loop_funcao               ; Volta ao fluxo principal

;============================== TABELA DE FREQUENCIA DE CARACTERERES =========================================================================
