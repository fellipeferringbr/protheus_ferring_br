
#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA410LEG 
@type			: Fun??o
@Sample			: MA410LEG().
@description	: Ponto de Entrada executado ao clicar no bot?o Legenda do Browse de Pedido de Venda.
                  Aqui ? definido novas legendas na interface. (Ferring) 
                  (Atualiza??o da rotina: Considera Legenda padr?o + as customizadas "Ferring")
@return			: Null
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 07/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
User Function MA410LEG()

Local aLegenda := PARAMIXB

//------------------------------------------------------------+
// 	 ADICIONA  NOVAS LEGENDAS NA INTERFACE PADR?O (LEGENDA)  
//-------------------------------------------------------------+
Aadd(aLegenda, {"BR_CINZA"	    , "Pedido Bloqueado por padr?o"})
Aadd(aLegenda, {"BR_LARANJA"    , "Pedido Bloqueado por desconto"})
Aadd(aLegenda, {"BR_BRANCO"		, "Enviar Bomi"})
Aadd(aLegenda, {"BR_PINK"		, "Enviado Bomi"})
Aadd(aLegenda, {"BR_MARRON"		, "Retornado Bomi"})

Return (aLegenda)
