#include "totvs.ch"


/**************************************************************************************************
Função:
M410ALOK

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada executado antes de iniciar a alteração do Pedido de Venda e utilizado para
validar se será permitdo ou não esta alteração.

Parâmetros:
Nenhum

Retorno:
lRet => Lógico, sendo:
        .T. - Prossegue alteracao do Pedido de Venda.
        .F. - Impede alteracao no pedido de venda.
**************************************************************************************************/
User Function M410ALOK()

If ALTERA
   U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
EndIf   

Return .T.