#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

/*/
??????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??rograma  ?T100LOK  ?Autor ?Renato Takao          ?Data ?AR/09    ??
???????????????????????????????????????
??escri?o ?onto de entrada valida   itens da NFE - mata103            ??
??         ?                                                           ??
???????????????????????????????????????
??etorno   ?/F                                                         ??
???????????????????????????????????????
??arametros?enhum                                                      ??
??         ?                                                           ??
???????????????????????????????????????
??  DATA   ?Programador   ?anutencao efetuada                         ??
???????????????????????????????????????
??         ?              ?                                           ??
???????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
/*/
User Function MT100LOK()	
Local lRet          := .T. 
Local cArmazem      := aCols[n,GdFieldPos("D1_LOCAL")]  
Local cCfOp         := aCols[n,GdFieldPos("D1_CF")] 
Local cLoteCtl      := aCols[n,GdFieldPos("D1_LOTECTL")] 
Local cProduto      := aCols[n,GdFieldPos("D1_COD")]   
Local cTES          := aCols[n,GdFieldPos("D1_TES")]    
Local dDtFab        := aCols[n,GdFieldPos("D1_DTFABR")] 
Local cOper         := GdFieldGet("D1_OPER",n) 
Local cForn         := GdFieldGet("D1_FORNECE",n) 
Local nQuant        := GdFieldGet("D1_QUANT",n) 
Local cUF           := CUFORIG
Local dDtVen        := aCols[n,GdFieldPos("D1_DTVALID")]   
Local cLotctl       := Posicione(("SB1"),1,xFilial("SB1")+cProduto,"SB1->B1_RASTRO")
Local cEstoq        := Posicione(("SF4"),1,xFilial("SF4")+cTES,"SF4->F4_ESTOQUE")  
Local nIntDa        := Posicione(("SB1"),1,xFilial("SB1")+cProduto,"SB1->B1_XINTDA")   
Local dDtMinf       := GetMv("AC_DTMLOF")   
Local dDtMinV       := GetMv("AC_DTMLOV")  
Local cTipoDoc      := cTipo
Local cProd         := GdFieldGet("D1_COD",n)
Local cES_DEVARM    := SuperGetMv( "ES_DEVARM", .T., "55" ) 
Local cES_DIMARM    := SuperGetMv( "ES_DIMARM", .T., "50" )
Local cES_IMPFORN   := SuperGetMv("ES_IMPFORN")
Local cFornece      :=  CA100FOR
Local cMsg          := "As notas de devolução devem ser feitas para o armazem presente no parâmetro ES_DEVARM" + CRLF + "Conteudo atual do par?etro: " + cES_DEVARM
Local cMsg2         := "As notas de Importação devem ser feitas para o armazem presente no parâetro cES_DIMARM" + CRLF + "Conteudo atual do par?etro: " + cES_DIMARM
Local cMensagem     := "Este produto ou armazem não está validado, armazens validados: " + cES_DIMARM
Local cMensagem2    := "Este armaz? n? est?validado para esta opera?o, armazens validados: " + cES_DIMARM
Local cInfo         := ""
Local lDeleted      := aCols[n, Len(aCols[n])]
Local cTpOperImp    := AllTrim(GetNewPar("ES_TPOPIMP", "05|07|")) // Tipos de opera?o de importa?o
Local cTpOperComp   := AllTrim(GetNewPar("ES_TPOPCOM", "08|"   )) // Tipos de opera?o de complemento de importa?o importa?o
Local cConta		:= ""
Local cCCusto		:= "" 		
Local cRateio		:= ""
Local lProcEIC		:= .F.
local nI
If FunName() == "A103Devol"	
	Return .T.
EndIf

//INICIO TRATAMENTO PARA IMPORTA?O E DEVOLU?O.
//Adicionado tratamento para importa?o por mais armaz?s al? do 50. por Leandro Fini - Farinelli Sistemas em 06/06/16
If cTipoDoc <> "D"  .And. (Substr(cCfOp,1,1) == "3") //importa?o
	If (AllTrim(cArmazem) $ cES_DIMARM)
		If cProd > "50.000.000" .AND. cProd < "59.999.999" .And. cArmazem <> "50" .AND. Alltrim(cEstoq) == 'S' //armaz? da qualidade, produto de venda.
			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		ElseIf cProd > "25.000.000" .AND. cProd < "25.999.999" .AND. cArmazem <> "50" .AND. Alltrim(cEstoq) == 'S'  //amostra gr?is
   			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		ElseIf cProd > "70.000.000" .AND. cProd < "79.999.999" .AND. cArmazem <> "75" .AND. Alltrim(cEstoq) == 'S'  //armaz? material promocional
   			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		ElseIf cProd > "15.000.000" .AND. cProd < "15.999.999" .AND. cArmazem <> "66" .AND. Alltrim(cEstoq) == 'S' //armaz? padr?s para qualidade
   			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		EndIf
	Else
		lRet := .F.
		MsgInfo(cMensagem2, "Aviso") 
	EndIf
