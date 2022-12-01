#INCLUDE "FEFINR710.CH"
#Include "TOTVS.CH"

Static lFWCodFil := .T.

/**************************************************************************************************
Fun็ใo:
FeFinR710

Data:
03/05/2017

Autor:
Tiago Bandeira Brasiliano

Descri็ใo:
Este relat๓rio ้ uma c๓pia do relat๓rio padrใo de Bordero de Contas a Pagar (FINR710.PRW).
Por้m o mesmo foi desenvolvido a pedido do usuแrio Luis de forma a ordenar o relat๓rio por
data de vencimento (o que nใo era possํvel no relat๓rio original, jแ que o mesmo nใo apresenta
pontos de entrada).

Parโmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FeFinR710()

Local oReport
Local aAreaR4	:= GetArea()

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aAreaR4)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ ReportDef บ Autor ณ Marcio Menon		   บ Data ณ  27/07/06 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Definicao do objeto do relatorio personalizavel e das      บฑฑ
ฑฑบ          ณ secoes que serao utilizadas.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Grupo de perguntas do relatorio                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 												              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local cReport 	:= "FEFINR710" 				// Nome do relatorio
Local cDescri 	:= STR0001 + STR0002   		//"Este programa tem a funo de emitir os borderos de pagamen-" ### "tos."
Local cTitulo 	:= STR0003 					//"Emisso de Borderos de Pagamentos"
Local cPerg		:= "FIN710"					// Nome do grupo de perguntas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica as perguntas selecionadas 		   				     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
pergunte("FIN710",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Vari veis utilizadas para parametros						ณ
//ณ mv_par01				// Do Bordero						ณ
//ณ mv_par02				// At o Bordero					ณ
//ณ mv_par03				// Data para dbito					ณ
//ณ mv_par04				// Qual Moeda						ณ
//ณ mv_par05				// Outras Moedas					ณ
//ณ mv_par06				// Converte por						ณ
//ณ mv_par07				// Compoen saldo por				ณ
//ณ mv_par08				// Considera Filial					ณ
//ณ mv_par09				// Da Filial						ณ
//ณ mv_par10				// Ate Filia						ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia a data para debito com a data base do sistema		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	MV_PAR03:=dtoc(dDataBase)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do componente de impressao                                      ณ
//ณ                                                                        ณ
//ณTReport():New                                                           ณ
//ณExpC1 : Nome do relatorio                                               ณ
//ณExpC2 : Titulo                                                          ณ
//ณExpC3 : Pergunte                                                        ณ
//ณExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ณ
//ณExpC5 : Descricao                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescri)

oReport:HideHeader()	//Oculta o cabecalho do relatorio
oReport:SetPortrait()	//Imprime o relatorio no formato retrato
oReport:HideFooter()	//Oculta o rodape do relatorio

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                              ADMIN



//ณ                      Definicao das Secoes                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Secao 01                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New(oReport, STR0054 , {"SEA"})	//"CABECALHO"

TRCell():New(oSection1, "CABEC", "", STR0054 , "", 80,/*lPixel*/,/*CodeBlock*/)		//"CABECALHO"
oSection1:SetHeaderSection(.F.)	//Nao imprime o cabecalho da secao
oSection1:SetPageBreak(.T.)		//Salta a pagina na quebra da secao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Secao 02                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection2 := TRSection():New(oSection1, STR0041 , {"SEA","SA6","SEF","SA2","SE2"})		//"BORDERO"
TRCell():New(oSection2, "EA_PREFIXO", "SEA", STR0042 , PesqPict("SEA","EA_PREFIXO"), TamSX3("EA_PREFIXO")[1],/*lPixel*/,/*CodeBlock*/)	//"PRF"
TRCell():New(oSection2, "EA_NUM"    , "SEA", STR0043 , PesqPict("SEA","EA_NUM")    , TamSX3("EA_NUM")[1]    ,/*lPixel*/,/*CodeBlock*/)	//"NUMERO"
TRCell():New(oSection2, "EA_PARCELA", "SEA", STR0044 , PesqPict("SEA","EA_PARCELA"), TamSX3("EA_PARCELA")[1],/*lPixel*/,/*CodeBlock*/)	//"PC"
TRCell():New(oSection2, "BENEF"     , ""   , STR0045 , PesqPict("SA2","A2_NOME")   , 33						,/*lPixel*/,/*CodeBlock*/)	//"B E N E F I C I A R I O"
TRCell():New(oSection2, "A6_NREDUZ", "SA6", STR0046 , PesqPict("SA6","A6_NREDUZ") , 15						,/*lPixel*/,/*CodeBlock*/)	//"BANCO"
TRCell():New(oSection2, "EF_NUM"    , "SEF", STR0047 , PesqPict("SEF","EF_NUM")    , TamSX3("EF_NUM")[1]    ,/*lPixel*/,/*CodeBlock*/)	//"HISTORICO"
TRCell():New(oSection2, "A2_BANCO"  , "SA2", STR0048 , PesqPict("SA2","A2_BANCO")  , TamSX3("A2_BANCO")[1]  ,/*lPixel*/,/*CodeBlock*/)	//"BCO"
TRCell():New(oSection2, "A2_AGENCIA", "SA2", STR0049 , PesqPict("SA2","A2_AGENCIA"), TamSX3("A2_AGENCIA")[1],/*lPixel*/,/*CodeBlock*/)	//"AGENC"
TRCell():New(oSection2, "A6_DVAGE"  , "SA6", "DV"    , PesqPict("SA6","A6_DVAGE")  , TamSX3("A6_DVAGE")[1]	,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection2, "A2_NUMCON" , "SA2", STR0050 , PesqPict("SA2","A2_NUMCON") , TamSX3("A2_NUMCON")[1] ,/*lPixel*/,/*CodeBlock*/)	//"NUMERO CONTA"
TRCell():New(oSection2, "A6_DVCTA"  , "SA6", "DV"    , PesqPict("SA6","A6_DVCTA")  , TamSX3("A6_DVCTA")[1] 	,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection2, "A2_CGC"  	, "SA2", STR0051 , "@R 99999999/9999999"       , 20						,/*lPixel*/,/*CodeBlock*/) 	//"CNPJ/CPF"
TRCell():New(oSection2, "E2_VENCREA", "SE2", STR0052 , PesqPict("SE2","E2_VENCREA"), 11						,/*lPixel*/,/*CodeBlock*/)  //"DT.VENC"
TRCell():New(oSection2, "VALORPAGAR", ""   , STR0053 , TM(0,17)					   , 18						,/*lPixel*/,/*CodeBlock*/)										    //"VALOR A PAGAR"

