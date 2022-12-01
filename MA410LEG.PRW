
#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA410LEG 
@type			: Função
@Sample			: MA410LEG().
@description	: Ponto de Entrada executado ao clicar no botão Legenda do Browse de Pedido de Venda.
                  Aqui é definido novas legendas na interface. (Ferring) 
                  (Atualização da rotina: Considera Legenda padrão + as customizadas "Ferring")
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
// 	 ADICIONA  NOVAS LEGENDAS NA INTERFACE PADRÃO (LEGENDA)  
//-------------------------------------------------------------+
Aadd(aLegenda, {"BR_CINZA"	    , "Pedido Bloqueado por padrão"})
Aadd(aLegenda, {"BR_LARANJA"    , "Pedido Bloqueado por desconto"})
Aadd(aLegenda, {"BR_BRANCO"		, "Enviar Bomi"})
Aadd(aLegenda, {"BR_PINK"		, "Enviado Bomi"})
Aadd(aLegenda, {"BR_MARRON"		, "Retornado Bomi"})

Return (aLegenda)
