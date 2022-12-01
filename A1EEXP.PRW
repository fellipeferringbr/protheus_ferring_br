#INCLUDE "Protheus.ch"
#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A1eExp    ºAutor  ³Tatiane De Oliveira º Data ³  06/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação dos  Clientes(SA1)                    º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄd¿
//³	leiaute 			                                                        ³
//³COL#	Campo		Descrição										Tipo Tamanho³
//³1	ID_CLIENTE	Código do Cliente no  ERP do Cliente			C		14  ³
//³2	TIPOCLI		Tipo Cliente (Governo, Privado,Distribuidor)	C		15  ³
//³3	CGC			Número de CNPJ 									C		18  ³
//³4	DESCRICAO	Nome do Cliente									C		79  ³
//³5	REGIAO		Região geográfica do Cliente					C		30  ³
//³6	ENDERECO	Endereço do Cliente								C		40  ³
//³7	BAIRRO		Bairro do Cliente								C		20  ³
//³8	CARGO1		Cargo do contato 01								C		30  ³
//³9	CARGO2		Cargo do contato 02								C		30  ³
//³10	CARGO3		Cargo do contato 03								C		30  ³
//³11	CEP			CEP do Cliente									C		9   ³
//³12	CIDADE		Cidade do Cliente								C		20  ³
//³13	UF			UF do Cliente									C		2   ³
//³14	CONTATO1	Nome da pessoa de contato 01					C		30  ³
//³15	CONTATO2	Nome da pessoa de contato 02					C		30  ³
//³16	CONTATO3	Nome da pessoa de contato 03					C		30  ³
//³17	EMAIL1		e-mail do contato 01							C		80  ³
//³18	EMAIL2		e-mail do contato 02							C		80  ³
//³19	EMAIL3		e-mail do contato 03							C		80  ³
//³20	FAX			Número de FAX do Cliente						C		18  ³
//³21	FONE		Número de telefone do Cliente					C		18  ³
//³22	FONE1		Telefone do contato 01							C		18  ³
//³23	FONE2		Telefone do contato 02							C		18  ³
//³24	FONE3		Telefone do contato 03							C		18  ³
//³25	OBS			Observações sobre o Cliente						C		254 ³
//³26	RAMAL		Ramal 											C		18  ³
//³27	RAMAL1		Ramal do contato 01								C		18  ³
//³28	RAMAL2		Ramal do contato 02								C		18  ³
//³29	RAMAL3		Ramal do contato 03								C		18  ³
//³30	EMPRESA		Código da empresa 0001 ...						C		4   ³
//³31	STATUS		Situação do Cliente (ATIVO ou INATIVO) 01/02	C		2   ³
//³32	ID_REGIAO	Chave estrangeira da tabela Alíquotas 			C		3   ³
//³     			(Zona/lista de preços do Cliente)  							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄdÙ
ENDDOC*/

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome do Arquivo: Cliente(dataatual).txt		          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function A1eExp()

Local aBotoes	:= {}
Local aSays		:= {}
Local nOpcao	:= 0
Local oRegua    := Nil

Private __RETORNO := ""

Processa({|| RA1eExp() } )


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RA1eExp   ºAutor  ³Tatiane De Oliveira º Data ³  06/12/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo de exportação dos  Clientes(SA1)                    º±±
±±º          ³Conforme o layout comentado abaixo                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function RA1eExp()
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
Local cTipo		:=""

cQuery +=" Select A1_COD,A1_LOJA,A1__TIPO,A1_CGC,A1_NOME,A1__REGIAO,A1_END,A1_BAIRRO,A1_CEP,A1_MUN,A1_EST,"+CRLF
cQuery +="A1_EMAIL,A1_FAX,A1_TEL,A1_MSBLQL,A1_TABELA"+CRLF
cQuery +=" from " + RetSQLName("SA1") + " where  D_E_L_E_T_='' and A1_XDCL='S' and A1_MSBLQL='2'"+CRLF

cQuery:=changequery(cQuery)
memowrite("c:\temp\RA1eExp.sql",cQuery)

LJMsgRun("Aguarde, consultando Lançamentos...","Aguarde...",bQuery)

ProcRegua(nTotReg)

//Gera o arquivo TXT
If nTotReg > 0
	_cNomFile := "\arqs_dcl\Clientes"+DToS(date()) +".TXT"
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
         do case
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='D'
         		cTipo:="DISTRIBUIDOR"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='DF'
         		cTipo:="DISTRIBUIDOR"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='ER'
         		cTipo:="PRIVADO"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='F'
         		cTipo:="PRIVADO"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='FU'
         		cTipo:="PRIVADO"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='H'
         		cTipo:="PRIVADO"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='MP'
         		cTipo:="GOVERNO"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='OP'
         		cTipo:="GOVERNO"
         	CASE ALLTRIM(TMP_CSV->A1__TIPO)=='RF'
         		cTipo:="PRIVADO"
         	OTHERWISE
         		cTipo:="PRIVADO"
      ENDCASE  
      
      if cTipo <> "PRIVADO"
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_COD)+ALLTRIM(TMP_CSV->A1_LOJA)+";"
		cLinhaCSV +=cTipo+";"												
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_CGC)+";"												
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_NOME)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1__REGIAO)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_END)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_BAIRRO)+";"	
		cLinhaCSV +=";;;"
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_CEP)+";"		
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_MUN)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_EST)+";"	
		cLinhaCSV +=";;;" 
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_EMAIL)+";"	
		cLinhaCSV +=";;"                           
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_FAX)+";"	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_TEL)+";"	
		cLinhaCSV +=";;;;;;;;;"       
		if TMP_CSV->A1_MSBLQL='1'
			cLinhaCSV +="2;"
		else
			cLinhaCSV +="1;"
		endif	
		cLinhaCSV +=ALLTRIM(TMP_CSV->A1_TABELA)+";"	
		FWrite(nHdl,cLinhaCSV+Chr(13)+Chr(10))
	Endif
		TMP_CSV->(dbSkip())
		cLinhaCSV:=""
	EndDo 
	
FClose(nHdl)
MsgAlert("Atenção, foi gerado o arquivo "+_cNomFile+".")

Return(Nil)


