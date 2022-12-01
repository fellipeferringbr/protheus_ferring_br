#Include "Protheus.ch"

Static aFormBatch := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERASB8DBFºAutor  ³Microsiga           º Data ³  12/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera um arquivo CSV dos saldos dos lotes dos produtos de   º±±
±±º          ³ Vendas                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function GeraSb8Dbf()

Local cCadastro     := "Relatório Controle de Lotes"
Local aSays         := {}
Local aButtons      := {}
Local aFiliais		:= {}
Local nOpcao  		:= 0 
Local oProcess      := Nil
Local lEnd          := .F.

// AADD(aSays,"Extração dos saldos por lote considerando as regras de saldo, local de estoque e produtos.")

AADD(aSays,"                               [RELATÓRIO FERRING DE CONTROLE DE LOTES]                           ")
AADD(aSays,"")
AADD(aSays,"Faz extração dos dados saldos por lote - tabela (SB8) aplicando as seguintes regras: ")
AADD(aSays,"Considera apenas os locais de estoque 01 e 50")
AADD(aSays,"Produtos cuja o código iniciam com número 5")
AADD(aSays,"Que possuem Saldo maior que zero")
AADD(aSays,"")
AADD(aSays,"Observações:")
AADD(aSays,"Parâmetro quando não informado considera todas as filiais")
AADD(aSays,"Relatório em formato de arquivo (.csv)")
AADD(aSays,"Diretório em que o relatório será gerado: C:\TEMP ")


AADD(aButtons,{2,.T.,{|| FechaBatch()  }})
AADD(aButtons,{5,.T.,{|| aFiliais	:= AdmGetFil(.F.,.F.,"SC8") }}) 
AADD(aButtons,{1,.T.,{|| nOpcao 	:= 1, FechaBatch()	}})

FormBatch(cCadastro, aSays, aButtons, /*bValid*/, 375/*nAltura*/, /*nLargura*/ )


If nOpcao == 1 .And. FwAlertYesNo("Confirma a geração do arquivo CSV dos saldos de lotes?","Atenção")

    oProcess := MsNewProcess():New( {|lEnd|  ProcRelato(aFiliais, @oProcess, @lEnd)  },;
                                    "Extraindo dados para o relatório","Efetuando a leitura do banco de dados...", .T.)

	oProcess:Activate()
EndIf


Return( )

Static Function ProcRelato( aFiliais, oProcess, lEnd )
        
Local cArq		:= ""
Local cIndTRB	:= ""
Local cQuery  	:= ""
Local cAliasSB8 := ""
Local cAliasTRB := ""
Local cFilSel 	:= ""       
Local aStru		:= {}
Local nTotReg 	:= 0
Local nI 		:= 0
// ----------------
Local cAuxDesc 	:= ""
Local cAuxProd 	:= ""
Local cStatus 	:= ""
Local nSubQuan 	:= 0
Local nSubVal  	:= 0
Local nTotQuan 	:= 0
Local nTotVal  	:= 0
Local cMv:= GetMV("MV_CQ")

//-----------------------
Private	cLinhaCSV 	:= ""


// ------------------------------------------------
//  Process 01 Leitura tabela de saldo por lote
// ------------------------------------------------

If Len(aFiliais) > 0

	For nI := 1 To Len( aFiliais )
		cFilSel += aFiliais[nI] + IIF( nI == Len(aFiliais),"","/")
	Next

	cFilSel := FormatIn( cFilSel, "/" )
EndIf 

cAliasSB8 := GetNextAlias()

IIF( Select(cAliasSB8)  > 0, (cAliasSB8)->( DbCloseArea()), Nil )

cQuery := " SELECT B8_PRODUTO,B1_DESC,B8_FILIAL,B8_LOCAL,B8_LOTECTL,B1_DVENLOT,Sum(B8_SALDO) AS B8_SALDO,B8_EMPENHO "
cQuery += " FROM "+RetSqlName("SB8")+","+RetSqlName("SB1") 
cQuery += " WHERE  B1_COD=B8_PRODUTO "  
If Len(cFilSel) > 0
   cQuery += " AND B8_FILIAL IN " + cFilSel 
