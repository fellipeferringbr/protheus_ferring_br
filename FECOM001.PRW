#Include 'Protheus.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FECOM001 บ Autor ณ Samir			Data ณ  03/07/2018บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Bloquear o fornecedor de acordo com a data informada.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  			                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FECOM001()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Local aArea 	:= GetArea()
	Local nOpca 	:= 0
	Local aSays 	:= {}
	Local aButtons  := {}
	Local aRegs		:= {}
	Local cCadastro := OemToAnsi("Atualiza็ใo Fornecedores")
	Private	cPerg   := "ATUA2BLQ"
	Private cArqTxt := " "
	Private aAutoLog := {}
	Private cArqCSV
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta as perguntas                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Aadd(aRegs,{cPerg,"01","Fornecedor De?"     		,"","","mv_ch1","C", 06	,0,0,"G","","mv_par01","   ","","","","","   ","","","","","","","","","","","","","","","","","","","SA2",""})
	Aadd(aRegs,{cPerg,"02","Fornecedor Ate?"     		,"","","mv_ch2","C", 06	,0,0,"G","","mv_par02","   ","","","","","   ","","","","","","","","","","","","","","","","","","","SA2",""})
	Aadd(aRegs,{cPerg,"03","Data sem compra?"  			,"","","mv_ch3","D", 8	,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	Pergunte(cPerg,.F.)
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta tela principal                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AADD(aSays,OemToAnsi("Bloquear o(s) fornecedor(res) conforme defini็ใo das perguntas." ))
	AADD(aSays,OemToAnsi(" " ))
	AADD(aSays,OemToAnsi("Clique no botใo parโmetros para definir as perguntas."))
	AADD(aSays,OemToAnsi("NA PASTA TEMP SERม GRAVADO UM ARQUIVO "))
	AADD(aSays,OemToAnsi("COM OS FORNECEDORES BLOQUEADOS."))
	AADD(aButtons, { 5,.T.,{|o| (Pergunte(cPerg,.T.),o:oWnd:refresh())}})
	AADD(aButtons, { 1,.T.,{|o| (ProcSa2(),o:oWnd:End())}})
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
ฑฑบPrograma  ณ xImpSra บ Autor ณ Andre Elias de Araujo Data ณ  15/12/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao do cadastro de produtos                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ProcSa2()
	Local hdl := FCreate("C:\temp\LogProcSA2.txt", 0)
	Local _cQuery  := " "
	Local cQueryF1 := " "
	IncProc("Lendo o cadastro de Fornecedores. Aguarde... ")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a query com os fornecedores                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_cQuery := " SELECT * "
		_cQuery += " FROM "+RetSqlName("SA2")+" "
		_cQuery += " WHERE A2_FILIAL = '"     + xFilial("SA2") +"' "
		_cQuery += " AND A2_COD BETWEEN '"    + MV_PAR01       + "' AND '"+ MV_PAR02+ "'"
		_cQuery += " AND A2_MSBLQL   <> '1' "
		_cQuery += " AND D_E_L_E_T_ = ' ' "
		_cQuery += " ORDER BY A2_COD,A2_LOJA "
		TcQuery _cQuery New Alias "TMP1"     
		ProcRegua( TMP1->( Reccount() ) ) 
		TMP1->(dbGoTop())
		While TMP1->(!Eof())

			dbSelectArea("SA2")
			dbSetOrder(1)
			If SA2->(MsSeek(xFilial("SA2")+ TMP1->A2_COD + TMP1->A2_LOJA,.T.))
				If DTOS(SA2->A2_XDTCAD) >= DTOS(MV_PAR03)
					//
					// Fornecedor foi cadastrado dentro do periodo de Validacao 
					//
					TMP1->(dbSkip())
					Loop
				EndIf
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Monta a query (SF1) verificar se teve compra a partir da data informada.                                                    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQueryE2 := " SELECT  * "+  chr(13)+chr(10) 
		 	cQueryE2 += " FROM  "+RetSqlName('SE2')+"  SE2 "+ chr(13)+chr(10) 
		 	cQueryE2 += " WHERE  "+ chr(13)+chr(10)
		 	cQueryE2 += " SE2.E2_EMISSAO    >= '" + Dtos(MV_PAR03) + "' AND "+ chr(13)+chr(10)
		 	cQueryE2 += " SE2.E2_FORNECE     = '" + TMP1->A2_COD   + "' AND "+ chr(13)+chr(10)
		 	cQueryE2 += " SE2.E2_LOJA        = '" + TMP1->A2_LOJA  + "' AND "+ chr(13)+chr(10)
			cQueryE2 += " SE2.D_E_L_E_T_     = ' ' "+ chr(13)+chr(10)
			cQueryE2 += " ORDER BY E2_FILIAL   "+ chr(13)+chr(10)

			TcQuery cQueryE2 New Alias "TMPSE2"
			TMPSE2->(dbGoTop())


			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Monta a query (SF1) verificar se teve compra a partir da data informada.                                                    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cQueryF1 := " SELECT  * "+  chr(13)+chr(10) 
		 	cQueryF1 += " FROM  "+RetSqlName('SF1')+"  SF1 "+ chr(13)+chr(10) 
		 	cQueryF1 += " WHERE  "+ chr(13)+chr(10)
		 	cQueryF1 += " SF1.F1_DTDIGIT    >= '" + Dtos(MV_PAR03)   + "' AND "+ chr(13)+chr(10)
		 	cQueryF1 += " SF1.F1_FORNECE     = '" + TMP1->A2_COD     + "' AND "+ chr(13)+chr(10)
		 	cQueryF1 += " SF1.F1_LOJA        = '" + TMP1->A2_LOJA    + "' AND "+ chr(13)+chr(10)
			cQueryF1 += " SF1.D_E_L_E_T_     = ' ' "+ chr(13)+chr(10)
			cQueryF1 += " ORDER BY F1_FILIAL  "+ chr(13)+chr(10)
			
			TcQuery cQueryF1 New Alias "TMPSF1"
			TMPSF1->(dbGoTop())
			
			If TMPSF1->(Eof()) .And. TMPSE2->(Eof())
			 
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Nใo localizado compra para o fornecedor
				//ณ Atualiza o SA2 - bloqueia o fornecedor                                                    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				dbSelectArea("SA2")
				dbSetOrder(1)
				If SA2->(MsSeek(xFilial("SA2")+ TMP1->A2_COD + TMP1->A2_LOJA,.T.))
					RecLock("SA2",.F.)
					SA2->A2_MSBLQL := "1"
					MSUnlock()
					FWrite(hdl,"Fornecedor: "+ TMP1->A2_COD +"/"+ TMP1->A2_LOJA +" - "+SA2->A2_NREDUZ+" - Data: "+DTOC(MV_PAR03)+ " - => bloqueado! "+CHR(13)+CHR(10))
				EndIf
				
			EndIf
			//
			//Fecha a tabelas
			//
			TMPSF1->(dbCloseArea())
			TMPSE2->(dbCloseArea())
			//
			//Pula para o proximo fornecedor
			//
			TMP1->(dbSkip())
		EndDo
	FClose(hdl)                           
	TMP1->(dbCloseArea())
Return      

