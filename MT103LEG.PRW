#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT103LEG
//PE(Ponto de Entrada para Inclusão de Status na Leganda da Pre-Nota e Documento Entrada
@author QsdoBrasil - Luiz Junior
@type function
@since Jan/2020 
@version 1.0 / FERRING
@return Nil
/*/

User function MT103LEG()
Local aArea := Getarea()
Local aRet  := PARAMIXB[1] 

aAdd(aRet, {"BR_CANCEL","Docto Pre-Nota Rejeitada"}) 

RestArea(aArea)
Return aRet                 