#include "totvs.ch"


/**************************************************************************************************
Fun??o:
CT102CARR

Autor:
Tiago Bandeira Brasiliano

Data:
28/10/2014

Descri??o:
Ponto de entrada que efetua o tratamento no momento de carregar os dados para o arquivo temporario.
Tem a fun??o de manipular o tempor?rio no momento da leitura (numa c?pia de lan?amento cont?bil
por exemplo).

Par?metros:
nOpc      = Op??o da Rotina
dDataLanc = Data do Lan?amento Cont?bil
cLote     = Lote do Lan?amento
cSubLote  = SubLote do Lan?amento
cDoc      = N?mero do Documento

Retorno:
Nenhum
**************************************************************************************************/
User Function CT102CARR()

Local nOpc       := ParamIXB[1]													
Local dDataLanc  := ParamIXB[2]													
Local cLote      := ParamIXB[3]													
Local cSubLote   := ParamIXB[4]													
Local cDoc       := ParamIXB[5]

//+--------------------------------------------------------------------------------------------+
//| Para manter a regra de que todos os lan?amentos devem ser inclu?dos com o tipo 9, ou seja, |
//| pr?-lan?amento, foi inseriada esta valida??o, para que no momento da c?pia seja respeitado |
//| o inicializador padr?o do campo (que foi alterado para "9").                               |
//| Esta regra funciona em conjunto com a fun??o VldTpSaldo() e com o Ponto de Ent. CT105LOK.  |
//+--------------------------------------------------------------------------------------------+
If nOpc == 7 // 7=C?pia
	TMP->CT2_TPSALD := CriaVar("CT2_TPSALD")
EndIf

Return .T.