EndIf

//Adicionado tratamento para devolu?es onde valida os produtos para os respectivos armaz?s por Leandro Fini - Farinelli Sistemas em 06/06/2016
If cTipoDoc == "D" .And. (Substr(cCfOp,1,1) == "2") .OR. cTipoDoc == "D" .And. (Substr(cCfOp,1,1) == "1") 
	If (AllTrim(cArmazem) $ cES_DIMARM)
		If cProd > "50.000.000" .AND. cProd < "59.999.999" .And. cArmazem <> "55" .AND. Alltrim(cEstoq) == 'S'  //armaz? da qualidade, produto de venda.
			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		ElseIf cProd > "25.000.000" .AND. cProd < "25.999.999" .AND. cArmazem <> "55" .AND. Alltrim(cEstoq) == 'S'  //amostra gr?is
   			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		ElseIf cProd > "70.000.000" .AND. cProd < "79.999.999" .AND. cArmazem <> "55" .AND. Alltrim(cEstoq) == 'S'   //armaz? material promocional
   			lRet := .F.
			MsgInfo(cMensagem, "Aviso")
		ElseIf cProd > "15.000.000" .AND. cProd < "15.999.999" .AND. cArmazem <> "55" .AND. Alltrim(cEstoq) == 'S'  //armaz? padr?s para qualidade
   			lRet := .F.
			MsgInfo(cMensagem, "Aviso")		
		EndIf
	Else
		lRet := .F.
		MsgInfo(cMensagem2, "Aviso") 			
	EndIf
EndIf
//FIM TRATAMENTO DE IMPORTA?O E DEVOLU?O


//INICIO TRATAMENTO PARA TIPO DE OPERA?ES DE IMPORTA?O (Atualmente 05 e 07) - IMPORTACAO E COMPLEMENTO DE IMPORTACAO (Atualmente a 08) 
//POR LEANDRO FINI - FARINELLI SISTEMAS - 24/06/16
If lRet .And. cTipoDoc == "N" .AND. !(cOper $ cTpOperImp) .AND. cUF == "EX" .AND. cFornece $ cES_IMPFORN
	lRet := .F.
	MsgAlert("Para Importa?o deve-se utilizar algum dos seguintes tipos de opera?o para os fornecedores cadastrados no par?etro ES_IMPFORN: " + cTpOperImp)
EndIf

If lRet .And. cTipoDoc == "C" .AND. !(cOper $ cTpOperComp) .AND. cUF == "EX" .AND. cFornece $ cES_IMPFORN
	lRet := .F.
	MsgAlert("Para complemento de Importa?o deve-se utilizar algum dos seguintes tipos de opera?o para os fornecedores cadastrados no par?etro ES_IMPFORN: " + cTpOperComp)
EndIf
//FIM DE TRATAMENTO DE OPERA?ES DE IMPORTA?O E COMPLEMENTO DE IMPORTA?O

//+-----------------------------------------------------------------+
//| Valida se j?houve entrada do mesmo lote em alguma outra linha. |
//+-----------------------------------------------------------------+
If lRet .And. !lDeleted .And. !Empty(AllTrim(cLoteCtl))

	For nI := 1 To Len(aCols)
	
		If nI <> n .And. !aCols[nI, Len(aCols[nI])]
		
			If cProduto == aCols[nI,GdFieldPos("D1_COD")] .And. cLoteCtl == aCols[nI, GdFieldPos("D1_LOTECTL")]
			
				If cOper $ cTpOperImp
				
					lRet := .F.
					MsgAlert("Atenção! O mesmo numero de lote já foi inserido na linha " + AllTrim(Str(nI)) + " deste documento.")
					
				Else  //ElseIf !l100Auto   RODRIGO - AVSYTEM - FERRING 10/09/18
				
					lRet := MsgYesNo("O mesmo numero de lote já foi inserido na linha " + AllTrim(Str(nI)) + CRLF + "Deseja confirmar a entrada deste lote?", "Atenção")
				
				EndIf
				
			EndIf
			
		EndIf
	
	Next nI

EndIf

