#include "totvs.ch"


/**************************************************************************************************
Função:
CT102CARR

Autor:
Tiago Bandeira Brasiliano

Data:
28/10/2014

Descrição:
Ponto de entrada que efetua o tratamento no momento de carregar os dados para o arquivo temporario.
Tem a função de manipular o temporário no momento da leitura (numa cópia de lançamento contábil
por exemplo).

Parâmetros:
nOpc      = Opção da Rotina
dDataLanc = Data do Lançamento Contábil
cLote     = Lote do Lançamento
cSubLote  = SubLote do Lançamento
cDoc      = Número do Documento

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
//| Para manter a regra de que todos os lançamentos devem ser incluídos com o tipo 9, ou seja, |
//| pré-lançamento, foi inseriada esta validação, para que no momento da cópia seja respeitado |
//| o inicializador padrão do campo (que foi alterado para "9").                               |
//| Esta regra funciona em conjunto com a função VldTpSaldo() e com o Ponto de Ent. CT105LOK.  |
//+--------------------------------------------------------------------------------------------+
If nOpc == 7 // 7=Cópia
	TMP->CT2_TPSALD := CriaVar("CT2_TPSALD")
EndIf

Return .T.