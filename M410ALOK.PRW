#include "totvs.ch"


/**************************************************************************************************
Fun??o:
M410ALOK

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada executado antes de iniciar a altera??o do Pedido de Venda e utilizado para
validar se ser? permitdo ou n?o esta altera??o.

Par?metros:
Nenhum

Retorno:
lRet => L?gico, sendo:
        .T. - Prossegue alteracao do Pedido de Venda.
        .F. - Impede alteracao no pedido de venda.
**************************************************************************************************/
User Function M410ALOK()

If ALTERA
   U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
EndIf   

Return .T.