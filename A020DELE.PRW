#include "totvs.ch"


/**************************************************************************************************
Função:
A020DELE

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:

Parâmetros:
Ponto de entrada para validações relacionadas a exclusão de Fornecedores.
Este ponto é chamado na primeira validação após a confirmação da exclusão, antes de excluir o 
fornecedor, deve ser utilizado para validações adicionais para a EXCLUSÃO do fornecedor, 
para verificar algum arquivo/campo criado pelo usuário, para validar se o movimento será 
efetuado ou não.

Retorno:
lRet => Lógico. Caso verdadeiro, prossegue com o processo de deleção. Caso falso, 
        abandona o processo de deleção.
**************************************************************************************************/
User Function A020DELE()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.