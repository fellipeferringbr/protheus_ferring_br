#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'rwmake.CH'   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHLFIS001  บAutor  ณ Rodrigo Correa     บ Data ณ  10/08/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExporta para Excel Relatorio Fechamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function HLFIS001()

	Local lRet	   := .T.
	Local cDesc1   := "Esta rotina gera um arquivo em Excel contendo"
	Local cDesc2   := "Informacoes para o Fechamento Mensal "
	Local cDesc3   := " "
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local cTitulo := "Gera็ใo de Arquivo"
	Private cPerg    := "HLFIS001  "
	Private cPathLoc := ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica as perguntas selecionadas                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	// *** Chamada de funcao para criacao de perguntas no SX1 ***
	//Pergunte(cPerg,.F.)
	ValidPerg()
	Pergunte(cPerg,.F.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ   * * * * * * * * * *  MONTAGEM DA TELA  * * * * * * * * * * * *    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	@ 200,1 TO 380,380 DIALOG oDlg TITLE OemToAnsi("Gerao de Arquivo Excel")
	@ 02,10 TO 080,190
	@ 10,018 Say " Este programa ir  gerar um arquivo Excel
	@ 20,018 Say " no diret๓rio C:\TEMP\ , conforme os"
	@ 30,018 Say " parametros definidos pelo usuแrio, no formato xls. "

	@ 70,090 BMPBUTTON TYPE  1 ACTION SelReg()
	@ 70,150 BMPBUTTON TYPE  5 ACTION Pergunte(cPerg,.T.)

	Activate Dialog oDlg Centered
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSelReg    บAutor  ณCecilia             บ Data ณ  02/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona Registros                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelReg()

	Local lRet	  := .T.
	Local cDesc1  := "Esta rotina gera um arquivo em excel"
	Local cDesc2  := " "
	Local cDesc3  := " "
	Local aSay    := {}
	Local aButton := {}
	Local nOpc    := 0
	Local nCont   := 0
	Local cTitulo := "Gera็ใo de Arquivo"
	Local ni := 0

	_dDATAde      := mv_par01             // Data de
	_dDATAate     := mv_par02             // Data Ate     
	_cFilde       := mv_par04             // Data de
	_cFilate      := mv_par05             // Data Ate     


	IF MV_PAR03 = 1 //ENTRADA
		aStru := {}
		Aadd(aStru, { "TRB_FORNEC"  ,"C",06,0}) //FORNECEDOR
		Aadd(aStru, { "TRB_LOJA"    ,"C",04,0}) //LOJA
		Aadd(aStru, { "TRB_NOME"    ,"C",50,0}) //NOME FOR
		Aadd(aStru, { "TRB_DTDIGI"  ,"D",08,0}) //DTDIGIT
		Aadd(aStru, { "TRB_EMISSA"  ,"D",08,0}) //EMISSAO
		Aadd(aStru, { "TRB_DOC"     ,"C",09,0}) //DOC
		Aadd(aStru, { "TRB_SERIE"   ,"C",03,0}) //SERIE
		Aadd(aStru, { "TRB_ESPECI"  ,"C",05,0}) //ESPECIE DOC
		Aadd(aStru, { "TRB_EST"     ,"C",02,0}) //ESTADO
		Aadd(aStru, { "TRB_TES"     ,"C",03,0}) //TES
		Aadd(aStru, { "TRB_CF"      ,"C",05,0}) //CF
		Aadd(aStru, { "TRB_CLASFI"  ,"C",03,0}) //SITUACAO TRIBUTARIA
		Aadd(aStru, { "TRB_ITEM"    ,"C",04,0}) //ITEM
		Aadd(aStru, { "TRB_COD"     ,"C",15,0}) //COD PRODUTO
		Aadd(aStru, { "TRB_DESC"    ,"C",40,0}) // DESCRICAO DO PRODUTO
		Aadd(aStru, { "TRB_UM"      ,"C",02,0}) //UNIDADE
		Aadd(aStru, { "TRB_SEGUM"   ,"C",02,0}) //SEGUNDA UNIDADE
		Aadd(aStru, { "TRB_QUANT"   ,"N",11,2}) //QUANTIDADE
		Aadd(aStru, { "TRB_QTSEGU"  ,"N",13,2}) //QUANTIDADE SEGUNDA UNIDADE
		//	Aadd(aStru, { "TRB_QTSEGU"  ,"N",11,2}) //QUANTIDADE SEGUNDA UNIDADE
		Aadd(aStru, { "TRB_VUNIT"   ,"N",14,2}) //VALOR UNITARIO
		Aadd(aStru, { "TRB_TOTAL"   ,"N",14,2}) //VALOR TOTAL
		Aadd(aStru, { "TRB_VALBRU"  ,"N",14,2}) //VALOR BRUTO
		Aadd(aStru, { "TRB_VALDES"  ,"N",12,2}) //DESCONTO
		Aadd(aStru, { "TRB_VALFRE"  ,"N",14,2}) //FRETE
		Aadd(aStru, { "TRB_BASEIC"  ,"N",14,2}) //BASE ICM
		Aadd(aStru, { "TRB_PICM"    ,"N",05,2}) //ALIQ ICM
		Aadd(aStru, { "TRB_VALICM"  ,"N",14,2}) //VAL ICM
		Aadd(aStru, { "TRB_VICMRE"  ,"N",14,2}) //VAL ICM RETIDO (SOLIDARIO) RODRIGO 17/08/10
		Aadd(aStru, { "TRB_BASEIP"  ,"N",14,2}) //BASE IPI
		Aadd(aStru, { "TRB_IPI"     ,"N",06,2}) //ALIQ IPI
		Aadd(aStru, { "TRB_VALIPI"  ,"N",14,2}) //VAL IPI
		Aadd(aStru, { "TRB_BASIM5"  ,"N",14,2}) //BASE IMP 5
		Aadd(aStru, { "TRB_ALQIM5"  ,"N",06,2}) //ALIQ IMP 5
		Aadd(aStru, { "TRB_VALIM5"  ,"N",14,2}) //VAL IMP 5
		Aadd(aStru, { "TRB_BASIM6"  ,"N",14,2}) //BASE IMP 6
		Aadd(aStru, { "TRB_ALQIM6"  ,"N",06,2}) //ALIQ IMP 6
		Aadd(aStru, { "TRB_VALIM6"  ,"N",14,2}) //VAL IMP 6
		Aadd(aStru, { "TRB_CC"      ,"C",09,0}) //CENTRO DE CUSTO
		Aadd(aStru, { "TRB_BASEIR"  ,"N",14,2}) //BASE IR
		Aadd(aStru, { "TRB_ALIQIR"  ,"N",05,2}) //ALIQ IR
		Aadd(aStru, { "TRB_VALIRR"  ,"N",14,2}) //VALOR IR
		Aadd(aStru, { "TRB_BASEIS"  ,"N",14,2}) //BASE ISS
		Aadd(aStru, { "TRB_ALIQIS"  ,"N",05,2}) //ALIQ ISS
		Aadd(aStru, { "TRB_VALISS"  ,"N",14,2}) //VALOR ISS
		Aadd(aStru, { "TRB_BASEIN"  ,"N",14,2}) //BASE INSS
		Aadd(aStru, { "TRB_ALIQIN"  ,"N",05,2}) //ALIQ INSS
		Aadd(aStru, { "TRB_VALINS"  ,"N",14,2}) //VAL INSS
		Aadd(aStru, { "TRB_VALPIS"  ,"N",14,2}) //VAL PIS
		Aadd(aStru, { "TRB_VALCOF"  ,"N",14,2}) //VAL COFINS
		Aadd(aStru, { "TRB_VALCSL"  ,"N",14,2}) //VAL CSLL   
		Aadd(aStru, { "TRB_CSTIPI"  ,"C",02,0}) //CST IPI   //RODRIGO 13/03/12
		Aadd(aStru, { "TRB_CSTPIS"  ,"C",02,0}) //CST PIS   //RODRIGO 13/03/12
		Aadd(aStru, { "TRB_CSTCOF"  ,"C",02,0}) //CST COF   //RODRIGO 13/03/12 
		Aadd(aStru, { "TRB_DIFAL"  ,"N",14,2}) //VALOR DIFAL   //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_VFCDIF" ,"N",14,2}) //VALOR FCPDIF  //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_PDDES"  ,"N",05,2}) //ALIQUOTA DESTINO //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_PDORI"  ,"N",05,2}) //ALIQUOTA ORIGEM  //RODRIGO 10/08/18 
		Aadd(aStru, { "TRB_BASDES" ,"N",14,2}) //BASE DESTINO //RODRIGO 10/08/18  
		Aadd(aStru, { "TRB_BSFCST" ,"N",14,2}) //BASE FCP ST  //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_ALFCST" ,"N",05,2}) //ALIQUOTA FCP ST //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_VFECST" ,"N",14,2}) //VALOR FCP ST  //RODRIGO 10/08/18 


		//		_cArqTmp := CriaTrab(aStru,.T.)
		//		DbUseArea(.T.,__LocalDriver,_cArqTmp,"TRB",.T.)
		oTempTable := FWTemporaryTable():New("TRB")
		oTemptable:SetFields(aStru)
		oTempTable:AddIndex("index01",{"TRB_FORNEC"})
		oTempTable:Create()


		DbSelectArea("SD1")
		aStru2:= SD1->(dbStruct())
		DbCloseArea()

		//	cQuery :=cQuery := "SELECT * "
		//	cQuery := cQuery + " FROM " + RetSQLName("SD1") + " SD1, " + RetSQLName("SF1") + " SF1, "  + RetSQLName("SA2") + " SA2, "  + RetSQLName("SB1") + " SB1 "
		//	cQuery := cQuery + " WHERE  SD1.D1_FILIAL  = SF1.F1_FILIAL  AND"
		//	cQuery := cQuery + "        SD1.D1_DOC     = SF1.F1_DOC     AND"
		//	cQuery := cQuery + "        SD1.D1_SERIE   = SF1.F1_SERIE   AND"
		//	cQuery := cQuery + "        SD1.D1_FORNECE = SF1.F1_FORNECE  AND"
		//	cQuery := cQuery + "        SD1.D1_LOJA    = SF1.F1_LOJA    AND"
		//	cQuery := cQuery + "        SD1.D1_COD     = SB1.B1_COD     AND"
		//	cQuery := cQuery + "        SD1.D1_FORNECE = SA2.A2_COD     AND"
		//	cQuery := cQuery + "        SD1.D1_LOJA    = SA2.A2_LOJA    AND"
		//	cQuery := cQuery + "        SD1.D1_DTDIGIT  >= '"  + dtos(_dDATAde)  + "' AND"
		//	cQuery := cQuery + "        SD1.D1_DTDIGIT  <= '"  + dtos(_dDATAate) + "' AND"
		//	cQuery := cQuery + "        SD1.D1_FILIAL  >= '"   + _cFilDe  + "' AND"
		//	cQuery := cQuery + "        SD1.D1_FILIAL  <= '"   + _cFilAte + "' AND"
		//	cQuery := cQuery + " SD1.D_E_L_E_T_  = ' ' AND "
		//	cQuery := cQuery + " SF1.D_E_L_E_T_  = ' ' AND "
		//	cQuery := cQuery + " SA2.D_E_L_E_T_  = ' ' AND "
		//	cQuery := cQuery + " SB1.D_E_L_E_T_  = ' '"
		//	cQuery := cQuery + " ORDER BY SD1.D1_FILIAL,SD1.D1_DOC"

		cQuery := cQuery := "SELECT CASE WHEN (F1_TIPO IN ('N','C','I')) THEN "
		cQuery := cQuery + "(SELECT TOP 1 A2_NOME FROM " + RetSQLName("SA2") + " WHERE A2_COD=F1_FORNECE AND A2_LOJA=F1_LOJA AND D_E_L_E_T_ = ' ') "
		cQuery := cQuery + " ELSE "
		cQuery := cQuery + "(SELECT TOP 1 A1_NOME FROM " + RetSQLName("SA1") + " WHERE A1_COD=F1_FORNECE AND A1_LOJA=F1_LOJA AND D_E_L_E_T_ = ' ') "
		cQuery := cQuery + " END NOME ,* "	
		cQuery := cQuery + " FROM " + RetSQLName("SD1") + " SD1 " 
		cQuery := cQuery + " INNER JOIN " + RetSQLName("SF1") + " SF1 ON "	
		cQuery := cQuery + "        SD1.D1_FILIAL  = SF1.F1_FILIAL  AND"
		cQuery := cQuery + "        SD1.D1_DOC     = SF1.F1_DOC     AND"
		cQuery := cQuery + "        SD1.D1_SERIE   = SF1.F1_SERIE   AND"
		cQuery := cQuery + "        SD1.D1_FORNECE = SF1.F1_FORNECE AND"
		cQuery := cQuery + "        SD1.D1_LOJA    = SF1.F1_LOJA    AND"
		cQuery := cQuery + "        SD1.D_E_L_E_T_  = ' ' AND "
		cQuery := cQuery + "        SF1.D_E_L_E_T_  = ' ' "
		cQuery := cQuery + " INNER JOIN " + RetSQLName("SB1") + " SB1 ON "	
		cQuery := cQuery + "        SD1.D1_COD     = SB1.B1_COD     AND"
		cQuery := cQuery + "        SB1.D_E_L_E_T_  = ' '"
		cQuery := cQuery + " INNER JOIN " + RetSQLName("SF4") + " SF4 ON "	
		cQuery := cQuery + "        SD1.D1_TES     = SF4.F4_CODIGO   AND"
		cQuery := cQuery + "        SF4.D_E_L_E_T_  = ' '"
		cQuery := cQuery + " WHERE "	
		cQuery := cQuery + "        SD1.D1_DTDIGIT  >= '"  + dtos(_dDATAde)  + "' AND"
		cQuery := cQuery + "        SD1.D1_DTDIGIT  <= '"  + dtos(_dDATAate) + "' AND"
		cQuery := cQuery + "        SD1.D1_FILIAL  >= '"   + _cFilDe  + "' AND"
		cQuery := cQuery + "        SD1.D1_FILIAL  <= '"   + _cFilAte + "'"
		cQuery := cQuery + " ORDER BY SD1.D1_FILIAL,SD1.D1_DOC"
		cQuery := ChangeQuery(cQuery)


		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.F.)

		For ni := 1 to Len(aStru2)
			If aStru2[ni,2] != 'C'
				TCSetField('TMP', aStru2[ni,1], aStru2[ni,2],aStru2[ni,3],aStru2[ni,4])
			Endif
		Next

		dbSelectArea("TMP")
		DbGoTop()
		While !Eof()
			RecLock("TRB",.T.)
			TRB_FORNEC := TMP->D1_FORNECE
			TRB_LOJA   := TMP->D1_LOJA
			//		TRB_NOME   := TMP->A2_NOME
			TRB_NOME   := TMP->NOME
			TRB_DTDIGI := TMP->D1_DTDIGIT
			TRB_EMISSA := TMP->D1_EMISSAO
			TRB_DOC    := TMP->D1_DOC
			TRB_SERIE  := TMP->D1_SERIE
			TRB_ESPECI := TMP->F1_ESPECIE
			TRB_EST    := TMP->F1_EST
			TRB_TES    := TMP->D1_TES
			TRB_CF     := TMP->D1_CF
			TRB_CLASFI := TMP->D1_CLASFIS
			TRB_ITEM   := TMP->D1_ITEM
			TRB_COD    := TMP->D1_COD
			TRB_DESC   := TMP->B1_DESC
			TRB_UM     := TMP->D1_UM
			TRB_SEGUM  := TMP->D1_SEGUM
			TRB_QUANT  := TMP->D1_QUANT
			TRB_QTSEGU := TMP->D1_QTSEGUM
			TRB_VUNIT  := TMP->D1_VUNIT
			TRB_TOTAL  := TMP->D1_TOTAL
			TRB_VALBRU := TMP->F1_VALBRUT
			TRB_VALDES := TMP->D1_VALDESC
			TRB_VALFRE := TMP->D1_VALFRE
			TRB_BASEIC := TMP->D1_BASEICM
			TRB_PICM   := TMP->D1_PICM
			TRB_VALICM := TMP->D1_VALICM
			TRB_VICMRE := TMP->D1_ICMSRET //RODRIGO 17/08/10
			TRB_BASEIP := TMP->D1_BASEIPI
			TRB_IPI    := TMP->D1_IPI
			TRB_VALIPI := TMP->D1_VALIPI
			TRB_BASIM5 := TMP->D1_BASIMP5
			TRB_ALQIM5 := TMP->D1_ALQIMP5
			TRB_VALIM5 := TMP->D1_VALIMP5
			TRB_BASIM6 := TMP->D1_BASIMP6
			TRB_ALQIM6 := TMP->D1_ALQIMP6
			TRB_VALIM6 := TMP->D1_VALIMP6
			TRB_CC     := TMP->D1_CC
			TRB_BASEIR := TMP->D1_BASEIRR
			TRB_ALIQIR := TMP->D1_ALIQIRR
			TRB_VALIRR := TMP->D1_VALIRR
			TRB_BASEIS := TMP->D1_BASEISS
			TRB_ALIQIS := TMP->D1_ALIQISS
			TRB_VALISS := TMP->D1_VALISS
			TRB_BASEIN := TMP->D1_BASEINS
			TRB_ALIQIN := TMP->D1_ALIQINS
			TRB_VALINS := TMP->D1_VALINS
			TRB_VALPIS := TMP->F1_VALPIS
			TRB_VALCOF := TMP->F1_VALCOFI
			TRB_VALCSL := TMP->F1_VALCSLL  
			TRB_CSTIPI := TMP->F4_CTIPI  
			TRB_CSTPIS := TMP->F4_CSTPIS  
			TRB_CSTCOF := TMP->F4_CSTCOF 
			TRB_DIFAL  := TMP->D1_DIFAL
			TRB_VFCDIF := TMP->D1_VFCPDIF
			TRB_PDDES  := TMP->D1_PDDES
			TRB_PDORI  := TMP->D1_PDORI
			TRB_BASDES := TMP->D1_BASEDES
			TRB_BSFCST := TMP->D1_BSFCPST
			TRB_ALFCST := TMP->D1_ALFCPST
			TRB_VFECST := TMP->D1_VFECPST

			TRB->(MsUnLock())

			dbSelectArea("TMP")
			DbSkip()
		End

		aAdd( aSay, cDesc1 )
		aAdd( aSay, cDesc2 )
		aAdd( aSay, cDesc3 )

		aAdd( aButton, { 5, .T., { || cPathLoc := SelArq()   } } )
		aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
		aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

		FormBatch( cTitulo, aSay, aButton )

		If nOpc <> 1
			lRet := .F.
		Else
			if Empty(cPathLoc)
				//			cPathLoc := "C:\relato_microsiga\"
				cPathLoc := "C:\TEMP\"
			Endif
			Processa({|| ProcInt()}, "Gerando integra็ใo...")
		EndIf

	ENDIF

	IF MV_PAR03 = 2 //SAIDA
		aStru := {}
		Aadd(aStru, { "TRB_CLIENT"  ,"C",06,0}) //FORNECEDOR
		Aadd(aStru, { "TRB_LOJA"    ,"C",04,0}) //LOJA
		Aadd(aStru, { "TRB_NOME"    ,"C",50,0}) //NOME FOR
		//	Aadd(aStru, { "TRB_DTDIGI"  ,"D",08,0}) //DTDIGIT
		Aadd(aStru, { "TRB_EMISSA"  ,"D",08,0}) //EMISSAO
		Aadd(aStru, { "TRB_DOC"     ,"C",09,0}) //DOC
		Aadd(aStru, { "TRB_SERIE"   ,"C",03,0}) //SERIE
		Aadd(aStru, { "TRB_ESPECI"  ,"C",05,0}) //ESPECIE DOC
		Aadd(aStru, { "TRB_EST"     ,"C",02,0}) //ESTADO
		Aadd(aStru, { "TRB_TES"     ,"C",03,0}) //TES
		Aadd(aStru, { "TRB_CF"      ,"C",05,0}) //CF
		Aadd(aStru, { "TRB_CLASFI"  ,"C",03,0}) //SITUACAO TRIBUTARIA
		Aadd(aStru, { "TRB_ITEM"    ,"C",04,0}) //ITEM
		Aadd(aStru, { "TRB_COD"     ,"C",15,0}) //COD PRODUTO
		Aadd(aStru, { "TRB_DESC"    ,"C",40,0}) // DESCRICAO DO PRODUTO
		Aadd(aStru, { "TRB_UM"      ,"C",02,0}) //UNIDADE
		Aadd(aStru, { "TRB_SEGUM"   ,"C",02,0}) //SEGUNDA UNIDADE
		Aadd(aStru, { "TRB_QUANT"   ,"N",11,2}) //QUANTIDADE
		Aadd(aStru, { "TRB_QTSEGU"  ,"N",11,2}) //QUANTIDADE SEGUNDA UNIDADE
		Aadd(aStru, { "TRB_VUNIT"   ,"N",14,2}) //VALOR UNITARIO
		Aadd(aStru, { "TRB_TOTAL"   ,"N",14,2}) //VALOR TOTAL
		Aadd(aStru, { "TRB_VALBRU"  ,"N",14,2}) //VALOR BRUTO
		Aadd(aStru, { "TRB_VALDES"  ,"N",12,2}) //DESCONTO
		Aadd(aStru, { "TRB_VALFRE"  ,"N",14,2}) //FRETE
		Aadd(aStru, { "TRB_BASEIC"  ,"N",14,2}) //BASE ICM
		Aadd(aStru, { "TRB_PICM"    ,"N",05,2}) //ALIQ ICM
		Aadd(aStru, { "TRB_VALICM"  ,"N",14,2}) //VAL ICM
		Aadd(aStru, { "TRB_VICMRE"  ,"N",14,2}) //VALOR DO ICMS RETIDO
		Aadd(aStru, { "TRB_BASEIP"  ,"N",14,2}) //BASE IPI
		Aadd(aStru, { "TRB_IPI"     ,"N",06,2}) //ALIQ IPI
		Aadd(aStru, { "TRB_VALIPI"  ,"N",14,2}) //VAL IPI
		Aadd(aStru, { "TRB_BASIM5"  ,"N",14,2}) //BASE IMP 5
		Aadd(aStru, { "TRB_ALQIM5"  ,"N",06,2}) //ALIQ IMP 5
		Aadd(aStru, { "TRB_VALIM5"  ,"N",14,2}) //VAL IMP 5
		Aadd(aStru, { "TRB_BASIM6"  ,"N",14,2}) //BASE IMP 6
		Aadd(aStru, { "TRB_ALQIM6"  ,"N",06,2}) //ALIQ IMP 6
		Aadd(aStru, { "TRB_VALIM6"  ,"N",14,2}) //VAL IMP 6
		//	Aadd(aStru, { "TRB_CC"      ,"C",09,0}) //CENTRO DE CUSTO
		Aadd(aStru, { "TRB_BASEIR"  ,"N",14,2}) //BASE IR
		//	Aadd(aStru, { "TRB_ALIQIR"  ,"N",05,2}) //ALIQ IR
		Aadd(aStru, { "TRB_BASEIS"  ,"N",14,2}) //BASE ISS
		Aadd(aStru, { "TRB_ALIQIS"  ,"N",05,2}) //ALIQ ISS
		Aadd(aStru, { "TRB_VALISS"  ,"N",14,2}) //VALOR ISS
		Aadd(aStru, { "TRB_BASEIN"  ,"N",14,2}) //BASE INSS
		Aadd(aStru, { "TRB_ALIQIN"  ,"N",05,2}) //ALIQ INSS
		Aadd(aStru, { "TRB_VALINS"  ,"N",14,2}) //VAL INSS
		Aadd(aStru, { "TRB_VALPIS"  ,"N",14,2}) //VAL PIS
		Aadd(aStru, { "TRB_VALCOF"  ,"N",14,2}) //VAL COFINS
		Aadd(aStru, { "TRB_VALCSL"  ,"N",14,2}) //VAL CSLL
		Aadd(aStru, { "TRB_CSTIPI"  ,"C",02,0}) //CST IPI   //RODRIGO 13/03/12
		Aadd(aStru, { "TRB_CSTPIS"  ,"C",02,0}) //CST PIS   //RODRIGO 13/03/12
		Aadd(aStru, { "TRB_CSTCOF"  ,"C",02,0}) //CST COF   //RODRIGO 13/03/12 
		Aadd(aStru, { "TRB_DIFAL"  ,"N",14,2}) //VALOR DIFAL   //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_VFCDIF" ,"N",14,2}) //VALOR FCPDIF  //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_PDDES"  ,"N",05,2}) //ALIQUOTA DESTINO //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_PDORI"  ,"N",05,2}) //ALIQUOTA ORIGEM  //RODRIGO 10/08/18 
		Aadd(aStru, { "TRB_BASDES" ,"N",14,2}) //BASE DESTINO //RODRIGO 10/08/18  
		Aadd(aStru, { "TRB_BSFCST" ,"N",14,2}) //BASE FCP ST  //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_ALFCST" ,"N",05,2}) //ALIQUOTA FCP ST //RODRIGO 10/08/18
		Aadd(aStru, { "TRB_VFECST" ,"N",14,2}) //VALOR FCP ST  //RODRIGO 10/08/18 

		//	_cArqTmp := CriaTrab(aStru,.T.)
		//	DbUseArea(.T.,__LocalDriver,_cArqTmp,"TRB",.T.)

		oTempTables := FWTemporaryTable():New(TRB)
		oTemptables:SetFields(aStru)
		oTempTables:AddIndex("index01",{"TRB_CLIENT"})
		oTempTables:Create()


		DbSelectArea("SD2")
		aStru2:= SD2->(dbStruct())
		DbCloseArea()

		//	cQuery :=cQuery := "SELECT * "
		//	cQuery := cQuery + " FROM " + RetSQLName("SD2") + " SD2, " + RetSQLName("SF2") + " SF2, "  + RetSQLName("SA1") + " SA1, "  + RetSQLName("SB1") + " SB1 "
		//	cQuery := cQuery + " WHERE  SD2.D2_FILIAL  = SF2.F2_FILIAL  AND"
		// 	cQuery := cQuery + "        SD2.D2_DOC     = SF2.F2_DOC     AND"
		// 	cQuery := cQuery + "        SD2.D2_SERIE   = SF2.F2_SERIE   AND"
		// 	cQuery := cQuery + "        SD2.D2_CLIENTE = SF2.F2_CLIENTE  AND"
		// 	cQuery := cQuery + "        SD2.D2_LOJA    = SF2.F2_LOJA    AND"
		// 	cQuery := cQuery + "        SD2.D2_COD     = SB1.B1_COD     AND"
		// 	cQuery := cQuery + "        SD2.D2_CLIENTE = SA1.A1_COD     AND"
		// 	cQuery := cQuery + "        SD2.D2_LOJA    = SA1.A1_LOJA    AND"
		// 	cQuery := cQuery + "        SD2.D2_EMISSAO  >= '"  + dtos(_dDATAde)  + "' AND"
		// 	cQuery := cQuery + "        SD2.D2_EMISSAO  <= '"  + dtos(_dDATAate) + "' AND"
		// 	cQuery := cQuery + "        SD2.D2_FILIAL  >= '"   + _cFilDe  + "' AND"
		// 	cQuery := cQuery + "        SD2.D2_FILIAL  <= '"   + _cFilAte + "' AND"
		//	cQuery := cQuery + " SD2.D_E_L_E_T_  = ' ' AND "
		//	cQuery := cQuery + " SF2.D_E_L_E_T_  = ' ' AND "
		//	cQuery := cQuery + " SA1.D_E_L_E_T_  = ' ' AND "
		//	cQuery := cQuery + " SB1.D_E_L_E_T_  = ' '"
		//	cQuery := cQuery + " ORDER BY SD2.D2_FILIAL,SD2.D2_DOC"
		//	cQuery := ChangeQuery(cQuery)  




		cQuery := cQuery := "SELECT CASE WHEN (F2_TIPO = 'N') THEN "
		cQuery := cQuery + "(SELECT TOP 1 A1_NOME FROM " + RetSQLName("SA1") + " WHERE A1_COD=F2_CLIENTE AND A1_LOJA=F2_LOJA AND D_E_L_E_T_ = ' ') "
		cQuery := cQuery + " ELSE "
		cQuery := cQuery + "(SELECT TOP 1 A2_NOME FROM " + RetSQLName("SA2") + " WHERE A2_COD=F2_CLIENTE AND A2_LOJA=F2_LOJA AND D_E_L_E_T_ = ' ') "
		cQuery := cQuery + " END NOME ,* "	
		cQuery := cQuery + " FROM " + RetSQLName("SD2") + " SD2 " 
		cQuery := cQuery + " INNER JOIN " + RetSQLName("SF2") + " SF2 ON "	
		cQuery := cQuery + "        SD2.D2_FILIAL  = SF2.F2_FILIAL  AND"
		cQuery := cQuery + "        SD2.D2_DOC     = SF2.F2_DOC     AND"
		cQuery := cQuery + "        SD2.D2_SERIE   = SF2.F2_SERIE   AND"
		cQuery := cQuery + "        SD2.D2_CLIENTE = SF2.F2_CLIENTE  AND"
		cQuery := cQuery + "        SD2.D2_LOJA    = SF2.F2_LOJA    AND"
		cQuery := cQuery + "        SD2.D_E_L_E_T_  = ' ' AND "
		cQuery := cQuery + "        SF2.D_E_L_E_T_  = ' ' "
		cQuery := cQuery + " INNER JOIN " + RetSQLName("SB1") + " SB1 ON "	
		cQuery := cQuery + "        SD2.D2_COD     = SB1.B1_COD     AND"
		cQuery := cQuery + "        SB1.D_E_L_E_T_  = ' '"
		cQuery := cQuery + " INNER JOIN " + RetSQLName("SF4") + " SF4 ON "	
		cQuery := cQuery + "        SD2.D2_TES     = SF4.F4_CODIGO   AND"
		cQuery := cQuery + "        SF4.D_E_L_E_T_  = ' '"
		cQuery := cQuery + " WHERE "	
		cQuery := cQuery + "        SD2.D2_EMISSAO  >= '"  + dtos(_dDATAde)  + "' AND"
		cQuery := cQuery + "        SD2.D2_EMISSAO  <= '"  + dtos(_dDATAate) + "' AND"
		cQuery := cQuery + "        SD2.D2_FILIAL  >= '"   + _cFilDe  + "' AND"
		cQuery := cQuery + "        SD2.D2_FILIAL  <= '"   + _cFilAte + "'"
		cQuery := cQuery + " ORDER BY SD2.D2_FILIAL,SD2.D2_DOC"
		cQuery := ChangeQuery(cQuery)
		//MEMOWRITE("C:\TEMP\relatorio.SQL", cQuery)	
		//	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.F.)






		For ni := 1 to Len(aStru2)
			If aStru2[ni,2] != 'C'
				TCSetField('TMP', aStru2[ni,1], aStru2[ni,2],aStru2[ni,3],aStru2[ni,4])
			Endif
		Next


		dbSelectArea("TMP")
		DbGoTop()
		While !Eof()
			RecLock("TRB",.T.)
			TRB_CLIENT := TMP->D2_CLIENTE
			TRB_LOJA   := TMP->D2_LOJA
			//	TRB_NOME   := TMP->A1_NOME
			TRB_NOME   := TMP->NOME
			//	TRB_DTDIGI := TMP->D2_DTDIGIT
			TRB_EMISSA := TMP->D2_EMISSAO
			TRB_DOC    := TMP->D2_DOC
			TRB_SERIE  := TMP->D2_SERIE
			TRB_ESPECI := TMP->F2_ESPECIE
			TRB_EST    := TMP->F2_EST
			TRB_TES    := TMP->D2_TES
			TRB_CF     := TMP->D2_CF
			TRB_CLASFI := TMP->D2_CLASFIS
			TRB_ITEM   := TMP->D2_ITEM
			TRB_COD    := TMP->D2_COD
			TRB_DESC   := TMP->B1_DESC
			TRB_UM     := TMP->D2_UM
			TRB_SEGUM  := TMP->D2_SEGUM
			TRB_QUANT  := TMP->D2_QUANT
			TRB_QTSEGU := TMP->D2_QTSEGUM
			TRB_VUNIT  := TMP->D2_PRCVEN
			TRB_TOTAL  := TMP->D2_TOTAL
			TRB_VALBRU := TMP->F2_VALBRUT
			TRB_VALDES := TMP->D2_DESCON
			TRB_VALFRE := TMP->D2_VALFRE
			TRB_BASEIC := TMP->D2_BASEICM
			TRB_PICM   := TMP->D2_PICM
			TRB_VALICM := TMP->D2_VALICM
			TRB_VICMRE := TMP->D2_ICMSRET  
			TRB_BASEIP := TMP->D2_BASEIPI
			TRB_IPI    := TMP->D2_IPI
			TRB_VALIPI := TMP->D2_VALIPI
			TRB_BASIM5 := TMP->D2_BASIMP5
			TRB_ALQIM5 := TMP->D2_ALQIMP5
			TRB_VALIM5 := TMP->D2_VALIMP5
			TRB_BASIM6 := TMP->D2_BASIMP6
			TRB_ALQIM6 := TMP->D2_ALQIMP6
			TRB_VALIM6 := TMP->D2_VALIMP6
			//		TRB_CC     := TMP->D2_CC
			TRB_BASEIR := TMP->D2_BASEIRR
			//		TRB_ALIQIR := TMP->D2_ALIQIRR
			TRB_BASEIS := TMP->D2_BASEISS
			TRB_ALIQIS := TMP->D2_ALIQISS
			TRB_VALISS := TMP->D2_VALISS
			TRB_BASEIN := TMP->D2_BASEINS
			TRB_ALIQIN := TMP->D2_ALIQINS
			TRB_VALINS := TMP->D2_VALINS
			TRB_VALPIS := TMP->F2_VALPIS
			TRB_VALCOF := TMP->F2_VALCOFI
			TRB_VALCSL := TMP->F2_VALCSLL
			TRB_CSTIPI := TMP->F4_CTIPI  
			TRB_CSTPIS := TMP->F4_CSTPIS  
			TRB_CSTCOF := TMP->F4_CSTCOF
			TRB_DIFAL  := TMP->D2_DIFAL
			TRB_VFCDIF:= TMP->D2_VFCPDIF
			TRB_PDDES  := TMP->D2_PDDES
			TRB_PDORI  := TMP->D2_PDORI
			TRB_BASDES:= TMP->D2_BASEDES
			TRB_BSFCST:= TMP->D2_BSFCPST
			TRB_ALFCST:= TMP->D2_ALFCPST
			TRB_VFECST:= TMP->D2_VFECPST  

			TRB->(MsUnLock())

			dbSelectArea("TMP")
			DbSkip()
		End

		aAdd( aSay, cDesc1 )
		aAdd( aSay, cDesc2 )
		aAdd( aSay, cDesc3 )

		aAdd( aButton, { 5, .T., { || cPathLoc := SelArq()   } } )
		aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
		aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

		FormBatch( cTitulo, aSay, aButton )

		If nOpc <> 1
			lRet := .F.
		Else
			if Empty(cPathLoc)
				//			cPathLoc := "C:\relato_microsiga\"
				cPathLoc := "C:\TEMP\"
			Endif
			Processa({|| ProcInt()}, "Gerando integra็ใo...")
		EndIf

	ENDIF

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcInt   บAutor  ณCecilia             บ Data ณ  02/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para gerar um arquivo com extensใo .xls com os      บฑฑ
ฑฑบ          ณ dados filtrados.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcInt()

	Local _aArea    := GetArea()
	Local cPath     := cPathLoc
	Local nHandle   := 0
	Local cArqPesq 	:= cPath + "Fechamento.xls"
	Local cCabHtml  := ""
	Local cLinFile  := ""
	Local cFileCont := ""
	Private nCt      := 0

	//	ProcRegua( nCt )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria um arquivo do tipo *.xls	                                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nHandle := FCREATE(cArqPesq, 0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o arquivo pode ser criado, caso contrario um alerta sera exibido      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If FERROR() != 0
		Alert("Nใo foi possํvel abrir ou criar o arquivo: " + cArqPesq )
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤิ
	//ณmonta cabe็alho de pagina HTML para posterior utiliza็ใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤิ
	cCabHtml := "<!-- Created with AEdiX by Kirys Tech 2000,http://www.kt2k.com --> " + CRLF
	cCabHtml += "<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>" + CRLF
	cCabHtml += "<html>" + CRLF
	cCabHtml += "<head>" + CRLF
	cCabHtml += "  <title>Fechamento</title>" + CRLF
	cCabHtml += "  <meta name='GENERATOR' content='AEdiX by Kirys Tech 2000,http://www.kt2k.com'>" + CRLF
	cCabHtml += "</head>" + CRLF
	cCabHtml += "<body bgcolor='#FFFFFF'>" + CRLF
	cCabHtml += "" + CRLF


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHง
	//ณMonta Rodape Html para posterior utiliza็aoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHง

	cRodHtml := "</body>" + CRLF
	cRodHtml += "</html>" + CRLF

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAqui come็a a montagem da pagina html propriamente ditaณ
	//ณ	 acrescenta o cabe็alho                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cFileCont := cCabHtml

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ//Aqui come็a o corpo da pagina mesmo                                                                                         ณ
	//ณ// Inicia uma tabela html e alimenta a variavel do relatorio ja que o relatorio inteiro estara contido em apenas uma variavelณ
	//ณ	// estrutura basica de tabela em html                                                                                        ณ
	//ณ	// <table> inicia uma tabela                                                                                                 ณ
	//ณ	// <TR> inicio de linha                                                                                                      ณ
	//ณ	// <TD> </TD> Coluna de uma tabela repetir tantas vezes quantas colunas existirem                                            ณ
	//ณ	// importante!!!! o numero de colunas nao podera ser alterado dentro da table ou seja todas as linhas tem que ter o mesmo    ณ
	//ณ	// numero de colunas (para aglutinar colunas ้ necessแrio utilizar um comando especifico do html, que nใo sera exemplificado ณ
	//ณ	// aqui                                                                                                                      ณ
	//ณ	// </TR> finaliza uma linha da tabela                                                                                        ณ
	//ณ	// </Table> finaliza a tabela                                                                                                ณ
	//ณ	// Utilizado o parametro Style das colunas para formatar cor da celula e tipo da fonte                                       ณ
	//ณ	                                                                                                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	IF MV_PAR03 = 1 //ENTRADA

		cLinFile := "<Table style='background: #FFFFFF; width: 100%;' border='0' cellpadding='2' cellspacing='2'>"+ CRLF

		//Primeira linha da tabela
		cLinFile += "<TR>"
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>FORNEC         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>LOJA           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>NOME           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>DIGITAC        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>EMISSAO        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>DOC            </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>SERIE          </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ESPECIE        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ESTADO         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>TES            </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CFOP           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CLASF          </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ITEM           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CODIGO         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>DESCPRO        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>UM             </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>UMSEG          </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>QUANTI         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>QUANTSEG       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL UNIT        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL TOTAL       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL BRUTO       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL DESC        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL FRETE       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE ICMS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ ICMS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL ICMS        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL ICMS_RET    </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IPI       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IPI       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IPI         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IMP5      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IMP5      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IMP5        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IMP6      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IMP6      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IMP6        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CC             </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IRRF      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IRRF      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IRRF        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE ISS       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ ISS       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL ISS         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE INSS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ INSS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL INSS        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL PIS         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL COFINS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL CSLL        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CST IPI        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CST PIS        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CST COF        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL DIFAL       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL FCP DIF     </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ. DES      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ. ORI      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE DES       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BS FCP ST      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>AL FCP ST      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL FCP ST      </b></TD>"+ CRLF
		cLinFile += "</TR>"+ CRLF



		// anexa a linha montada ao corpo da tabela
		cFileCont += cLinFile
		cLinFile := ""
		(FWRITE(nHandle, cFileCont) )
		cLinFile := ""

		//La็o de processamento principal, aqui ้ onde devera ser feito o la็o de processo do programa
		//gerando as linhas e anexando-as ao corpo da planilha

		DbSelectArea("TRB")
		Index on TRB_COD TO _cArqTmp
		dbGoTop()
		While !Eof()
			//	IncProc()

			cLinFile := "<TR><TD> " +TRB->TRB_FORNEC +     "</TD>"+ CRLF
			cLinFile += "<TD>     " +TRB->TRB_LOJA   +    "</TD>"+ CRLF
			cLinFile += "<TD>     " +TRB->TRB_NOME   +    "</TD>"+ CRLF
			cLinFile += "<TD>    "  +DTOC(TRB->TRB_DTDIGI) + "</TD>"+ CRLF
			cLinFile += "<TD>    " +DTOC(TRB->TRB_EMISSA) + "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_DOC +     "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_SERIE +   "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_ESPECI  + "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_EST  +    "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_TES  +    "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CF  +     "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CLASFI  + "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_ITEM  +   "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_COD  +    "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_DESC  +   "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_UM  +     "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_SEGUM  +  "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_QUANT,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_QTSEGU,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VUNIT,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_TOTAL,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALBRU,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALDES,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALFRE,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIC,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_PICM,"@E 99.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALICM,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VICMRE,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIP,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_IPI,"@E 99.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIPI,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASIM5,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALQIM5,"@E 999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIM5,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASIM6,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALQIM6,"@E 999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIM6,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CC  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIR,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALIQIR,"@E 99.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIRR,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALIQIS,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALISS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIN,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALIQIN,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALINS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALPIS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALCOF,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALCSL,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CSTIPI  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CSTPIS  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CSTCOF  +"</TD>"+ CRLF		
			cLinFile += "<TD>    " +TRansform(TRB->TRB_DIFAL  ,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VFCDIF,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_PDDES  ,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_PDORI  ,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASDES,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BSFCST,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALFCST,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VFECST,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "</TR>" + CRLF


			(FWRITE(nHandle, cLinFile))
			CLinFile := ""

			dbSelectArea("TRB")
			dbSkip()
		EndDo

		cLinFile := "</Table>"

		//Acrescenta o rodap้ html
		(FWRITE(nHandle, cRodHtml))

		// fecha a tabela aberta no inicio do arquivo

		TRB->( dbCloseArea() )
		TMP->( dbCloseArea() )

		fCLose(nHandle)
		msgAlert("Abra o arquivo " + cArqPesq + " atrav้s do Excel para ver o resultado!")

		RestArea( _aArea )

	ENDIF

	IF MV_PAR03 = 2 //SAIDA

		cLinFile := "<Table style='background: #FFFFFF; width: 100%;' border='0' cellpadding='2' cellspacing='2'>"+ CRLF

		//Primeira linha da tabela
		cLinFile += "<TR>"
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CLIENTE         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>LOJA           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>NOME           </b></TD>"+ CRLF
		//	cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>DIGITAC        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>EMISSAO        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>DOC            </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>SERIE          </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ESPECIE        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ESTADO         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>TES            </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CFOP           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CLASF          </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ITEM           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CODIGO         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>DESCPRO        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>UM             </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>UMSEG           </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>QUANTI         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>QUANTSEG       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL UNIT        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL TOTAL       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL BRUTO       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL DESC        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL FRETE       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE ICMS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ ICMS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL ICMS        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL ICMS_RET    </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IPI       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IPI       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IPI         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IMP5      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IMP5      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IMP5        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IMP6      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IMP6      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL IMP6        </b></TD>"+ CRLF
		//	cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CC             </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE IRRF      </b></TD>"+ CRLF
		//	cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ IRRF      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE ISS       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ ISS       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL ISS         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE INSS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ INSS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL INSS        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL PIS         </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL COFINS      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL CSLL        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CST IPI        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CST PIS        </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>CST COF        </b></TD>"+ CRLF  
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL DIFAL       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL FCP DIF     </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ. DES      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>ALIQ. ORI      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BASE DES       </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>BS FCP ST      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>AL FCP ST      </b></TD>"+ CRLF
		cLinFile += "<TD style='Background: #FFFFC0; font-style: Bold;'><b>VL FCP ST      </b></TD>"+ CRLF
		cLinFile += "</TR>"+ CRLF


		// anexa a linha montada ao corpo da tabela
		cFileCont += cLinFile
		cLinFile := ""
		(FWRITE(nHandle, cFileCont) )
		cLinFile := ""

		//La็o de processamento principal, aqui ้ onde devera ser feito o la็o de processo do programa
		//gerando as linhas e anexando-as ao corpo da planilha

		DbSelectArea("TRB")
		Index on TRB_COD TO _cArqTmp
		dbGoTop()
		While !Eof()
			//	IncProc()

			cLinFile := "<TR><TD> " +TRB->TRB_CLIENT +     "</TD>"+ CRLF
			cLinFile += "<TD>     " +TRB->TRB_LOJA   +    "</TD>"+ CRLF
			cLinFile += "<TD>     " +TRB->TRB_NOME   +    "</TD>"+ CRLF
			//		cLinFile += "<TD>    "  +DTOC(TRB->TRB_DTDIGI) + "</TD>"+ CRLF
			cLinFile += "<TD>    " +DTOC(TRB->TRB_EMISSA) + "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_DOC +     "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_SERIE +   "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_ESPECI  + "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_EST  +    "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_TES  +    "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CF  +     "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CLASFI  + "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_ITEM  +   "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_COD  +    "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_DESC  +   "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_UM  +     "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_SEGUM  +  "</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_QUANT,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_QTSEGU,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VUNIT,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_TOTAL,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALBRU,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALDES,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALFRE,"@E 999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIC,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_PICM,"@E 99.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALICM,"@E 99,999,999.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VICMRE,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIP,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_IPI,"@E 99.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIPI,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASIM5,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALQIM5,"@E 999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIM5,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASIM6,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALQIM6,"@E 999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALIM6,"@E 99,999,999.99")   +"</TD>"+ CRLF
			//		cLinFile += "<TD>    " +TRB->TRB_CC  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIR,"@E 99,999,999.99")   +"</TD>"+ CRLF
			//		cLinFile += "<TD>    " +TRansform(TRB->TRB_ALIQIR,"@E 99.99")  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALIQIS,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALISS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASEIN,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALIQIN,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALINS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALPIS,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALCOF,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VALCSL,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CSTIPI  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CSTPIS  +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRB->TRB_CSTCOF  +"</TD>"+ CRLF  
			cLinFile += "<TD>    " +TRansform(TRB->TRB_DIFAL  ,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VFCDIF,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_PDDES  ,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_PDORI  ,"@E 99.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BASDES,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_BSFCST,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_ALFCST,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "<TD>    " +TRansform(TRB->TRB_VFECST,"@E 99,999,999.99")   +"</TD>"+ CRLF
			cLinFile += "</TR>" + CRLF


			(FWRITE(nHandle, cLinFile))
			CLinFile := ""

			dbSelectArea("TRB")
			dbSkip()
		EndDo

		cLinFile := "</Table>"

		//Acrescenta o rodap้ html
		(FWRITE(nHandle, cRodHtml))

		// fecha a tabela aberta no inicio do arquivo

		TRB->( dbCloseArea() )
		TMP->( dbCloseArea() )

		fCLose(nHandle)
		msgAlert("Abra o arquivo " + cArqPesq + " atrav้s do Excel para ver o resultado!")

		RestArea( _aArea )

	ENDIF

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSelArq    บAutor  ณ Ernani Forastieri  บ Data ณ  20/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina auxiliar de Selecao do arquivo texto a ser importadoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelArq()
	Private _cExtens   := "Arquivo XLS ( *.XLS ) |*.XLS|"
	_cRet := cGetFile( _cExtens, "Selecione o Arquivo",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
	_cRet := ALLTRIM( _cRet )
Return( _cRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ ValidPerg ณ Autor ณ Denilson Correa      ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Valida se existe as Perguntas no SX1                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()

	Local j, i := 0
	_cAlias := Alias()
	DbSelectArea("SX1")
	DbSetOrder(1)
	aRegs :={}
	Aadd(aRegs,{cPerg,"01","Data de    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"02","Data ate   ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"03","Tipo       ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","NF Entrada","","","","","NF Saida","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"04","Filial de  ?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})
	Aadd(aRegs,{cPerg,"05","Filial ate ?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				EndIf
			Next
			MsUnlock()
		EndIf
	Next
	DbSelectArea(_cAlias)
Return
