;202402841904 Pedro Henrique Silvestre de Mello Moreira TA
;202307476331 Sarah Ferrari TA

;Armazenar uma tabela de caracteres alfanum�ricos (mai�sculas, min�sculas e d�gitos) na mem�ria IRAM do Atmega2560, no padr�o ASCII, a partir do endere�o 0x200. 
;Armazenar tamb�m o c�digo ASCII do espa�o em branco (0x20). Armazenar tamb�m o c�digo correspondente ao comando <ESC> (0x1B).

;DEFININDO VARI�VEIS
.DEF caractere = r16
.DEF flag = r17 ;ponto de parada
.DEF contador = r18
.DEF termo = r19
.DEF input = r20
.DEF somaCaractere = r21
.DEF comparador = r22
.DEF contaAparicao = r23
.DEF enderecoComparacao = r24


; TAREFA 1 CRIANDO TABELA DOS DIGITOS

;carregand os valores nos registradores
inicioTabelaCaracteres:
ldi  caractere,0x30;inicando com o valor 0x30 correspondente ao digito 0
ldi termo,0x1
ldi flag,0xA
ldi r27,0x02 ; apontadores do endere�o incialmente 0x200
ldi r26,0x00
ldi somaCaractere,0xFF; R21 como FF para configurar os pinos como sa�da
out DDRD, somaCaractere; Configura todos os pinos de PORTD como sa�da
clr somaCaractere;limpa o registrador

tabelaDigito:
st X,caractere
out PORTD,caractere;imprimi caractere na saida
add caractere,termo
inc contador 
inc r26
cp flag,contador
brne tabelaDigito

;REATRIBUINDO OS VALORES INICIAIS
ldi caractere,0X41 ;codigo A maiusculo
ldi flag,0X1A
ldi contador,0x0

tabelaMaiusculo:
;Criando tabela maiuscula
st X,caractere
out PORTD,caractere;imprimi caractere na saida
add caractere,termo
inc contador 
inc r26
cp flag,contador
brne tabelaMaiusculo

;REATRIBUINDO OS VALORES INICIAIS
ldi caractere,0X61 ;codigo a minusuculo
ldi contador,0x0 ;redefinindo contador

tabelaMinusculo:
;Criando tabela minuscula
st X,caractere
out PORTD,caractere;imprimi caractere na saida
add caractere,termo
inc contador 
inc r26
cp flag,contador
brne tabelaMinusculo

;ARMAZENANDO O ESPA�O EM BRANCO E O ESC
ldi caractere,0X20
st X,caractere
out PORTD,caractere;imprimi caractere na saida
inc r26
ldi caractere,0x1B
st X,caractere
out PORTD,caractere;imprimi caractere na saida


;TAREFA 0: DEFINIR O LOOP PRINCIPAL QUE AGUARDA O C�DIGO DE ENTRADA PARA INICIAR UMA DAS ROTINAS 
inicio:
clr r25
out DDRC,r25; define PORTC como entrada
in r25,PINC ; L� o valor no pinc e armazena em r25
cpi r25,0X1C;compara entrada com o c�digo do incio de montagem da tabela
breq tabelaInputInicio
cpi r25,0X1D
breq iniciarContaCaracteres
cpi r25,0X1E
breq iniciarAparicaoCaractere
rjmp inicio

iniciarContaCaracteres:
rjmp inicioContaCaracteres
iniciarAparicaoCaractere:
rjmp aparicaoCaractereInicio


;TAREFA 2
;DEFININDO AS PORTAS
tabelaInputInicio:
clr input         ; R20 como 0 para configurar os pinos como entrada
out DDRC, r20    ; Configura todos os pinos de PORTC como entrada
ldi somaCaractere,0xFF; R21 como FF para configurar os pinos como sa�da
out DDRD, somaCaractere; Configura todos os pinos de PORTD como sa�da
clr somaCaractere;limpa o registrador
ldi r29,0x03


