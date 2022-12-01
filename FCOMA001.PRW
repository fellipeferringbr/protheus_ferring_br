#include "rwmake.ch"
#include "TOTVS.CH"
#include "protheus.ch"
                                  
/*/{Protheus.doc} FCOMA001
//Rotina principal para o Processo de Rejeição
@author QsdoBrasil - Luiz Junior
@type function
@since Jan/2020
@version 1.0 / Ferring
@return Nil
/*/

User Function FCOMA001(cTipoNf)

Local cAlter:= "N"

If cTipoNf == 'D'
   
   If Empty(SF1->F1_XREJPNF)      
      If Empty(SF1->F1_STATUS) .And. SF1->F1_TIPO == 'N'
         AbreTela(cTipoNf)  
      Else    
         Alert("Permitido somente para Pré-Nota.")      
      Endif        
   Else
      If !Empty(SF1->F1_XREJPNF) .And. MsgYesNo("Existe rejeição para essa Pré-Nota, deseja alterar ?")
         cAlter := "S"
         AbreTela(cTipoNf,cAlter)
      EndIf     
   EndIf
Else 
   If !Empty(SF1->F1_XREJPNF)
      AbreTela(cTipoNf,cAlter)
   Else
      If Empty(SF1->F1_STATUS) .And. SF1->F1_TIPO == 'N'
         Alert("Não existe rejeição para essa Pré-Nota.")      
      Else    
         Alert("Permitido somente para Pré-Nota.")      
      Endif     
   EndIf
EndIF

Return


Static Function AbreTela(cTipoNf,cAlter)

Local aArea     := GetArea()
Local aParam    := {}
Local aRet      := {}
Local cSelec    := ""
Local cObserv   := ""
Local cMensRej  := SF1->F1_XREJPNF+" - "+posicione("SX5",1,XFILIAL("SX5")+'ZZ'+SF1->F1_XREJPNF,"X5_DESCRI")
Local cDadEmail := Alltrim(SF1->F1_FILIAL)+Alltrim(SF1->F1_DOC)+Alltrim(SF1->F1_SERIE)+Alltrim(SF1->F1_FORNECE)+Alltrim(SF1->F1_LOJA)+Alltrim(SF1->F1_FORMUL)  
Local cUsuario  := FWLeUserLg("F1_USERLGI", 1)   

   If cTipoNF == 'D'
	   	   
       aAdd(aParam,{1,"Selecione",Space(15),"","","REJPN",".T.",0,.F.}) // Tipo caractere
	   aAdd(aParam,{11,"Observação","",".T.",".T.",.T.}) //-- Campo Memo
	
	   If ParamBox(aParam," ",@aRet) //-- Colocar o título ‘Rejeição de pré-nota’
	
	      // MemoWrite("C:\Acessos\rejeicao.txt", VarInfo("aRet",aRet, , .F.))
	      RecLock( "SF1", .f. )
	         SF1->F1_XREJPNF := aRet[1]
		     SF1->F1_XOBSREJ := aRet[2]
	      MsUnLock()
	      U_FCOMA002(cDadEmail,cUsuario,cAlter)     
	
	   Endif
	Else  

       MsgInfo("<b>"+cMensRej+"</b><br>"+SF1->F1_XOBSREJ,"Rejeição Pré Nota")	

	Endif
    RestArea(aArea)

Return Nil                                     
                                                  