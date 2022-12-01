
#Include "Protheus.ch"

//------------------------------------------------------------------------------------------
//  ARQUIVO FONTE PARA REUNIR ROTINAS DE USO GERAL.
//------------------------------------------------------------------------------------------
User Function FCOMM001() ; Return("Fonte especifico para rotinas genericas (SIGACOM). De Uso Geral.")

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldCtaCC 
@type		    :   Função de usuário 
@Sample			:   U_VldCtaCC( cConta, cCCusto, cRateio, cCallOrig ).
@description	:   Atualização da Rotina -> Valida o preenchimento da Conta Contabil x Centro de Custo.
					Regra:
					        Permite Ativar nova regra de validação atraves do(s)
							parametros: ES_ChkNVLA, ES_ChkNVLB, ES_ChkNVLC quando
							desativado permanece a validação já existente.
							
observação      :   Validação executada pelos processos P.E.:
					A 	- MT120LOK (P.E Pedido de Compra -  LinhaOk Itens)
					B	- MT140LOK (P.E Pré-documento de entrada - LinhaOk Itens)
					C	- MT100LOK (P.E Documento Entrada - LinhaOk Itens)	

@Param	cConta	: 	Código conta contabil
@Param	cCCusto	:	Código Centro de custo
@Param	cRateio	: 	1=Sim;2=Nao 
@Param	cCallOrig:	Nome da rotina de origem para identificar a chamada.
@return			:   lRet =  .T. (Validacao Sucesso) ou .F. (Validacao Inconsistência)
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 29/09/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
User Function VldCtaCC( cConta, cCCusto, cRateio, cCallOrig )
                                                                
Local aArea 		:= GetArea()
Local cNvlConta		:= ""
Local cNvlCusto 	:= ""
Local lSigaEIC		:= .F.
Local lSemRateio	:= .F.
Local lCheckNvl		:= .F.
Local lRet 			:= .T.     

lSigaEIC 	:= ( nModulo == 17 )
lSemRateio	:= ( cRateio <> "1" )

//------------------------------------------------------------------------------------------+
//  SO FAZ A VALIDACAO DA CONTA CONTABIL X CENTRO DE CUSTO CASO O MODULO ACESSADO SEJA      |
//   DIFERENTE DE SIGAEIC E ITEM DA NOTA FISCAL SEM RATEIO                                 | 
//-----------------------------------------------------------------------------------------+
If (!lSigaEIC .And. lSemRateio)         
   
	If EMPTY(Val(SubStr( cConta,1,1)))    // Obrigando Preenchimento da Conta contabil
		MsgAlert("Preencher conta Contabil - Duvidas com preenchimento consultar Contabilidade")                    								
		lRet := .F.    
	Else 

		IF Val(SubStr(cConta,1,1)) >= 3  			// Validando se a conta preenchida for maior que 3 precisa centro de custo
			If EMPTY(Val(SubStr(cCCusto,1,1)))    	// Obrigando Preenchimento do Centro de Custo 
				MsgAlert("Preencher Campo Dpto (Centro de Custo) - Duvidas com preenchimento consultar Contabilidade")
				lRet := .F. 
			Else      
				IF !Empty(cConta) .AND. !Empty(cCCusto)   //validando se tanto a Conta e Centro de Custo estão preenchidos
					
					Do Case 
						// -------------------------------------------
						// 		(P.E Pedido de Compra)
						// -------------------------------------------
						Case cCallOrig == "MT120LOK"
							lCheckNvl := SuperGetMv("ES_ChkNVLA",,.T.)
						// -------------------------------------------
						//  	(P.E Pré-documento de entrada)
						// -------------------------------------------
						Case cCallOrig == "MT140LOK"
							lCheckNvl := SuperGetMv("ES_ChkNVLB",,.T.)
						// -------------------------------------------
						//		(P.E Documento Entrada)
						//--------------------------------------------
						Case cCallOrig == "MT100LOK" 
							lCheckNvl := SuperGetMv("ES_ChkNVLC",,.T.)
					EndCase

					// ----------------------------------------------------------------------------------------------------
					// Ticket - 20200916002N-Amarracao Contas e CC Pedido Compra_AN1   
					// Nova regra: ( lCheckNvl )
					//  			Se centro de custo e conta contábil  possuem o mesmo nível.
					// 				Custo (CTT_CRGNV1) x Conta (CT1_RGNV1) .
					// ----------------------------------------------------------------------------------------------------					
					If ( lCheckNvl )
						
						cNvlCusto	:= Posicione("CTT",1,xFilial("CTT") + cCCusto	,"CTT_CRGNV1")	//-- Contra Regra Nivel 1
						cNvlConta	:= Posicione("CT1",1,xFilial("CT1") + cConta	,"CT1_RGNV1")	//-- Regra de Ligacao Nivel 1 
						
						If ( cNvlCusto <> cNvlConta .And. (!Empty(cNvlCusto) .Or. !Empty(cNvlConta)) )
							MsgAlert("Centro de custo e Conta contábil possuem níveis diferentes, por favor verificar com o Depto de Contabilidade!" + CRLF + CRLF + ;
										"Nível  Centro Custo:"		+ IIF(!Empty(cNvlCusto), AllTrim(cNvlCusto),"Não informado") + CRLF + ;
										"Nível  Conta Contábil: " 	+ IIF(!Empty(cNvlConta), AllTrim(cNvlConta),"Não informado"))    
							lRet := .F.	
						Endif 
					Else 			
						IF Val(SubStr(cConta,1,1)) >= 6   // Caso a Conta for Maior que 6
							IF Val(SubStr(cCCusto,1,1)) >= 3 .AND. Val(SubStr(cCCusto,1,1)) <=5 // So pode os Centros de Custo que sao mencionados     
								MsgAlert("Para Contas que Comecam com 6, são validos seguintes Dpto(s):" + ;
										" Distribuição / Finanças / Desenv. e Inova - Duvidas com preenchimento consultar Contabilidade")   // trocar o Centro de Custo
								lRet := .F.      
							ENDIF	
						ELSE		
							IF Val(SubStr(cConta,1,1)) <> Val(SubStr(cCCusto,1,1))
								MsgAlert("Departamento e ou Conta Contábil diferentes, essa regra só é valida para contas que comecem com 6 - Dúvidas com " + ; 
										 "preenchimento consultar Contabilidade")
								lRet := .F.
							ENDIF
						ENDIF  							
					EndIf
				EndIf
			EndIf
		EndIf                        
	EndIf  	
