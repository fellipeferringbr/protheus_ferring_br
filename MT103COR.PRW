#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} MT103COR
//PE(Ponto de Entrada para manipulação das cores da Linha do Documento de Entrada
@author QsdoBrasil - Luiz Junior
@type function
@since Jan/2020 
@version 1.0 / FERRING
@return Nil
/*/

User function MT103COR()
Local aArea := Getarea()
Local aRet  := PARAMIXB[1]
	
	aRet[1][1] := "EMPTY(F1_STATUS) .AND. EMPTY(F1_XREJPNF)"                                   // Pré Nota	  
	aRet[7][1] := "!EMPTY(F1_STATUS) .AND. F1_TIPO == 'N' .AND. EMPTY(F1_XREJPNF)"	           // Normal
	aAdd(aRet, {"EMPTY(F1_STATUS) .AND. F1_TIPO == 'N' .AND. !EMPTY(F1_XREJPNF)","BR_CANCEL"}) // Rejeitada Pre-Nota
	
RestArea(aArea)
Return aRet                 