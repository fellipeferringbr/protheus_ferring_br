#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FWMVCDef.ch"

/*/{Protheus.doc} CRMA980
description Compatibiliza??o dos pontos de entradas da Rotinas MATA030 para MVC
@type function
@version R12.1.33
@author Antonio
@since 04/04/2022
@return xret
/*/

User Function CRMA980()
	Local aParam    := PARAMIXB
	Local xRet      := .T.
	Local oObject   := aParam[1] //Objeto do formul?rio ou do modelo, conforme o caso
	Local cIdPonto  := aParam[2] //ID do local de execu??o do ponto de entrada(se ?  p?s valida??o, pr? valida??o, commit, etc)
	Local cIdModel  := aParam[3] //ID do formul?rio

	//Captura a opera??o executada na aplica??o
	Local nOperation    := oObject:GetOperation()
	/*
	1- pesquisar
	2- visualizar
	3- incluir
	4- alterar
	5- excluir
	6- outras fun??es
	7- copiar
	*/
	IF cIdPonto <> Nil //(Se ele clicar em Incluir/Alterar/Excluir/Visualizar)

		IF cIdPonto == 'MODELCOMMITNTTS' //"Chamada ap?s a grava??o total do modelo e FORA da transa??o

			//Ajuste e Compatibiliza??o do Fonte M030INC.prw para MVC.
			//AJUSTE AVSYSTEtot
			//
			If nOperation== 3    /// Inclusao
				IF SA1->A1_XALOLOT = "1"
					DbSelectArea("SZA")
					SZA->(DBSETORDER(1))
					IF !SZA->(DBSEEK(XFILIAL("SZA")+SA1->A1_COD+SA1->A1_LOJA))

						RECLOCK("SZA",.T.)
						SZA->ZA_FILIAL  := XFILIAL("SZA")
						SZA->ZA_CLIENTE := SA1->A1_COD
						SZA->ZA_LOJA    := SA1->A1_LOJA
						SZA->ZA_NOME    := SA1->A1_NOME
						SZA->ZA_CGC  	:= SA1->A1_CGC
						SZA->ZA_DTGERA  := DATE()
						MSUNLOCK()
						//
						//GRAVA??O DO SZB - Copia a Regra Padr?o
						//

						cQuery := "SELECT * FROM "+RetSqlName("SZB")+" ZB "
						cQuery += "WHERE ZB.D_E_L_E_T_ = '' "
						cQuery += "AND ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB.ZB_CLIENTE = '999999' AND ZB.ZB_LOJA = '99' "
						cQuery += "ORDER BY ZB_PRODUTO "
						DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSZB', .F.,.T.)


						WHILE TSZB->(!EOF())

							//AADD(aColsEx,{TSZB->ZB_PRODUTO,TSZB->ZB_DESCRI,TSZB->ZB_RGPUBLI,TSZB->ZB_RGPRIVA,.F.})
							RECLOCK("SZB",.T.)
							SZB->ZB_FILIAL  := XFILIAL("SZB")
							SZB->ZB_CLIENTE := SA1->A1_COD
							SZB->ZB_LOJA    := SA1->A1_LOJA
							SZB->ZB_PRODUTO := TSZB->ZB_PRODUTO
							SZB->ZB_DESCRI  := TSZB->ZB_DESCRI
							SZB->ZB_RGPUBLI := TSZB->ZB_RGPUBLI
							SZB->ZB_RGPRIVA := TSZB->ZB_RGPRIVA
							MSUNLOCK()

							TSZB->(DBSKIP())
						ENDDO
						TSZB->(DBCLOSEAREA())

					EndIf
				EndIf
			ElseIf nOperation== 4 // Altera??o

				If SA1->(FieldPos("A1__CONGEL")) > 0 .AND. SA1->A1__CONGEL <> "1"

					Reclock("SA1", .F.)
					SA1->A1_X_DATA := DDATABASE
					SA1->(MsUnlock())

					//---------------------------------------------------------------
					// Rotina para bloquear cliente
					// e disparar e-mails aos respons?veis pela permis?o do cadastro
					//---------------------------------------------------------------
					If !( FwIsInCallStack("U_FFATA015") )
						U_BlqCliente()
					EndIf

					U_SetLogAIF("SA1") //-- Registra altera??es na AIF

				EndIf

			EndIf

		ElseIf cIdPonto == "MODELCANCEL" //Ao ser acionado o bot?o de cancelamento

			// N?o grava log se o usu?rio cancelou a inclus?o
			U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

			xRet := .T.
			// Ajuste e Compatibili??o da rotina M030EXC.PRW Para MVC. Quando a Opera??o ? exclus?o.
		ElseIf cIDPonto == 'FORMPOS'

		    IF nOperation = 5 //Exclus?o
			   U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

			// Ajuste e Compatibili??o da rotina M030ALT.PRW Para MVC. Quando a Opera??o ? altera??o.
		    ELSEIF nOperation = 4 // Altera??o

				If SA1->(FieldPos("A1__CONGEL")) > 0 .AND. SA1->A1__CONGEL == "1"
					FwAlertWarning("Este cliente est? congelado por duplicidade de CNPJ/CPF e n?o pode ser Alterado.","Cliente congelado")
					xRet := .F.
				Else
					U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
				EndIf

				If xRet
					If ! U_FE_A1VldCGC(.F.)
						xRet := .F.
					Endif
				Endif

			ElseIf nOperation == 3 // Inclus?o
				// Verifica se o CPF/CNPJ do cliente j? existe na base de dados e n?o permitir? nova inclus?o.
				/*
				If ExistChav("SA1",cFilial+M->A1_CGC,3,.F.)
					MsgAlert("O CNPJ/CPF "+M->A1_CGC+" j? existe e n?o pode ser inserido novamente!","Duplicidade CNPJ/CPF")
					xRet := .F.
				EndIf
				*/
				If ! U_FE_A1VldCGC(.T.)
					xRet := .F.
				Endif
			EndIf

		ElseIf cIDPonto == 'MODELVLDACTIVE'

		/*ElseIf cIdPonto == 'BUTTONBAR'
                xRet:={}
                 // -------------------------------------------------------------------
                //-- Rotina -> Cadastro de enderecos de entrega x clientes
                // -------------------------------------------------------------------
                Aadd(xRet,{"End. Entrega"    , "U_RFATA010()"    , 0 , 4,0,NIL})

                // -------------------------------------------------------------------
                // Rotina -> Realiza desbloqueio ou bloqueio do cliente selecionado
                // -------------------------------------------------------------------
                Aadd(xRet,{"Libera Cliente"  , "U_FFATA015('2')" , 0 , 4,0,NIL})
                Aadd(xRet,{"Bloqueia Cliente", "U_FFATA015('1')" , 0 , 4,0,NIL})
         */
		EndIf
	Endif

