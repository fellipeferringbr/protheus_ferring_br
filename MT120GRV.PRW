#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MT120GRV

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descri??o:
Ponto de entrada utilizado para continuar ou n?o a inclus?o, altera??o ou exclus?o do Pedido de 
Compra ou Autoriza??o de Entrega.

Par?metros:
ParamIXB[1] => cPedido - N?mero do pedido.										
ParamIXB[2] => lInclui - Controla a inclus?o.										
ParamIXB[3] => lAltera - Controla a altera??o.										
ParamIXB[4] => lExclui - Controla a exclus?o.

Retorno:
lRet => L?gico. Indica se dever? continuar com a inclus?o, altera??o ou exclus?o (.T.) ou se n?o
        dever? continuar a inclus?o, altera??o ou exclus?o (.F.).
**************************************************************************************************/
User Function MT120GRV()

Local cPedido := ParamIXB[1]										
Local lInclui := ParamIXB[2]										
Local lAltera := ParamIXB[3]										
Local lExclui := ParamIXB[4]

If lInclui .Or. lAltera // Loga apenas inclus?o e altera??o. A exclus?o ? feita pelo MTA120E
	U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
EndIf

Return .T.