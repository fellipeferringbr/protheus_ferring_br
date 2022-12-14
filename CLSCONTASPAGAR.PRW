#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"


#DEFINE MOV_BANC_SEM_CHEQUE .T.


/**************************************************************************************************
Fun??o:
ClsContasPagar

Descri??o:
Dummy function.
**************************************************************************************************/
User Function ClsContasPagar()
Return Nil


/**************************************************************************************************
Classe:
ClsContasPagar

Autor:
Tiago Bandeira Brasiliano

Data:
03/02/2018

Descri??o:
Classe respons?vel por efetuar a cria??o (via ExecAuto) dos t?tulos de Contas a Pagar.
**************************************************************************************************/
Class ClsContasPagar From ClsExecAuto

Data cPrefixo
Data cNumero
Data cParcela
Data cTipo
Data cFornece
Data cLoja
Data cBanco
Data cAgencia
Data cConta
Data cXAdiExp
Data lExpenseMobi
Data aDadosBco
Data cErrorLog

Method New()
Method AddCabec(cCampo, xValor)
Method Gravacao(nOpcao, Transacao)
Method ClassificaNFE(cNota, cSerie, cFornece, cLojaFor)
	
EndClass


/**************************************************************************************************
Classe:
New

Autor:
Tiago Bandeira Brasiliano

Data:
03/02/2018

Descri??o:
Construtor da classe.
**************************************************************************************************/
Method New() Class ClsContasPagar

_Super:New()

::aTabelas     := {"SE2","SA2","SE4"}
::cPrefixo     := Space(TamSX3("E2_PREFIXO")[1])
::cNumero      := Space(TamSX3("E2_NUM"    )[1])
::cParcela     := Space(TamSX3("E2_PARCELA")[1])
::cTipo        := Space(TamSX3("E2_TIPO"   )[1])
::cFornece     := Space(TamSX3("E2_FORNECE")[1])
::cLoja        := Space(TamSX3("E2_LOJA"   )[1])
::cBanco       := Space(TamSX3("A6_COD"    )[1])
::cAgencia     := Space(TamSX3("A6_AGENCIA")[1])
::cConta       := Space(TamSX3("A6_NUMCON" )[1])
::cXAdiExp     := Space(TamSX3("E2_XADIEXP")[1])
::lExpenseMobi := .F.
::aDadosBco    := {}
::cFileLog     := "ClsContasPagar.LOG"
::cErrorLog    := ""

Return Self


/**************************************************************************************************
Classe:
AddCabec

Autor:
Tiago Bandeira Brasiliano

Data:
03/02/2018

Descri??o:
Adiciona os campos do t?tulo.
**************************************************************************************************/
Method AddCabec(cCampo, xValor) Class ClsContasPagar

If AllTrim(cCampo) == "E2_PREFIXO"
	::cPrefixo := xValor
ElseIf Alltrim(cCampo) == "E2_NUM"
	::cNumero  := xValor
ElseIf Alltrim(cCampo) == "E2_PARCELA"
	::cParcela := xValor
ElseIf Alltrim(cCampo) == "E2_TIPO"
	::cTipo	   := xValor
ElseIf Alltrim(cCampo) == "E2_FORNECE"
	::cFornece := xValor
ElseIf Alltrim(cCampo) == "E2_LOJA"
	::cLoja    := xValor
ElseIf AllTrim(cCampo) == "E2_XADIEXP"
	::cXAdiExp   := xValor
	::lExpenseMobi := .T.
ElseIf Alltrim(cCampo) == "AUTBANCO"
	::cBanco   := xValor
ElseIf Alltrim(cCampo) == "AUTAGENCIA"
	::cAgencia := xValor
ElseIf Alltrim(cCampo) == "AUTCONTA"
	::cConta   := xValor
EndIf

_Super:AddCabec(cCampo, xValor)

Return Nil


/**************************************************************************************************
Classe:
Gravacao

Autor:
Tiago Bandeira Brasiliano

Data:
03/02/2018

Descri??o:
Efetua a grava??o das informa??es.
**************************************************************************************************/
Method Gravacao(nOpcao, cTransacao) Class ClsContasPagar

Local dDataBackup := dDataBase
Local lRetorno    := .T.
Local cAliasTmp   := GetNextAlias()
Local bErroNovo   := {|| }
Local bErroOrig   := {|| }
Local lErrorLog   := .F.
Local aPergs      := {}

