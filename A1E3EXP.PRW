#INCLUDE "Protheus.ch"
#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A1e3Exp   ºAutor  ³Tatiane De Oliveira º Data ³  11/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação dos  Vendedores(SA3) e Clientes (SA1) º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³leiaute 			                                   			³
//³Campo		Descrição						Tipo	Tamanho	³
//³ID_CLIENTE	Chave estrangeira do Cliente	C		14  	³
//³ID_VENDEDOR	Chave estrangeira do Vendedor	C		10		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/ 
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome do Arquivo: Cliente_Vendedor(dataatual).txt	  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function A1e3Exp()  

Local aBotoes	:= {}
Local aSays		:= {}
Local nOpcao	:= 0
Local oRegua    := Nil

Private __RETORNO := ""

Processa({|| RA1e3Exp() } )


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RA1e3Exp  ºAutor  ³Tatiane De Oliveira º Data ³  11/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação dos  Vendedores(SA3) e Clientes (SA1) º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function RA1e3Exp()
Local nTotReg   := 0
Local nHdl      := 0 
Local cQuebra1  := ""
Local cQuebra2  := ""
Local aTot1     := {}
Local aTot2     := {}
Local aTotG     := {}
Local aTotProd  := {}
Local cQuery    := ""   
Local cLinhaCSV := ""    
Local cTipos    := ""
Local bQuery    := {|| Iif(Select("TMP_CSV") > 0, TMP_CSV->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_CSV",.F.,.T.) , dbSelectArea("TMP_CSV"),TMP_CSV->(dbEval({|| nTotReg++ })) ,TMP_CSV->(dbGoTop())}
lOCAL cEmp		:=""

cQuery +=" Select SA1.A1_COD,SA1.A1_LOJA,SA1.A1__VEND,SA3.A3_COD"+CRLF
cQuery +=" from " + RetSQLName("SA1") + " SA1 "+CRLF
cQuery +=" inner join " + RetSQLName("SA3") + " SA3 ON SA1.A1__VEND=SA3.A3_COD "
cQuery +=" WHERE  SA1.D_E_L_E_T_='' and SA3.D_E_L_E_T_='' AND SA1.A1__VEND!='' "+CRLF

cQuery:=changequery(cQuery)
memowrite("c:\temp\RA1e3Exp.sql",cQuery)

LJMsgRun("Aguarde, consultando Lançamentos...","Aguarde...",bQuery)

ProcRegua(nTotReg)

//Gera o arquivo TXT
If nTotReg > 0
	_cNomFile := "\arqs_dcl\Cliente_Vendedor"+DToS(date()) +".TXT"
	nHdl := FCreate(_cNomFile)
	If nHdl <= 0
		MsgAlert("Atenção, não foi possível criar o arquivo " + _cNomFile +"Verifique suas permissões de escrita na unidade ")
		Return(Nil)  
	EndIf 
Else           
	MsgAlert("Não há dados para serem exportados com os parâmetros informados.")
	Return(Nil)
EndIf                                          

//	DbSelectArea("SM0")
	cEmp:=STRZERO(VAL(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]),4) //STRZERO(VAL(SM0->M0_CODIGO),4)
 	While TMP_CSV->(!Eof())
		IncProc()     

		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_COD)+ALLTRIM(TMP_CSV->A1_LOJA)+";"
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_COD)+";"
		FWrite(nHdl,cLinhaCSV+Chr(13)+Chr(10))
		TMP_CSV->(dbSkip())
		cLinhaCSV:=""
	EndDo 
	
FClose(nHdl)
MsgAlert("Atenção, foi gerado o arquivo "+_cNomFile+".")

Return(Nil)