oSection2:Cell("A6_DVAGE"):SetCanPrint( { || !Empty( SA2->A2_AGENCIA ) } )
oSection2:Cell("A6_DVCTA"):SetCanPrint( { || !Empty( SA2->A2_NUMCON  ) } )

oSection2:Cell("VALORPAGAR"):cTitle := PadL(oSection2:Cell("VALORPAGAR"):cTitle,oSection2:Cell("VALORPAGAR"):nSize)

oSection2:SetTotalInLine (.F.) 	//O totalizador da secao sera impresso em coluna
oSection2:SetHeaderBreak(.T.)   //Imprime o cabecalho das celulas apos a quebra

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportPrint บAutorณ Marcio Menon       บ Data ณ  27/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime o objeto oReport definido na funcao ReportDef.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPO1 - Objeto TReport do relatorio                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportPrint(oReport)

Local oSection1 	:= oReport:Section(1)
Local oSection2 	:= oReport:Section(1):Section(1)
Local oBreak1
Local oFunction1
Local cChave      	:= ""
Local cFiltro     	:= ""
Local cAliasSea		:= "SEA"
Local cJoin 		:= ""
Local lBaixa		:= .F.
Local lCheque     	:= .F.
Local lAbatimento 	:= .F.
Local cLoja  		:= ""
Local nVlrPagar		:= 0
Local cModelo   	:= CriaVar("EA_MODELO")
Local cNumConta		:= CriaVar("EA_NUMCON")
Local lSeaEof     	:= .F.
Local cDvCta		:= ""
Local cFilialSEA
Local nLen := 0

Private nJuros := 0
Private dBaixa := CriaVar("E2_BAIXA")