Return xRet
User Function BlqCliente()
Local nXy
Local aSx3:={}

Private _lValid  := .F.
Private _cCpoSX3 := ""
Private aCampos   := {}

Private _cArea   := GetArea()


If SA1->A1_MSBLQL == "2"

    If ALTERA
        RecLock("SA1", .F.)
        SA1->A1_MSBLQL := "1"
        MsgInfo("Esta altera??o bloqueou o cliente. Aguarde libera??o.")
        SA1->(msUnlock() )
    Endif


	aSx3:=FWSX3Util():GetAllFields( "SA1" , .F. )

    For nXy:=1 To Len(aSx3)

		_cCpoSX3:= aSx3[nXy]

		If SA1->&_cCpoSX3 <> M->&_cCpoSX3
			_lValid:=.T.

			If FWSX3Util():GetFieldType( aSx3[nXy] )  == "C"
				aAdd(aCampos, {GetSx3Cache(aSx3[nXy],"X3_TITULO"), FWSX3Util():GetDescription( aSx3[nXy] ) , SA1->&_cCpoSX3,          Alltrim(M->&_cCpoSX3) })
			ElseIf FWSX3Util():GetFieldType( aSx3[nXy] )  == "N"
				aAdd(aCampos, {GetSx3Cache(aSx3[nXy],"X3_TITULO"), FWSX3Util():GetDescription( aSx3[nXy] ), STR(SA1->&_cCpoSX3),     cValToChar(M->&_cCpoSX3)})
			ElseIf FWSX3Util():GetFieldType( aSx3[nXy] )  == "D"
				aAdd(aCampos, {GetSx3Cache(aSx3[nXy],"X3_TITULO"), FWSX3Util():GetDescription( aSx3[nXy] ), DTOC(SA1->&_cCpoSX3),    DTOC(M->&_cCpoSX3)})
			ElseIf FWSX3Util():GetFieldType( aSx3[nXy] )  == "M"
				aAdd(aCampos, {GetSx3Cache(aSx3[nXy],"X3_TITULO"), FWSX3Util():GetDescription( aSx3[nXy] ), MEMOREAD(SA1->&_cCpoSX3),MEMOREAD(M->&_cCpoSX3)})
			EndIf

		EndIf

		_cCpoSX3 := ""
	Next
    // Alerta usu?rios sobre altera??es no Cadastro de Clientes
    If _lValid == .T.

        MsgRun(PadC("Aguarde. Notificando Altera??o!",100),, {|| CursorWait(),FMail9b(aCampos),CursorArrow()})

    EndIf

