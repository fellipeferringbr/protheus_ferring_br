#include "totvs.ch"


/**************************************************************************************************
Função:
MT096DEL

Autor:
Tiago Bandeira Brasiliano

Data:
24/09/2014

Descrição:
Ponto de Entrada de validação quando um aprovador é excluído de um grupo de aprovação.
Este ponto de entrada é executado apenas caso existam documentos pendentes para este grupo de
aprovação.
Observação: Os documentos passam para a próxima fase de aprovação.

Foi necessária a criação deste ponto de entrada, pois a Totvs implementou uma nova lógica na rotina
de exclusão de aprovadores, que impossibilitava a exclusão dos mesmos.

Parâmetros:
Nenhum

Retorno:
lRet => Retorno boleano indicando se o aprovador pode ser excluído (.T.) ou não (.F.)
**************************************************************************************************/
User Function MT096DEL()

Local lRet := .T. // Sempre libera a exclusão do aprovador

Return lRet