If oReport:lXlsTable
	MessageBox(STR0055,'Alerta!',16) //"Formato de impressใo Tabela nใo suportado neste relat๓rio"
	oReport:CancelPrint()
	Return
Endif

SEA->(DbGoTop())
SE2->(DbGoTop())

cChave := SEA->(IndexKey())

#IFDEF TOP

	cAliasSea 		:= GetNextAlias()

	cChave 	:= "%"+SqlOrder(cChave)+"%"

	oSection1:BeginQuery()

	If MV_PAR08 == 1 //Considera Filial?
	  	If lFWCodFil .And. (MsModoFil("SEA")[3]=="E".Or.MsModoFil("SEA")[2]=="E".Or.MsModoFil("SEA")[1]=="E")
			If MsModoFil("SEA")[3] == "E"
				nLen := Len(FwCompany(MV_PAR09))
			EndIf
			If MsModoFil("SEA")[2] == "E"
				nLen += Len(FwUnitBusiness(MV_PAR10))
			EndIf
			If MsModoFil("SEA")[1] == "E"
				nLen += Len(FwFilial(MV_PAR10))
			EndIf
			cFilialSEA := "EA_FILIAL BETWEEN '" + SubStr(MV_PAR09,1,nLen) + "' AND '" + SubStr(MV_PAR10,1,nLen) + "' "
		Else
			cFilialSEA := "EA_FILIAL = '" + xFilial("SEA") + "' "
		EndIf
	Else
		cFilialSEA := "EA_FILIAL = '" + xFilial("SEA") + "' "
	EndIf

	cFilialSEA := "%"+cFilialSEA+"%"

	BeginSql Alias cAliasSea
		SELECT 	SEA.EA_FILIAL, SEA.EA_FILORIG, SEA.EA_NUMBOR, SEA.EA_CART, SEA.EA_PREFIXO, SEA.EA_NUM,
					SEA.EA_PARCELA, SEA.EA_TIPO, SEA.EA_FORNECE, SEA.EA_LOJA, SEA.EA_MODELO ,
					SEA.EA_PORTADO, SEA.EA_AGEDEP,SEA.EA_NUMCON, SEA.EA_DATABOR
		FROM
			%table:SEA% SEA
		INNER JOIN %table:SE2% SE2
		    ON SE2.%NotDel%
		    AND E2_FILIAL = EA_FILORIG
		    AND E2_PREFIXO = EA_PREFIXO
		    AND E2_NUM = EA_NUM
		    AND E2_PARCELA = EA_PARCELA
		    AND E2_TIPO = EA_TIPO
		    AND E2_FORNECE = EA_FORNECE
		    AND E2_LOJA = EA_LOJA
		WHERE
		    %Exp:cFilialSEA% AND
			SEA.EA_NUMBOR >= %Exp:mv_par01% AND
			SEA.EA_NUMBOR <= %Exp:mv_par02% AND
			SEA.EA_CART = 'P' AND
			SEA.%notDel%
			
		ORDER BY E2_FILIAL, E2_VENCREA DESC
	EndSql
	oSection1:EndQuery()
	oSection2:SetParentQuery()

#ELSE

    If MV_PAR08 == 1 //Considera Filial?
		cFiltro := "EA_FILIAL >= '" + MV_PAR09 + "' .AND. EA_FILIAL <= '" + MV_PAR10+ "' .AND."
	Else
		cFiltro := "EA_FILIAL == '" + xFilial("SEA") + "' .And. "
	EndIf

	cFiltro += "EA_NUMBOR >= '" + mv_par01 + "' .And. "
	cFiltro += "EA_NUMBOR <= '" + mv_par02 + "' .And. "
	cFiltro += "EA_CART = 'P'"

	TRPosition():New(oSection2,"SE2",1,{|| If( Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2")),;
																xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA),;
																(cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA)) } )
	oSection1:SetFilter(cFiltro,cChave)

#ENDIF

oSection1:SetLineCondition( { ||	 FR710Chk(1,cAliasSea) } )
oSection2:SetLineCondition( { ||	 FR710Chk(2,cAliasSea) } )


TRPosition():New(oSection2,"SE2",1,{|| If( Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2")),;
															xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA),;
															(cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA)) } )