EndIf   
cQuery += " AND B8_SALDO > 0 "
cQuery += " AND B8_LOCAL IN ('01','50') "
cQuery += " AND Substring(B8_PRODUTO,1,1) = '5' "
cQuery += " AND "+RetSqlName("SB8")+".D_E_L_E_T_=' ' "
cQuery += " AND "+RetSqlName("SB1")+".D_E_L_E_T_=' ' "
cQuery += " GROUP BY B8_PRODUTO,B1_DESC,B8_FILIAL,B8_LOCAL,B8_LOTECTL,B1_DVENLOT,B8_EMPENHO "
cQuery += " ORDER BY B8_PRODUTO,B1_DESC,B8_FILIAL,B8_LOCAL,B8_LOTECTL,B1_DVENLOT,B8_EMPENHO "

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB8)

(cAliasSB8)->( DbEval({|| nTotReg++ }))
(cAliasSB8)->( DbGoTop() )

// --------------------------------------------------------
// ABORTA PROCESSAMENTO CASA NAO TENHA ENCONTRADO REGISTROS
// --------------------------------------------------------
If (cAliasSB8)->( Eof() )
	FwAlertInfo("Nenhum registro foi localizado para processamento" + CRLF + CRLF + ;
				"Verifique o parâmetro informado.","Relatório Controle Lote")
	Return( .F. )
EndIf 

// ------------------------------------------------
//  Process 02 Cria tabela temporária para receber os dados já com o tratamento
// ------------------------------------------------
aStru := {}

AADD(aStru,{"PRODUTO"		,"C",15,0})
AADD(aStru,{"DESCRIC"		,"C",40,0})
AADD(aStru,{"FILIAL "		,"C",02,0})
AADD(aStru,{"LOCAL"			,"C",02,0})
AADD(aStru,{"LOTE"			,"C",14,0})
AADD(aStru,{"FABRIC"		,"D",08,0})
AADD(aStru,{"VENCIM"		,"D",08,0})
AADD(aStru,{"REGRA_D"   	,"N",10,0})
AADD(aStru,{"MVCTM"			,"N",12,2})
AADD(aStru,{"MVCTD"			,"N",12,0})
AADD(aStru,{"MVDAM"			,"N",12,2})
AADD(aStru,{"MVDAD"			,"N",12,0})
AADD(aStru,{"QUANTIDADE"   	,"N",10,0})
AADD(aStru,{"VALOR"		  	,"N",12,2})
AADD(aStru,{"STATUS"	  	,"C",50,0})
// AADD(aStru,{"EMPENHO"	  	,"N",14,2})
//
//cArq := Criatrab(aStru, .T. )


cAliasTRB := GetNextAlias()

IIF( Select(cAliasTRB)  > 0, (cAliasTRB)->( DbCloseArea()), Nil )

oTempTable := FWTemporaryTable():New(cAliasTRB)
oTemptable:SetFields(aStru)
oTempTable:AddIndex("index01",{"PRODUTO","FILIAL","LOCAL","LOTE"})
oTempTable:Create()

//DbUseArea( .t. ,,cArq,cAliasTRB)
//cIndTRB := "PRODUTO+FILIAL+LOCAL+LOTE"
//IndRegua(cAliasTRB,cAliasTRB,cIndTRB,,,"Gerando Indice Temporario...")

// ------------------------------------------------
//  03	Efetiva gravação na tab temporária com os dados ajustados. 
// 		Efetiva gravação do arquivo .CSV já salvando no diretorio padrão
// ------------------------------------------------

DbSelectArea(cAliasSB8)

(cAliasSB8)->( DbGotop() )

ProcRegua( (cAliasSB8)->(LastRec()))

oProcess:SetRegua1( (cAliasSB8)->( LastRec()) )
oProcess:SetRegua2( (cAliasSB8)->( LastRec()) )