EndIf

RestArea(_cArea)

Return .T.
/*/
_____________________________________________________________________________
?????????????????????????????????????????????????????????????????????????????
??+---------+------------------+-------------------------+----------------+??
???   ? Fun??o: FMail9   ? Autor: Leandro Silva   ? Data: 12/10/08 ???
??+---------+------------------+-------------------------+----------------+??
???Descri??o? Envia e-mail para os destinat?rios						  ???
??+---------+-------------------------------------------------------------+??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
Static Function FMail9b(aCampos)

Local _cBody     := ""
Local cItens	 := ""
Local _cSerMail	 := AllTrim(GetMV("MV_RELSERV"))
Local _cConta  	 := Alltrim(GetMV("MV_RELACNT"))
Local _cSenha	 := AllTrim(GetMV("MV_RELPSW"))
Local _nTimeOut  := GetMv("MV_RELTIME")

Local _lEnviado	 := .F.
Local _lConectou := .F.
Local _cMailError:= ""
Local _cTitulo   := OemtoAnsi("Alerta de Altera??o do Cadastro de Clientes")
Local _cDest     := GetMailDest()
Local _cDestcco  := ""
Local nI         := 0
Local _cCor      := "white"

_cBody += "<p align=left><b><font face=Verdana size=3 color=#336699>"
_cBody += "ALTERA??O DO CADASTRO DE Clientes"
_cBody += "</b></font><br><br><br>"


_cBody += "<p align=left><b><font face=Verdana size=1 color=#336699>"
_cBody += "USU?RIO: "
_cBody += "<font face=Verdana size=1 color=#000080>"
_cBody += Upper(Substr(cUsuario,7,15))   // ALTERADO IUSPA DEVIDO ERRO DE COMPILA??O


_cBody += "<p align=left><b><font face=Verdana size=1 color=#336699>"
_cBody += "DATA E HORA: "
_cBody += "<font face=Verdana size=1 color=#000080>"
_cBody += DToC(date()) + " - " + Time()  // ALTERADO IUSPA DEVIDO ERRO DE COMPILA??O


_cBody += "<p align=left><b><font face=Verdana size=1 color=#336699>"
_cBody += "CLIENTE: "
_cBody += "<font face=Verdana size=1 color=#000080>"
_cBody += AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_NOME)   // ALTERADO IUSPA DEVIDO ERRO DE COMPILA??O


_cBody += "<p align=left><b><font face=Verdana size=1,5 color=#000080>"
_cBody += "<br><br>RELA?AO DE CAMPOS ALTERADOS"
_cBody += "</b></font><br><br>"

For nI := 1 To Len(aCampos)

	cItens += "<tr>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(aCampos[nI][1])) + "</td>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(aCampos[nI][2])) + "</td>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(aCampos[nI][4])) + "</td>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(aCampos[nI][3])) + "</td>"

	cItens += "</tr>"

	If AllTrim(_cCor) == "white"
		_cCor:="#E0EEEE"
	Else
   		_cCor:= "white"
   	EndIf

Next nI

_cBody += "<table border='0' align='center' cellpadding='1' cellspacing='1' bgColor=#ffffff bordercolor='#000000' width='100%'> "
_cBody += " <tr>"
_cBody += "   <td align='center' width='12%' bgcolor='#336699'> "
_cBody += "   <font size='1' color='white' face='Arial'><b>CAMPO</b></font></td>"

_cBody += "   <td align='center' width='12%' bgcolor='#336699'> "
_cBody += "   <font size='1' color='white' face='Arial'><b>DESCRI??O</b></font></td>"

_cBody += "   <td align='center' width='12%' bgcolor='#336699'>"
_cBody += "   <font size='1' color='white' face='Arial'><b>ANTES</b></font></td>"

_cBody += "   <td align='center' width='12%' bgcolor='#336699'>"
_cBody += "   <font size='1' color='white' face='Arial'><b>DEPOIS</b></font></td>"

_cBody += "</tr>"
_cBody += cItens
_cBody += "</table> <br>"



lSendMail	:= U_SendMail( /*cFrom*/, _cTitulo, _cBody, _cDest, /*cCC*/, /*cCopyOcult*/, /*cAttach*/, /*lAuto*/ )




