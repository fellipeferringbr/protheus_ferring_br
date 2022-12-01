#include "RWMAKE.ch"
#include "PROTHEUS.ch"
#include "TOPCONN.CH"
#include "TBICONN.CH"
                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110GRV  ºAutor  ³Cleyton Leal   G&Z  º Data ³  24/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pto de Entrada apos a gravação da SC para tratar o gestor  º±±
±±º          ³ que é responsavel pela aprovação.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Ferring                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MT110GRV() 

// Fonte Alterado conforme necessidade de ajuste no procedimento de Aprovação de 
// Solicitação de Compras só por parte do gestor do comprador 
// Analista: Juan carlos Zúnica - 20190515          

Local cUser		:= RetCodUsr()
Local _cGest	:= "" 
Local _cNum		:= SC1->C1_NUM
Local nItSol	:= SC1->C1_ITEM

DbSelectarea('SAI')
dbOrderNickName("AIGESTOR") // AI_FILIAL, AI_USER, AI_XGESTOR, R_E_C_N_O_, D_E_L_E_T_,	
	
	If DbSeek(xFilial('SAI')+cUser+_cGest)

		_cGest 	:= SAI->AI_XGESTOR   
 		DBCloseArea()
		dbSelectArea("SC1")
		dbSetOrder(1)
		dbSeek(xFilial("SC1")+_cNum+nItSol)   
		
		If !EMPTY(_cGest)
			
	   		RecLock("SC1",.F.)             
			SC1->C1_CODAPRO := Alltrim(_cGest)                                            	
	  		MsUnlock()
		  Else
		
	   		MsgAlert("Usuário não autorizado a gerar esta Solicitação de Compras para esta filial")
	   		MsgAlert("Favor entrar em contato com o Gestor de Compras")  
			Return .F.
			
		EndIf		       

   
	Else
	
		MsgAlert("Solicitante não cadastrado nesta filial")
		MsgAlert("Favor entrar em contato com o Gestor de Compras")     
		
		Return .F.
	
	Endif
	
Return .T. 