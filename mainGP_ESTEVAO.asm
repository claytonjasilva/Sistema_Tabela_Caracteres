;
; Created: 11/22/2024 8:57:28 PM
;
; Estevão Moraes - 202402070134 - TA
; Eduardo - TA
; Douglas - TA
; Gabriel Briao - TA
; Arthur Azeredo - 20240296933 - TA
; Viktor - 202402173031 - TA
;

clr r16          ; R16 como 0 para configurar os pinos como entrada
out DDRA, r16    ; Configura todos os pinos de PORTD como entrada

ldi r18,0xFF     ; R16 como FF para configurar os pinos como saída
out DDRC, r18    ; Configura todos os pinos de PORTC como saída

; Definições para ajudar eu rs
.DEF flag3 = r25
.DEF flag2 = r23
.DEF flag1 = r21
.DEF cont = r19
.DEF entrada = r17
.DEF valorAux = r16

inicio:
	; inicia o ponteiro X para a posição de memória 0x200
	ldi r27,0x02
	ldi r26,0x00

    rjmp IniciarEscEspaco

IniciarEscEspaco:
    ; Adiciona o espaço (0x20)
    ldi valorAux, 0x20         ; Carrega o código ASCII do espaço
    st X, valorAux            ; Armazena o espaço na memória
	inc r26

    ; Adiciona o ESC (0x1B)
    ldi valorAux, 0x1B
    st X, valorAux
	inc r26

	; Ir para PreencherMaisculas
	ldi valorAux, 0x41          ; Carrega o primeiro caractere (A) no registrador valorAux
    ldi cont, 26            ; Quantidade de caracteres maiúsculos (26 letras)
	rjmp PreencherMaiusculas

PreencherMaiusculas:
    st X, valorAux            ; Armazena o caractere atual no endereço apontado por X
    inc r26
	inc valorAux               
    dec cont               
    brne PreencherMaiusculas ; Se ainda houver caracteres, repete o loop

    ldi valorAux, 0x61          ; Carrega o primeiro caractere minúsculo (a)
    ldi cont, 26            ; Quantidade de caracteres minúsculos (26 letras)
    rjmp PreencherMinusculas

PreencherMinusculas:
    st X, valorAux            ; Armazena o caractere atual no endereço apontado por X
    inc r26
	inc valorAux
    dec cont
    brne PreencherMinusculas

    ldi valorAux,0x30         
    ldi cont,10
    rjmp PreencherDigitos

PreencherDigitos:
    st X, valorAux            ; Armazena o caractere atual no endereço apontado por X
    inc r26
	inc valorAux               ; Incrementa o caractere para o próximo (ex: 0 -> 1 -> 2 ...)
    dec cont               ; Decrementa o contador
    brne PreencherDigitos ; Se ainda houver caracteres, repete o loop

	rjmp LerEntrada ; pula para ler a entrada de comandos

LerEntrada:
	ldi flag1,0x1c ; flag do primeiro comando
	ldi flag2,0x1d ; flag do segundo comando
	ldi flag3,0x1e ; flag do terceiro comando

	in entrada,porta ; lê um input
	cp entrada,flag1 ; vê se é pro comando da tabela
	breq Tabela ; pula para a tabela caso a entrada seja igual a flag

	cp entrada,flag2 ; vê se é pro comando de número de caracteres
	breq NumeroDeCaracteres;  pula para verificar o número de caracteres se for engualzinho rs

	cp entrada,flag3 ; vê se é pro comando de frequentes
	breq FrequenciaEspecifica ; pula para determinar frequencia de um caractere se for engualzinho rs

	rjmp LerEntrada ; volta se nada for inserido na entrada

