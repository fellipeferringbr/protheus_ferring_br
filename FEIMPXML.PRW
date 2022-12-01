#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'AP5MAIL.CH'

USER FUNCTION FEIMPXML()
Local i
PRIVATE cPath := ""
PRIVATE aVetor := ""
PRIVATE aArq   := ""

SpedExport(1)
cPath := ALLTRIM(MV_PAR04)
IF !Empty(cPath)
	CARREGAXML(cPath)
	IF LEN(aVetor) > 0 
	  U_MXMLLUFT(aVetor)
	ENDIF
	
	//// Apaga todos os arquivos na pasta
	FOR i := 1 TO LEN(aArq)
		FERASE(ALLTRIM(cPath+aArq[i,1]))
	NEXT
ENDIF

RETURN()

STATIC FUNCTION CARREGAXML(cPath)
LOCAL cTitulo := "Arquivos para importação"
LOCAL cDoc    := ""
LOCAL cSerie  := ""
LOCAL cData   := ""
LOCAL dData   := ""
LOCAL cCod    := ""
LOCAL cLoja   := ""
LOCAL cNom    := ""
LOCAL cChave  := ""
LOCAL cArq    := ""
LOCAL cCNPJ   := ""
LOCAL cTexto  := ""
LOCAL cFile   := ""
LOCAL cAviso  := ""
LOCAL cErro   := ""
Local i
aVetor := {}

//// Caso o cPath estiver em branco busca os arquivos do ultimo diretorio gravada.
aArq := directory(cPath+"*.xml")
FOR i := 1 TO LEN(aArq)
	
	cFile := cPath+"\"+aArq[i,1]
	nHdl  := fOpen(cFile,0)
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
	fClose(nHdl)
	
	cAviso := ""
	cErro  := ""
	oTipo  := XmlParser(cBuffer,"_",@cAviso,@cErro)
	
	//// Verifica se é NFE
	IF TYPE("oTipo:_NfeProc") <> "U"
		oNfe   := XmlParser(cBuffer,"_",@cAviso,@cErro)

		IF TYPE("oNFe:_NfeProc")<> "U"
			oNF := oNFe:_NFeProc:_NFe
		ELSE
			oNF := oNFe:_NFe
		ENDIF
		
		cDoc   := ""
		cSerie := ""
		cData  := ""
		dData  := ""
		cCod   := ""
		cLoja  := ""
		cNom   := ""
		cChave := ""
		cTipo  := ""
		cArq   := aArq[i,1]
		cCNPJ  := ""
		
		//// Caso o CNPJ nao for da filial ativa nao carrega a nota.
		IF FWSM0Util():GetSM0Data(,,{"M0_CFC"})[1][2] = oNfe:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
      IF TYPE("oNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ") <> "U"
			  cCNPJ  := oNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
      ELSEIF TYPE("oNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF") <> "U"
			  cCNPJ  := oNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT
      ENDIF
			cDoc   := PADL(Alltrim(oNfe:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),9,"0") //Nro da Nota
			cSerie := PADR(oNfe:_NfeProc:_Nfe:_InfNfe:_IDE:_Serie:Text,3," ")
			dData  := STOD(SUBSTR(Alltrim(oNfe:_NfeProc:_Nfe:_InfNfe:_IDE:_dhEmi:TEXT),1,4) + SUBSTR(Alltrim(oNfe:_NfeProc:_Nfe:_InfNfe:_IDE:_dhEmi:TEXT),6,2) + SUBSTR(Alltrim(oNfe:_NfeProc:_Nfe:_InfNfe:_IDE:_dhEmi:TEXT),9,2))
			cChave := oNFe:_NFeProc:_protNFe:_infProt:_chNFe:TEXT
			//// VerIFica se o CNPJ e de Fornecedor ou de Cliente
			IF !EMPTY(POSICIONE("SA2",3,XFILIAL("SA2")+cCNPJ,"A2_COD"))
				
				//// VerIFica se a Nota já existe
				IF SF1->(DBSEEK(XFILIAL("SF1")+cDoc+cSerie+SA2->A2_COD+SA2->A2_LOJA))
					LOOP
				ELSE
					cCod  := SA2->A2_COD
					cLoja := SA2->A2_LOJA
					cNom  := SA2->A2_NREDUZ
					cTipo := "F"
				ENDIF
			ELSEIF !EMPTY(POSICIONE("SA1",3,XFILIAL("SA1")+cCNPJ,"A1_COD"))
				IF SF1->(DBSEEK(XFILIAL("SF1")+cDoc+cSerie+SA1->A1_COD+SA1->A1_LOJA))
					LOOP
				ELSE
					cCod  := SA1->A1_COD
					cLoja := SA1->A1_LOJA
					cNom  := SA1->A1_NREDUZ
					cTipo := "C"
				ENDIF
			ENDIF
			IF EMPTY(cCod)
				cCod  := ""
				cLoja := ""
				cNom  := "FORNECEDOR / CLIENTE NAO ENCONTRADO"
				cTipo := ""
			ENDIF
			AADD( aVetor, {.F.,cDoc,cSerie,dData,cCod,cLoja,cNom,cArq})
		ENDIF
	ENDIF
NEXT

IF LEN( aVetor ) == 0
	Aviso( cTitulo, "Não existem arquivos a serem importados para esta filial.", {"Ok"} )
	RETURN
ENDIF

RETURN()