While !(cAliasSB8)->(Eof())


	SB2->(dbSetOrder(1))
	SB2->(dbSeek((cAliasSB8)->B8_FILIAL+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_LOCAL))  

	SB8->(dbSetOrder(3))
   	SB8->(dbSeek((cAliasSB8)->B8_FILIAL+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_LOCAL+(cAliasSB8)->B8_LOTECTL))   

	oProcess:IncRegua1("Lendo lote: " + (cAliasSB8)->B8_LOTECTL)
	
	//-- Zera no Loop
	cStatus := ""

	If (cAliasSB8)->B8_EMPENHO > 0  
		If ChkBlqLote( (cAliasSB8)->B8_LOTECTL, (cAliasSB8)->B8_FILIAL )
			cStatus := "Bloqueado"
		EndIf 	
	EndIf 

	If Empty(cStatus)
		If ( (cAliasSB8)->B8_LOCAL ==  cMv ) 
			cStatus := "Quarentena"
		Else 
			If ( (SB8->B8_DTVALID-dDataBase) < (cAliasSB8)->B1_DVENLOT )
				cStatus := "Venda Interrompida"
			Else 
				cStatus := "Liberado para venda"
			EndIf 
		EndIf 
	EndIf 

	oProcess:IncRegua2("Tratando dados do lote:" + (cAliasSB8)->B8_LOTECTL )

	Reclock(cAliasTRB, .T. )

	(cAliasTRB)->PRODUTO    := (cAliasSB8)->B8_PRODUTO
	(cAliasTRB)->DESCRIC    := (cAliasSB8)->B1_DESC
	(cAliasTRB)->FILIAL     := (cAliasSB8)->B8_FILIAL
	(cAliasTRB)->LOCAL		:= (cAliasSB8)->B8_LOCAL
	(cAliasTRB)->LOTE 		:= (cAliasSB8)->B8_LOTECTL
	(cAliasTRB)->FABRIC  	:= IF(empty(SB8->B8_DTFABR),SB8->B8_DTVALID,SB8->B8_DTFABR)
	(cAliasTRB)->VENCIM   	:= SB8->B8_DTVALID
	(cAliasTRB)->REGRA_D 	:= (cAliasSB8)->B1_DVENLOT
	(cAliasTRB)->MVCTM  	:= Int(Round((SB8->B8_DTVALID - dDatabase)/30,2))
	(cAliasTRB)->MVCTD  	:= Round((Round((SB8->B8_DTVALID-dDatabase)/30,2) - (cAliasTRB)->MVCTM) * 30,0)
	(cAliasTRB)->MVDAM   	:= Int(Round((SB8->B8_DTVALID-dDatabase-(cAliasSB8)->B1_DVENLOT)/30,2))
	(cAliasTRB)->MVDAD   	:= Round((Round((SB8->B8_DTVALID-dDatabase-(cAliasSB8)->B1_DVENLOT)/30,2) - (cAliasTRB)->MVDAM ) * 30,0)
	(cAliasTRB)->QUANTIDADE	:= (cAliasSB8)->B8_SALDO
	(cAliasTRB)->VALOR     	:= SB2->B2_CM1 * (cAliasSB8)->B8_SALDO
	(cAliasTRB)->STATUS     := cStatus                                                                                                                 
	
	(cAliasTRB)->( MsUnLock() )
	(cAliasSB8)->( DbSkip() )
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara os itens da planilha.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cLinhaCSV += (cAliasTRB)->PRODUTO      +";"

	If cAuxProd <> (cAliasTRB)->PRODUTO .And. nSubQuan > 0
		cLinhaCSV += "***   TOTAL DO PRODUTO ; ; ; ; ; ; ; ; ; ;"
		cLinhaCSV += Transform(nSubQuan ,"@E 999,999,999")  	+";"
		cLinhaCSV += Transform(nSubVal  ,"@E 999,999,999.99")  	+";"
		cLinhaCSV += Chr(13)+Chr(10)
		cLinhaCSV += Chr(13)+Chr(10)
		cLinhaCSV += Chr(13)+Chr(10)
		nSubQuan  := 0
		nSubVal   := 0
	Endif
	cAuxProd := (cAliasTRB)->PRODUTO

	If cAuxDesc <> (cAliasTRB)->DESCRIC
		cLinhaCSV += (cAliasTRB)->DESCRIC+" - Filial :"+(cAliasTRB)->FILIAL      +";"
		cLinhaCSV += Chr(13)+Chr(10)
		cLinhaCSV += " "+";"
	Else
		cLinhaCSV += " "+";"
	Endif
	cAuxDesc := (cAliasTRB)->DESCRIC

	cLinhaCSV += (cAliasTRB)->LOCAL 		+";"
	cLinhaCSV += (cAliasTRB)->LOTE 		+";"
	cLinhaCSV += Dtoc((cAliasTRB)->FABRIC)  		+";"
	cLinhaCSV += Dtoc((cAliasTRB)->VENCIM)   	+";"
	cLinhaCSV += Transform((cAliasTRB)->REGRA_D,"@E 999,999,999")		+";"
	cLinhaCSV += Transform((cAliasTRB)->MVCTm,"@E 999,999")  		+";"
	cLinhaCSV += Transform((cAliasTRB)->MVCTd,"@E 999,999")  		+";"
	cLinhaCSV += Transform((cAliasTRB)->MVDAm,"@E 999,999")   		+";"
	cLinhaCSV += Transform((cAliasTRB)->MVDAd,"@E 999,999")   		+";"
	cLinhaCSV += Transform((cAliasTRB)->QUANTIDADE,"@E 999,999,999") 	+";"
	cLinhaCSV += Transform((cAliasTRB)->VALOR  ,"@E 999,999,999.99")  	+";"
	cLinhaCSV += (cAliasTRB)->STATUS      	+";"
	cLinhaCSV += Chr(13)+Chr(10)

	nSubQuan  += (cAliasTRB)->QUANTIDADE
	nSubVal   += (cAliasTRB)->VALOR
	nTotQuan  += (cAliasTRB)->QUANTIDADE
	nTotVal   += (cAliasTRB)->VALOR
	
