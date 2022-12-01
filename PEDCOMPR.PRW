#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PEDCOMPR ³ Autor ³ Walter Matsui         ³ Data ³ 19/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Pedido de Compras em formato Grafico.         ³±±
±±³          ³ MV_PCOMPRA                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PEDCOMPR()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aOrd           := {}
Local cDesc1         := "Este programa tem como objetivo imprimir os pedidos "
Local cDesc2         := "de compra em formato grafico."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := "PEDIDO DE COMPRAS"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "PEDCOMPR"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "PCGRAF"
Private CbTxt        := ""
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel      	 := "PEDCOMPR"
Private cString    	 := "SC7"
Private _cNumPed     := "" 
Private lConfirma    := .t.
Private _nConfirma   := 0    
Private cCodProd     :=""

dbSelectArea("SC7")
_aGetPosSC7 := GETAREA()
dbSetOrder(1)
pergunte(cPerg,.F.)
//If AllTrim(Upper(FunName())) $ "MATA121"
dbSelectArea("SC7")
mv_par01 := C7_NUM
mv_par02 := C7_NUM
mv_par03 := C7_EMISSAO
mv_par04 := C7_EMISSAO
cPerg := ""
//	mv_par05 := 2
//EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| ITFINR() },Titulo)

RestArea(_aGetPosSC7)

Set Device To Screen

If aReturn[5] == 1
	Set Printer TO
	DbcommitAll()
	//ourspool(wnrel)
EndIf

MS_FLUSH()

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ITCOMR02X º Autor ³ Walter Matsui      º Data ³  11/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ITFINR()

Local nOrdem

PRIVATE   oPrint
PRIVATE   n := 0
PRIVATE	nRec := 0
PRIVATE aBitmap := ""
Private aPedido  := {}
oPrint:=FwMSPrinter():New( "Pedido de Compras" )
oPrint:SetLandscape()	//SetPortrait()

dbSelectArea("SC7")
dbSetOrder(1)
DbSeek( xFilial()+MV_PAR01,.T.)

SetRegua(RecCount())
_lQuebra := .F.
_cPedAnt := ""


While (!EOF()) .And.  xFilial() == SC7->C7_FILIAL .And. SC7->C7_NUM <= MV_PAR02
	
	IncRegua()
	_lImpr := .T.
	
	If SC7->C7_EMISSAO < MV_PAR03 .Or. SC7->C7_EMISSAO > MV_PAR04
		DbSkip()
		Loop
	EndIf
	
	aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
		_lImpr := .F.
	else
		_cEstado:= SA2->A2_EST
		If _cEstado == 'EX' .and. lConfirma == .t.
			_nConfirma := Aviso("Confirmar","Deseja imprmir o PC em Inglês?",{"Sim","Nao"})  
			lConfirma := .f.
		endif

	EndIf
	///
	_cPedAnt := SC7->C7_NUM
	
	DbSelectArea("SC7")
	dbSkip()
	///
	If Eof() .or. _cPedAnt <> SC7->C7_NUM
		_lQuebra := .T.
		_cPedAnt := SC7->C7_NUM
	EndIf
	
	If _lImpr  .and. _lQuebra
		_lQuebra := .F.
		DbSelectArea("SC7")
		_aPosQuebra := GETAREA()
		Impress(oPrint)
		RESTAREA(_aPosQuebra)
		aPedido  := {}
	EndIf
	
	If aReturn[5]==1
		dbCommitAll()
	Endif
	
	DbSelectArea("SC7")
EndDo  


oPrint:Preview()     // Visualiza antes de imprimir
Private cStartPath := "\PEDIDOS_COMPRA\"
If MV_PAR01=MV_PAR02
	Private cJPeg      := "PC_"+AllTrim(MV_PAR01)
Else
	Private cJPeg      := Dtos(dDataBase)+StrTran(Time(),":","")
EndIf
oPrint:SaveAllAsJPEG(cStartPath+cJPEG,1640,1120,180)

Return





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Walter Matsui         ³ Data ³ 01/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint)

local j
dbSelectArea("SC7")
_aAreaImp := GETAREA()
dbSetOrder(1)
If !dbSeek(aPedido[1]+aPedido[2])
	RestArea(_aAreaImp)
	Return()
Else
	_aPosAtuC7 := GETAREA()
EndIf
PRIVATE oFont2n
PRIVATE oFont8
PRIVATE oFont9
PRIVATE oFont10
PRIVATE oFont15n
PRIVATE oFont16
PRIVATE oFont16n
PRIVATE oFont14n
PRIVATE oFont24
PRIVATE i := 0
PRIVATE aCoords1 := {0150,1900,0550,2300}
PRIVATE aCoords2 := {0450,1050,0550,1900}
PRIVATE aCoords3 := {0710,1900,0810,2300}
PRIVATE aCoords4 := {0980,1900,1050,2300}
PRIVATE aCoords5 := {1330,1900,1400,2300}
PRIVATE aCoords6 := {2280,1900,2380,2300}     // 2000 - 2100
PRIVATE aCoords7 := {2550,1900,2620,2300}     // 2270 - 2340
PRIVATE aCoords8 := {2900,1900,2970,2300}     // 2620 - 2690
PRIVATE oBrush
PRIVATE _cMsgC7 := ""

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont2n := TFont():New("Times New Roman",,10,,.T.,,,,,.F. )
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10n:= TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11 := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11n:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12 := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13n:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14 := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont18n:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oFont30n := TFont():New("Arial",9,30,.T.,.T.,5,.T.,5,.T.,.F.)

