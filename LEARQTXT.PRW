#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LeArqTxt  ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Le arquivo Texto e grava em outro formato texto tabulado   ³±±
±±³          ³                                                            ³±±        
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Contabilizacao TXT                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Le arquivo Header.txt contendo informacoes das ultimas atualizacoes das tabelas Web.

User Function LeArqTxt()

	Local   _cLinAtu := ""
	Private _aLinhas := {}
	Private _cPerg := "LETXT     " 
	Private _lOk
	Private _cLote := "000001"
	Private _cDoc  := "000001"
	Private _dData2
	Private _dData
	Private _aCab
	Private _cLote
	Private _cDoc
	Private _ddataOld := ddatabase
	//GeraPerg(_cPerg)   
	Pergunte(_cPerg,.T.)

	If Msgyesno("Confirma Geração de Arquivo de Contabilização Formatado ?","YESNO" )


		_lOk:= .T.

		oProcess:= MsNewProcess():New({|| LearqProc(oProcess)},"","",.F.)
		oProcess:cTitle:="Geração de Arquivo de Contabilização Formatado"
		oProcess:Activate()
	Else
		_lOk:= .F.
	Endif

	If _lOk
		MsgAlert("Processamento Ok ")
	Else
		MsgAlert("Processamento nao realizado.")
	Endif

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LearqProc ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Le arquvo Texto nao formatadoo solicitado para processar   ³±±
±±³          ³ contabilizacao Txt.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Contabilzacao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function LearqProc()

	If !File(AllTrim(MV_PAR17))
		Aviso("Atencao","Arquivo "+AllTrim(MV_PAR17)+" nao localizado.",{"Ok"})
		_lOk:= .F.
		Return(Nil)
	Endif

	FT_FUSE(AllTrim(MV_PAR17))//      ("\TEMP\CTB\ARQ.TXT")       // Abre o Arquivo

	FT_FGOTOP()

	oProcess:SetRegua1(2700)

	While !FT_FEOF()
		_cLinAtu  := FT_FREADLN()                   // Le uma linha
		AADD(_aLinhas,_cLinAtu)

		//_cDataAtu := SubStr(_cLinAtu,01,08)

		FT_FSKIP()                                  // Posiciona na proxima linha.
		oProcess:IncRegua1("Lendo Arquivo Texto") //Incrementa primeira regua

	Enddo
	FT_FUSE()

	GeraArqTxt()