EndDo

oProcess:SetRegua1( 1 )
oProcess:SetRegua2( 1 )

oProcess:IncRegua1("Gravando relatório...")
oProcess:IncRegua2("")

If  nSubQuan > 0
	cLinhaCSV += "***   TOTAL DO PRODUTO ; ; ; ; ; ; ; ; ; ;"
	cLinhaCSV += Transform(nSubQuan ,"@E 999,999,999")  	+";"
	cLinhaCSV += Transform(nSubVal  ,"@E 999,999,999.99")  	+";"
	cLinhaCSV += Chr(13)+Chr(10)
	cLinhaCSV += Chr(13)+Chr(10)
	cLinhaCSV += Chr(13)+Chr(10)
	nSubQuan  := 0
	nSubVal   := 0
Endif

cLinhaCSV += "***   TOTAIS GERAIS; ; ; ; ; ; ; ; ; ;"
cLinhaCSV += Transform(nTotQuan ,"@E 999,999,999")  	+";"
cLinhaCSV += Transform(nTotVal  ,"@E 999,999,999.99")  	+";"
cLinhaCSV += Chr(13)+Chr(10)
cLinhaCSV += Chr(13)+Chr(10)

(cAliasTRB)->(DbGoTop())


_cNomFile := "C:\TEMP\CONTRLOTE_"+DToS(DATE())+".CSV"
nHdl := FCreate(_cNomFile)
If nHdl <= 0
	MsgAlert("Atenção, não foi possível criar o arquivo " + _cNomFile +"Verifique suas permissões de escrita na unidade C:\TEMP")
	Return(.T.)  
EndIf 

 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava cabeçalho da planilha                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
FWrite(nHdl,"PLANILHA CONTROLE DE LOTES "+Chr(13)+Chr(10) )
FWrite(nHdl,"Referência: "+DTOC(Date())+Chr(13)+Chr(10)  +Chr(13)+Chr(10)  +Chr(13)+Chr(10))
                                                                                                                                                                                  
FWrite(nHdl,"DESCRITIVO DO PRODUTO;LOCAL;LOTE;FABRICACAO;VALIDADE;REGRA_D	;MVCT (Mes);MVCT (Dia);MVDA (Mes);MVDA (Dia);QUANTIDADE;VALOR;STATUS"+Chr(13)+Chr(10)  +Chr(13)+Chr(10))
FWrite(nHdl,cLinhaCSV+Chr(13)+Chr(10))
FClose(nHdl)

FwAlertSucess(	"Relatório gerado com sucesso!" + CRLF + CRLF + ;
				"Arquivo: " + _cNomFile,"Controle de Lotes") 
ShellExecute( "Open", _cNomFile, "", _cNomFile,1)

(cAliasSB8)->( DbCloseArea() )

(cAliasTRB)->( DbCloseArea() )

Return( .T. )


Static Function ChkBlqLote( cLote, cFilOrigem  )

Local aArea 		:= GetArea()
Local cAliasQry 	:= GetNextAlias()
Local cBlqZZD 		:= ""
Local nRecno 		:= 0
Local lBloqueado	:= .F.
   
	// -----------------------------------------------------------
	// Query para retornar ultimo lançamento do lote especificado    
	// ----------------------------------------------------------
	BeginSql ALIAS cAliasQry

		SELECT 
			MAX(R_E_C_N_O_) AS ULTRECNO 
		FROM 
			%Table:ZZD% ZZD  
		WHERE	
			ZZD_FILIAL		= %exp: cFilOrigem% 
			AND ZZD_LOTECT 	= %exp: cLote%
			AND ZZD_TPARQ  	= 'SDD'
			AND ZZD_STATUS	= '2'	// 0 -> Não enviado; 1 -> Erro no envio ; 2 -> Arquivo Enviado   
			AND ZZD.%NotDel%

	EndSql 

	// -----------------------------------------------------------
	// Checa status do ultimo lançamento da ZDD    
	// ----------------------------------------------------------
	If !(cAliasQry)->(EOF())
		
		nRecno := (cAliasQry)->ULTRECNO

		If !Empty( nRecno )
			DbSelectArea("ZZD")
			ZZD->( DbGoTo( nRecno ) )

			cBlqZZD 	:= UPPER(SubStr(ZZD->ZZD_INTEGR,1,1))
			lBloqueado 	:= ( cBlqZZD == "B" )
		EndIf 
	EndIf 

	(cAliasQry)->(DbCloseArea())

