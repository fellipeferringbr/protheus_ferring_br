#INCLUDE "Protheus.ch"
#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DA1ExP    ºAutor  ³Tatiane De Oliveira º Data ³  06/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação da Tabela de Preço (DA1)	          º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³leiaute 			                                                    			   ³
//³Campo			Descrição											Tipo	Tamanho³
//³ID_PRODUTO		Chave estrangeira do produto						C		18     ³
//³ID_REGIAO		Zona/área de ICMS/Lista de Preço					C		3      ³
//³PRECO_PAD		Preço do produto por embalagem padrão				N		12,4   ³
//³PRECO_UNITARIO	Preço unitário do produto							N		12,4   ³
//³VALIDADE_INI		Data de vigência da validade do preço (data inicial)D		8	   ³
//³VALIDADE_FIN		Data de vigência da validade do preço (data final)	D		8  	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome do Arquivo: Preços(dataatual).txt		          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function DA1ExP()

Local aBotoes	:= {}
Local aSays		:= {}
Local nOpcao	:= 0
Local oRegua    := Nil

Private __RETORNO := ""

Processa({|| RDA1ExP() } )


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RDA1ExP   ºAutor  ³Tatiane De Oliveira º Data ³  06/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação da Tabela de Preço (DA1)	          º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function RDA1ExP()
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
cQuery +=" Select I.DA1_ITEM,I.DA1_CODPRO,I.DA1_CODTAB,I.DA1_PRCVEN,I.DA1_DATVIG,P.DA0_DATATE"+CRLF
cQuery +=" from " + RetSQLName("DA1") +" I "+CRLF
cQuery +=" inner join " + RetSQLName("DA0") + " P ON I.DA1_CODTAB= P.DA0_CODTAB "+CRLF                                          
cQuery +=" WHERE I.D_E_L_E_T_='' AND P.D_E_L_E_T_='' AND P.DA0_ATIVO='1' and (P.DA0_DATATE='' or P.DA0_DATATE>'"+DTOC(date())+"') "+CRLF

cQuery:=changequery(cQuery)
memowrite("c:\temp\RDA1ExP.sql",cQuery)

LJMsgRun("Aguarde, consultando Lançamentos...","Aguarde...",bQuery)

ProcRegua(nTotReg)

//Gera o arquivo TXT
If nTotReg > 0
  //	_cNomFile := "\arqs_dcl\Precos"+DToS(date()) +".TXT" 
	_cNomFile := "c:\temp\Precos"+DToS(date()) +".TXT"       // add. Franklin 09.04.14
	nHdl := FCreate(_cNomFile)
	If nHdl <= 0
		MsgAlert("Atenção, não foi possível criar o arquivo " + _cNomFile +"Verifique suas permissões de escrita na unidade ")
		Return(Nil)  
	EndIf 
Else           
	MsgAlert("Não há dados para serem exportados com os parâmetros informados.")
	Return(Nil)
EndIf                                          

	//DbSelectArea("SM0")
	//cEmp:=STRZERO(VAL(SM0->M0_CODIGO),4)
    cEmp:=STRZERO(VAL(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]),4)
	While TMP_CSV->(!Eof())
		IncProc()     

		cLinhaCSV +=ALLTRIM(TMP_CSV->DA1_CODPRO)+";"
		cLinhaCSV +=ALLTRIM(TMP_CSV->DA1_CODTAB)+";"												
		cLinhaCSV +=Strtran(CVALTOCHAR(TMP_CSV->DA1_PRCVEN),".",",")+";" 
		cLinhaCSV +=Strtran(CVALTOCHAR(TMP_CSV->DA1_PRCVEN),".",",")+";"	
		//cLinhaCSV +=DTOC(TMP_CSV->DA1_DATVIG)+";"	
		cLinhaCSV +=TMP_CSV->DA1_DATVIG+";"	
		//cLinhaCSV +=DTOC(TMP_CSV->DA0_DATATE)+";"	
		cLinhaCSV +=TMP_CSV->DA0_DATATE+";"	
		FWrite(nHdl,cLinhaCSV+Chr(13)+Chr(10))
		TMP_CSV->(dbSkip())
		cLinhaCSV:=""
	EndDo 
	
FClose(nHdl)
MsgAlert("Atenção, foi gerado o arquivo "+_cNomFile+".")

Return(Nil)