oSection2:OnPrintLine( { || lBaixa := Fr710BxVL(cAliasSea, IIf (Empty((cAliasSea)->EA_LOJA), "", (cAliasSea)->EA_LOJA)), If(!lBaixa, lBaixa := Fr710BxBA(cAliasSea), Nil ),;
									 lCheque := (!Empty(SE5->E5_NUMCHEQ) .And. SEF->(MsSeek(xFilial("SEF")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ))),;
								    Fr710Config(cAliasSea, oSection2), .T. } )

oReport:OnPageBreak( { || ReportCabec(oReport, cModelo := (cAliasSea)->EA_MODELO, cAliasSea, lBaixa, lSeaEof) } )

oSection2:Cell("BENEF"):SetBlock( { || cDvCta := Posicione( "SA6", 1, xFilial("SA6") + (cAliasSEA)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON), "A6_DVCTA" ), ;
										cNumConta := RTrim( (cAliasSea)->EA_NUMCON ) + Iif( !Empty(cDvCta),"-","" ) + cDvCta, ;
										Fr710Benef(cAliasSea, lBaixa, lCheque, lAbatimento) } )

oSection2:Cell("A2_CGC"    ):SetBlock( { || Transform(SA2->A2_CGC, IIF(Len(Alltrim(SA2->A2_CGC))>11,"@R 99999999/9999-99","@R 999999999-99")) } )
oSection2:Cell("E2_VENCREA"):SetBlock( { || SE2->E2_VENCREA } )
oSection2:Cell("VALORPAGAR"):SetBlock( { || Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento) } )

oBreak1 := TRBreak():New(oSection1, { || (cAliasSea)->EA_NUMBOR }, STR0007)

oFunction1 := TRFunction():New(oSection2:Cell("VALORPAGAR"),,"SUM", oBreak1,,,,.F.,.F.)

oBreak1:OnPrintTotal( { || ReportTxtAut(oReport, cModelo, cNumConta, oFunction1:GetLastValue()), "" } )

oSection2:SetParentFilter({|cParam| (cAliasSea)->EA_NUMBOR == cParam },{|| (cAliasSea)->EA_NUMBOR } )

oSection2:Cell("A6_DVAGE"  ):SetBlock( { || Posicione( "SA6", 1, xFilial("SA6") + SA2->( A2_BANCO + A2_AGENCIA + A2_NUMCON ), "A6_DVAGE" ) } )
oSection2:Cell("A6_DVCTA"  ):SetBlock( { || Posicione( "SA6", 1, xFilial("SA6") + SA2->( A2_BANCO + A2_AGENCIA + A2_NUMCON ), "A6_DVCTA" ) } )
oSection2:Cell("A6_NREDUZ"  ):SetBlock( { || Posicione( "SA6", 1, xFilial("SA6") + SA2->( A2_BANCO + A2_AGENCIA + A2_NUMCON ), "A6_NREDUZ" ) } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia a impressao.						 								  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710BxVL บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe movimenta็ใo bancaria ou baixas que     บฑฑ
ฑฑบ          ณ movimentam banco.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710BxVL(cAliasSea, cLoja, lBaixa)
Local sFilial
Local cChave := ""
// Tratamento gestใo coorporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilFwSE2 := IIF( lGestao, FwFilial("SE2") , xFilial("SE2") )

// Borderos gerados em versao anterior
IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty( cFilFwSE2 )
	cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
Else //Borderos gerados a partir da versao 7.10
//	cChave := (cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
	cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
Endif
DbSelectArea("SE2")
dbSetOrder(1)
MsSeek(cChave)

If ( !Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") )) .or. (Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") ))
	sFilial := SE2->E2_FILIAL
Else
	sFilial := xFilial("SE5")
EndIf

dbSelectArea("SE5")
dbSetOrder(2)
SE5->(MsSeek(sFilial+"VL"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA ))

