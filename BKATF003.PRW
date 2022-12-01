#Include 'Protheus.ch'
//#INCLUDE "Directry.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BKATF003 บ Autor ณ Andre Elias de Araujo Data ณ  22/03/2017บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao do cadastro do Ativo    	                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cadastro de Ativos                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BKATF003()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Local aArea := GetArea()
	Local nOpca := 0
	Local aSays := {}
	Local aButtons := {}
	Local cCadastro := OemToAnsi("Importa็ใo de Ativos")
	Private aErro := {}
	
	Private cArqTxt := " "
	Private lMsErroAuto := .F.
	Private lMSHelpAuto := .F.
	Private aAutoLog := {}
	Private cArqCSV
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta tela principal                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AADD(aSays,OemToAnsi("Rotina de Importacao do Cadastro de Ativos"                  ))
	AADD(aSays,OemToAnsi("Ap๓s a importa็ใo do cadastro os itens informados deverใo ser conferidos." ))
	AADD(aSays,OemToAnsi("Clique no botใo parโmetros para selecionar o arquivo de importa็ใo."))
	//AADD(aSays,OemToAnsi("NA MESMA PASTA DO ARQUIVO .CSV SERม GRAVADO UM ARQUIVO "))
	//AADD(aSays,OemToAnsi("LOGIMP (RESUMO DA IMPORTAวรO)."))
	AADD(aButtons, { 5,.T.,{|o| (AbreArq(),o:oWnd:refresh())}})
	AADD(aButtons, { 1,.T.,{|o| (ImpArq(cArqCSV),o:oWnd:End())}})
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End()}})
	
	FormBatch( cCadastro, aSays, aButtons)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Restaura a area dos arquivos                                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AbreArq บ Autor ณ Andre Elias de Araujo Data ณ  22/03/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao do ativo fixo				                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function AbreArq()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cType := "Arquivos CSV|*.CSV"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exibe tela para selecionar arquivo                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cArqCSV := cGetFile(cType, OemToAnsi("Selecione o arquivo de interface"),0,"C:\TEMP\",.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.F.,.F.)
	
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ImpArq  บ Autor ณ Andre Elias de Araujo Data ณ  22/03/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao do ativo fixo			                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ImpArq(cArqCSV)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Private nHdl := 0
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida se o arquivo existe                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !File(cArqCSV)
		Aviso("Aten็ใo !","Arquivo nใo selecionado ou invแlido !",{"Ok"})
		Return
	Endif
	// 
	// GRAVAวรO VIA ROTINA AUTOMATICA
	//
	Processa({|| u_xSN1IMP(cArqCSV) },"Processando da importa็ใo")
	//
	//grava็ao manual dos registros
	//
	//Processa({|| u_xSN1IMPM(cArqCSV) },"Processando da importa็ใo")
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xSN1IMP บ Autor ณ Andre Elias de Araujo Data ณ  15/12/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao do cadastro Ativo Fixo	                      บฑฑ
ฑฑบ          ณ   via execauto                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Folha de Pagamento                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function xSN1IMP(cArqCSV)
  Local nLinha
  Local aAtfCab   := {}
  Local aAtfItens := {}
  Local aItens := {}
  local i,j
  PRIVATE lMsErroAuto	:= .F.
	
	
	_cArquivo := cArqCSV
	
	// Abre o arquivo
	nHandle := FT_FUse(_cArquivo)
	
	// Se houver erro de abertura abandona processamento
	
	if nHandle = -1
		
		return
	endif
	
	// Posiciona na primeria linha
	FT_FGoTop() // Retorna o n๚mero de linhas do arquivo
	nLast := FT_FLastRec()
	
	cDelim := ";"
	
	aCadSN1 := {}
	
	ProcRegua(nLast)
	
	IncProc()
	
	cLine  := FT_FReadLn()
	// Retorna a linha corrente
	aLinha := U__XGAVSTARR(cLine,cDelim) //StrTokArr(cLine,cDelim) //GAVSTR2ARR(cLine,cDelim)
	
	If ValType(aLinha)<>'A'
		Alert("Arquivo Invalido!! "+aLinha[1])
		// Fecha o Arquivo
		FT_FUSE()
		Return
	EndIF
	
	If Len(aLinha) < 3 // O ARQUIVO DEVERA TER NO MINIMO DOIS CAMPOS (PRODUTO + CAMPO ALTERADO)
		Alert("Arquivo Invalido!! "+aLinha[1])
		// Fecha o Arquivo
		FT_FUSE()
		Return
	EndIF
	
	nRecno := FT_FRecno()
	// Retorna o recno da Linha
	IF AllTrim(aLinha[2]) == "N1_CBASE" .and. AllTrim(aLinha[3]) == "N1_ITEM" .AND. !Empty(aLinha[3])
		
		//dbSelectArea("SX3")
		//dbSetOrder(2)
		//
		// Valido se todos os campos estao no SX3
		//
		cCmpFile := ""
		For i:=1 to Len(aLinha)
			
			cString := "" // ADCIONE AQUI OS CAMPOS QUE NAO PODEM CONTER NO ARQUIVO
			cCmpFile += aLinha[i]+";"
			
			IF !empty(AllTrim(GetSX3Cache(aLinha[I],"X3_TITULO"))) .and. ! cString $ AllTrim(aLinha[i])
				
				//aAdd(aCadSN1,{aLinha[i],SX3->X3_TIPO})
                aAdd(aCadSN1,{aLinha[i],GetSX3Cache(aLinha[I],"X3_TIPO")})
				
			Else
				Alert("Campo invalido!! "+aLinha[i])
				// Fecha o Arquivo
				FT_FUSE()
				Return
			EndIF
			
			
		Next i
			//verificar campos obrigatorios
			aCampOb := U__XGAVSTARR("N1_FILIAL;N1_CBASE;N1_ITEM;N1_AQUISIC;N1_QUANTD;N1_DESCRIC;N1_CHAPA;N1_NFISCAL;N1_VLAQUIS;N1_ICMSAPR;N1_CALCPIS;N1_MESCPIS;N3_HISTOR;N3_CCONTAB;N3_CUSTBEM;N3_CDEPREC;N3_CCUSTO;N3_CCDEPR;N3_DINDEPR;N3_VORIG1;N3_TXDEPR1;N3_TXDEPR2",";")
			For J:=1 to Len(aCampOb)
				If !aCampOb[j] $ cLine
					Alert("Campo obrigatorio nใo localizado na planilha!!"+aCampOb[j])
					FT_FUSE()
					Return
				EndIf
			Next J	
	Else
		Alert("Arquivo invalido!")
		Return
	EndIF
	
	// Posiciona na primeria linha
	FT_FGoTop() // Retorna o n๚mero de linhas do arquivo
	nLast := FT_FLastRec()
	
	cDelim := ";"
	
	ProcRegua(nLast)
	
	While !FT_FEOF()
		
		IncProc()
		aCadastro := {}
		cLine  := FT_FReadLn()
		// Retorna a linha corrente
		aLinha := U__XGAVSTARR(cLine,cDelim)//StrTokArr(cLine,cDelim) // GAVSTR2ARR(cLine,cDelim)
		
		If ValType(aLinha)<>'A'
			FT_FSKIP()
			Loop
		EndIF
		
		If Len(aLinha) < 3 // O ARQUIVO DEVERA TER NO MINIMO DOIS CAMPOS (PRODUTO + CAMPO ALTERADO)
			FT_FSKIP()
			Loop
		EndIF
		
		nRecno := FT_FRecno()
		// Retorna o recno da Linha
		IF AllTrim(aLinha[1]) == "N1_FILIAL" .and. AllTrim(aLinha[2]) == "N1_CBASE" .AND. !Empty(aLinha[3])
			
			FT_FSKIP()
			Loop
		EndIF
		IF AllTrim(aLinha[1]) == "N1_FILIAL" .or. UPPER(AllTrim(aLinha[1])) == "FILIAL" .or. Empty(AllTrim(aLinha[1]))
			
			FT_FSKIP()
			Loop
		EndIF
		// valida็ao da filial 
		IF AllTrim(aLinha[1]) <> cFilAnt
			Alert("Filial corrente diferente da filial informada no arquivo!")
			Return
		
		EndIf
		// INICIO
		// inclusใo do cabe็alho (aAtfCab) e do primeiro item (aAtfItens) do ativo fixo
		//
		aItens := {}
 
		For nLinha:=1 to Len(aLinha)
			
				
			IF aCadSN1[nLinha,2]=="N"
			 	If "N1_" $ aCadSN1[nLinha,1]  
			 		aAdd(aAtfCab, {aCadSN1[nLinha,1],Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})
			 	ElseIf  "N3_" $ aCadSN1[nLinha,1]
			 		//If !aCadSN1[nLinha,1] == 'N3_TXDEPR2' 
			 		 	aAdd(aAtfItens, {aCadSN1[nLinha,1],Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})
			 		 /*	if aCadSN1[nLinha,1] == 'N3_VRDACM1' 
			 		 		MsgAlert(Str(Val(StrTran((StrTran(aLinha[nLinha],".","")),",","."))))
			 		 	EndIf
			 		 	if aCadSN1[nLinha,1] == 'N3_VORIG1' 
			 		 		MsgAlert(Str(Val(StrTran((StrTran(aLinha[nLinha],".","")),",","."))))
			 		 	EndIf*/
			 		//EndIf
			 		If aCadSN1[nLinha,1] == 'N3_VORIG1' 
			 			aAdd(aAtfItens, {"N3_VORIG3",Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})    //Val(StrTran((StrTran(aLinha[13],".","")),",",""))
			 			aAdd(aAtfItens, {"N3_VORIG2",Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})  
			 		EndIf
			 		If aCadSN1[nLinha,1] == 'N3_VRDACM1' 
			 			aAdd(aAtfItens, {"N3_VRDACM3",Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})    //Val(StrTran((StrTran(aLinha[13],".","")),",",""))
			 		EndIf
			 		
			 	EndIf	
			ElseIF aCadSN1[nLinha,2]=="D"
				If "N1_" $ aCadSN1[nLinha,1] 
					aAdd(aAtfCab, {aCadSN1[nLinha,1],cToD(aLinha[nLinha]),Nil})
				ElseIf "N3_" $ aCadSN1[nLinha,1]
					
			 			aAdd(aAtfItens, {aCadSN1[nLinha,1],cToD(aLinha[nLinha]),Nil})
			 		
				EndIF
			Else
				If "N1_" $ aCadSN1[nLinha,1] 
					aAdd(aAtfCab, {aCadSN1[nLinha,1],cValToChar(aLinha[nLinha]),Nil})
				ElseIf "N3_" $ aCadSN1[nLinha,1]
					 	aAdd(aAtfItens, {aCadSN1[nLinha,1],cValToChar(aLinha[nLinha]),Nil})
			 	EndIf
			EndIF
			
		 Next nLinha
	 	aAdd(aAtfItens, {"N3_TIPO","01",Nil})
	 	aAdd(aAtfItens, {"N3_TPSALDO","1",Nil})
	 	
	 	//
	 	//copia do primeiro item para o Array aItens
	 	//
	 	Aadd(aItens, aAtfItens)
	 	/*//
	 	//INICIO DA INCLUSรO DO SEGUNDO ITEM NO aItens
	 	//somente os campos da tabela SN3 serใo incluidos no aItens
	 	//
         aAtfItens := {}
			For nLinha:=1 to Len(aLinha)
				//
				//verifico se o campo e numerico
				//
				IF aCadSN1[nLinha,2]=="N"
					If  "N3_" $ aCadSN1[nLinha,1]
						If aCadSN1[nLinha,1] == 'N3_TXDEPR2'
							aAdd(aAtfItens, {"N3_TXDEPR1",Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})
						Else
							If !aCadSN1[nLinha,1] == 'N3_TXDEPR1'
								aAdd(aAtfItens, {aCadSN1[nLinha,1],Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})
								
							EndIf
							If aCadSN1[nLinha,1] == 'N3_VORIG1'
								aAdd(aAtfItens, {"N3_VORIG3",Val(StrTran((StrTran(aLinha[nLinha],".","")),",",".")),Nil})
							EndIf
						EndIf
					EndIF	
				EndIf
				//
				//verifico se o campo ้ data
				//
				IF aCadSN1[nLinha,2]=="D"
						
						If "N3_" $ aCadSN1[nLinha,1]
							
							aAdd(aAtfItens, {aCadSN1[nLinha,1],cToD(aLinha[nLinha]),Nil})
							
						EndIF
				EndIf
				//
				//verifico se o campo ้ caracter
				//
				IF aCadSN1[nLinha,2]=="C"
						If "N3_" $ aCadSN1[nLinha,1]
							aAdd(aAtfItens, {aCadSN1[nLinha,1],cValToChar(aLinha[nLinha]),Nil})
							
						EndIf
				EndIF
				
			Next nLinha

	 	//aAdd(aAtfItens, {"N3_TIPO","10",Nil})
	 	//aAdd(aAtfItens, {"N3_TPSALDO","3",Nil})
	 	//
	 	//copia do segundo item para o array aItens
	 	//
		Aadd(aItens, aAtfItens)
 		//
 		//execu็ใo da rotina automatica 
 		//*/			
        DbselectArea("SN1")
        lMsErroAuto := .F.        
        MSExecAuto({|x,y,z| Atfa012(x,y,z)},aAtfCab,aItens,3)

		aAtfCab 	:= 	{}
		aAtfItens	:= 	{}

		If lMsErroAuto
			DisarmTransaction()
                        
            If !(IsBlind())   // COM INTERFACE GRมFICA
                MostraErro() // TELA
            Else // EM ESTADO DE JOB
                cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

                ConOut(PadC("Automatic routine ended with error", 80))
                ConOut("Error: "+ cError)
            EndIf
		Endif
		
		// Pula para pr๓xima linha
		FT_FSKIP()
	End
	If !lMsErroAuto
		MsgInfo("Ativo(s) importados!")
	EndIf
	//FClose(hdl)
	// Fecha o Arquivo
	FT_FUSE()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xSN1IMP บ Autor ณ Andre Elias de Araujo Data ณ  15/12/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao do cadastro Ativo Fixo	                      บฑฑ
ฑฑบ          ณ   grava็ใo manual                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Folha de Pagamento                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function xSN1IMPM(cArqCSV)
  Local nLinha
  Local aAtfCab   := {}
  Local aAtfItens := {}
  Local aItens := {}
  local i
  PRIVATE lMsErroAuto	:= .F.
	
	
	_cArquivo := cArqCSV
	
	// Abre o arquivo
	nHandle := FT_FUse(_cArquivo)
	
	// Se houver erro de abertura abandona processamento
	
	if nHandle = -1
		
		return
	endif
	
	// Posiciona na primeria linha
	FT_FGoTop() // Retorna o n๚mero de linhas do arquivo
	nLast := FT_FLastRec()
	
	cDelim := ";"
	
	aCadSN1 := {}
	
	
//	MsgStop("cArqCSV: "+cArqCSV)
	
	ProcRegua(nLast)
	
	IncProc()
	
	cLine  := FT_FReadLn()
	// Retorna a linha corrente
	aLinha := U__XGAVSTARR(cLine,cDelim) //StrTokArr(cLine,cDelim) //GAVSTR2ARR(cLine,cDelim)
	
	If ValType(aLinha)<>'A'
		Alert("Arquivo Invalido!! "+aLinha[1])
		// Fecha o Arquivo
		FT_FUSE()
		Return
	EndIF
	
	If Len(aLinha) < 3 // O ARQUIVO DEVERA TER NO MINIMO DOIS CAMPOS (PRODUTO + CAMPO ALTERADO)
		Alert("Arquivo Invalido!! "+aLinha[1])
		// Fecha o Arquivo
		FT_FUSE()
		Return
	EndIF
	
	nRecno := FT_FRecno()
	// Retorna o recno da Linha
	IF AllTrim(aLinha[2]) == "N1_CBASE" .and. AllTrim(aLinha[3]) == "N1_ITEM" .AND. !Empty(aLinha[3])
		
	//	dbSelectArea("SX3")
		//dbSetOrder(2)
		//
		// Valido se todos os campos estao no SX3
		//
		cCmpFile := ""
		For i:=1 to Len(aLinha)
			
			cString := "" // ADCIONE AQUI OS CAMPOS QUE NAO PODEM CONTER NO ARQUIVO
			cCmpFile += aLinha[i]+";"
			
            
			IF !empty(AllTrim(GetSX3Cache(aLinha[I],"X3_TITULO"))) .and. ! cString $ AllTrim(aLinha[i])
				
				aAdd(aCadSN1,{aLinha[i],,GetSX3Cache(aLinha[I],"X3_TIPO")})
				
			Else
				Alert("Campo invalido!! "+aLinha[i])
				// Fecha o Arquivo
				FT_FUSE()
				Return
			EndIF
			
		Next i
		
		//
		
	Else
		Alert("Arquivo invalido!")
		Return
	EndIF
	
	// Posiciona na primeria linha
	FT_FGoTop() // Retorna o n๚mero de linhas do arquivo
	nLast := FT_FLastRec()
	
	cDelim := ";"
	
	ProcRegua(nLast)
	
	While !FT_FEOF()
		
		IncProc()
		aCadastro := {}
		cLine  := FT_FReadLn()
		// Retorna a linha corrente
		aLinha := U__XGAVSTARR(cLine,cDelim)//StrTokArr(cLine,cDelim) // GAVSTR2ARR(cLine,cDelim)
		
		If ValType(aLinha)<>'A'
			FT_FSKIP()
			Loop
		EndIF
		
		If Len(aLinha) < 3 // O ARQUIVO DEVERA TER NO MINIMO DOIS CAMPOS (PRODUTO + CAMPO ALTERADO)
			FT_FSKIP()
			Loop
		EndIF
		
		nRecno := FT_FRecno()
		// Retorna o recno da Linha
		IF AllTrim(aLinha[1]) == "N1_FILIAL" .and. AllTrim(aLinha[2]) == "N1_CBASE" .AND. !Empty(aLinha[3])
			
			FT_FSKIP()
			Loop
		EndIF
		IF AllTrim(aLinha[1]) == "N1_FILIAL" 
			
			FT_FSKIP()
			Loop
		EndIF
		IF AllTrim(aLinha[1]) <> cFilAnt
			Alert("Filial corrente diferente da filial informada no arquivo!")
			Return
		
		EndIf
		//GRAVAวรO MANUAL
		
		For nLinha:=1 to Len(aLinha)
			
			IF aCadSN1[nLinha,2]=="N"
				aAdd(aCadastro, {aCadSN1[nLinha,1],VAL(aLinha[nLinha]),Nil})
			ElseIF aCadSN1[nLinha,2]=="D"
				aAdd(aCadastro, {aCadSN1[nLinha,1],cToD(aLinha[nLinha]),Nil})
			Else
				aAdd(aCadastro, {aCadSN1[nLinha,1],cValToChar(aLinha[nLinha]),Nil})
			EndIF
			
		 Next nLinha
		
			//
			// Valida se o Bem ja Existe
			// 
			cCBase := StrZero(Val(aCadastro[02][02]),10)
			cItem  := StrZero(Val(aCadastro[03][02]),4)
			cChapa := StrZero(Val(aCadastro[07][02]),10)
			
			
			DbSelectArea("SN1")
			DbSetOrder(1) //N1_FILIAL+N1_CBASE+N1_ITEM
			If DbSeek(xFilial("SN1")+cCBase+cItem)
				RecLock("SN1",.F.)
				SN1->N1_GRUPO   	:= aCadastro[31][02]
			    MsUnlock()      
			EndIf
			
			DbSelectArea("SN1")
			DbSetOrder(1) //N1_FILIAL+N1_CBASE+N1_ITEM
			If !DbSeek(xFilial("SN1")+cCBase+cItem)
				RecLock("SN1",.T.)
				SN1->N1_FILIAL    	:= xFilial("SN1")
				SN1->N1_CBASE     	:= cCBase
				SN1->N1_ITEM      	:= cItem
				SN1->N1_AQUISIC   	:= aCadastro[04][02] //Stod(TRB->N1_AQUISIC)
				SN1->N1_DESCRIC   	:= Substr(Alltrim(aCadastro[06][02]),1,40)
				SN1->N1_QUANTD    	:= aCadastro[05][02]
				SN1->N1_PATRIM    	:= "N"
				SN1->N1_CHAPA     	:= cCBase
				SN1->N1_CODBAR    	:= cCBase+cItem
				SN1->N1_DETPATR   	:= "99"
				SN1->N1_UTIPATR   	:= "9"            
				SN1->N1_STATUS 	   	:= "1"
				SN1->N1_CALCPIS		:= If(Empty(aCadastro[14][02]),"2",aCadastro[14][02])
				SN1->N1_CONSAB 		:= "1"
				SN1->N1_PENHORA		:= "0"
				SN1->N1_FORNEC		:= aCadastro[08][02]
				SN1->N1_LOJA		:= aCadastro[09][02]
	//			SN1->N1_NSERIE		:= TRB->N1_NSERIE
				SN1->N1_NFISCAL		:= aCadastro[11][02]
				SN1->N1_VLAQUIS		:= aCadastro[12][02]             
				SN1->N1_MESCPIS		:= aCadastro[15][02]
				SN1->N1_ICMSAPR		:= aCadastro[13][02]
				SN1->N1_GRUPO   	:= aCadastro[31][02]
				SN1->N1_XSERIE   	:= aCadastro[10][02]
				SN1->N1_XDESCRI   	:= aCadastro[06][02]
				SN1->N1_CSEGURO   	:= aCadastro[34][02]
			    MsUnlock()      
			Else
	//			cMsg += "Tabela SN1 - CBase: "+cCBase+" CItem: "+cItem+" - Nao Incluido, pois ja esta cadastrado!"+CHR(13)+CHR(10)     
			EndIf
			aN3Tipo := {"01","10"} 
			cSeqN3	 := 1
			For i := 1 To 2
				DbSelectArea("SN3")
				DbSetOrder(1) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
				//If !DbSeek(TRB->(FILIAL+CBASE+ITEM+TIPO_ATF))
				If !DbSeek(xFilial("SN3")+cCBase+cItem+aN3Tipo[i])//TRB->(xFilial("SN1")+N1_CBASE+N1_ITEM
			        SN3->(RecLock("SN3",.T.))
			        SN3->N3_FILIAL 	:= xFilial("SN3")
			        SN3->N3_CBASE  	:= cCBase
			        SN3->N3_ITEM   	:= cItem
			        SN3->N3_TIPO   	:= aN3Tipo[i] 
			        If aCadastro[16][2] <> "0"
			        	SN3->N3_HISTOR 	:= Substr(aCadastro[16][2],1,40)
			        EndIf
			        SN3->N3_CCONTAB	:= aCadastro[17][2] 	   	// CONTA DO BEM 
			        SN3->N3_SUBCTA  := aCadastro[32][2]//TRB->ITEMBEM
			        SN3->N3_SUBCCON := aCadastro[32][2]//TRB->ITEMBEM
			        SN3->N3_CUSTBEM	:= aCadastro[18][2]//TRB->N3_CUSTBEM 	   	// CENTRO DE CUSTO DO BEM
			        SN3->N3_CDEPREC	:= aCadastro[19][2]//TRB->N3_CDEPREC     	// CONTA DE DEPRECIACAO
			        SN3->N3_SUBCDEP	:= aCadastro[33][2]//TRB->ITEMDESP 	   	// CONTA DO BEM 
			        SN3->N3_CCDEPR	:= aCadastro[21][2]//TRB->N3_CCDEPR      	// CONTA DE DEPRECIACAO ACUMULADA.
			        SN3->N3_CCUSTO 	:= aCadastro[20][2]//TRB->N3_CCUSTO      	// CENTRO DE CUSTO DE DESPESA DO BEM
			        SN3->N3_DINDEPR	:= aCadastro[22][2]//TRB->N3_DINDEPR//Stod(TRB->N3_DINDEPR)  	// DATA DE INICIO DE DEPRECIACAO
					SN3->N3_TPSALDO	:= "1"
					SN3->N3_TPDEPR	:= "1"
					SN3->N3_CALCDEP	:= GetPar("MV_CALCDEP",.F.,"0") 
					SN3->N3_RATEIO 	:= "2"                                                                                                     
			        SN3->N3_VORIG1 	:= aCadastro[23][2]//TRB->N3_VORIG1	            // valor da aquisicao 
			        SN3->N3_TXDEPR1	:= If(i=1,aCadastro[24][2],aCadastro[28][2])               // taxa de depreciacao
			        SN3->N3_VRDACM1	:= If(i=1,aCadastro[25][2],aCadastro[29][2])                                         
			        SN3->N3_VORIG3 	:= aCadastro[23][2]//TRB->N3_VORIG1
			        SN3->N3_TXDEPR3	:= If(i=1,aCadastro[24][2],aCadastro[28][2])
			        SN3->N3_VRDACM3	:= If(i=1,aCadastro[25][2],aCadastro[29][2])                                         
			        SN3->N3_AQUISIC	:= aCadastro[04][02]//TRB->N1_AQUISIC//Stod(SubStr(TRB->N1_AQUISIC,5,4)+SubStr(TRB->N1_AQUISIC,3,2)+SubStr(TRB->N1_AQUISIC,1,2))  
			        SN3->N3_SEQ    	:= STRZERO(cSeqN3,3)
			        SN3->N3_BAIXA  	:= "0"
			        MsUnlock()
			        cSeqN3 += 1
				Else
	//				cMsg += "Tabela SN3 - CBase: "+cCBase+" CItem: "+cItem+" - Nao Incluido, pois ja esta cadastrado!"+CHR(13)+CHR(10)     
				EndIf
			Next
		    //
		    // SN4
		    //
		    dDataIni := aCadastro[04][02]//Ctod("31/01/2017")
		    aOcorren := {{"05","1"},{"05","1"}} 
		    aN4Tipo := {"01","10"} 
			cSeq	 := 1 //"001"
			i		 := 0
				For i := 1 To 2
					DbSelectArea("SN4")
					DbSetOrder(1) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
					If !DbSeek(xFilial("SN4")+cCBase+cItem+aN4Tipo[i]+DTOS(dDataIni)+aOcorren[i,1]+STRZERO(cSeq,3))
						SN4->(RecLock("SN4",.T.))
				        SN4->N4_FILIAL 	:= xFilial("SN4")
				        SN4->N4_CBASE  	:= cCBase
				        SN4->N4_ITEM   	:= cItem
				        SN4->N4_TIPO   	:= aN4Tipo[i] 
				        SN4->N4_OCORR  	:= aOcorren[i,1]
				        SN4->N4_TIPOCNT	:= aOcorren[i,2]
				        SN4->N4_CONTA	:= If(i=1,aCadastro[17][2],aCadastro[21][2])
				        SN4->N4_DATA	:= dDataIni
				        If i=1
				        	SN4->N4_QUANTD	:= 1
				        Else
				        	SN4->N4_TXMEDIA	:= 1
				        EndIf
				        SN4->N4_VLROC1	:= aCadastro[23][2]//TRB->N3_VORIG1
		//		        SN4->N4_VLROC2	:= TRB->N1_VLAQUIS2				
				        SN4->N4_VLROC3	:= aCadastro[23][2]//TRB->N3_VORIG1
				        SN4->N4_TXDEPR	:= If(i=1,aCadastro[24][2],aCadastro[28][2])//If(i=1,TRB->N3_TXDEPR1,TRB->N3_TXDEPR2)
				        SN4->N4_SEQ		:= STRZERO(cSeq,3) //cSeq
				        SN4->N4_TPSALDO	:= "1"
				        SN4->N4_CALCPIS	:= If(Empty(aCadastro[14][2]),"2",aCadastro[14][2])//If(Empty(TRB->N1_CALCPIS),"2",TRB->N1_CALCPIS)
				        SN4->N4_SUBCTA  := aCadastro[32][2]//TRB->ITEMBEM
				        MsUnlock()
				        cSeq += 1
				    EndIf
					DbSelectArea("SN5")
					DbSetOrder(1) //N5_FILIAL+N5_CONTA+DTOS(N5_DATA)+N5_TIPO+N5_TPBEM+N5_TPSALDO
					If !DbSeek(xFilial("SN5")+If(i=1,aCadastro[17][02]+Space(TamSx3(aCadastro[17][01])[1]-Len(aCadastro[17][02])),aCadastro[21][02]+Space(TamSx3(aCadastro[21][01])[1]-Len(aCadastro[21][02])))+DTOS(dDataIni)+aOcorren[i,2]+aN4Tipo[i]+"1")
						SN5->(RecLock("SN5",.T.))
				        SN5->N5_FILIAL 	:= xFilial("SN5")
				        SN5->N5_CONTA	:= If(i=1,aCadastro[17][2],aCadastro[21][2])//If(i=1,TRB->N3_CCONTAB,TRB->N3_CCDEPR)
				        SN5->N5_DATA	:= dDataIni
				        SN5->N5_TIPO   	:= aOcorren[i,2]
				        SN5->N5_VALOR1	:= aCadastro[23][2]//TRB->N3_VORIG1
				   //     SN5->N5_VALOR2	:= TRB->N1_VLAQUIS2
				        SN5->N5_VALOR3	:= aCadastro[23][2]//TRB->N3_VORIG1
				        SN5->N5_TPSALDO	:= "1"
				        SN5->N5_TPBEM	:= aN4Tipo[i]
				        MsUnlock()
				    Else
						SN5->(RecLock("SN5",.F.))
				        SN5->N5_VALOR1	+= aCadastro[23][2]//TRB->N3_VORIG1
				       // SN5->N5_VALOR2	+= TRB->N1_VLAQUIS2
				        SN5->N5_VALOR3	+= aCadastro[23][2]//TRB->N3_VORIG1
				        MsUnlock()
				    EndIf
			    Next
			    
			    //FIM DA GRAVAวรO MANUAL 
		
		// Pula para pr๓xima linha
		FT_FSKIP()
	End
	//FClose(hdl)
	// Fecha o Arquivo
	FT_FUSE()
	//Next
	MsgInfo("Fim da importa็ใo")
Return



/*/
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria um array baseando-se em uma string delimitada por um  บฑฑ 
ฑฑบ          ณ caracter pre-definido                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GAV-Interno                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function _XGAVSTARR( cString, cDelim )
             
Local aPieces := {}
Local nProc
    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atribui valores default aos parametros                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Default cString := ""
Default cDelim  := "/"
   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona um delimitador ao final da string - pos while       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cString += if( len(cString)==0, "", cDelim )
   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ - Procura a posicao do delimitador                           ณ
//ณ - Adiciona a matriz o elemento delimitado                    ณ
//ณ - Elimina da string o elemento acima                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
do while ! empty( cString )
      
      if ! ( nProc := at( cDelim, cString ) ) == 0
            
            aadd( aPieces, substr( cString, 1, nProc - 1 ) )
            cString := substr( cString, nProc + len( cDelim ) )
            
      endif
      
enddo
 
Return aPieces


Static Function GetPar(cPar)
return(getmv(cpar))