//+-----------------------------------------------------------------+
//| Valida se j?houve entrada para este mesmo n?ero de lote antes |
//+-----------------------------------------------------------------+
dbSelectArea("SF4")  // CADASTRO DE TES                                                                    
SF4->(DbSetOrder(1)) // FILIAL + CODIGO
If lRet .And. !lDeleted .And. SF4->(MsSeek(xFilial("SF4") + cTES)) .And.  cTipoDoc <> "D"

	//Busca as informa?es do lote selecionado
	If !Empty(AllTrim(cLoteCtl)) .And. SF4->F4_ESTOQUE == "S" // Se tiver lote e a TES movimenta estoque
	
		If U_FeLoteJaExiste(cLoteCtl, cProduto, "", .F., .T., .F., @cInfo)
			
			If cOper $ cTpOperImp // Segundo solicita?o da Renata, o bloqueio dever?ocorrer apenas para o tipo de opera?o de importa?o (05 e 07 no momento deste desenvolvimento). Para os damais, apenas uma mensagem dever?ser exibida.
				
				lRet := .F.
				MsgAlert("Aten?o! J?houve entrada deste n?ero de lote no sistema." + CRLF + cInfo)
				
			Else
			
				lRet := MsgYesNo("J?houve entrada deste n?ero de lote no sistema." + CRLF + cInfo + "Deseja confirmar a entrada deste lote?", "Aten?o")
			
			EndIf
			
		EndIf
	
	EndIf
	
EndIf
                                                             
//+-----------------------------------------------------------------+
//| Efetua as demais valida?es da nota fiscal de entrada.          |
//+-----------------------------------------------------------------+
If lRet .And. !lDeleted .And. Alltrim(cLotctl) $ ('L,S') .And. Alltrim(cEstoq) == 'S'  
	If Empty(cLoteCtl)
		MsgAlert("Digitar o N?ero do Lote")
		lRet := .F.
	ElseIf Empty(dDtFab)
		MsgAlert("?necess?io digitar a data de fabrica?o para esse Produto e TES" + CRLF)
		lRet := .F.
	ElseIf Empty(dDtVen)         
		MsgAlert("?necess?io digitar a data de vencimento para esse Produto e TES" + CRLF)            
		lRet := .F.
	ElseIf dDtFab < dDtMinf
		MsgAlert("A data de fabrica?o tem que ser superior a "+ DtoC(dDtMinf) + CRLF)     
		lRet := .F.
	ElseIf dDtVen < dDtFab          
		MsgAlert("A data de vencimento tem que ser maior que a data de fabrica?o" + CRLF)
		lRet := .F.
	ElseIf dDtFab > dDataBase    
		MsgAlert("A data de fabrica?o n? pode ser maior que a data base do sistema" + CRLF)   
		lRet := .F.      
	ElseIf dDtFab > dDtVen    
		MsgAlert("A data de fabrica?o n? pode ser maior que a data de vencimento" + CRLF)     
		lRet := .F.
	ElseIf dDtVen < dDtMinV
		MsgAlert("A data de vencimento n? pode ser menor que "+DtoC(dDtMinV) + CRLF)   
		lRet := .F.  
	ElseIf nIntDa == 0 .OR. Empty(nIntDa)
	   	MsgAlert("O Intervalo de Vencimento do lote n? est?preenchido no cadastro do produto. ")   
		lRet := .F.   
	ElseIf (((VAL(SUBSTR(DTOC(dDtVen),7,4)) - VAL(SUBSTR(DTOC(dDtFab),7,4)))*12)+((VAL(SUBSTR(DTOC(dDtVen),4,2)) - VAL(SUBSTR(DTOC(dDtFab),4,2))))) > nIntDa
		MsgAlert("O Vencimento do Lote n? pode ser Superior a "+ CVALTOCHAR(nIntDa)+" meses"  + CRLF)   
		lRet := .F.   
	ElseIf (((VAL(SUBSTR(DTOC(dDtVen),7,4)) - VAL(SUBSTR(DTOC(dDtFab),7,4)))*12)+((VAL(SUBSTR(DTOC(dDtVen),4,2)) - VAL(SUBSTR(DTOC(dDtFab),4,2))))) < nIntDa
		lRet := MsgNoYes("Data de Vencimento ?inferior a "+CVALTOCHAR(nIntDa)+" Meses"+CRLF+"Deseja Prosseguir com essa data?"," Confirmar Vencimento Lote")  	
	EndIf   	
EndIf


