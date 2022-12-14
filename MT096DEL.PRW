#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MT096DEL

Autor:
Tiago Bandeira Brasiliano

Data:
24/09/2014

Descri??o:
Ponto de Entrada de valida??o quando um aprovador ? exclu?do de um grupo de aprova??o.
Este ponto de entrada ? executado apenas caso existam documentos pendentes para este grupo de
aprova??o.
Observa??o: Os documentos passam para a pr?xima fase de aprova??o.

Foi necess?ria a cria??o deste ponto de entrada, pois a Totvs implementou uma nova l?gica na rotina
de exclus?o de aprovadores, que impossibilitava a exclus?o dos mesmos.

Par?metros:
Nenhum

Retorno:
lRet => Retorno boleano indicando se o aprovador pode ser exclu?do (.T.) ou n?o (.F.)
**************************************************************************************************/
User Function MT096DEL()

Local lRet := .T. // Sempre libera a exclus?o do aprovador

Return lRet