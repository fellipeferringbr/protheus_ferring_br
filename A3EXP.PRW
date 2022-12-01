#INCLUDE "Protheus.ch"
#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A3Exp     ºAutor  ³Tatiane De Oliveira º Data ³  11/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação dos  Vendedores(SA3)                  º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³leiaute 			                                                     					³
//³Campo			Descrição												Tipo	Tamanho ³
//³ID_VENDEDOR		Código do Vendedor no sistema de gestão					C		10      ³
//³NOME				Nome do Vendedor										C		40      ³
//³OBS				Observações sobre o Vendedor							C		40      ³
//³TERRITORIO		Território de vendas									C		10      ³
//³DOCUMENTO		Numero do documento do Vendedor (RG ou CPF)				C		20      ³
//³ENDERECO			Endereço do Vendedor									C		40      ³
//³BAIRRO			Bairro do Vendedor										C		25      ³
//³CEP				CEP do Vendedor											C		9       ³
//³CIDADE			Cidade do Vendedor										C		25      ³
//³UF				UF do Vendedor											C		2       ³
//³CONTATO_DDD		Número do DDD do Vendedor								C		3       ³
//³CONTATO_TELEFONE	Numero de telefone do Vendedor							C 		20      ³
//³CONTATO_EMAIL	Descrição do email do Vendedor							C		40      ³
//³ATIVO			Identificador se o Vendedor está Ativo/Inativo Sim/Não	C		3		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome do Arquivo: Vendedor(dataatual).txt		          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function A3Exp()

Local aBotoes	:= {}
Local aSays		:= {}
Local nOpcao	:= 0
Local oRegua    := Nil

Private __RETORNO := ""

Processa({|| RA3Exp() } )


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RA3Exp    ºAutor  ³Tatiane De Oliveira º Data ³  11/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação dos  Vendedores(SA3)                  º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function RA3Exp()
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

cQuery +=" Select A3_COD,A3_NOME,A3_END,A3_BAIRRO,A3_CEP,A3_MUN,A3_EST,A3_DDDTEL,A3_TEL,A3_EMAIL"+CRLF
cQuery +=" from " + RetSQLName("SA3") + " where  D_E_L_E_T_=''  "+CRLF

cQuery:=changequery(cQuery)
memowrite("c:\temp\RA3Exp.sql",cQuery)

LJMsgRun("Aguarde, consultando Lançamentos...","Aguarde...",bQuery)

ProcRegua(nTotReg)

//Gera o arquivo TXT
If nTotReg > 0
	_cNomFile := "\arqs_dcl\Vendedor"+DToS(date()) +".TXT"
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

		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_COD)+";"
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_NOME)+";"												
		cLinhaCSV +=";"												
		cLinhaCSV +=";"	
		cLinhaCSV +=";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_END)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_BAIRRO)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_CEP)+";"		
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_MUN)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_EST)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_DDDTEL)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_TEL)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A3_EMAIL)+";"	
		cLinhaCSV +="SIM;"                           
		FWrite(nHdl,cLinhaCSV+Chr(13)+Chr(10))
		TMP_CSV->(dbSkip())
		cLinhaCSV:=""
	EndDo 
	
FClose(nHdl)
MsgAlert("Atenção, foi gerado o arquivo "+_cNomFile+".")

Return(Nil)


