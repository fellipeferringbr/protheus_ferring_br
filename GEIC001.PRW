#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/* 

//////////////////////
//AV SYSTEM 23/08/2018
//Inicio da Retirada de valicao
//


USER FUNCTION GEIC001(nxOpc)
LOCAL lRet := .F.


//
//Tratamento para Inclusão/Alteração de Despseas quando o Embarque não está Aprovado
//Quando não houver aprovação nunca poderá gerar financeiro.
//
IF EMPTY(SW6->W6_APROV)
	
//	
//	Verifica se o valor informado é igual ao valor da previsão da despesa
	
//	SWI->(DBSETORDER(1))
//	IF SWI->(DBSEEK(XFILIAL("SWI")+SW6->W6_TAB_PC+SYB->YB_DESP))
//		IF M->WD_VALOR_R >= (SWI->WI_VALOR - 1) .AND. M->WD_VALOR_R <= (SWI->WI_VALOR + 1)
//			M->WD_GERFIN  := "1"
//		ELSE
//			M->WD_GERFIN  := "2"
//		ENDIF
//	ENDIF
//	
	
	//// Gatilho chamado pelo campo WD_VALOR_R = X3_WHEN
	IF nxOpc = 1
		lRet := .T.
	//// Gatilho chamado pelo campo WD_VALOR = X3_VLDUSER
	ELSEIF nxOpc = 2
		lRet := .T.
		//// Gatilho chamado pelo campo WD_GERFIN = X3_WHEN
	ELSEIF nxOpc = 3
		lRet := .F.
	ENDIF
	
//
//	Tratamento para Inclusão de Despseas quando o Embarque ESTÁ Aprovado
//	LINCAUX é a variavel que informa se é INCLUSÃO = .T.
//
ELSEIF SW6->W6_APROV = "2"  .AND. LINCAUX = .T.
	
//
//	Verifica se o valor informado é igual ao valor da previsão da despesa
	
//	SWI->(DBSETORDER(1))
//	IF SWI->(DBSEEK(XFILIAL("SWI")+SW6->W6_TAB_PC+SYB->YB_DESP))
//		IF M->WD_VALOR_R >= (SWI->WI_VALOR - 1) .AND. M->WD_VALOR_R <= (SWI->WI_VALOR + 1)
//			M->WD_GERFIN  := "1"
//		ELSE
//			M->WD_GERFIN  := "2"
//		ENDIF
//	ENDIF
//
	//// Gatilho chamado pelo campo WD_VALOR_R = X3_WHEN
	IF nxOpc = 1
		lRet := .T.
	//// Gatilho chamado pelo campo WD_VALOR = X3_VLDUSER
	ELSEIF nxOpc = 2
		lRet := .T.
		//// Gatilho chamado pelo campo WD_GERFIN = X3_WHEN
	ELSEIF nxOpc = 3
		IF M->WD_GERFIN = "1"
			lRet := .T.
		ELSEIF M->WD_GERFIN = "2"
			lRet := .F.
		ENDIF
	ENDIF
	
//
//	Tratamento para Alteração de Despseas quando o Embarque ESTÁ Aprovado
//	LINCAUX é a variavel que informa se é Alteração = .F.
 // Como as despesas já estão aprovadas permite ao usuário gerar financeiro.
//

ELSEIF SW6->W6_APROV = "2"  .AND. LINCAUX = .F. .AND. SWD->WD_BASEADI = "2" 
	//ELSEIF SW6->W6_APROV = "2"  .AND. LINCAUX = .F.	
	//// Gatilho chamado pelo campo WD_VALOR_R = X3_WHEN
	IF nxOpc = 1
		lRet := .F.
	//// Gatilho chamado pelo campo WD_VALOR_R = X3_VLDUSER
	ELSEIF nxOpc = 2
		lRet := .T.
		//// Gatilho chamado pelo campo WD_GERFIN = X3_WHEN
	ELSEIF nxOpc = 3
		lRet := .T.
	ENDIF

ELSEIF SW6->W6_APROV = "2"  .AND. LINCAUX = .F. .AND. SWD->WD_BASEADI = "1"
	IF nxOpc = 1
		lRet := .T.
	ELSEIF nxOpc = 2
		lRet := .T.	
	ENDIF		                                                                       
ENDIF	

RETURN(lRet)

// FIM
// AV SYSTEM 23-08-2018
////////////////