oBrush := TBrush():New("",4)

oPrint:StartPage()   // Inicia uma nova página
//********************************************************
//** IMPRESAO DO CABECALHO DO PEDIDO - PRIMEIRA PÁGINA
//********************************************************
Impr_Cab()
///
///VERIFICA O TAMANHO DO PEDIDO - PARA APURAR A QUANTIDADE DE PAGINAS NECESSARIAS
_nLin 		:= 1
_nPag 		:= 1
_nTot 		:= 0
aOBS 		:= {}
_nContaTot 	:= 0
_nContaAtu  := 0
_nFrete 	:= 0
_nSeguro 	:= 0
_nDespesa 	:= 0
_nIPI	 	:= 0
_nICMS	 	:= 0
_nDescont	:= 0
Private _cMsgForm 	:= ""
Private _nMoeda		:= 0
dbSelectArea("SC7")
Do While !Eof() .and. SC7->C7_FILIAL+SC7->C7_NUM = aPedido[1]+aPedido[2]
	_nContaTot := _nContaTot + 1
	cDescri :=  ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao generica do Produto.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If AllTrim(mv_par06) == "B1_DESC"
	//		dbSelectArea("SB1")
	//		dbSetOrder(1)
	//		dbSeek( xFilial()+SC7->C7_PRODUTO )
	//		cDescri := Alltrim(SB1->B1_DESC)
	//		dbSelectArea("SC7")
	//	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao cientifica do Produto.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If AllTrim(mv_par06) == "B5_CEME"
	//		dbSelectArea("SB5")
	//		dbSetOrder(1)
	//		If dbSeek( xFilial()+SC7->C7_PRODUTO )
	//			cDescri := Alltrim(B5_CEME)
	//		EndIf
	//		dbSelectArea("SC7")
	//	EndIf
	
	dbSelectArea("SC7")
	cDescri  := Alltrim(SC7->C7_DESCRI)
	cCodProd := SC7->C7_PRODUTO

	If _cEstado == 'EX' .and. _nConfirma == 1 

		dbSelectArea("SA5")
		dbSetOrder(1)
		If dbSeek(xFilial()+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
			cDescri  := cDescri + " ("+Alltrim(SA5->A5_NOMPROD)+")"
          	cCodProd := Alltrim(SA5->A5_CODPRF)		
		EndIf
	//	_aDescrTXT := U_FQUEBRATXT(cDescri,40)
	ENDIF
	//_aDescrTXT := U_FQUEBRATXT(cDescri,65)
	_aDescrTXT := U_FQUEBRATXT(cDescri,58)
	If len(_aDescrTXT) > 1
		For j:= 2 to Len(_aDescrTXT)
			_nContaTot := _nContaTot + 1
		Next
	EndIf
	_cMsgC7 := SC7->C7_MSG
	dbSelectArea("SC7")
	dbSkip()
EndDo
//If _nContaTot > 0  .AND. !EMPTY(_cMsgC7)
//	cMensagem 	:= " (*) " + Formula(_cMsgC7)
//	aMensagem 	:= U_FQUEBRATXT(cMensagem,60)
//	If Len(aMensagem) > 0
////		_nContaTot += Len(aMensagem)
//	EndIf
//EndIf
///
If _nContaTot <= 20
	Impr_Itens("1")
Else
	Impr_Itens("2")
EndIf
///
RestArea(_aPosAtuC7)
_nItemAtu 	:= 0
cMensagem	:= ""
dbSelectArea("SC7")
Do While !Eof() .and. SC7->C7_FILIAL+SC7->C7_NUM = aPedido[1]+aPedido[2]
	If !Empty(SC7->C7_OBS)
		AADD(aOBS,SC7->C7_OBS)
	EndIf
	
	// Busca descricao do Produto
	cDescri :=  ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao generica do Produto.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If AllTrim(mv_par06) == "B1_DESC"
	//		dbSelectArea("SB1")
	//		dbSetOrder(1)
	//		dbSeek( xFilial()+SC7->C7_PRODUTO )
	//		cDescri := Alltrim(SB1->B1_DESC)
	//		dbSelectArea("SC7")
	//	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao cientifica do Produto.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	If AllTrim(mv_par06) == "B5_CEME"
	//		dbSelectArea("SB5")
	//		dbSetOrder(1)
	//		If dbSeek( xFilial()+SC7->C7_PRODUTO )
	//			cDescri := Alltrim(SB5->B5_CEME)
	//		EndIf
	//		dbSelectArea("SC7")
	//	EndIf
	
	dbSelectArea("SC7")
	
	RecLock("SC7",.F.)  //Atualizacao do flag de Impressao
	Replace C7_EMITIDO With "S"
	Replace C7_QTDREEM With C7_QTDREEM + 1
	MsUnLock()
	
	cDescri := Alltrim(SC7->C7_DESCRI)
	cCodProd := SC7->C7_PRODUTO
	
	If _cEstado == 'EX' .and. _nConfirma == 1 
		dbSelectArea("SA5")
		dbSetOrder(1)
		If dbSeek(xFilial()+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO).And. !Empty(SA5->A5_CODPRF)
			cDescri  := cDescri + " ("+Alltrim(SA5->A5_NOMPROD)+")"
          	cCodProd := Alltrim(SA5->A5_CODPRF)		
		EndIf
	//	_aDescrTXT := U_FQUEBRATXT(cDescri,40)
	ENDIF                                 
		_aDescrTXT := U_FQUEBRATXT(cDescri,58)
//	_aDescrTXT := U_FQUEBRATXT(cDescri,65)
	///
	dbSelectArea("SC7")
	oPrint:Say  (0520+(50*_nLin),0120,SC7->C7_ITEM,oFont10n)
	oPrint:Say  (0520+(50*_nLin),0220,cCodProd,oFont10n)
//	oPrint:Say  (0520+(50*_nLin),0220,SC7->C7_PRODUTO,oFont10n)
	If len(_aDescrTXT) > 0
		oPrint:Say  (0520+(50*_nLin),0570,_aDescrTXT[1],oFont10n)
	EndIf
	oPrint:Say  (0520+(50*_nLin),1850,SC7->C7_UM,oFont10n)
	oPrint:Say  (0520+(50*_nLin),1940,Transform(SC7->C7_QUANT,"@E 99,999,999.999"),oFont10n)//"@E 99,999,999.99")
	oPrint:Say  (0520+(50*_nLin),2220,Transform(SC7->C7_PRECO,"@E 99,999,999.99"),oFont10n)
	oPrint:Say  (0520+(50*_nLin),2465,Transform(SC7->C7_IPI,"@E 99.99"),oFont10n)
	oPrint:Say  (0520+(50*_nLin),2570,Transform(SC7->C7_TOTAL,"@E 99,999,999.99"),oFont10n)
	oPrint:Say  (0520+(50*_nLin),2840,DTOC(SC7->C7_DATPRF),oFont10n)
	//	oPrint:Say  (0520+(50*_nLin),3010,AllTrim(SC7->C7_CC),oFont10n)
	//	oPrint:Say  (0520+(50*_nLin),3160,AllTrim(SC7->C7_NUMSC),oFont10n)

	cGrupoD:=FWGetSX5 ('Z4',SC7->C7_XDEPART,) 

	oPrint:Say  (0520+(50*_nLin),3010,cGrupoD,oFont10n)
	oPrint:Say  (0520+(50*_nLin),3160,SC7->C7_XSOLICI,oFont10n)
	
	_nFrete 	:= _nFrete + SC7->C7_VALFRE
	_nSeguro 	:= _nSeguro + SC7->C7_SEGURO
	_nDespesa 	:= _nDespesa + SC7->C7_DESPESA
	_nIPI	 	:= _nipi + SC7->C7_VALIPI
	_nICMS	 	:= _nICMS + SC7->C7_VALICM
	_nDescont 	:= _nDescont + SC7->C7_VLDESC
	_nLin 		:= _nLin + 1
	_nTot 		:= _nTot + SC7->C7_TOTAL
	_nContaAtu  := _nContaAtu + 1
	_cMsgForm   := SC7->C7_MSG
	_nMoeda		:= SC7->C7_MOEDA  
	cDescri  := ""
   	cCodProd := ""

	If len(_aDescrTXT) > 1
		For j:= 2 to Len(_aDescrTXT)
			If _nLin <= 33
				oPrint:Say  (0520+(50*_nLin),0570,_aDescrTXT[j],oFont10n)
				_nContaAtu := _nContaAtu + 1
				_nlin:=_nlin+1
				GeraQbrPg()
			EndIf
		Next
	EndIf
	///
	GeraQbrPg()
	///
	dbSelectArea("SC7")
	//	_cMsgC7 := SC7->C7_MSG
	dbSkip()
EndDo
//If !Empty(_cMsgC7)
//cMensagem 	:= " (*) " + Formula(_cMsgC7)
//aMensagem 	:= U_FQUEBRATXT(cMensagem,60)
//If Len(aMensagem) > 0
//	For s:=1 to len(aMensagem)
//		oPrint:Say  (0520+(50*_nLin),0570,aMensagem[s],oFont10n)
//		If s < len(aMensagem)
//			_nLin += 1
//		EndIf
//		GeraQbrPg()
//	Next
//EndIf
//EndIf
If _nPag = 1 .AND. _nLin>20
	Impr_Rd2(_nPag)
	oPrint:EndPage()
	oPrint:StartPage()
	Impr_Cab2()
	//	Impr_Itens("2")
	_nPag := _nPag + 1
	_nLin := -5
//ELSEIf _nPag = 2 .AND. _nLin>20
  //	Impr_Rd2(_nPag)
	//oPrint:EndPage()
	//oPrint:StartPage()
	//Impr_Cab2()
	
	//_nPag := _nPag + 1
	//_nLin := -5	
EndIf
RestArea(_aPosAtuC7)

///
//********************************************************
//** IMPRESAO DO BLOCO DE MENSAGENS E TOTALIZACAO - ULTIMA PÁGINA ANTES DO RODAPE
//********************************************************
Impr_Mens()
//
//********************************************************
//** IMPRESAO DO RODAPE DO PEDIDO - ULTIMA FOLHA
//********************************************************
Impr_Roda(_nPag)
dbSelectArea("SC7")
///
oPrint:EndPage() // Finaliza a página

Return Nil



Static Function Impr_Cab()
// LOGOTIPO
cBitMap:= ""
cBitMap:= "OXY.BMP"
_cEMail := "compas@ferring.com.br"
OpenSM0()
If _cEstado == 'EX' .AND.  _nConfirma == 1

	
	_cNumPed := SC7->C7_NUM
	fBox(0070,0100,0450,1290,4)
	fBox(0070,1300,0210,2700,4)
	fBox(0070,2700,0210,3300,4)
	fBox(0210,1300,0450,3300,4)
	oPrint:Say  (0085,1650,"PURCHASE ORDER",oFont18n)
	oPrint:Say  (0090,2840,"Nº: "+Transform(SC7->C7_NUM,"@R !!!.999"),oFont18n)
	oPrint:Say  (0155,1320,"Date: "+DTOC(SC7->C7_EMISSAO),oFont10n)
	oPrint:Say  (0155,2320,"Impress: "+DTOC(DATE()),oFont10n)
	//
//	oPrint:Say  (0230,1330,"Supplier: " + AllTrim(SA2->A2_NOME) + " - "+SA2->A2_COD+"-"+SA2->A2_LOJA+"                           Contact : " +  SA2->A2_CONTATO,oFont10n)
oPrint:Say  (0230,1330,"Supplier: " + AllTrim(SA2->A2_NOME) + " - "+SA2->A2_COD+"-"+SA2->A2_LOJA+"                           Contact : " +  SC7->C7_CONTATO,oFont10n)
	oPrint:Say  (0280,1330,"Address: " + AllTrim(SA2->A2_END) + "      Quarter: " + SA2->A2_BAIRRO,oFont10)
	//oPrint:Say  (0280,2600,"Contato : " +  SA2->A2_CONTATO,oFont10)
	oPrint:Say  (0330,1330,"Zip Code: "+Trans(Alltrim(SA2->A2_CEP),"@R 99999-999") + "      " + AllTrim(SA2->A2_MUN) + "   -   " + SA2->A2_EST,oFont10)
	oPrint:Say  (0330,2600,"E-Mail: "+SA2->A2_EMAIL,oFont10)
	//oPrint:Say  (0380,1330,"CNPJ: " + Trans(Alltrim(SA2->A2_CGC),"@R 99.999.999/9999-99") +"      Inscriçao: "+SA2->A2_INSCR ,oFont10)
	oPrint:Say  (0380,2300,"Telephone: "+Substr(SA2->A2_TEL,1,15),oFont10)
	oPrint:Say  (0380,2780,"Fax: "+Substr(SA2->A2_FAX,1,15),oFont10)
	//
	oPrint:Say  (0095,0120,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_NOMECOM'})[1][2],oFont14n)
	oPrint:Say  (0160,0120,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT '})[1][2]+ " - BRAZIL " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_COMPENT'})[1][2],oFont11n)
	oPrint:Say  (0215,0120,"Zip Code: "+Trans(Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPENT'})[1][2]),"@R 99999-999") + "      " + AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDENT'})[1][2]) + "   -   " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2],oFont11n)
	oPrint:Say  (0270,0120,"Telephone: "+Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TEL'})[1][2]) + "         Fax: "+Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FAX'})[1][2]),oFont11n)
	oPrint:Say  (0325,0120,"CNPJ: " + Trans(Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]),"@R 99.999.999/9999-99") +"  Registration: "+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_INSC'})[1][2] ,oFont11n)
	oPrint:Say  (0380,0120,"E-Mail: " + _cEMail ,oFont11n)
	//
	//fBox(0370,0100,0370,1290,3)
	//Private _nSolicit := GETADVFVAL("SC1","C1_SOLICIT",xFilial("SC1")+SC7->C7_NUMSC,1,"")
	//oPrint:Say  (0385,0120,"Solicitante: " + _nSolicit,oFont11n)