Return(Nil)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraArqTxt³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquvo Texto com formato solicitado para processar    ³±±
±±³          ³ contabilizacao Txt.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Contabilzacao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraArqTxt()

	Local _i := 0
	Private _cPath    := "\TEMP\CTB\"
	Private _cFile    := Alltrim(MV_PAR18)
	Private _cEOL     := "CHR(13)+CHR(10)"
	Private _nTamLin  := 29
	Private _cBuffer  := ""
	Private _cLin     := ""
	Private _cDebito2 := Space(20)
	Private _cCredito2:= Space(20)
	Private _cCC2D    := Space(9)
	Private _cCC2C    := Space(9)
	Private _cTipo    := " "    
	Private _aTotItem := {}
	Private lMsErroAuto := .F.


	If	File(_cFile)  // Nao executa o processo caso nao localize o arquivo. 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abre o arquivo texto inteiro.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nHandle := fOpen(_cFile,2)                         // Abre o Arquivo
		//_nBytes  := _nTamLin+2
		//While _nBytes == _nTamLin+2
		//   _nBytes  := fRead(_nHandle, @_cBuffer, _nTamLin + 2) // Le uma linha
		//   _cLin := _cLin + _cBuffer
		//End
		/////fErase(_cFile)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria um arquivo texto Novo.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_lOk:= .F.
		_nHandle := fCreate(_cFile)

		Return  // aborta o processo de geracao do log (para o notebook)
	EndIf


	If Empty(_cEOL)
		_cEOL := CHR(13)+CHR(10)
	Else
		_cEOL := Trim(_cEOL)
		_cEOL := &_cEOL
	Endif

	If _nHandle == -1
		MsgAlert("O arquivo "+_cFile+" nao pode ser criado! Verifique os parametros.","Atencao!")
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui informacoes da Nota Fiscal ao arquivo Texto.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//_cCpo := Dtoc(date()) + "  " + Time() + " Ok " + _cProcMens + _cEol

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as informacoes da(s) Nota(s) Fiscal(is) ao arquivo Texto.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cLinha   := "000"  // Linha Contabil
	_cDataAnt := ""
	lFirst    := .T.

	oProcess:SetRegua2(Len(_aLinhas))

	For _i := 1 to Len(_aLinhas)
		If Substr(_aLinhas[_i],01,Len(Rtrim(MV_PAR16)))==Rtrim(MV_PAR16)    // '        |' 
			// Layout Novo
			_cNumLan  := MV_PAR01 //'400'

			_cDia := Substr(_aLinhas[_i],MV_PAR02,02)

			oProcess:IncRegua2("Gerando Arquivo Contabil em Texto: "+StrZero(_i,5)+"/"+StrZero(Len(_aLinhas),5)) //Incrementa primeira regua

			If !Empty(_cDia) .And. _cDia<>"DT"

				If MV_PAR03==0        // Se a Posicao do Mes =0 pegar o mes da database
					_cMes := Substr(Dtos(ddatabase),5,2)
				Else
					_cMes := Substr(_aLinhas[_i],MV_PAR03,02)
				Endif
				If MV_PAR04==0        // Se a Posicao do Ano =0 pegar o ano da database
					_cAno := Substr(Dtos(ddatabase),3,2)
				Else
					_cAno := Substr(_aLinhas[_i],MV_PAR04,02)
				Endif             

				_cData    := _cDia + _cMes + _cAno
				If lFirst
					lFirst :=.f.
					_cDataAnt := _cData
				Endif
				_cDebito  := Substr(_aLinhas[_i],MV_PAR06,MV_PAR07)  //Se tiver mascara Substr(_aLinhas[_i],MV_PAR06,01)+Substr(_aLinhas[_i],31,01)+Substr(_aLinhas[_i],33,01)+Substr(_aLinhas[_i],35,02)+Substr(_aLinhas[_i],38,05)
				_cCredito := Substr(_aLinhas[_i],MV_PAR08,MV_PAR09)  //Se tiver mascara Substr(_aLinhas[_i],MV_PAR08,01)+Substr(_aLinhas[_i],47,01)+Substr(_aLinhas[_i],49,01)+Substr(_aLinhas[_i],51,02)+Substr(_aLinhas[_i],54,05)

				If .T. // Converte contas de plano de contas antigo? - Criar parametro. Criado campo CT1_XCTANT e CTT_XCCANT
					dbSelectArea("CT1")
					If !Empty(_cDebito)
						Locate for AllTrim(_cDebito) $ CT1->CT1_XCTANT
						If .Not. Eof()
							_cDebito2  := CT1->CT1_CONTA
						Else
							_cDebito2  := Pad("Nao Contemplada",20)
						Endif
					Else
						_cDebito2  := Space(20)
					Endif

					If !Empty(_cCredito)
						Locate for AllTrim(_cCredito) $ CT1->CT1_XCTANT
						If .Not. Eof()
							_cCredito2  := CT1->CT1_CONTA
						Else
							_cCredito2 := Pad("Nao Contemplada",20)
						Endif
					Else
						_cCredito2 := Space(20)
					Endif

					If !Empty(_cDebito)
						If !Empty(alltrim(_cDebito))
							dbSelectArea("CTT")
							Locate for Substr(_cDebito,5,2) $ CTT->CTT_XCCANT
							If .Not. Eof()
								_cCC2D  := CTT->CTT_CUSTO
							Else
								_cCC2D  := Space(09)
							Endif
						Endif
					Else
						_cCC2D  := Space(09)
					Endif

					If !Empty(_cCredito)
						If !Empty(alltrim(_cCredito))
							dbSelectArea("CTT")
							Locate for Substr(_cCredito,5,2) $ CTT->CTT_XCCANT
							If .Not. Eof()
								_cCC2C  := CTT->CTT_CUSTO
							Else
								_cCC2C  := Space(09)
							Endif
						Endif
					Else
						_cCC2C  := Space(09)
					Endif

				Endif

				If MV_PAR11==0      // Se a posicao do historico for zero, pegar historico padrao.
					_cHist    := Pad("IMPORTACAO LP JDS DOC " + Substr(_aLinhas[_i],MV_PAR10,05),MV_PAR11)   
				Else
					_cHist    := Pad(Substr(_aLinhas[_i],MV_PAR10,MV_PAR11) + Substr(_aLinhas[_i],MV_PAR10,05),MV_PAR11)   
				Endif

				_cValor   := Substr(_aLinhas[_i],MV_PAR12,03) + Substr(_aLinhas[_i],MV_PAR13,03) + Substr(_aLinhas[_i],MV_PAR14,03) + Substr(_aLinhas[_i],MV_PAR15,02)
				If Val(_cValor)==0
					_cValor := Substr(_aLinhas[_i],118,03) + Substr(_aLinhas[_i],122,03) + Substr(_aLinhas[_i],126,03) + Substr(_aLinhas[_i],130,02)
				Endif 
				// Tratamento para contas não contempladas no de-para
				If !empty(alltrim(_cDebito))
					If empty(alltrim(_cDebito2))
						_cDebito2:="91219301            "
					Endif
				Endif

				If !empty(alltrim(_cCredito))
					If empty(alltrim(_cCredito2))
						_cDebito2:="91219301            "
					Endif
				Endif
				//         
				If !Empty(alltrim(_cDebito2))
					If !Empty(alltrim(_cCredito2))
						_cTipo := "X"
					Else
						_cTipo := "D"
					Endif
				Else
					If !Empty(alltrim(_cCredito2))
						_cTipo := "C"
					Else
						_cTipo := "?"
					Endif
				Endif

				_cLinhaNova := _cNumLan +"|"+ _cData +"| "+ _cTipo +" |"+ _cDebito +"|"+ _cCredito +"|"+ _cDebito2 +"|"+ _cCredito2 +"|"+ _cCC2D +"|"+ _cCC2C +"|"+ _cHist +"|"+ _cValor+"|"+_cEOL

				fWrite(_nHandle,_cLinhaNova,Len(_cLinhaNova))

				If MV_PAR19 > 1
					If !"Contemplada" $ _cDebito2 +_cCredito2
						Contabiliza() 
					Endif
				Endif
			Else
				// ignora a linha
			Endif
		Endif   

	Next _i

	If MV_PAR19 > 1 .And. Len(_aTotItem) > 0
		_cLinha := "000"
		_cDataAnt := _cData

		// Criar parametro para informar se contabiliza ou somente gera arquivo texto.
		///*
		_aCab := {{"CT_DATA" ,_dData	,NIL},;
		{"CT2_LOTE"	,_cLote		,NIL},;
		{"CT2_DOC"	,_cDoc		,NIL}}

		MSExecAuto({|x,y,Z| CTBA102(x,y,Z)},_aCab,_aTotItem,3)

		If lMsErroAuto
			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() // TELA
			Else // EM ESTADO DE JOB
				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)
			EndIf

			Alert("Inconsistência na Contabilização!")
			_lOk := .F.
		Else
			_lOk := .T.
		Endif
		//*/
		_aTotItem := {}
	Endif

	FClose(_nHandle)  
	_ddataOld := ddatabase

	Aviso("Mensagem","Arquivo Gerado : "+_cFile,{"Ok"})