EndIf
 
RestArea(aArea)	 
			
Return (lRet) 


#include "protheus.ch"
                     
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetLogAIF 
@type		    : Rotina de usuário
@Sample			: U_SetLogAIF("SA1") 
@description	: Rotina responsavel por atualizar os campos customizados da tabela AIF Log de alterações Cli/For .
				  Atualiza com o novo conteúdo alterado.

@Param	cOperBlq: Alias Tabela SA1 Cliente ou SA2 Fornecedor
@return			: Nulo
@Observ.        : Está rotina é chamada pelos pontos de entrada:
				  P.E -> M030PALT -> Após gravação da alteração do Cliente.
				  P.E -> M020ALT  -> Após gravação da alteração do Fornecedor. 
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 09/1/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
User Function SetLogAIF( cAlias ) 

Local aArea     := GetArea()
Local cFilAlias	:= ""
Local cFilAIF   := ""
Local cFornec   := ""
Local cLoja     := ""
Local cDataAlt  := ""
Local cAliasQry := ""
Local cCampo	:= ""
Local xValue 	:= ""
Local cPicture	:= ""
Local cTipo		:= ""
Local cUserName := ""


//--------------------------------------------------------------------
//	Ignora log para os casos de altrações em campo de sistema MSBLQL 
//-------------------------------------------------------------------
If FWIsInCallStack("U_FFATA015")

	//É necessario habilitar a chave FWLOGMSG_DEBUG = 1 no appserver.ini.
	FWLogMsg('WARN',, 'U_SetLogAIF', FunName(), '', '01', "Campos reservados MSBLQL é desconsiderado no LOG AIF U_SetLogAIF()", 0, 0, {})
	
	Return(.F.)
EndIf 

//+--------------------------------------------------------------------+
//| Efetua a gravação do usuário que efetuou a alteração no Cli/forn   |
//| e também o conteúdo do campo que foi inserido pelo usuário.        |
//| Estas informações serão utilizadas posteriomente para auditoria    |
//| através do relatório de clientes/forncedores                       |
//+--------------------------------------------------------------------+

