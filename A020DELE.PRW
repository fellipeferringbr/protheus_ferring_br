#include "totvs.ch"


/**************************************************************************************************
Fun??o:
A020DELE

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descri??o:

Par?metros:
Ponto de entrada para valida??es relacionadas a exclus?o de Fornecedores.
Este ponto ? chamado na primeira valida??o ap?s a confirma??o da exclus?o, antes de excluir o 
fornecedor, deve ser utilizado para valida??es adicionais para a EXCLUS?O do fornecedor, 
para verificar algum arquivo/campo criado pelo usu?rio, para validar se o movimento ser? 
efetuado ou n?o.

Retorno:
lRet => L?gico. Caso verdadeiro, prossegue com o processo de dele??o. Caso falso, 
        abandona o processo de dele??o.
**************************************************************************************************/
User Function A020DELE()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.