//+-----------------------------------------------------------------+
//| Efetua validacao dos dados ref. ao lote                         |
//+-----------------------------------------------------------------+
If ( lRet )
	lRet := ConfirmaLote() //TIRADO TEMPORARIO RODRIGO 10/10/18           
EndIf
               
//+-----------------------------------------------------------------+
//| Efetua validacao da conta contabil x centro de Custo            |
//+-----------------------------------------------------------------+
If ( lRet )

	cConta		:= GdFieldGet("D1_CONTA")
	cCCusto		:= GdFieldGet("D1_CC")
	cRateio		:= GdFieldGet("D1_RATEIO") 
	lProcEIC	:= !Empty(GdFieldGet("D1_CONHEC")) //-- Nº Processo EIC

	//-- NF de origem EIC nao passa por esta validacao
	If ( !lProcEIC )
		lRet := U_VldCtaCC( cConta, cCCusto, cRateio, "MT100LOK" /*Name P.E*/)
	EndIf 
EndIf

Return lRet



/**************************************************************************************************
Fun?o:
ConfirmaLote

Autor:
Tiago Bandeira Brasiliano

Data:
24/1/2018

Descri?o:
Rotina desenvolvida para efetuar a confirma?o de informa?es referentes ao lote no momento da 
classifica?o fiscais de importa?o (Duplo Check), solicitado pelo Eduardo Cota, visando com isto
reduzir o n?ero de informa?es incorretas na classifica?o das mesmas no sistema.

Altera?es necess?ias na Dicion?io:
Tabela:      SX3
Campo:       D1_LOTECTL
Campo da X3: X3_WHEN
Novo Valor:  INCLUI .Or. Empty(SF1->F1_HAWB)

Tabela:      SX3
Campo:       D1_DTFABR
Campo da X3: X3_WHEN
Novo Valor:  INCLUI .Or. Empty(SF1->F1_HAWB)

Par?etros:
Nenhum

Retorno:
lRetorno => Indica se as informa?es de lote digitadas na tela de valida?o est? iguais as
            informa?es digitadas na linha do produto (.T.) ou n? (.F.).
**************************************************************************************************/
Static Function ConfirmaLote()

Local aAreaAtu   := GetArea()
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSB1   := SB1->(GetArea())
Local aAreaSF4   := SF4->(GetArea())
Local lClassNota := IsInCallStack("MATA103")                                                                     // Verifica se foi chamado da tela de Classifica?o de Nota (MATA103) e n? da tela de Pr?Nota (MATA100). Esta valida?o ser?feita apenas na classifica?o.
Local lCtrlEst   := Posicione("SF4", 1, xFilial("SF4") + GdFieldGet("D1_TES", n), "F4_ESTOQUE") == "S"           // Verifica se a TES controla estoque
Local lCtrlLote  := AllTrim(Posicione("SB1", 1, xFilial("SB1") + GdFieldGet("D1_COD", n), "B1_RASTRO")) $ "S|L|" // Verifica a rastreabiliade do Produto
Local lImporta   := SubStr(GdFieldGet("D1_CF", n), 1, 1) == "3"                                                  // Verifica se CFOP ?de importa?o (inicicada com 3)
Local aPergs     := {}
Local aRet       := {}
Local lRetorno   := .T.
Local bK_CTRL_C  := SetKey(K_CTRL_C)
Local bK_CTRL_V  := SetKey(K_CTRL_V)
// Insere um SetKey

//SetKey(K_CTRL_C, {|| MsgAlert( "A tecla CTRL+C foi pressionada" )})
//SetKey(K_CTRL_V, {|| MsgAlert( "A tecla CTRL+V foi pressionada" )})

// Apaga um SetKey

SetKey(K_CTRL_C, {||})
SetKey(K_CTRL_V, {||})