;LENDO TABELA INPUT
inicioLeitura:
;DEFININDO AS PORTAS
clr input         ; R20 como 0 para configurar os pinos como entrada
out DDRC, r20    ; Configura todos os pinos de PORTC como entrada

tabelaInput:
leitura:
in input,PINC ; Le os valores de pinc e armazena em r20

verficarFimCadeia:
cpi input,0X1B ;verifica se � ESC
breq fimleitura ; Sai da leitura se for esc

verifcarCaractereValido: ; verifica se o input corresponde a um carctere imprimivel em ascii
cpi input,0X20 ; compara o valor do input com o come�o da tabela 
brlo inicioLeitura ;retorna a entrada at� o caractere ser v�lido
cpi input,0X7F ;compara a entrada com o final da tabela 
brsh inicioLeitura;tabelaInputInicio ;se for maior ou igual retorna ao inicio
rjmp verificaArmazenamento

verificaArmazenamento:;Verifica se o limiite do armazenamento chegou
cpi r28,0XFF
breq inicio; caso a tabela esteja cheia atualiza os 10 mais frequentes

armazenainput:
st Y,input
out PORTD,input;imprimi o caractere armazenado na porta D
inc r28
rjmp leitura

fimleitura:
ldi input,0X20 ; tribui o espa�o em branco
st Y,input ; armazena o espa�o em branco 
inc r28
rjmp inicio;termina a leitura voltando ao inicio

/*
; TAREFA 5 n�o foi completada o sistema de tabelas apresentava muitos probelmas na execu��o segue uma vers�o incompleta do oque deveria ser feito
;TAREFA 5 ARMAZENAR UMA TABELA COM A FREQUENCIA DOS CARACTERES
tabelaFreqCaractereInicio:
clr enderecoComparacao
clr contaAparicao
clr input
clr caractere
ldi r26,0X00;percorrer tabela caractere
ldi r27,0X03
ldi r31,0X03
analisaFreqCaractere: 
ld input,X ;armazena o valor do caractere num registrador para compara-lo
cpi input,0x00 ; verifica se chegou no fim da tabela
breq fimTabelaDeFreq
cpi input,0x20;comparar com espaco em branco e pular
breq pularEspacoBrancoX
;verificar se o caractere em X j� n�o est� na tabela de frequencia



rjmp analisaFreqCaractere
cp input,comparador
breq presenteNaTabela
inc r30




ld caractere,Z;percorrer tabela duas vezes uma vez travando o caractere e outra comparando
cpi caractere,0x20;realizar as mesmas compara��es com Z
breq pularEspacoBrancoZ
cpi caractere,0x00;ve se chegou no final da tabela
breq fimTabelaComparacao

cp caractere,input;compara valor de da compara��o
breq caracteresIguais

caracteresDiferentes:;se forem diferentes apenas reinicie e loop e incremente a comparacao
inc r30
rjmp analisaFreqCaractere

pularEspacoBrancoX:
inc r26
rjmp analisaFreqCaractere


presenteNaTabela:
inc r26
rjmp analisaFreqCaractere




caracteresIguais:
inc contaAparicao; incrementa contador de aparicao caso sejam iguais 
inc r30; salta para o prox a ser comparado
rjmp analisaFreqCaractere; reinicia loop



fimTabelaComparacao:
inc r26;salta para o proximo a ser comparado
rjmp armazenaContagem

armazenaContagem:
ldi r31,0x04
mov r30,enderecoComparacao
st Z,input;armazena o carctere
inc enderecoComparacao ; armazena no endereci seguinte a frequencia
mov r30,enderecoComparacao
st Z,contaAparicao
clr contaAparicao ; limpa conta aparicao
inc enderecoComparacao;pula para o proximo enderco
clr r30 ;limpa o r30 para recome�ar a sequencia 
rjmp analisaFreqCaractere


pularEspacoBrancoZ:
inc r30
rjmp analisaFreqCaractere


fimTabelaDeFreq:
rjmp inicio

*/