//+--------------------------------------------------------------------+
//| Efetua uma busca pelo último elemento adicionado para este cliente |
//| e loja no dia. Isto é necessário, pois para o mesmo cliente + loja |
//| podem ocorrer N alterações na mesma data.                          |
//+--------------------------------------------------------------------+

cFilAIF := xFilial("AIF")

Do Case 
	Case cAlias == "SA1"

		cFilAlias	:= xFilial("SA1")
		cFornec   	:= SA1->A1_COD
		cLoja     	:= SA1->A1_LOJA
	
	Case cAlias == "SA2"
		
		cFilAlias	:= xFilial("SA2")
		cFornec   	:= SA2->A2_COD
		cLoja     	:= SA2->A2_LOJA
		
End Case 

cAliasQry := GetNextAlias()
cDataAlt  := DtoS(Date())

IIF( Select( cAliasQry ) > 0, (cAliasQry)->( DbCloseArea() ), Nil)

	
cQuery := " SELECT "
cQuery += "    R_E_C_N_O_  "
cQuery += " FROM " + RetSqlName("AIF") + " AIF "
cQuery += " WHERE "
cQuery += "    AIF.AIF_FILIAL 		= '"+  cFilAIF 		+ "' "
cQuery += "    AND AIF.AIF_FILTAB 	= '"+  cFilAlias	+ "' "
cQuery += "    AND AIF.AIF_TABELA 	= '"+  cAlias 		+ "' "
cQuery += "    AND AIF.AIF_CODIGO 	= '"+  cFornec 		+ "' "
cQuery += "    AND AIF.AIF_LOJA 	= '"+  cLoja 		+ "' "
cQuery += "    AND AIF.AIF_DATA 	= '"+  cDataAlt		+ "' "
cQuery += "    AND AIF.D_E_L_E_T_ 	= ''"
cQuery += "    AND AIF.AIF_HORA IN  (SELECT " 
cQuery += " 						    MAX(AIF_HORA) AIF_HORA "
cQuery += " 						 FROM " + RetSqlName("AIF") + " AIF2 "
cQuery += " 						 WHERE "
cQuery += " 						    AIF2.AIF_FILIAL 	= '"+  cFilAIF 		+ "' "
cQuery += " 						    AND AIF2.AIF_FILTAB = '"+  cFilAlias	+ "' "
cQuery += " 						    AND AIF2.AIF_TABELA = '"+  cAlias 		+ "' "
cQuery += " 						    AND AIF2.AIF_CODIGO = '"+  cFornec 		+ "' "
cQuery += " 						    AND AIF2.AIF_LOJA 	= '"+  cLoja 		+ "' "
cQuery += " 						    AND AIF2.AIF_DATA 	= '"+  cDataAlt		+ "' "
cQuery += " 						    AND AIF2.D_E_L_E_T_ = '' ) "
cQuery += " ORDER BY R_E_C_N_O_ "
		

DbUseArea(/*lNewWorkArea*/,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,/*lShared*/,/*lReadOnly*/)	

(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(Eof())

	DbSelectArea("AIF")
	cUserName	:= AllTrim(Upper(UsrFullName(RetCodUsr()))) 
	While !(cAliasQry)->(Eof())

		AIF->(dbGoTo((cAliasQry)->R_E_C_N_O_))
		
		cCampo		:= AllTrim(AIF->AIF_CAMPO)
		cTipo 		:= TamSX3(cCampo)[3]

		//-- Ignora gravação de campos do tipo MEMO "M"
		If ( cTipo <> "M" )
		
			cPicture 	:= PesqPict( cAlias, cCampo)
			xValue		:= AllToChar( (cAlias)->&(cCampo), cPicture, cTipo == "D" )
			xValue 		:= IIF( cTipo == "C", AllTrim(xValue), xValue )

			RecLock("AIF", .F.)
			AIF->AIF_XCONTE := xValue			// Conteúdo atual do campo (que o usuário acabou de alterar)
			AIF->AIF_XUSUAR := cUserName		// Nome do usuário que efetuou a alteração.
			AIF->(MsUnlock())

		EndIf 

		(cAliasQry)->(DbSkip())

	EndDo
EndIf 

(cAliasQry)->(DbCloseArea())


RestArea(aArea)
 
Return( .T. )