// CONNECT SMTP SERVER _cSerMail ACCOUNT _cConta PASSWORD _cSenha Result lConectou

// SEND MAIL FROM AllTrim(_cConta) ;
// To AllTrim(_cDest);
// SUBJECT	AllTrim(_cTitulo) ;
// Body _cBody FORMAT TEXT RESULT _lEnviado

// If !(_lEnviado)
// 	GET MAIL ERROR _cMailError
// 	Alert(_cMailError)
// EndIf

// DISCONNECT SMTP SERVER

Return .T.


Static Function GetMailDest()

Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cMailDest := ""


BEGINSQL ALIAS cAliasQry
    SELECT
        ZBL_CODUSR
    FROM
        %TABLE:ZBL% ZBL
    WHERE
        ZBL.ZBL_FILIAL  = %xFILIAL:ZBL%     AND
        ZBL.ZBL_TABELA  =  'SA1'            AND
        ZBL.ZBL_PERLIB  =   '1'             AND
        ZBL.%NOTDEL%
ENDSQL


While ( cAliasQry )->( !Eof() )

    cAux        := UsrRetMail( (cAliasQry)->ZBL_CODUSR )
    cAux        := AllTrim(cAux)

    If !Empty(cAux)
        cMailDest   += cAux + ";"
    EndIf

    ( cAliasQry )->( DbSkip() )
EndDo

( cAliasQry )->( DbCloseArea() )


RestArea( aArea )

Return( cMailDest )
User Function CRM980MDEF()
Local aRotina := {}
//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Fun??o de Usu?rio
// [n][3] - Opera??o (1-Pesquisa; 2-Visualiza??o; 3-Inclus?o; 4-Altera??o; 5-Exclus?o)
// [n][4] - Acesso relacionado a rotina, se esta posi??o n?o for informada nenhum acesso ser? validado
//----------------------------------------------------------------------------------------------------------
//If FWIsInCallStack("CRMA980BRA")
	// -------------------------------------------------------------------
	//-- Rotina -> Cadastro de enderecos de entrega x clientes
	// -------------------------------------------------------------------
	Aadd(aRotina,{"End. Entrega"    , "U_RFATA010()"    , 0 , 4,0,NIL})
	// -------------------------------------------------------------------
	// Rotina -> Realiza desbloqueio ou bloqueio do cliente selecionado
	// -------------------------------------------------------------------
	Aadd(aRotina,{"Libera Cliente"  , "U_FFATA015('2')" , 0 , 4,0,NIL})
	Aadd(aRotina,{"Bloqueia Cliente", "U_FFATA015('1')" , 0 , 4,0,NIL})
//EndIf
Return( aRotina )
