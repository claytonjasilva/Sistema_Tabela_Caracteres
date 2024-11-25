;202402841904 Pedro Henrique Silvestre de Mello Moreira TA
;202307476331 Sarah Ferrari TA

;Armazenar uma tabela de caracteres alfanuméricos (maiúsculas, minúsculas e dígitos) na memória IRAM do Atmega2560, no padrão ASCII, a partir do endereço 0x200. 
;Armazenar também o código ASCII do espaço em branco (0x20). Armazenar também o código correspondente ao comando <ESC> (0x1B).

;DEFININDO VARIÁVEIS
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
ldi r27,0x02 ; apontadores do endereço incialmente 0x200
ldi r26,0x00
ldi somaCaractere,0xFF; R21 como FF para configurar os pinos como saída
out DDRD, somaCaractere; Configura todos os pinos de PORTD como saída
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

;ARMAZENANDO O ESPAÇO EM BRANCO E O ESC
ldi caractere,0X20
st X,caractere
out PORTD,caractere;imprimi caractere na saida
inc r26
ldi caractere,0x1B
st X,caractere
out PORTD,caractere;imprimi caractere na saida


;TAREFA 0: DEFINIR O LOOP PRINCIPAL QUE AGUARDA O CÓDIGO DE ENTRADA PARA INICIAR UMA DAS ROTINAS 
inicio:
clr r25
out DDRC,r25; define PORTC como entrada
in r25,PINC ; Lê o valor no pinc e armazena em r25
cpi r25,0X1C;compara entrada com o código do incio de montagem da tabela
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
ldi somaCaractere,0xFF; R21 como FF para configurar os pinos como saída
out DDRD, somaCaractere; Configura todos os pinos de PORTD como saída
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
cpi input,0X1B ;verifica se é ESC
breq fimleitura ; Sai da leitura se for esc

verifcarCaractereValido: ; verifica se o input corresponde a um carctere imprimivel em ascii
cpi input,0X20 ; compara o valor do input com o começo da tabela 
brlo inicioLeitura ;retorna a entrada até o caractere ser válido
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
ldi input,0X20 ; tribui o espaço em branco
st Y,input ; armazena o espaço em branco 
inc r28
rjmp inicio;termina a leitura voltando ao inicio

/*
; TAREFA 5 não foi completada o sistema de tabelas apresentava muitos probelmas na execução segue uma versão incompleta do oque deveria ser feito
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
;verificar se o caractere em X já não está na tabela de frequencia



rjmp analisaFreqCaractere
cp input,comparador
breq presenteNaTabela
inc r30




ld caractere,Z;percorrer tabela duas vezes uma vez travando o caractere e outra comparando
cpi caractere,0x20;realizar as mesmas comparações com Z
breq pularEspacoBrancoZ
cpi caractere,0x00;ve se chegou no final da tabela
breq fimTabelaComparacao

cp caractere,input;compara valor de da comparação
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
clr r30 ;limpa o r30 para recomeçar a sequencia 
rjmp analisaFreqCaractere


pularEspacoBrancoZ:
inc r30
rjmp analisaFreqCaractere


fimTabelaDeFreq:
rjmp inicio

*/


;TAREFA3:determinar o número de caracteres presentes na tabela de sequência de caracteres. 

;1- percorrer a tabela
inicioContaCaracteres:
ldi r27,0x03; endereço inicial da tabela
ldi r26,0x00
ldi somaCaractere,0xFF; R21 como FF para configurar os pinos como saída
out DDRD, somaCaractere; Configura todos os pinos de PORTD como saída
clr contador;limpar contador
clr caractere;limpar r16
clr somaCaractere;limpar somaCaractere

contaCaracteres:
ld caractere,X; 1 - armazenar valor do caracter na tabela num registrador
cpi caractere,0X20;2- cericar se caractere é um espaço em branco
breq espacoEmBranco; ignora o espaço
cpi caractere,0X00;Verifica se o espaço está vazio caso esteja significa o fim da tabela
breq imprimirCaractere ;caso chegue no fim da tabele direciona até a impressão
inc somaCaractere ;se for um caractere valido acrescenta um no contador de soma
sts 0X401,somaCaractere;armazena valor da soma no endereço


espacoEmBranco:;3-caso caractere seja igual ao espaço em branco,verifique o proximo
inc r26
rjmp contaCaracteres

imprimirCaractere:;5- imprimir numa porta de saida
out PORTD,somaCaractere
rjmp inicio;volta para o inicio


; TAREFA 4: ler um novo byte correspondente a um caractere em uma porta de entrada e contar o número de vezes que o caractere está presente na tabela de sequência de caracteres
; Armazenar o resultado no endereço de memória 0x402. Verificar se o caractere de entrada é válido. Caso o caractere disponibilizado na entrada não seja válido, 
;ler um novo caractere em loop até a entrada apresentar um caractere válido.

aparicaoCaractereInicio:
clr contador ; limpa contador      
ldi input,0xFF; R21 como FF para configurar os pinos como saída
out DDRD, input; Configura todos os pinos de PORTD como saída
ldi r27,0X03;definindo os endereços da tabela
ldi r26,0X00

aparicaoCaractere:
;1- LER BYTE DE ENTRADA
clr input
out DDRC, input ;define pinc como entrada
in input,PINC ;armazena input em r20
;2- VERIFICAR SE É VALIDO
validacaoEntrada:
cpi input,0X20
brlo caractereInvalido ;retorna a entrada até o caractere ser válido
cpi input,0X7F ;compara a entrada com o final da tabela 
brsh caractereInvalido;tabelaInputInicio ;se for maior ou igual retorna ao inicio
;3 - (SE VALIDO) CONTAR NUMERO DE VEZES Q APAREE NA TABELA
comparacao:
ld comparador,X ;3.1 - armazenar o valor da tabela caractere num registrador
cpi comparador,0X00 ;Verifica se chegou ao fim da tabela
breq armazenaComparacao
cp comparador,input ;3.2 compara com o valor de input
breq aparicao;3.3- Se o comparador for igual direciona a aparicao
inc r26;3-4 Se não for igual continua a verificar até chegar no fim da tabela
rjmp comparacao

aparicao:;3.4 - incrementa variavel de aparicoes
inc contador
inc r26
rjmp comparacao
;4- ARMAZENAR RESULTADO NA MEMÓRIA(0X402)
armazenaComparacao:
sts 0X402,contador
rjmp imprimiComparacao
;5 - LIBERA NA PORTA DE SAIDA
imprimiComparacao:
out PORTD,contador
clr r26; reinicia o percorrer da tabela
clr contador;reinicia o contador de aparições
rjmp inicio;volta ao inicio após imprimir o numero de aparicoes

;(SE NÃO) LER NOVAMENTE(PASSO 1)
caractereInvalido:
rjmp aparicaoCaractere


 



 