While SE5->(!Eof()) .and. ;
		SE5->E5_FILIAL		== sFilial	 		.and. ;
		SE5->E5_TIPODOC		== "VL"            	.and. ;
		SE5->E5_PREFIXO		== SE2->E2_PREFIXO 	.and. ;
		SE5->E5_NUMERO		== SE2->E2_NUM 	 	.and. ;
		SE5->E5_PARCELA		== SE2->E2_PARCELA 	.and. ;
		SE5->E5_TIPO		== SE2->E2_TIPO	 	.and. ;
		SE5->E5_DATA		== SE2->E2_BAIXA	.and. ;
		SE5->E5_CLIFOR		== SE2->E2_FORNECE 	.and. ;
		SE5->E5_LOJA		== cLoja

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Sข considera baixas que nao possuem estorno   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
		If SubStr( SE5->E5_DOCUMEN,1,6 ) == (cAliasSea)->EA_NUMBOR .And. SE5->E5_MOTBX != "PCC"
			lBaixa := .T.
			Exit
		Endif
	EndIf
	SE5->(dbSkip())
Enddo

Return lBaixa

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710BxBA บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe baixa automatica ou baixa que nao tenha บฑฑ
ฑฑบ          ณ movimentacao bancaria.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fr710BxBA(cAliasSea, lBaixa)
Local sFilial
Local cChave := ""
// Tratamento gestใo coorporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilFwSE2 := IIF( lGestao , FwFilial("SE2") , xFilial("SE2") )


// Borderos gerados em versao anterior
IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty( cFilFwSE2 )
	cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+(cAliasSea)->EA_LOJA
Else //Borderos gerados a partir da versao 7.10
//   cChave := (cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+(cAliasSea)->EA_LOJA
	 cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+(cAliasSea)->EA_LOJA
Endif

DbSelectArea("SE2")
dbSetOrder(1)
MsSeek(cChave)

If ( !Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") )) .or. (Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") ))
	sFilial := SE2->E2_FILIAL
Else
	sFilial := xFilial("SE5")
EndIf

dbSelectArea("SE5")
dbSetOrder(2)

If (SE5->(MsSeek( sFilial +"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA)))
	While SE5->(!Eof()) .and. ;
			SE5->E5_FILIAL		== sFilial			.and. ;
			SE5->E5_TIPODOC		== "BA"            	.and. ;
			SE5->E5_PREFIXO		== SE2->E2_PREFIXO 	.and. ;
			SE5->E5_NUMERO		== SE2->E2_NUM 	 	.and. ;
			SE5->E5_PARCELA		== SE2->E2_PARCELA 	.and. ;
			SE5->E5_TIPO		== SE2->E2_TIPO	 	.and. ;
			SE5->E5_DATA		== SE2->E2_BAIXA	.and. ;
			SE5->E5_CLIFOR		== SE2->E2_FORNECE 	.and. ;
			SE5->E5_LOJA		== SE2->E2_LOJA

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Sข considera baixas que nao possuem estorno   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
			If SubStr( SE5->E5_DOCUMEN,1,6 ) == (cAliasSea)->EA_NUMBOR .And. SE5->E5_MOTBX != "PCC"
				lBaixa := .T.
				Exit
			Endif
		EndIf
		SE5->(dbSkip())
	Enddo
Endif

Return lBaixa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710BenefบAutor  ณ  Marcio Menon      บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o campo Beneficiario conforme o modelo do          บฑฑ
ฑฑบ          ณ bordero.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710Benef(cAliasSea, lBaixa, lCheque, lAbatimento)

Local cBenef 	:= ""
Local cChave	:= ""
Local lGestao	:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa

SE2->(dbSetOrder(1))
SE2->(DbSeek(FwxFilial("SE2",(cAliasSea)->EA_FILORIG)+(cAliasSea)->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA)))


// Localiza o fornecedor do titulo que esta no bordero
// Borderos gerados em versao anterior
IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(IIf(lGestao,FWFilial("SA2"),xFilial("SA2")))
	cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
Else //Borderos gerados a partir da versao 7.10
	If !Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(Iif(lGestao,FWFilial("SA2"),xFilial("SA2")))
		cChave := (cAliasSea)->EA_FILORIG+SE2->E2_FORNECE+SE2->E2_LOJA
	Else
		cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
	Endif
Endif

SA2->(MsSeek(cChave))

If (cAliasSea)->EA_MODELO $ "CH/02"
	If !lAbatimento
		If lCheque
			cBenef := SEF->EF_BENEF
		ElseIf lBaixa
			cBenef := SE5->E5_BENEF
		Else
			cBenef := SA2->A2_NOME
		Endif
	EndIf
Else
	cBenef := SA2->A2_NOME
Endif

Return cBenef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710VPagar บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz os calculos dos valores a pagar dos titulos.		        บฑฑ
ฑฑบ          ณ 						                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento)
Local nAbat  	:= 0
Local nVlrPagar	:= 0
DEFAULT lBaixa 	:= .F.

SE2->(dbSetOrder(1))
SE2->(DbSeek(FwxFilial("SE2",(cAliasSea)->EA_FILORIG)+(cAliasSea)->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA)))