;TAREFA3:determinar o n�mero de caracteres presentes na tabela de sequ�ncia de caracteres. 

;1- percorrer a tabela
inicioContaCaracteres:
ldi r27,0x03; endere�o inicial da tabela
ldi r26,0x00
ldi somaCaractere,0xFF; R21 como FF para configurar os pinos como sa�da
out DDRD, somaCaractere; Configura todos os pinos de PORTD como sa�da
clr contador;limpar contador
clr caractere;limpar r16
clr somaCaractere;limpar somaCaractere

contaCaracteres:
ld caractere,X; 1 - armazenar valor do caracter na tabela num registrador
cpi caractere,0X20;2- cericar se caractere � um espa�o em branco
breq espacoEmBranco; ignora o espa�o
cpi caractere,0X00;Verifica se o espa�o est� vazio caso esteja significa o fim da tabela
breq imprimirCaractere ;caso chegue no fim da tabele direciona at� a impress�o
inc somaCaractere ;se for um caractere valido acrescenta um no contador de soma
sts 0X401,somaCaractere;armazena valor da soma no endere�o


espacoEmBranco:;3-caso caractere seja igual ao espa�o em branco,verifique o proximo
inc r26
rjmp contaCaracteres

imprimirCaractere:;5- imprimir numa porta de saida
out PORTD,somaCaractere
rjmp inicio;volta para o inicio


; TAREFA 4: ler um novo byte correspondente a um caractere em uma porta de entrada e contar o n�mero de vezes que o caractere est� presente na tabela de sequ�ncia de caracteres
; Armazenar o resultado no endere�o de mem�ria 0x402. Verificar se o caractere de entrada � v�lido. Caso o caractere disponibilizado na entrada n�o seja v�lido, 
;ler um novo caractere em loop at� a entrada apresentar um caractere v�lido.

aparicaoCaractereInicio:
clr contador ; limpa contador      
ldi input,0xFF; R21 como FF para configurar os pinos como sa�da
out DDRD, input; Configura todos os pinos de PORTD como sa�da
ldi r27,0X03;definindo os endere�os da tabela
ldi r26,0X00

aparicaoCaractere:
;1- LER BYTE DE ENTRADA
clr input
out DDRC, input ;define pinc como entrada
in input,PINC ;armazena input em r20
;2- VERIFICAR SE � VALIDO
validacaoEntrada:
cpi input,0X20
brlo caractereInvalido ;retorna a entrada at� o caractere ser v�lido
cpi input,0X7F ;compara a entrada com o final da tabela 
brsh caractereInvalido;tabelaInputInicio ;se for maior ou igual retorna ao inicio
;3 - (SE VALIDO) CONTAR NUMERO DE VEZES Q APAREE NA TABELA
comparacao:
ld comparador,X ;3.1 - armazenar o valor da tabela caractere num registrador
cpi comparador,0X00 ;Verifica se chegou ao fim da tabela
breq armazenaComparacao
cp comparador,input ;3.2 compara com o valor de input
breq aparicao;3.3- Se o comparador for igual direciona a aparicao
inc r26;3-4 Se n�o for igual continua a verificar at� chegar no fim da tabela
rjmp comparacao

aparicao:;3.4 - incrementa variavel de aparicoes
inc contador
inc r26
rjmp comparacao
;4- ARMAZENAR RESULTADO NA MEM�RIA(0X402)
armazenaComparacao:
sts 0X402,contador
rjmp imprimiComparacao
;5 - LIBERA NA PORTA DE SAIDA
imprimiComparacao:
out PORTD,contador
clr r26; reinicia o percorrer da tabela
clr contador;reinicia o contador de apari��es
rjmp inicio;volta ao inicio ap�s imprimir o numero de aparicoes

;(SE N�O) LER NOVAMENTE(PASSO 1)
caractereInvalido:
rjmp aparicaoCaractere


 



 