else
	
	
	//If File(cBitMap)
	//oPrint:SayBitmap(0090,2790,cBitMap,0400,110 )
	//EndIf
	_cNumPed := SC7->C7_NUM
	fBox(0070,0100,0450,1290,4)
	fBox(0070,1300,0210,2700,4)
	//fBox(0070,2700,0160,3300,4)
	fBox(0070,2700,0210,3300,4)
	fBox(0210,1300,0450,3300,4)
	oPrint:Say  (0085,1650,"PEDIDO DE COMPRAS",oFont18n)
	oPrint:Say  (0090,2840,"Nº: "+Transform(SC7->C7_NUM,"@R !!!.999"),oFont18n)
	oPrint:Say  (0155,1320,"Emissão: "+DTOC(SC7->C7_EMISSAO),oFont10n)
	oPrint:Say  (0155,2320,"Impressão: "+DTOC(DATE()),oFont10n)
	//
//	oPrint:Say  (0230,1330,"Fornecedor: " + AllTrim(SA2->A2_NOME) + " - "+SA2->A2_COD+"-"+SA2->A2_LOJA+"                           Contato : " +  SA2->A2_CONTATO,oFont10n)
	oPrint:Say  (0230,1330,"Fornecedor: " + AllTrim(SA2->A2_NOME) + " - "+SA2->A2_COD+"-"+SA2->A2_LOJA+"                           Contato : " +  SC7->C7_CONTATO,oFont10n)
	oPrint:Say  (0280,1330,"Endereço: " + AllTrim(SA2->A2_END) + "      Bairro: " + SA2->A2_BAIRRO,oFont10)
	//oPrint:Say  (0280,2600,"Contato : " +  SA2->A2_CONTATO,oFont10)
	oPrint:Say  (0330,1330,"CEP: "+Trans(Alltrim(SA2->A2_CEP),"@R 99999-999") + "      " + AllTrim(SA2->A2_MUN) + "   -   " + SA2->A2_EST,oFont10)
	oPrint:Say  (0330,2600,"E-Mail: "+SA2->A2_EMAIL,oFont10)
	oPrint:Say  (0380,1330,"CNPJ: " + Trans(Alltrim(SA2->A2_CGC),"@R 99.999.999/9999-99") +"      Inscriçao: "+Trans(Alltrim(SA2->A2_INSCR), "@R 999.999.999.999") ,oFont10)
	oPrint:Say  (0380,2300,"Telefone: "+Substr(SA2->A2_TEL,1,15),oFont10)
	oPrint:Say  (0380,2780,"Fax: "+Substr(SA2->A2_FAX,1,15),oFont10)
	//
	oPrint:Say  (0095,0120,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_NOMECOM'})[1][2],oFont14n)
	oPrint:Say  (0160,0120,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT '})[1][2] + " - " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_COMPENT'})[1][2],oFont11n)
	oPrint:Say  (0215,0120,"CEP: "+Trans(Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPENT'})[1][2]),"@R 99999-999") + "      " + AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDENT'})[1][2]) + "   -   " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2],oFont11n)
	oPrint:Say  (0270,0120,"Telefone: "+Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TEL'})[1][2]) + "         Fax: "+Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FAX'})[1][2]),oFont11n)
	oPrint:Say  (0325,0120,"CNPJ: " + Trans(Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]),"@R 99.999.999/9999-99") +"      Inscriçao: "+Trans(Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_INSC'})[1][2]), "@R 999.999.999.999") ,oFont11n)
	oPrint:Say  (0380,0120,"E-Mail: " + _cEMail ,oFont11n)
	//
	//fBox(0370,0100,0370,1290,3)
	//Private _nSolicit := GETADVFVAL("SC1","C1_SOLICIT",xFilial("SC1")+SC7->C7_NUMSC,1,"")
	//oPrint:Say  (0385,0120,"Solicitante: " + _nSolicit,oFont11n)
	
endif
Return


Static Function Impr_Itens(_cPar)
_nXX := 0
_nYY := 0
If _cPar $ "34"
	_nXX := 1
EndIf
If _cPar $ "2"
	_nYY := 1
EndIf
fBox(0470-(300*_nXX),0100,1590+(640*_nYY),3300,1)
fBox(0470-(300*_nXX),0210,1590+(640*_nYY),0210,1)
fBox(0470-(300*_nXX),0550,1590+(640*_nYY),0550,1)
fBox(0470-(300*_nXX),1830,1590+(640*_nYY),1830,1)
fBox(0470-(300*_nXX),1930,1590+(640*_nYY),1930,1)
fBox(0470-(300*_nXX),2200,1590+(640*_nYY),2200,1)
fBox(0470-(300*_nXX),2450,1590+(640*_nYY),2450,1)
fBox(0470-(300*_nXX),2550,1590+(640*_nYY),2550,1)
fBox(0470-(300*_nXX),2810,1590+(640*_nYY),2810,1)
fBox(0470-(300*_nXX),3000,1590+(640*_nYY),3000,1)
fBox(0470-(300*_nXX),3150,1590+(640*_nYY),3150,1)
///

If _cEstado == 'EX' .AND.  _nConfirma == 1
	
	oPrint:Say  (0480-(300*_nXX),0110,"Item",oFont11n)
	oPrint:Say  (0480-(300*_nXX),0230,"Code",oFont11n)
	oPrint:Say  (0480-(300*_nXX),0570,"Description",oFont11n)
	oPrint:Say  (0480-(300*_nXX),1850,"UM",oFont11n)
	oPrint:Say  (0480-(300*_nXX),1950,"Quantity",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2220,"Unit. Value",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2470,"IPI",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2570,"Total Value",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2840,"Delivery",oFont11n)
	oPrint:Say  (0480-(300*_nXX),3020,"Depart.",oFont11n)
	oPrint:Say  (0480-(300*_nXX),3170,"S.C.",oFont11n)
	///
	fBox(0540-(300*_nXX),0100,0540-(300*_nXX),3300,1)
else
	oPrint:Say  (0480-(300*_nXX),0110,"Item",oFont11n)
	oPrint:Say  (0480-(300*_nXX),0230,"Código",oFont11n)
	oPrint:Say  (0480-(300*_nXX),0570,"Descrição",oFont11n)
	oPrint:Say  (0480-(300*_nXX),1850,"UM",oFont11n)
	oPrint:Say  (0480-(300*_nXX),1950,"Quantidade",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2220,"Vlr.Unitário",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2470,"IPI",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2570,"Vr. Total",oFont11n)
	oPrint:Say  (0480-(300*_nXX),2840,"Entrega",oFont11n)
	oPrint:Say  (0480-(300*_nXX),3020,"Depart.",oFont11n)
	oPrint:Say  (0480-(300*_nXX),3170,"S.C.",oFont11n)
	///
	fBox(0540-(300*_nXX),0100,0540-(300*_nXX),3300,1)
	
endif
Return



Static Function Impr_Mens()

local z , y
OpenSM0()
If _cEstado == 'EX' .AND.  _nConfirma == 1
	
	fBox(1620,0100,1870,1480)
	oPrint:Say  (1640,0120,"Comments:" ,oFont11)
	//_cNomeMoeda := "(*) VALORES EM " + IIF(_nMoeda = 1, "REAL (R$).","DOLAR (US$).")
	//oPrint:Say  (1685,0140,_cNomeMoeda,oFont10n)
	z:= 1
	
	If Len(aOBS) > 0
		For z:=1 to Len(aOBS)
			If z<=4
				oPrint:Say  (1640+(75*z),0140,aOBS[z],oFont10) //oPrint:Say  (1640+(45*z),0140,aOBS[z],oFont10)
			EndIf
		Next
	Endif
	
	If !Empty(_cMsgForm)
		cMensForm 	:= " (*) " + Formula(_cMsgForm)
		aMensForm 	:= U_FQUEBRATXT(cMensForm,65)//60
		If Len(aMensForm) > 0
			For y:=1 to Len(aMensForm)
				If y<=3
					oPrint:Say  (1685+(75*(y+z)),0140,aMensForm[y],oFont10)  //oPrint:Say  (1685+(45*(y+z)),0140,aMensForm[y],oFont10)
				EndIf
			Next
		EndIf
	EndIf
	
	///
	fBox(1620,1500,1870,3300)
	oPrint:Say  (1640,1530,"Value of the Merchandises: " + AllTrim(Transform(_nTot,"@E 99,999,999.99")) ,oFont12n)
	oPrint:Say  (1690,1530,"(+) Freight: " + AllTrim(Transform(_nFrete,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1690,2080,"(+) Insurance: " + AllTrim(Transform(_nSeguro,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1690,2630,"(+) Expenditure: " + AllTrim(Transform(_nDespesa,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1740,1530,"(-) Discount : " + AllTrim(Transform(_nDescont,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1740,2080,"(+) IPI: " + AllTrim(Transform(_nIPI,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1740,2630,"Val. ICMS: " + AllTrim(Transform(_nICMS,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1800,2630,"Value Total:  " + AllTrim(Transform(((_nTot+_nIPI+_nFrete+_nSeguro)-_nDescont),"@E 99,999,999.99")),oFont14n)
	
	//
	dbSelectArea("SE4")
	dbSetOrder(1)
	If dbSeek(xFilial()+SC7->C7_COND)
		_cCond := SE4->E4_DESCRI //SE4->E4_COND
	Else
		_cCond := ""
	EndIf
	dbSelectArea("SC7")
	//
	fBox(1900,0100,2030,2580)
	fBox(1900,2600,2030,3300)
	oPrint:Say  (1920,0120,"Delivery place:   " + STRTRAN(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT '})[1][2]),"§","• andar Sala ")+" - "+AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDENT'})[1][2])+" - "+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2]+" - Zip Code: "+Transform(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPENT'})[1][2],"@R 99999-999"),oFont11)
	oPrint:Say  (1970,0120,"Collection place: " + STRTRAN(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDCOB'})[1][2]),"§","• andar Sala ")+" - "+AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDCOB'})[1][2])+" - "+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]+" - Zip Code: "+Transform(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPCOB'})[1][2],"@R 99999-999"),oFont11)
	oPrint:Say  (1920,2630,"Term of payment: " + _cCond ,oFont11n)
	//oPrint:Say  (1970,2630,"Obs. do Frete: " + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " )),oFont11n)
	///
	
else
	fBox(1620,0100,1870,1480)
	oPrint:Say  (1640,0120,"Observações:" ,oFont11n)
	//_cNomeMoeda := "(*) VALORES EM " + IIF(_nMoeda = 1, "REAL (R$).","DOLAR (US$).")
	//oPrint:Say  (1685,0140,_cNomeMoeda,oFont10n)
	z:= 1
	
	If Len(aOBS) > 0
		For z:=1 to Len(aOBS)
			If z<=4
				oPrint:Say  (1640+(75*z),0140,aOBS[z],oFont10n) //oPrint:Say  (1640+(45*z),0140,aOBS[z],oFont10)
			EndIf
		Next
	Endif
	
	If !Empty(_cMsgForm)
		cMensForm 	:= " (*) " + Formula(_cMsgForm)
		aMensForm 	:= U_FQUEBRATXT(cMensForm,65)//60
		If Len(aMensForm) > 0
			For y:=1 to Len(aMensForm)
				If y<=3
					oPrint:Say  (1685+(75*(y+z)),0140,aMensForm[y],oFont10)  //oPrint:Say  (1685+(45*(y+z)),0140,aMensForm[y],oFont10)
				EndIf
			Next
		EndIf
	EndIf
	
	///
	fBox(1620,1500,1870,3300)
	oPrint:Say  (1640,1530,"Valor das Mercadorias : " + AllTrim(Transform(_nTot,"@E 99,999,999.99")) ,oFont12n)
	oPrint:Say  (1690,1530,"(+) Frete: " + AllTrim(Transform(_nFrete,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1690,2080,"(+) Seguro: " + AllTrim(Transform(_nSeguro,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1690,2630,"(+) Despesa: " + AllTrim(Transform(_nDespesa,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1740,1530,"(-) Descontos : " + AllTrim(Transform(_nDescont,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1740,2080,"(+) IPI: " + AllTrim(Transform(_nIPI,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1740,2630,"Val. ICMS: " + AllTrim(Transform(_nICMS,"@E 99,999,999.99")),oFont12n)
	oPrint:Say  (1800,2630,"Total Geral :   " + AllTrim(Transform(((_nTot+_nIPI+_nFrete+_nSeguro)-_nDescont),"@E 99,999,999.99")),oFont14n)
	
	//
	dbSelectArea("SE4")
	dbSetOrder(1)
	If dbSeek(xFilial()+SC7->C7_COND)
		_cCond := SE4->E4_DESCRI //SE4->E4_COND
	Else
		_cCond := ""
	EndIf
	dbSelectArea("SC7")
	//
	fBox(1900,0100,2030,2580)
	fBox(1900,2600,2030,3300)
	oPrint:Say  (1920,0120,"Local de Entrega :   " + STRTRAN(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT'})[1][2]),"§","• andar Sala ")+" - "+AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDENT'})[1][2])+" - "+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2]+" - CEP: "+Transform(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPENT'})[1][2],"@R 99999-999"),oFont11)
	oPrint:Say  (1970,0120,"Local de Cobrança: " + STRTRAN(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDCOB'})[1][2]),"§","• andar Sala ")+" - "+AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDCOB'})[1][2])+" - "+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]+" - CEP: "+Transform(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPCOB'})[1][2],"@R 99999-999"),oFont11)
	oPrint:Say  (1920,2630,"Condição Pagto: " + _cCond ,oFont11n)
	//oPrint:Say  (1970,2630,"Obs. do Frete: " + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF"," " )),oFont11n)
endif
Return()


Static Function Impr_Roda(_nPag)
OpenSM0()
If _cEstado == 'EX' .AND.  _nConfirma == 1
	
	oPrint:Say  (2060,0750,"Puchaser",oFont11n)
	oPrint:Say  (2060,2100,"Management",oFont11n)
	// Incluir em parametroes os nomes   
	
	If Alltrim(cUserName)=="NANCI"
	oPrint:Say  (2170,0690,"Nanci Noto",oFont11)
	oPrint:Say  (2170,2040,"Nanci Noto",oFont11)
	ELSEIF FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] == "01" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2] == "01"  
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCM")),oFont11)
	ELSEIF FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] == "01" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2] == "02"  
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCJ")),oFont11)
	ELSEIF FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] == "02" 
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCC")),oFont11)
	else
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCT")),oFont11)
	ENDIF
	
	fBox(2050,0100,2130,3300)
	fBox(2130,0100,2260,3300)
	fBox(2050,1600,2260,1600)
	fBox(2050,3300,2260,3300)
	//
	fBox(2260,0100,2350,3300)
	//fBox(2340,3100,2330,3300)
	oPrint:Say  (2270,0150," *** PLEASE CONFIRM ***",oFont8)
	//	oPrint:Say  (2300,0150," *** NOTA2: Os Bloquetos de cobrança deverão ser entregues com no mínimo de 10 dias de antecedência do 1o. prazo de vencimento.",oFont8)
	oPrint:Say  (2300,3125,"Page: "+aLLtRIM(STR(_nPag)),oFont8)
	
else
	oPrint:Say  (2060,0750,"Comprador",oFont11n)
	oPrint:Say  (2060,2100,"Gerência",oFont11n)
	// Incluir em parametros os nomes
   //	oPrint:Say  (2170,0690,"Marcos Barbosa",oFont11)
   //	oPrint:Say  (2170,2040,cUserName,oFont11)
   
   	If Alltrim(cUserName)=="NANCI"
	oPrint:Say  (2170,0690,"Nanci Noto",oFont11)
	oPrint:Say  (2170,2040,"Nanci Noto",oFont11)
	ELSEIF FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] == "01" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2] == "01"  
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCM")),oFont11)
	ELSEIF FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] == "01" .AND. FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2] == "02"  
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCJ")),oFont11)
	ELSEIF FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] == "02" 
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCC")),oFont11)
	else
	oPrint:Say  (2170,0690,Alltrim(cUserName),oFont11)
	oPrint:Say  (2170,2040,ALLTRIM(GETMV("MV_XGERPCT")),oFont11)
	ENDIF

	
	fBox(2050,0100,2130,3300)
	fBox(2130,0100,2260,3300)
	fBox(2050,1600,2260,1600)
	fBox(2050,3300,2260,3300)
	//
	fBox(2260,0100,2350,3300)
	//fBox(2340,3100,2330,3300)
	oPrint:Say  (2270,0150," *** NOTA1: Títulos não poderao ser negociados com fatoring sem previa consulta ao n/depto. financiero P06.11.04.Rev00 Anexo 1. Mencionar o número de nosso pedido de compra em sua nota fiscal.",oFont8)
	oPrint:Say  (2300,0150," *** NOTA2: Os Bloquetos de cobrança deverão ser entregues com no mínimo de 10 dias de antecedência do 1o. prazo de vencimento.",oFont8)
	oPrint:Say  (2300,3125,"Pag: "+aLLtRIM(STR(_nPag)),oFont8)
endif
Return


Static Function Impr_Rd2(_nPag)
If _cEstado == 'EX' .AND.  _nConfirma == 1
fBox(2260,0100,2330,3300)
fBox(2260,3100,2330,3300)
oPrint:Say  (2270,0150,"This order continues in the next page...",oFont10)
oPrint:Say  (2270,3120,"Page: "+aLLtRIM(STR(_nPag)),oFont11n)
else
fBox(2260,0100,2330,3300)
fBox(2260,3100,2330,3300)
oPrint:Say  (2270,0150,"Esse pedido continua na próxima página...",oFont10)
oPrint:Say  (2270,3120,"Pag: "+aLLtRIM(STR(_nPag)),oFont11n)
endif
Return


Static Function Impr_Cab2()

Local _n5
Local i

OpenSM0()
fBox(0070,0100,0170,3300)
oPrint:Say  (0090,0130,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_NOMECOM'})[1][2],oFont14n)
If SA2->A2_EST == 'EX' .AND.  _nConfirma == 1

oPrint:Say  (0090,2450,"Continuation of the order : "+_cNumPed,oFont14n)
else                                                                
oPrint:Say  (0090,2500,"Continuação do pedido : "+_cNumPed,oFont14n)
endif
Return

Static Function fBox(_n1,_n2,_n3,_n4,_n5)

Local _n5
Local i 

If _n5 = Nil
	_n5 := 1
EndIf
For i := 0 to _n5
	oPrint:Line (_n1+i,_n2,_n1+i,_n4)
	oPrint:Line (_n3-i,_n2,_n3-i,_n4)
	oPrint:Line (_n1,_n2+i,_n3,_n2+i)
	oPrint:Line (_n1,_n4-i,_n3,_n4-i)
Next i
Return


Static Function GeraQbrPg()
If _nPag = 1 
	If _nLin>33
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("3")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf
ElseIF _nPag = 2
	If _nLin> 20 //32
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf 
ElseIF _nPag = 3
	If _nLin>20
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf	
ElseIF _nPag = 4
	If _nLin>20
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf	
ElseIF _nPag = 5
	If _nLin>20
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf	
ElseIF _nPag = 6
	If _nLin> 20 //32
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf 
ElseIF _nPag = 7
	If _nLin>20
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf	
ElseIF _nPag = 8
	If _nLin>20
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf	
ElseIF _nPag = 9
	If _nLin>20
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf	
Else
	If _nLin>40
		Impr_Rd2(_nPag)
		oPrint:EndPage()
		oPrint:StartPage()
		Impr_Cab2()
		Impr_Itens("4")
		_nPag := _nPag + 1
		_nLin := -5
	EndIf

EndIf
Return


User Function FQUEBRATXT(_xTXT,_nTam)
//****************************************************************************
//** FUNCAO  : FQUEBRATXT  ** Data : 28/09/06
//****************************************************************************
//** Descricao : Funcao separa e retorna o texto original no tamanho solicitado,
//** sem quebra de palavras pela metade (separa sempre entre espacos em branco).
//****************************************************************************

SetPrvt("_xTXT,_nTam,_aRet,_nMens,_cTxtMens")

_aRet 		:= {}
_xTXT		:= AllTrim(_xTXT)
_nPosQbra 	:= _nTam
//////////////////////////////////////////////////////////////////////////////////
// Verificando o tamanho de cada linha de mensagem e executando a quebra das
// mesnas se necessario.
//////////////////////////////////////////////////////////////////////////////////
If Len(_xTXT)>0
	If Len(_xTXT)>_nPosQbra
		_nLinQbra := 0
		Do While !Empty(AllTrim(_xTXT))
			If Len(_xTXT)>_nPosQbra
				_cTextoMax  := Substr(_xTXT,1,_nPosQbra)
				_nPosQbra1	:= AT(chr(10),_cTextoMax)
				_nPosQbra2	:= RAT(" ",_cTextoMax)
				//				If _nPosQbra2 > _nPosQbra1
				//					_nPosQbra := _nPosQbra2
				//				Else
				//					_nPosQbra := _nPosQbra1
				//				EndIf
				If  _nPosQbra1 > 0
					_nPosQbra := _nPosQbra1
				Else
					_nPosQbra := _nPosQbra2
				EndIf
				If _nPosQbra = 0
					_nPosQbra 	:= _nTam
				EndIf
			Else
				_nPosQbra := Len(_xTXT)
			EndIf
			_cTextoFim	:= Substr(_xTXT,1,_nPosQbra)
			_xTXT 		:= AllTrim(Substr(_xTXT,_nPosQbra+1,Len(_xTXT)))
			_nPosQbra 	:= _nTam
			_nPosCHR10  := AT(CHR(10),_cTextoFim)
			If _nPosCHR10 > 0
				_cTextoFim := Substr(_cTextoFim,1,_nPosCHR10-1)
			EndIf
			If !Empty(_cTextoFim)
				aadd(_aRET,_cTextoFim)
			EndIf
		EndDo
	Else
		_nPosCHR10  := AT(CHR(10),_xTxt)
		If _nPosCHR10 > 0
			_xTxt := Substr(_xTxt,1,_nPosCHR10-1)
		EndIf
		If !Empty(AllTrim(_xTxt))
			aadd(_aRET,AllTrim(_xTxt))
		EndIf
		//			aadd(_aRET,AllTrim(_xTxt))
	EndIf
EndIf

Return(_aRet)