If lAbatimento
	nAbat 	:= SE2->E2_SALDO
Else
	nAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_FILIAL)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua calculo dos juros do titulo posicionado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fa080Juros(1)
dbSelectArea( "SA2" )
dbSeek( xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA))

/*If lBaixa .And. SA2->A2_TIPO == "F" .And. SA2->A2_CALCIRF == "2"
	If ! lAbatimento
		nVlrPagar := Round(NoRound(xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,(cAliasSea)->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
		nAbat := 0
	EndIf
Else*/
	If ! lAbatimento
		If mv_par07 == 1
			nVlrPagar := Round(NoRound(xMoeda(SE2->E2_SALDO-SE2->E2_SDDECRE+SE2->E2_SDACRES-nAbat+nJuros,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,(cAliasSea)->EA_DATABOR,dDataBase),MsDecimais(1)+1,SE2->E2_TXMOEDA ,SM2->M2_MOEDA2),MsDecimais(1)+1),MsDecimais(1))
    	Else
			nVlrPagar := Round(NoRound(xMoeda(SE2->E2_VALOR-SE2->E2_DECRESC+SE2->E2_ACRESC-nAbat+nJuros,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,(cAliasSea)->EA_DATABOR,dDataBase),MsDecimais(1)+1,SE2->E2_TXMOEDA ,SM2->M2_MOEDA2),MsDecimais(1)+1),MsDecimais(1))
		EndIf
	Endif

Return nVlrPagar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportCabec บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o cabecalho do relatorio.				 		        บฑฑ
ฑฑบ          ณ 						                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportCabec(oReport, cModelo, cAliasSea, lBaixa, lSeaEof)

Local cStartPath	:= GetSrvProfString("Startpath","")
Local cLogo			:= ""
Local cTexto 		:= ""
Local lHlpNoTab 	:= .F.

//Se a quebra de secao for na impressao do texto da autorizacao
//Volta o registro para imprimir o cabecalho
If (cAliasSea)->(EOF())
    lSeaEof := .T.
	(cAliasSea)->(dbSkip(-1))
	cModelo := (cAliasSea)->EA_MODELO
EndIf

dbSelectArea( "SA6" )
DbSeek(FwxFilial("SA6",(cAliasSea)->EA_FILORIG)+(cAliasSea)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON))

If lBaixa
	SA6->(MsSeek(xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA)))
Else
	SA6->(MsSeek(xFilial("SA6")+(cAliasSea)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)))
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica o modelo do documento.				  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lHlpNoTab := IIf(Empty(cModelo),.F.,.T.)
If cModelo $ "CH/02"
	cTexto := Tabela("58",@cModelo,lHlpNoTab)
Elseif cModelo $ "CT/30"
	cTexto := Tabela("58",@cModelo,lHlpNoTab)
Elseif cModelo $ "CP/31"
	cTexto := Tabela("58",@cModelo,lHlpNoTab)
ElseIf cModelo $ "CC/01/03/04/05/10/41/43"
	cTexto := Tabela("58",@cModelo,lHlpNoTab)
Else
	cTexto := Tabela("58",@cModelo,lHlpNoTab)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho.							  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport:ThinLine()

cLogo := cStartPath + "LGRL" + FWSM0Util():GetSM0Data(,,{"M0_CODIGO"})[1][2] + IIf( lFWCodFil, FWGETCODFILIAL, FWSM0Util():GetSM0Data(,,{"M0_CODFIL"})[1][2] ) + ".BMP" 	// Empresa+Filial

If !File( cLogo )
	cLogo := cStartPath + "LGRL" + FWSM0Util():GetSM0Data(,,{"M0_CODIGO"})[1][2]+ ".BMP" 						// Empresa
endif