Return          


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ GeraPerg º Autor ³ Walter Matsui      º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Static Function GeraPerg(_cPerg)
//
//	PutSx1(_cPerg,"01","Codigo Lancamento Padrao     ?","Codigo Lancamento"		,""						,"mv_ch1","C",03,0,0,"G","","","","","mv_par01","133","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"02","Posicao Data Lacamento (dia) ?",""						,""						,"mv_ch2","N",03,0,0,"G","","","","","mv_par02","10","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"03","Posicao Data Lacamento (mes) ?",""						,""               		,"mv_ch3","N",03,0,0,"G","","","","","mv_par03","00","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"04","Posicao Data Lacamento (ano) ?",""						,""                 	,"mv_ch4","N",03,0,0,"G","","","","","mv_par04","00","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"05","Campo Ano (2 ou 4) digitos   ?",""						,""         			,"mv_ch5","N",01,0,0,"G","","","","","mv_par05","2" ,"","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"06","Tamanho da Conta Debito      ?",""						,""						,"mv_ch6","N",03,0,0,"G","","","","","mv_par06","23","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"07","Tamanho da Conta Debito      ?","           "			,""            			,"mv_ch7","N",03,0,0,"G","","","","","mv_par07","10","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"08","Posicao da Conta Credito     ?","              "		,""						,"mv_ch8","N",03,0,0,"G","","","","","mv_par08","34","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"09","Tamanho da Conta Credito     ?","          "			,""          			,"mv_ch9","N",03,0,0,"G","","","","","mv_par09","10","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"10","Posicao do Historico         ?","             "			,""             		,"mv_chA","N",03,0,0,"G","","","","","mv_par10","45","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"11","Tamanho do Historico         ?","          "			,""          			,"mv_chB","N",03,0,0,"G","","","","","mv_par11","53","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"12","Posicao Valor (bilhar)       ?","             "			,"             "		,"mv_chC","N",03,0,0,"G","","","","","mv_par12","100","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"13","Posicao Valor (milhar)       ?","                   ?"	,"                   ?"	,"mv_chd","N",03,0,0,"G","","","","","mv_par13","104","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"14","Posicao Valor (centena)      ?","                   ?"	,"                   ?"	,"mv_che","N",03,0,0,"G","","","","","mv_par14","108","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"15","Posicao Valor (centavos)     ?","                   ?"	,"                   ?"	,"mv_chf","N",03,0,0,"G","","","","","mv_par15","112","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"16","Identificador Lancam.Valido  ?","                   ?"	,"                   ?"	,"mv_chg","C",15,0,0,"G","","","","","mv_par16","        |","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"17","Diretorio/aqruivo Origem     ?","                   ?"	,"                   ?"	,"mv_chh","C",50,0,0,"G","","","","","mv_par17","\TEMP\CTB\ARQ.TXT","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"18","Diretorio/aqruivo Destino    ?","                   ?"	,"                   ?"	,"mv_chi","C",50,0,0,"G","","","","","mv_par18","\TEMP\CTB\ARQNOVO.TXT","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"19","Processamento"			       ,"Processamento"		    ,"Processamento"		,"mv_chj","N",01,0,1,"C",""	,"","","","mv_par19","Gera Arquivo","Gera Arquivo","Gera Arquivo","","Contabiliza Arquivo","Contabiliza Arquivo","Contabiliza Arquivo","","Gera/Contabiliza","Gera/Importa","Gera/Importa","","","","","",{},{},{})
//
//
//Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Contabilizº Autor ³ Walter Matsui      º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Contabiliza os lancamentos atraves de funcao execauto.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Contabiliza() 

	_cLote := "000001"
	_cDoc  := "000001"
	_dData2:= Ctod(Substr(_cData,1,2)+"/"+Substr(_cData,3,2)+"/"+Substr(_cData,5,2))
	///_dData := "20"+Substr(_cData,5,2)+Substr(_cData,3,2)+Substr(_cData,1,2)
	_dData := Ctod(Substr(_cData,1,2)+"/"+Substr(_cData,3,2)+"/"+Substr(_cData,5,2))

	_aCab := {{"CT_DATA" ,_dData	,NIL},;
	{"CT2_LOTE"	,_cLote		,NIL},;
	{"CT2_DOC"	,_cDoc		,NIL}}

	If _cData==_cDataAnt
		_cLinha := Soma1(_cLinha,3)
		_aItem := {{"CT2_LINHA"		,_cLinha	,NIL},;
		{"CT2_DC"		,If(_cTipo=="D","1",If(_cTipo=="C","2","3")),NIL},;
		{"CT2_DEBITO"	,_cDebito2	,NIL},;
		{"CT2_CREDIT"	,_cCredito2,NIL},;
		{"CT2_MOEDAS"	,"12222"	,NIL},;
		{"CT2_VALOR"	,Val(Substr(_cValor,1,Len(_cValor)-2)+"."+	Substr(_cValor,Len(_cValor)-1,2) )  ,NIL},;
		{"CT2_HIST"		,_cHist 	,NIL},;
		{"CT2_CCD"		,_cCC2D	    ,NIL},;
		{"CT2_CCC"		,_cCC2C     ,NIL},;
		{"CT2_DTVENC"	,_dData	    ,NIL}}
		Aadd(_aTotItem,_aItem)
		dDatabase := _dData2
	Else

		_cDataAnt := _cData

		// Criar parametro para informar se contabiliza ou somente gera arquivo texto.
		///*
		MSExecAuto({|x,y,Z| CTBA102(x,y,Z)},_aCab,_aTotItem,3)

		If lMsErroAuto
				If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() // TELA
			Else // EM ESTADO DE JOB
				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)
			EndIf
			Alert("Inconsistência na Contabilização!")
			_lOk := .F.
		Else
			_lOk := .T.
		Endif

		_aTotItem := {}

		_cLinha := "000"
		_cLinha := Soma1(_cLinha,3)
		_aItem := {{"CT2_LINHA"		,_cLinha	,NIL},;
		{"CT2_DC"		,If(_cTipo=="D","1",If(_cTipo=="C","2","3")),NIL},;
		{"CT2_DEBITO"	,_cDebito2	,NIL},;
		{"CT2_CREDIT"	,_cCredito2,NIL},;
		{"CT2_MOEDAS"	,"12222"	,NIL},;
		{"CT2_VALOR"	,Val(Substr(_cValor,1,Len(_cValor)-2)+"."+	Substr(_cValor,Len(_cValor)-1,2) )  ,NIL},;
		{"CT2_HIST"		,_cHist 	,NIL},;
		{"CT2_CCD"		,_cCC2D	    ,NIL},;
		{"CT2_CCC"		,_cCC2C     ,NIL},;
		{"CT2_DTVENC"	,_dData	    ,NIL}}
		Aadd(_aTotItem,_aItem)
		dDatabase := _dData2


	Endif

Return(NIL)