If lClassNota .And. lCtrlEst .And. lCtrlLote .And. lImporta
	
	//+--------------------------------------------------------+
	//| Cria a vari?el private (caso ela n? exista) que ir? | 
	//| conter os dados de lotes da tela, onde:                |
	//| n = ?dice do item no aCols.                           |
	//| aInfoLote[n, 01] = Indica se a linha n foi validada.   |
	//| aInfoLote[n, 02] = N?ero do Lote.                     |
	//| aInfoLote[n, 03] = Data de Fabrica?o do Lote.         |
	//| aInfoLote[n, 04] = Data de Validade do Lote.           |
	//+--------------------------------------------------------+
	If Type("aInfoLote") == "U"
		_SetNamedPrvt( "aInfoLote" , {} , "MATA103" )
	EndIf
	//+------------------------------------------------------------+
	//| Ajusta o tamanho do array de informa?es de acordo com a   |
	//| quantidade de linhas do aCols do grid.                     |
	//+------------------------------------------------------------+
	If Len(aInfoLote) < Len(aCols)
		aSize(aInfoLote, Len(aCols))
	EndIf
	//+------------------------------------------------------------+
	//| Cria os valores iniciais para a vari?el (caso eles ainda  |
	//| n? tenham sido definidos.                                 |
	//+------------------------------------------------------------+
	If aInfoLote[n] == Nil
		aInfoLote[n] := {.F., CriaVar("D1_LOTECTL"), CriaVar("D1_DTFABR"), CriaVar("D1_DTVALID")}
	EndIf
	
	lRetorno := aInfoLote[n, 1]
	cLote    := aInfoLote[n, 2]
	dDtFabr  := aInfoLote[n, 3]
	dDtValid := aInfoLote[n, 4]
	
	If cLote <> GdFieldGet("D1_LOTECTL", n) .Or. dDtFabr <> GdFieldGet("D1_DTFABR", n) .Or. dDtValid <> GdFieldGet("D1_DTVALID", n) // Abre a tela apenas caso o usu?io ainda n? tenha digitado os valores corretamente
	
		//+------------------------------------------------------------+
		//| Cria as vari?eis da tela de perguntas.                    |
		//+------------------------------------------------------------+
		aAdd(aPergs, {1, "Lote"             , cLote    , "@!", ".T.", , ".T.", 40                     , .T.})
		aAdd(aPergs, {1, "Data Fabric. Lote", dDtFabr  , "@D", ".T.", , ".T.", TamSX3("D1_DTFABR" )[1], .T.})
		aAdd(aPergs, {1, "Data Valid. Lote" , dDtValid , "@D", ".T.", , ".T.", TamSX3("D1_DTVALID")[1], .T.})
		
		If ParamBox(aPergs, "Confirma?o de dados do lote", @aRet,,,,,,,,.F.) // Abre a tela de par?etros para que o usu?io informe a data de refer?cia para processamento.
		
			//+------------------------------------------------------------+
			//| Obt? o retorno dos par?etros digitados pelo usu?io.     |
			//+------------------------------------------------------------+
			cLote    := aRet[1]
			dDtFabr  := aRet[2]
			dDtValid := aRet[3]
			
			//+------------------------------------------------------------+
			//| Efetua a dupla valida?o das informa?es de lote, ou seja, |
			//| verifica se as informa?es que foram digitadas na tela de  |
			//| confirma?o s? iguais aos valores do grid.                |
			//+------------------------------------------------------------+
			If cLote <> GdFieldGet("D1_LOTECTL", n) .Or. dDtFabr <> GdFieldGet("D1_DTFABR", n) .Or. dDtValid <> GdFieldGet("D1_DTVALID", n)
			
				MsgInfo("Aten?o! Os dados de confirma?o divergem dos valores informados para o item." + CRLF + "Os mesmos dever? ser digitados novamente.")
				
				//+------------------------------------------------------------+
				//| Limpa as informa?es no Grid de Itens caso                 |
				//| o usu?io tenha informado valores divergentes.             |
				//| (Removida esta funcionalidade a pedido do Rapha).          |
				//+------------------------------------------------------------+
				//GdFieldPut("D1_LOTECTL", CriaVar("D1_LOTECTL"), n)
				//GdFieldPut("D1_DTFABR" , CriaVar("D1_DTFABR") , n)
				//GdFieldPut("D1_DTVALID", CriaVar("D1_DTVALID"), n)
				//Eval(bGdRefresh)
				
				lRetorno := .F.
				
			Else
				
				lRetorno := .T.
				
				//+------------------------------------------------------------+
				//| Salva as informa?es caso o usu?io tenha digitado         |
				//| corretamente (para valida?es posteriores, ou caso         |
				//| o usu?io abra a tela de valida?o novamente).             |
				//+------------------------------------------------------------+
				aInfoLote[n, 1] := lRetorno
				aInfoLote[n, 2] := cLote
				aInfoLote[n, 3] := dDtFabr
				aInfoLote[n, 4] := dDtValid
			
			EndIf
		
		Else
		
			lRetorno := .F.
			
		EndIf
		
	EndIf

EndIf

//HABILITA NOVAMENTE O CTRL C E CTRL v
SetKey(K_CTRL_C, bK_CTRL_C)
SetKey(K_CTRL_V, bK_CTRL_V)

RestArea(aAreaSF4)
RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaAtu)
                       
Return lRetorno         
                      	