oReport:SkipLine()
oReport:SayBitmap (oReport:Row(),005,cLogo,291,057)
oReport:SkipLine()
oReport:SkipLine()
oReport:SkipLine()
oReport:ThinLine()
oReport:SkipLine()
oReport:SkipLine()
//Texto do tipo de bordero
oReport:PrintText(FWSM0Util():GetSM0Data(,,{"M0_NOME"})[1][2] + PadC(OemToAnsi(STR0034),100) + OemToAnsi(STR0035)+DtoC(dDataBase))
oReport:PrintText(Space(Len(FWSM0Util():GetSM0Data(,,{"M0_NOME"})[1][2])) + PadC(cTexto,100) + OemToAnsi(STR0036) + (cAliasSea)->EA_NUMBOR)
oReport:SkipLine()
oReport:SkipLine()
//Dados do Banco
oReport:PrintText(Pad(OemToAnsi(STR0037) + SA6->A6_NOME,100))
oReport:PrintText(Pad(	OemToAnsi(STR0038) + RTrim(SA6->A6_AGENCIA) + Iif( !Empty(SA6->A6_DVAGE),"-","") + RTrim(SA6->A6_DVAGE) + ;
						OemToAnsi(STR0040) + RTrim(SA6->A6_NUMCON)  + Iif( !Empty(SA6->A6_DVCTA),"-","") + RTrim(SA6->A6_DVCTA),100))
oReport:PrintText(Pad(SA6->A6_END + " "  + SA6->A6_MUN + " " + SA6->A6_EST,100))
oReport:SkipLine()
oReport:SkipLine()
oReport:ThinLine()

If lSeaEof
	(cAliasSea)->(dbSkip())
EndIf

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710Config บAutor  ณ Marcio Menon       บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe ou oculta as colunas do relatorio, conforme o modelo   บฑฑ
ฑฑบ          ณ do bordero.			                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710Config(cAliasSea, oSection2)

Do Case

Case	(cAliasSea)->EA_MODELO $ "CH/02"
	oSection2:Cell("EF_NUM"    ):Enable()
	oSection2:Cell("EF_NUM"    ):SetBlock({ || "CH. " + SEF->EF_NUM})
	oSection2:Cell("A2_BANCO"  ):Disable()
	oSection2:Cell("A2_AGENCIA"):Disable()
	oSection2:Cell("A6_DVAGE"  ):Disable()
	oSection2:Cell("A2_NUMCON" ):Disable()
	oSection2:Cell("A6_DVCTA"  ):Disable()
	oSection2:Cell("A2_CGC"    ):Disable()

Case	(cAliasSea)->EA_MODELO $ "CT/30"
	oSection2:Cell("A6_NREDUZ" ):Disable()
	oSection2:Cell("A2_BANCO"  ):Disable()
	oSection2:Cell("A2_AGENCIA"):Disable()
	oSection2:Cell("A6_DVAGE"  ):Disable()
	oSection2:Cell("A2_NUMCON" ):Disable()
	oSection2:Cell("A6_DVCTA"  ):Disable()
	oSection2:Cell("A2_CGC"    ):Disable()
   //Verifica se existe numero de cheque
	If (SEF->(MsSeek(xFilial("SEF") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA + SE5->E5_NUMCHEQ)))
		oSection2:Cell("EF_NUM"    ):SetTitle("NUM. CHEQUE")
		oSection2:Cell("EF_NUM"    ):SetBlock({ || SEF->EF_NUM})
		oSection2:Cell("EF_NUM"    ):Enable()
	Else
		oSection2:Cell("EF_NUM"    ):SetTitle("")
	EndIf

Case	(cAliasSea)->EA_MODELO $ "CT/31"
	oSection2:Cell("A6_NREDUZ" ):Enable()
	oSection2:Cell("A2_BANCO"  ):Disable()
	oSection2:Cell("A2_AGENCIA"):Disable()
	oSection2:Cell("A6_DVAGE"  ):Disable()
	oSection2:Cell("A2_NUMCON" ):Disable()
	oSection2:Cell("A6_DVCTA"  ):Disable()
	oSection2:Cell("A2_CGC"    ):Disable()
   //Verifica se existe numero de cheque
	If (SEF->(MsSeek(xFilial("SEF") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA + SE5->E5_NUMCHEQ)))
		oSection2:Cell("EF_NUM"    ):SetTitle("NUM. CHEQUE")
		oSection2:Cell("EF_NUM"    ):SetBlock({ || SEF->EF_NUM})
		oSection2:Cell("EF_NUM"    ):Enable()
	Else
		oSection2:Cell("EF_NUM"    ):SetTitle("NUM. CHEQUE")
	EndIf