Private lMsErroAuto := .F.

::cChave := ::cFilGrv + ::cPrefixo + ::cNumero + ::cParcela + ::cTipo + ::cFornece + ::cLoja

::SetEnv(1, "FIN")

If !Empty(::dEmissao)
	dDataBase := ::dEmissao
EndIf

DbSelectArea("SE2")
SE2->(DbOrderNickname("XADIEXP")) // FILIAL + XADIEXP
If ::lExpenseMobi .And. SE2->(MsSeek(xFilial("SE2") + ::cXAdiExp))
	lRetorno := .F.
	::cMensagem	:= "O Adiantamento n?mero '" + ::cXAdiExp + " j? foi integrado no t?tulo n?mero '" + SE2->E2_PREFIXO + "/" + SE2->E2_NUM + "' [Prefixo/N?mero] e portanto n?o ser? reprocessado."
EndIf

If lRetorno
	
	DbSelectArea("SE2")  // Cabe?alho das notas de entrada
	SE2->(DbSetOrder(1)) // FILIAL, PREFIXO, NUM, PARCELA, TIPO, FORNECE, LOJA
	
	//+------------------------+
	//| Efetua pr?-valida??es  |
	//+------------------------+
	If nOpcao == 3 .Or. nOpcao == 4 // 3=Inclus?o ; 4=Altera??o
	
		If nOpcao == 3 .And. Empty(::cNumero)
	
			//+---------------------------------------------------+
			//| Obt?m o pr?ximo n?mero de titulo do fornecedor    |
			//+---------------------------------------------------+
			BEGINSQL ALIAS cAliasTmp
			
				%NoParser%
				
				SELECT MAX(E2_NUM) ULTIMO
				FROM %Table:SE2% SE2
				WHERE SE2.%NotDel%
				  AND SE2.E2_FILIAL = %xFilial:SE2%
				  AND SE2.E2_PREFIXO = %Exp:Self:cPrefixo%
				  AND SE2.E2_FORNECE = %Exp:Self:cFornece%
				  AND SE2.E2_LOJA = %Exp:Self:cLoja%
				  
			ENDSQL
			
			DbSelectArea(cAliasTmp)
			(cAliasTmp)->(DbGoTop())
			If !(cAliasTmp)->(EoF())
				::cNumero := Soma1((cAliasTmp)->ULTIMO)
			EndIf
			(cAliasTmp)->(DbCloseArea())
			
			::AddCabec("E2_NUM", ::cNumero)
			::cChave := ::cFilGrv + ::cPrefixo + ::cNumero + ::cParcela + ::cTipo + ::cFornece + ::cLoja
	
		EndIf
		
		If Empty(::dEmissao)
		
			::dEmissao := dDatabase
			::AddCabec("E2_EMISSAO", ::dEmissao)
			
		EndIf
		
		If !Empty(::cBanco) .And. !Empty(::cAgencia) .And. !Empty(::cConta)
			::aDadosBco := {::cBanco, ::cAgencia, ::cConta,,,, MOV_BANC_SEM_CHEQUE}
		EndIf
		
		If Empty(::cNumero) .And. nOpcao == 4
		
			lRetorno    := .F.
			::cMensagem := "O n?mero do t?tulo n?o foi informado. Este campo ? obrigat?rio!"
			
		ElseIf Empty(::cFornece)
		
			lRetorno    := .F.
			::cMensagem := "O c?digo do fornecedor n?o foi informado. Este campo ? obrigat?rio!" 
			
		ElseIf Empty(::cLoja)
		
			lRetorno    := .F.
			::cMensagem := "A loja do fornecedor n?o foi informado. Este campo ? obrigat?rio!" 
			  
		ElseIf nOpcao == 3 .And. SE2->(MsSeek(xFilial("SE2") + ::cPrefixo + ::cNumero + ::cParcela + ::cTipo + ::cFornece + ::cLoja))
				
			lRetorno    := .F.
			::cMensagem	:= "O t?tulo '" + ::cPrefixo + "/" + ::cNumero + "' [Prefixo/N?mero] j? foi cadastrada para o fornecedor '" + ::cFornece + "/" + ::cLoja + "' [C?digo/Loja]"
		
		ElseIf nOpcao == 4 .And. !SE2->(MsSeek(xFilial("SE2") + ::cPrefixo + ::cNumero + ::cParcela + ::cTipo + ::cFornece + ::cLoja))
				
			lRetorno 	:= .F.
			::cMensagem	:= "O t?tulo '" + ::cPrefixo + "/" + ::cNumero + "' [Prefixo/N?mero] n?o foi localizada para o fornecedor '" + ::cFornece + "/" + ::cLoja + "' [C?digo/Loja]"
						
		EndIf
		
	Else
	
		lRetorno    := .F.
		::cMensagem := "Tipo de Opera??o inv?lida"
		
	EndIf
	
	If lRetorno
	
		//+------------------------+
		//| Controle de Transacao. |
		//+------------------------+
		Begin Transaction
		
			bErroNovo   := {|e| TrataErrorLog(Self, e) }    // Defino um novo bloco de c?digo para tratamento de erro personalizado
			bErroOrig   := ErrorBlock(bErroNovo)            // Atribuo meu tratamento personalizado de erro e salvo o original (para voltar posteriormente)
		
			Begin Sequence
			
				//+----------------------------------------------------+
				//| Altero os par?metros relacionados ao adiantamento  |
				//| e fa?o a persist?ncia dos mesmos antes da ExecAuto |
				//+----------------------------------------------------+
				Pergunte("FIN050", .F.,,,,, @aPergs)
				MV_PAR05 := 2  // Gera Cheque Para Adiantamento = N?o
				MV_PAR09 := 2  // Gera Movimento Sem Cheque = N?o
				__SaveParam("FIN050", aPergs)
				
				//+----------------------------------------------------+
				//| Gravacao do T?tulo no Contas a Pagar.              |	
				//+----------------------------------------------------+
				MSExecAuto({|a, b, c, d, e| FINA050(a, b, c, d, e)}, ::aCabec, , nOpcao,, ::aDadosBco)
				
				If !Empty(Self:cErrorLog)
					Break
				EndIf
				
			Recover
			
				lErrorLog := .T.
				
			End Sequence
			
			ErrorBlock(bErroOrig)
			
			If lErrorLog
			
				lRetorno    := .F.
				
				If ::lExibeTela
					Alert(::cErrorLog)
				EndIf
				
				::cMensagem := ::cErrorLog
				 
				DisarmTransaction()
					
			ElseIf lMsErroAuto
			
				lRetorno := .F.
					
				If ::lExibeTela
					If !(IsBlind())   // COM INTERFACE GR?FICA
                        MostraErro() // TELA
                    Else // EM ESTADO DE JOB
                      ::cMensagem := MostraErro(::cPathLog, ::cFileLog)
                    EndIf
				EndIf
				
				
				
				DisarmTransaction()
			
			Else
			
				ConfirmSX8()
				
				::cNumero := SE2->E2_NUM
				
				// Define as informa??es de Retorno:
				::SetRegRetorno("HEADER", "SE2")
				::SetCampoRetorno("E2_FILIAL" , xFilial("SCJ"))
				::SetCampoRetorno("E2_PREFIXO", ::cPrefixo    )
				::SetCampoRetorno("E2_NUM"    , ::cNumero     )
				::SetCampoRetorno("E2_TIPO"   , ::cTipo       )
				::SetCampoRetorno("E2_PARCELA", ::cParcela    )
				::SetCampoRetorno("E2_FORNECE", ::cFornece    )
				::SetCampoRetorno("E2_LOJA"   , ::cLoja       )
				::cMensagem := "Manuten??o do T?tulo de Contas a Pagar (SE2) efetuada com sucesso: " + ::cPrefixo + "/" + ::cNumero
							
			EndIf
		
		//+------------------------+
		//| Encerra a Transacao.   |
		//+------------------------+
		End Transaction
		
	EndIf
	
EndIf

dDataBase := dDataBackup

::SetEnv(2, "FAT")

Return lRetorno


/**************************************************************************************************
Fun??o:
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
03/02/2018

Descri??o:
Fun??o utilizada para sobrepor o tratamento de erro padr?o do sistema (error handler).
Isto ? feito para evitar que um error log interrompa o processamento de uma rotina executada via
job.
**************************************************************************************************/
Static Function TrataErrorLog(oNota, oErrorLog)

Local lRet    := .F.
Local cDescri := oErrorLog:Description			
Local cStack  := oErrorLog:ErrorStack

If Empty(oNota:cErrorLog) .And. !Empty(cDescri)
	oNota:cErrorLog := cDescri + CRLF + cStack
	lRet := .T.
EndIf

Return lRet