Tabela:
	ldi r27,0x03 ; inicia o ponteiro X da posição de memória 0x300
	ldi r26,0x00 ; inicia o ponteiro X da posição de memória 0x300
	
	Leitura:
		in entrada,porta ; lê um input
		cpi entrada,0x1b ; compara para ver se o comando é esc
		breq LerEntrada ; pula se for engualzinho rs

		ldi cont,64 ; define o contador (virou economia agora)
		ldi r29,0x02 ; define o ponteiro Y
		ldi r28,0x00 ; define o ponteiro Y

	VerificarTabela:
		ld valorAux,Y ; armazena num valor auxiliar porque o assembly é chei de firula
		cp entrada,valorAux ; compara
		breq ArmazenarNaTabela ; pula se for engualzinho rs
		
		dec cont ; decrementa o contador
		inc r28 ; incrementa a posição do ponteiro
		cpi cont,0 ; se for zero
		breq Leitura ; ele volta pra lá sem armazenar valor algum
		
		rjmp VerificarTabela ; volta pra ser loop, minino é burro e não sabe sozinho

	ArmazenarNaTabela:
		st X,entrada ; tendo sido as condições assistidas, vai armazenar no endereço apontado
		out portc,entrada ; tá mostrando no output, oxi!

		cpi r26,0xFF ; vê se tá na última posição de memória
		breq ArmazenarFrequentes ; pula se tá nas últimas
		
		inc r26 ; incrementa a posição de memória
		rjmp Leitura ; volta pro loop de leitura

NumeroDeCaracteres:
	ldi r27,0x03 ; inicia o ponteiro X da posição de memória 0x300
	ldi r26,0x00 ; inicia o ponteiro X da posição de memória 0x300
	ldi cont,0 ; contador para o número de caracteres

	ContarNaTabela:
		ld valorAux,X ; armazena no valor auxiliar o ponteiro
		inc r26 ; incrementa o ponteiro
		
		cpi valorAux,0x20 ; vê se é espaço em branco
		breq ContarNaTabela ; volta para não contar se ( é assim, você tem que largar a mão do não) for em branco

		cpi valorAux,0x00 ; verifica se não está com nada
		breq Resultado ; volta se for vazio

		inc cont ; incrementa o contador se nenhuma condição for assistida
		rjmp ContarNaTabela ; volta se  não for nenhum dos casos

	Resultado:
		sts 0x401,cont ; armazena o resultado no espaço de memória 0x401
		out portc,cont ; tá mostrando no output, ora bolas!
		rjmp LerEntrada ; volta pra ler o que o usuário quiser

FrequenciaEspecifica:
	ldi r27,0x03 ; define ponteiro X para o inicio da tabela
	ldi r26,0x00 ; define ponteiro X para o inicio da tabela
	ldi cont,0 ; contador para a frequência

	LeituraCaractere:
		in entrada,porta ; lê o input na portaa

		InicioFrequencia:
			ld valorAux,X ; valor auxiliar para verificar se acabou

			cpi valorAux,0x00 ; verifica se acabou os valores
			breq ResultadoFrequencia ; vai para o fim dessa etapa
		
			ldi r29,0x02 ; define ponteiro Y para inicio da tabela
			ldi r28,0x00 ; define ponteiro Y para inicio da tabela

			VerificarTabelaNaFrequencia:
				ld valorAux,Y ; armazena num valor auxiliar porque o assembly é chei de firula
				cp entrada,valorAux ; compara
				breq ContarFrequencia ; pula se for engualzinho rs
			
				cpi valorAux,0x00 ; verifica se acabou os valores
				breq InicioFrequencia ; vai para o fim dessa etapa
			
				inc r28 ; incrementa a posição do ponteiro
				cpi r28,0x00 ; ve se é o ultimo
				breq InicioFrequencia ; volta pro começo do loop principal

				rjmp VerificarTabelaNaFrequencia ; volta pra ser loop, minino é burro

		ContarFrequencia:
			ld valorAux,X ; coloca o valor da posição do ponteiro X
			inc r26 ; próxima posição ponteiro
			cp entrada,valorAux ; compara
			brne InicioFrequencia ; volta se for diferente para não contar

			inc cont ; incrementa contador
			rjmp InicioFrequencia ; volta o loop

		ResultadoFrequencia:
			sts 0x402,cont ; armazena o resultado
			out portc,cont ; exibe o valor na portac

			rjmp ArmazenarFrequentes
	