Case	(cAliasSea)->EA_MODELO $ "CC/01/03/04/05/10/41/43"
	oSection2:Cell("A6_NREDUZ" ):Enable()
	oSection2:Cell("A2_BANCO"  ):Enable()
	oSection2:Cell("A2_AGENCIA"):Enable()
	oSection2:Cell("A6_DVAGE"  ):Enable()
	oSection2:Cell("A2_NUMCON" ):Enable()
	oSection2:Cell("A6_DVCTA"  ):Enable()
	oSection2:Cell("A2_CGC"    ):Enable()
	oSection2:Cell("EF_NUM"    ):Disable()
EndCase


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportTxtAutบAutor  ณ Marcio Menon       บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o Total Geral por extenso e as mensagens de	        บฑฑ
ฑฑบ          ณ autorizacao, conforme o modelo do bordero.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportTxtAut(oReport, cModelo, cNumConta, nVlrSecao)
Local nCount

oReport:SkipLine()
oReport:PrintText(Extenso(nVlrSecao,.F.,MV_PAR04))
oReport:SkipLine()

If cModelo $ "CH/02"
	//"AUTORIZAMOS V.SAS. A EMITIR OS CHEQUES NOMINATIVOS AOS BENEFICIARIOS EM REFERENCIA,"
	oReport:PrintText(STR0008)
	//"DEBITANDO EM NOSSA CONTA CORRENTE NO DIA "
	oReport:PrintText(STR0009 + DtoC( mv_par03 ))
	//"PELO VALOR ACIMA TOTALIZADO."
	oReport:PrintText(STR0010)

Elseif cModelo $ "CT/30"
	//"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS ACIMA RELACIONADOS EM NOSSA"
	oReport:PrintText(STR0011)
	//"CONTA MOVIMENTO NO DIA "###", PELO VALOR ACIMA TOTALIZADO."
	oReport:PrintText(STR0012 + DtoC( mv_par03 ) + OemToAnsi(STR0013))

Elseif cModelo $ "CP/31"
	//"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS EM REFERENCIA, LEVANDO A DEBITO DE NOSSA"
	oReport:PrintText(STR0014)
	//"CONTA CORRENTE NUM. "###" NO DIA "###" PELO VALOR ACIMA TOTALIZADO."
	oReport:PrintText(STR0015 + cNumConta + OemToAnsi(STR0016) + DtoC( mv_par03 ) + OemToAnsi(STR0017))

Elseif cModelo $ "CC/01/03/04/05/10/41/43"
	//"AUTORIZAMOS V.SAS. A EMITIREM ORDEM DE PAGAMENTO, OU DOC PARA OS BANCOS/CONTAS ACIMA."
	oReport:PrintText(STR0018)
	//"DOS TITULOS RESPECTIVOS DEBITANDO EM NOSSA C/CORRENTE NUM "
	oReport:PrintText(STR0019 + cNumConta)
	//"NO DIA "### " PELO VALOR ACIMA TOTALIZADO."
	oReport:PrintText(STR0020 + dToC( mv_par03 ) + OemToAnsi(STR0021))

Else
	//"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS EM REFERENCIA, LEVANDO A DEBITO DE NOSSA"
	oReport:PrintText(STR0022)
	//"CONTA CORRENTE NUM. "###" NO DIA "###" PELO VALOR ACIMA TOTALIZADO."
	oReport:PrintText(STR0023 + cNumConta + OemToAnsi(STR0016) + DtoC( mv_par03 ) + OemToAnsi(STR0017))
EndIf

For nCount := 1 to 5
	oReport:SkipLine()
Next

oReport:PrintText("-----------------------------------",/*nRow*/,900)
oReport:PrintText(FWSM0Util():GetSM0Data(,,{"M0_NOMECOM"})[1][2],/*nRow*/,900)

Return ""
