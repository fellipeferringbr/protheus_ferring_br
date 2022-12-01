#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA410COR 
@type			: Função
@Sample			: MA410COR().
@description	: Ponto de Entrada executado na definição das as legendas do Browse de Pedido de Venda.
                  Aqui é definido novas legendas ao browse. (Ferring) 
                  (Atualização da rotina: Considera Legenda padrão + as customizadas "Ferring")
@return			: Null
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 07/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------

User Function MA410COR()

Local aCores	:= PARAMIXB
Local nPosBlq   := 0


//------------------------------------------------------------------------------
// ADICONA NOVA CONDIÇÃO PARA AS LEGENDAS DE BLOQUEIO REGRA/VERBA
//------------------------------------------------------------------------------ 
nPosBlq := aScan( aCores, {|x| AllTrim(x[3]) == "Pedido Bloqueado por Regra" } )

If ( nPosBlq > 0 )
    aCores[nPosBlq][1] += " .AND. C5_XBLQ == ''"
EndIf 

nPosBlq := aScan( aCores, {|x| AllTrim(x[3]) == "Pedido Bloqueado por Verba" } )

If ( nPosBlq > 0 )
    aCores[nPosBlq][1] += " .AND. C5_XBLQ == ''"
EndIf 
//------------------------------------------------------------+
// 	 ADICIONA  NOVAS LEGENDAS AO BROWSE DO PEDIDO DE VENDA  
//-------------------------------------------------------------+
//Aadd(aCores,{"Empty(C5_LIBEROK)        .AND. Empty(C5_NOTA).AND. C5_BLQ == '1'      .And. C5_XBLQ == '1'"  ,"BR_CINZA"     , "Pedido Bloqueado por padrão"})
//Aadd(aCores,{"Empty(C5_LIBEROK)        .AND. Empty(C5_NOTA).AND. C5_BLQ == '2'      .And. C5_XBLQ == '2'"  ,"BR_LARANJA"   , "Peido. Bloqueado por desconto"})
Aadd(aCores,{"Empty(C5_NOTA).AND. C5_BLQ == '1'      .And. C5_XBLQ == '1'"  ,"BR_CINZA"     , "Pedido Bloqueado por padrão"})
Aadd(aCores,{"Empty(C5_NOTA).AND. C5_BLQ == '2'      .And. C5_XBLQ == '2'"  ,"BR_LARANJA"   , "Peido. Bloqueado por desconto"})
Aadd(aCores,{"AllTRIM(C5__BOMI) == '1' .AND. Empty(C5_BLQ) .AND. !Empty(C5_LIBEROK) .AND. Empty(C5_NOTA)"  ,"BR_BRANCO"    , "Enviar Bomi"  })
Aadd(aCores,{"AllTRIM(C5__BOMI) == '2' .AND. Empty(C5_BLQ) .AND. !Empty(C5_LIBEROK) .AND. Empty(C5_NOTA)"  ,"BR_PINK"      , "Enviado Bomi"   })
Aadd(aCores,{"AllTRIM(C5__BOMI) == '3' .AND. Empty(C5_BLQ) .AND. !Empty(C5_LIBEROK) .AND. Empty(C5_NOTA)"  ,"BR_MARRON"    , "Retornado Bomi"})

Return( aCores )
