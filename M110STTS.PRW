#include "RWMAKE.ch"
#include "PROTHEUS.ch"
#include "TOPCONN.CH"
#include "TBICONN.CH"         


User Function M110STTS() 

Local cNumSol   := Paramixb[1]
Local nOpc 		:= Paramixb[2]
Local cUser		:= RetCodUsr()
Local _cGest	:= ""
Local _cDest	:= ""

If nOpc == 1 .or. nOpc == 2// Inclusao ou Alteração

	DbSelectarea('SAI')
	dbOrderNickName("AIGESTOR") // AI_FILIAL, AI_USER, AI_XGESTOR, R_E_C_N_O_, D_E_L_E_T_	
	If DbSeek(xFilial('SAI')+cUser+_cGest)
		
		_cGest := SAI->AI_XGESTOR   
		
		msgalert("Solicitação "+alltrim(cNumSol)+" incluída com sucesso!")      
		
		//Encontra e-mail Gestor
	
			If PswSeek (_cGest, .T.) 
				_cGest := PswRet(1)
		  		_cDest := PswRet() [1][14]
			Endif
	
		
   		U_RCOM02(SC1->C1_NUM,_cDest, " - INCLUIDA"," ") 
			
		DBCloseArea()
			
	Else  

		MsgAlert("Favor informar seu Gestor") 
			
		Return .F.	
                                                        
   	Endif
         

endif



Return .T.

