#Include "Protheus.ch"
#include "rwmake.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ImpFrete ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa um arquivo texto contendo informacoes de nota      ³±±
±±³          ³ fiscal de conhecimento de frete.                           ³±±        
±±³          ³ Le arquivo Texto e gera uma nota fiscal de entrada.        ³±±
±±³          ³                                                            ³±±        
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ferring                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ImpFrete()

	Local   _cLinAtu := ""
	Private _aLinhas := {}
	Private _cPerg := "IMPFRETE  " 
	Private _lOk
	Private _cLote := "000000001"
	Private _cDoc  := "000000001"
	Private _dData2
	Private _dData
	Private _aCab
	Private _cLote
	Private _cDoc
	Private _ddataOld := ddatabase
	Private _cArq,_cFor,_cLoja,_cProd,_cTES

	//GeraPerg(_cPerg)   
	Pergunte(_cPerg,.T.)

	_cArq  := MV_PAR01
	_cFor  := MV_PAR02
	_cLoja := MV_PAR03
	_cProd := MV_PAR04
	_cTES  := MV_PAR05

	If Msgyesno("Confirma Importação das Notas de Conhecimento de Frete ?","YESNO" )


		_lOk:= .T.

		oProcess:= MsNewProcess():New({|| LearqProc(oProcess)},"","",.F.)
		oProcess:cTitle:="Importação das Notas de Conhecimenot de Frete"
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

	If !File(AllTrim(_cArq))
		Aviso("Atencao","Arquivo "+AllTrim(_cArq)+" nao localizado.",{"Ok"})
		_lOk:= .F.
		Return(Nil)
	Endif

	FT_FUSE(AllTrim(_cArq))//      ("\TEMP\COM\ARQ.TXT")       // Abre o Arquivo

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

	LeCampos()

