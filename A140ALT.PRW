#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#include 'parmtype.ch'


/*/{Protheus.doc} A140ALT
//PE(Ponto de Entrada para manipulação dos dados da Pre-Nota na Alteração
@author QsdoBrasil - Luiz Junior
@type function
@since Jan/2020 
@version 1.0 / FERRING
@return Nil
/*/


User Function A140ALT()

   Local aArea 	:= GetArea()
   
   F1_XREJPNF := " "
   F1_XOBSREJ := " "
   
   RestArea(aArea)

RETURN .T.