#include "totvs.ch"


/**************************************************************************************************
Função:
MT120GRV

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:
Ponto de entrada utilizado para continuar ou não a inclusão, alteração ou exclusão do Pedido de 
Compra ou Autorização de Entrega.

Parâmetros:
ParamIXB[1] => cPedido - Número do pedido.										
ParamIXB[2] => lInclui - Controla a inclusão.										
ParamIXB[3] => lAltera - Controla a alteração.										
ParamIXB[4] => lExclui - Controla a exclusão.

Retorno:
lRet => Lógico. Indica se deverá continuar com a inclusão, alteração ou exclusão (.T.) ou se não
        deverá continuar a inclusão, alteração ou exclusão (.F.).
**************************************************************************************************/
User Function MT120GRV()

Local cPedido := ParamIXB[1]										
Local lInclui := ParamIXB[2]										
Local lAltera := ParamIXB[3]										
Local lExclui := ParamIXB[4]

If lInclui .Or. lAltera // Loga apenas inclusão e alteração. A exclusão é feita pelo MTA120E
	U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
EndIf

Return .T.