RestArea( aArea)

Return( lBloqueado )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FormBatch³ Autor ³ Juan Jose Pereira	    ³ Data ³ 04/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta tela generica para processo batch					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FormBatch( cTitle, aSays, aButtons, lOk, bValid )		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ cTitle = Titulo da janela								  ³±±
±±³			 ³ aSays  = Array com Says 									  ³±±
±±³			 ³ aButtons = Array com bottoes								  ³±±
±±³			 ³ aButtons[i,1] = Tipo de botao 							  ³±±
±±³			 ³ aButtons[i,2] = Tipo de enabled							  ³±±
±±³			 ³ aButtons[i,3] = bAction 									  ³±±
±±³			 ³ aButtons[i,4] = Hint do Botao							  ³±±
±±³			 ³ bValid = Bloco de validacao do Form 						  ³±±
±±³			 ³ nAltura= Altura do Form em Pixel (Default 250)			  ³±±
±±³			 ³ nLargura = Largura do Form em Pixel (Default 520)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#DEFINE LARGURA_DO_SBUTTON 32

Static Function FormBatch( cTitle, aSays, aButtons, bValid, nAltura, nLargura )

Local nButtons:= Len(aButtons),;
nSays:= Len(aSays),;
oSay,;
i,nTop, nType, lEnabled, oFormPai, oFont, ;
nLarguraBox, nAlturaBox, nLarguraSay, cTextSay

DEFAULT aSays:={}, aButtons:={}
DEFAULT nAltura:= 250, nLargura:= 520

// Numero maximo de linhas //
If( nSays>15 )
	nSays:=15
EndIf

// Numero maximo de botoes //
If( nButtons>5 )
	nButtons:= 5
EndIf

oFormPai:= Atail(aFormBatch)
If( oFormPai==NIL )
	oFormPai:= oMainWnd
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -11

DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO nAltura,nLargura OF oFormPai PIXEL

AADD(aFormBatch,oDlg)

nAlturaBox:= (nAltura-60)/2
nLarguraBox:= (nLargura-20)/2
@ 10,10 TO nAlturaBox,nLarguraBox OF oDlg PIXEL

//======================================================//
// monta says (bof)												 //
//======================================================//
nTop:=20

nLarguraSay:= nLarguraBox-30
for i:=1 to nSays
	cTextSay:= "{||'"+aSays[i]+"'}"
	oSay := TSay():New( nTop, 20, MontaBlock(cTextSay),oDlg,, oFont, .F., .F., .F., .T.,,, nLarguraSay, 10, .F., .F., .F., .F., .F. )
	nTop+= 10
next
//======================================================//
// monta says (eof)												 //
//======================================================//

//======================================================//
// monta bottoes(bof) 											 //
//======================================================//
nPosIni:= ((nLargura-20)/2) - (nButtons* LARGURA_DO_SBUTTON )
nAlturaButton:= nAlturaBox+10

for i:=1 to nButtons
	nType:= aButtons[i,1]
	lEnabled:= aButtons[i,2]
	
	DEFAULT lEnabled:= .T.
	
	If lEnabled
		If Len(aButtons[i]) > 3 .And. ValType(aButtons[i,4]) == "C"
			SButton():New( nAlturaButton, nPosIni, nType,aButtons[i,3],oDlg,.T.,aButtons[i,4])
		Else
			SButton():New( nAlturaButton, nPosIni, nType,aButtons[i,3],oDlg,.T.,,)
		Endif
	Else
		SButton():New( nAlturaButton, nPosIni, nType,,oDlg,.F.,,)
	EndIf
	
	nPosIni+= LARGURA_DO_SBUTTON
next
//======================================================//
// monta bottoes(bof) 											 //
//======================================================//
oDlg:Activate( ,,,.T.,bValid,,,, )

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FechaBatch³ Autor ³ Juan Jose Pereira	    ³ Data ³ 04/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fecha Ultima tela de batch 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FechaBatch()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FechaBatch()

Local oDlg:= Atail( aFormBatch )

oDlg:End()

ASize( aFormBatch,Len(aFormBatch)-1 )

Return nil  