ArmazenarFrequentes:
    ; Inicialização dos ponteiros e variáveis
    ldi r27, 0x04     ; Ponteiro X para início da área de frequência (0x400)
    ldi r26, 0x00

    ; Área de frequência será estruturada como:
    ; [Caractere][Frequência] para cada posição

    ; Limpar área de memória primeiro
    ldi cont, 0x00    ; Contador para limpar
    LimparAreaFrequencia:
        st X+, cont   ; Limpa o byte de caractere
        st X+, cont   ; Limpa o byte de frequência
        cpi r26, 0x14 ; 10 posições * 2 bytes por entrada
        brne LimparAreaFrequencia

    ; Reiniciar ponteiros para varredura
    ldi r27, 0x03     ; Ponteiro X volta para início da tabela de caracteres
    ldi r26, 0x00
    
    ; Inicializar ponteiro Y para área de frequência
    ldi r29, 0x04
    ldi r28, 0x00

    ; Zerar registradores de controle
    ldi cont, 0x00    ; Contador de frequência atual
    ldi valorAux, 0x00 ; Caractere atual

    VarreduraCaracteres:
        ld r20, X+    ; Carregar caractere da tabela
        
        cpi r20, 0x00 ; Verificar fim da tabela
        breq OrdenarFrequentes ; Se fim da tabela, ordenar

        ; Verificar se caractere já existe na tabela de frequência
        ldi r29, 0x04
        ldi r28, 0x00

        VerificarExistencia:
            ld r21, Y     ; Carregar caractere da tabela de frequência
            cp r20, r21   ; Comparar com caractere atual
            breq IncrementarFrequencia

            inc r28
            cpi r28, 0x0A ; 10 entradas
            breq InserirNovaEntrada

            adiw Y, 2     ; Próxima entrada
            rjmp VerificarExistencia

        IncrementarFrequencia:
            std Y+1, r22  ; Incrementar frequência
            rjmp VarreduraCaracteres

        InserirNovaEntrada:
            ; Procurar entrada com menor frequência para substituir
            ldi r29, 0x04
            ldi r28, 0x00
            ldi r22, 0xFF ; Maior valor inicial
            
            EncontrarMenorFrequencia:
                ld r24, Y+  ; Carregar frequência
                cp r24, r22  ; Comparar
                brlo AtualizarMenor

                inc r28
                cpi r28, 0x0A
                breq VarreduraCaracteres

                adiw Y, 1
                rjmp EncontrarMenorFrequencia

            AtualizarMenor:
                ; Atualizar entrada com novo caractere e frequência
                st -Y, r20  ; Armazenar caractere
                st Y+, r23 ; Armazenar frequência inicial 1
                rjmp VarreduraCaracteres

        OrdenarFrequentes:
            ; Implementar algoritmo de ordenação por frequência
            ; Método de bolha simples
            ldi r29, 0x04
            ldi r28, 0x00

            LoopExterno:
                ldi r27, 0x04
                ldi r26, 0x00
                ldi cont, 0x0A  ; Tamanho da tabela

            LoopInterno:
                ld r20, X+     ; Carregar frequência atual
                ld r21, X+     ; Carregar próxima frequência

                cp r20, r21     ; Comparar frequências
                brsh ProximaComparacao ; Pular se já ordenado

                ; Trocar entradas
                st -X, r21      ; Trocar frequência
                st X, r20       ; Trocar caractere correspondente

            ProximaComparacao:
                dec cont
                brne LoopInterno

                inc r28
                cpi r28, 0x0A
                brne LoopExterno

    ; Retornar ao fluxo principal
    rjmp LerEntrada