Return(Nil)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ LeCampos ³ Autor ³ Walter Matsui         ³ Data ³ 26/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os dados nos campos necessarios para gerar a nota  ³±±
±±³          ³ fiscal                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Contabilzacao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeCampos()

	Local _i := 0
	Private cCGC 		
	Private cRazao 		
	Private cCodTran 	
	Private cSerie		
	Private cDoc	 	
	Private dEmissao 	
	Private cTipoFrete	
	Private nPesoBruto 	
	Private nFrete		
	Private nBaseICM	
	Private nAliqICM	
	Private nValICM		
	Private nValFrete	
	Private cNotOri		

	oProcess:SetRegua2(Len(_aLinhas))

	For _i := 1 to Len(_aLinhas)

		If Substr(_aLinhas[_i],01,03) == '321'
			cCGC 		:= Substr(_aLinhas[_i],004,14)
			cRazao 	:= Substr(_aLinhas[_i],018,40)
			cCodTran 	:= Substr(_aLinhas[_i],058,10)
		ElseIf Substr(_aLinhas[_i],01,03) == '322'

			oProcess:IncRegua2("Gerando Arquivo Contabil em Texto: "+StrZero(_i,5)+"/"+StrZero(Len(_aLinhas),5)) //Incrementa primeira regua

			cSerie		:= Pad(Substr(_aLinhas[_i],014,05),3)
			cDoc	 	:= StrZero(Val(Substr(_aLinhas[_i],019,12)),09)
			dEmissao 	:= Substr(_aLinhas[_i],031,08) //ddmmaaaa
			dEmissao	:= Ctod(Substr(dEmissao,1,2)+"/"+Substr(dEmissao,3,2)+"/"+Substr(dEmissao,5,5))
			cTipoFrete	:= Substr(_aLinhas[_i],039,01) // C/F
			nValFrete	:= Val(Substr(_aLinhas[_i],047,15))/100
			nPesoBruto := Val(Substr(_aLinhas[_i],050,07))/100
			nFrete		:= Val(Substr(_aLinhas[_i],047,15))/100
			nBaseICM	:= Val(Substr(_aLinhas[_i],062,15))/100
			nAliqICM	:= Val(Substr(_aLinhas[_i],077,06))/100
			nValICM	:= Val(Substr(_aLinhas[_i],081,15))/100
			cCGCEmisor	:= Substr(_aLinhas[_i],205,14)

			//nValFretePeso
			//Frete valor?
			//Valor SEC/CAT?
			//Valor ITF?
			//Valor do Despacho
			//CGC Embarcadora

			If Substr(_aLinhas[_i],236,08)<>"00000000"
				cNotOri	:= AllTrim(Substr(_aLinhas[_i],233,03))+" - "+ Substr(_aLinhas[_i],236,08)+ " / "
			Endif
			If Substr(_aLinhas[_i],247,08)<>"00000000"
				cNotOri	+= AllTrim(Substr(_aLinhas[_i],244,03))+" - "+ Substr(_aLinhas[_i],247,08)+ " / "  
			Endif
			If Substr(_aLinhas[_i],258,08)<>"00000000"
				cNotOri	+= AllTrim(Substr(_aLinhas[_i],255,03))+" - "+ Substr(_aLinhas[_i],258,08)+ " / " 
			Endif
			If Substr(_aLinhas[_i],269,08)<>"00000000"
				cNotOri	+= AllTrim(Substr(_aLinhas[_i],266,03))+" - "+ Substr(_aLinhas[_i],269,08)+ " / "
			Endif
			If Substr(_aLinhas[_i],300,08)<>"00000000"
				cNotOri	+= AllTrim(Substr(_aLinhas[_i],277,03))+" - "+ Substr(_aLinhas[_i],300,08)+ " / "
			Endif
			If Substr(_aLinhas[_i],310,08)<>"00000000"
				cNotOri	+= AllTrim(Substr(_aLinhas[_i],307,03))+" - "+ Substr(_aLinhas[_i],310,08)+ " / "
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gera a nota fiscal                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Begin Transaction
			//Processa ({||GERANFE()})  
			GERANFE()
			//End Transaction

		ElseIf Substr(_aLinhas[_i],01,03) == "323"

		Endif

	Next _i

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
//	PutSx1(_cPerg,"01","Diretorio/aqruivo Origem     ?","                   ?"	,"                   ?"	,"mv_ch1","C",50,0,0,"G","","","","","mv_par01","\TEMP\COM\ARQ.TXT","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"02","Codigo do Fornecedor         ?","                   ?"	,"                   ?"	,"mv_ch2","C",06,0,0,"G","","","","","mv_par02","                 ","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"03","Loja do Fornecedor           ?","                   ?"	,"                   ?"	,"mv_ch3","C",02,0,0,"G","","","","","mv_par03","                 ","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"04","Codigo do Produto Frete      ?","                   ?"	,"                   ?"	,"mv_ch4","C",15,0,0,"G","","","","","mv_par04","                 ","","","","","","","","","","","","","","","","",{},{},{})
//	PutSx1(_cPerg,"05","TES                          ?","                   ?"	,"                   ?"	,"mv_ch5","C",03,0,0,"G","","","","","mv_par05","                 ","","","","","","","","","","","","","","","","",{},{},{})
//
//
//Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GERANFE   ³ Autor ³ Wilson A. da Cruz    ³ Data ³ 04/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera execauto da notas de saida selecionadas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Itapua                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GERANFE()

	Local _aCab:={}
	Local _aItens:={}
	Local _aTemp :={}
	Private lMsErroAuto := .f.
	Private lMsHelpAuto := .t.

	// Verifica se a nota já foi emitida
	SF1->(dbSetOrder(1))
	SF1->(dbSeek(xFilial("SF1") + cDoc + cSerie + _cFor + _cLoja ))
	If !SF1->(Eof())
		msgalert("Atenção! Doc "+cDoc+" já foi lançada no sistema!","ALERT")
		Return
	Endif


	Aadd(_aCab,{"F1_TIPO"   ,"N"		,Nil})
	Aadd(_aCab,{"F1_FORMUL" ,"N"		,Nil})
	Aadd(_aCab,{"F1_DOC"    ,cDoc		,Nil})
	Aadd(_aCab,{"F1_SERIE"  ,cSerie		,Nil})
	Aadd(_aCab,{"F1_EMISSAO",dEmissao	,Nil})
	Aadd(_aCab,{"F1_DTDIGIT",ddatabase	,Nil})
	Aadd(_aCab,{"F1_FORNECE",_cFor	,Nil})
	Aadd(_aCab,{"F1_LOJA"   ,_cLoja	,Nil})
	Aadd(_aCab,{"F1_ESPECIE","CTE"		,Nil})
	Aadd(_aCab,{"F1_STATUS" ," "		,Nil})  // Pre-nota

	//For _nI := 1 to len(_aItensDev)
	_aTemp :={}
	Aadd(_aTemp, {"D1_COD"    ,_cProd,Nil})
	Aadd(_aTemp, {"D1_UM"     ,Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_UM"),Nil})
	Aadd(_aTemp, {"D1_QUANT"  ,1,Nil})

	Aadd(_aTemp, {"D1_VUNIT"  ,nValFrete,Nil})
	Aadd(_aTemp, {"D1_TOTAL"  ,nValFrete,Nil})

	If !Empty(_cTES) 
		Aadd(_aTemp, {"D1_TES"    ,_cTES,Nil})
	Endif

	Aadd(_aTemp, {"D1_DOC"    ,cDoc,Nil})
	Aadd(_aTemp, {"D1_EMISSAO",dEmissao,Nil})
	Aadd(_aTemp, {"D1_DTDIGIT",ddatabase,Nil})
	Aadd(_aTemp, {"D1_SERIE"  ,cSerie,Nil})
	Aadd(_aTemp, {"D1_FORNECE",_cFor,Nil})
	Aadd(_aTemp, {"D1_LOJA"   ,_cLoja,Nil})
	//	Aadd(_aTemp, {"D1_NFORI"  ,"",Nil})
	//	Aadd(_aTemp, {"D1_SERIORI","",Nil})
	//	Aadd(_aTemp, {"D1_ITEMORI","",Nil})
	//	Aadd(_aTemp, {"D1_IDENTB6","",Nil})

	aadd(_aItens,aClone(_aTemp))

	//    IncProc("Gerando Documento de Entrada...")
	//Next _nI

	lMsErroAuto := .f.
	//MSExecAuto({|v,w,x,y,z| MATA103(v,w,x,y,z)},_aCab,_aItens,3,NIL)  //inclusao
	MSExecAuto({|v,w,x,y,z| MATA140(v,w,x,y,z)},_aCab,_aItens,3,NIL)  //inclusao  // pre-nota
	If lMsErroAuto
		If (!IsBlind()) // COM INTERFACE GRÁFICA
			MostraErro() // TELA
		Else // EM ESTADO DE JOB
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)
		EndIf


		Return
	EndIf

Return
