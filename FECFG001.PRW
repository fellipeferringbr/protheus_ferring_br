#include "totvs.ch"
#include "fileio.ch"


/**************************************************************************************************
Função:
FECFG001

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2014

Descrição:
Este programa será utilizado durante a limpeza do ambiente da Ferring, para auditar se os 
programas do menu realmente estão compilado no repositório de objetos (este programa poderá
ser removido do projeto e do repositório no futuro após esta fase de correção do ambiente).

**************************************************************************************************/
User Function FECFG001()

Local cXNUPath  := "\SYSTEM\"
Local cLogPath  := "\TEMP\"
Local cLogFile  := "Menu_Log_" + SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2) + ".csv"
Local nHndLog   := 0
Local nHndXNU   := 0
Local nSizeXNU  := 0
Local aArqXNU   := {}
Local cArqXNU   := ""
Local cXML      := ""
Local cError    := ""
Local cWarning  := ""
Local oXML      := Nil
Local lSoEnable := .T.
Local lSoUser   := .T.
Local nJ, nI	:= 0

// Abre o ambiente (para que a função seja executada diretamente da tela de abertura)
RpcSetType(3)
RpcSetEnv("01", "01",,,"FAT",GetEnvServer())

//Cria o arquivo de Log
nHndLog := FCreate(cLogPath + cLogFile , FC_NORMAL)

If nHndLog == -1
	Alert("Erro na criação do arquivo CSV de log: " + clogPath + cLogFile)
	Return .F.
EndIf 
		
//Carrega todos os arquivos XNU do diretório
aArqXNU := Directory(cXNUPath + "*.XNU")

FWrite(nHndLog, "Numero do Arquivo;Nome do Arquivo;Caminho;Função;User Function;Existe no RPO" + CRLF)

For nI := 1 To 1 //Len(aArqXNU)

	cNumArq := AllTrim(Str(nI))
	cArqXNU := aArqXNU[nI,1]
	nHndXNU := FOpen(cXNUPath + cArqXNU, FO_READ)
	
	If nHndXNU == -1
		Alert("Erro na abertura do arquivo XNU: " + aArqNXU[1,1])
		Return .F.
	EndIf 
	
	nSizeXNU := FSeek(nHndXNU, 0, 2) // Verifica o tamanho de caracteres do arquivo
	FSeek(nHndXNU, 0, 0)             // Posiciona no inicio do arquivo
	FRead(nHndXNU, @cXML, nSizeXNU ) // Lê todo o arquivo e grava na strig
	
	// Remove caracteres inválidos do XML
	// e converte para formato válido
	cXML := StrTran(cXml, "&", "")
	cXML := NoAcento(cXML)
	cXML := AnsiToOem(cXML)
	cXML := EncodeUTF8(cXML)
	
	// Efetua o parser do arquivo XNU para o objeto XML
	oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
	If oXML == Nil
		FWrite(nHndLog, cNumArq + ";" + cArqXNU + ";;" + "<ERRO>LOADINGFILE" + ";" + "E" + ";" + CRLF)
	ElseIf XMLChildEx(oXML, "_APMENU") == Nil
		FWrite(nHndLog, cNumArq + ";" + cArqXNU + ";;" + "<ERRO>XNUINVALIDO" + ";" + "E" + ";" + CRLF)
	Else
		// Carrega todas as funções do arquivo no array
		//aFuncoes := {}
		//U_GetXMLFunctions(oXML:_APMENU, @aFuncoes)
		
		aMenu := U_XMLToArr(oXML:_APMENU)
		aFuncoes := U_SimplificaArr(aMenu)
		
		For nJ := 1 To Len(aFuncoes)
		
			cCaminho  := aFuncoes[nJ, 1]
			cFuncao   := AllTrim(aFuncoes[nJ, 2])
			lEnable   := Iif(aFuncoes[nJ, 3] == Nil, .F., aFuncoes[nJ, 3])
			lUserFunc := Iif(aFuncoes[nJ, 4] == Nil, .F., aFuncoes[nJ, 4])
			
			If (!lSoEnable .Or. (lSoEnable .And. lEnable)) .And.;
			   (!lSoUser .Or. (lSoUser .And. lUserFunc))   
			
				lAchou := Iif(lUserFunc, FindFunction("U_" + cFuncao), FindFunction(cFuncao))
			
			 	FWrite(nHndLog, cNumArq + ";" + cArqXNU + ";" + cCaminho + ";"  + cFuncao + ";" + Iif(lUserFunc, "S", "N") + ";" + Iif(lAchou, "S", "N") + CRLF)
			 	
			EndIf  
		Next nJ
	EndIf
		
	FClose(nHndXNU)

Next nI

FClose(nHndLog)

Alert("Fim da Carga de Dados")

RpcClearEnv()

Return .T.


/**************************************************************************************************
Função:
GetXMLFunctions

Autor:
Tiago Bandeira Brasiliano

Data:
11/09/2014

Descrição:
Retorna um array contendo as funções de um determinado arquivo XML (já carregado do arquivo de 
menu .XNU).

Parâmetros:
oXMLNode   => Nó do XML de onde partirá a busca pelas funções (normalmente o nó principal do XML).
aFunctions => Retorna o array contendo as funções no XML (deverá ser passado como referência).

Retorno:
Nenhum
**************************************************************************************************/
User Function GetXMLFunctions(oXMLNode, aFunctions)

Local nSize     := XMLChildCount(oXMLNode)
Local nI        := 0
Local nJ        := 0
Local cFunction := ""
Local xNode     := Nil

Default aFunctions := {}

If !Upper(oXMLNode:REALNAME) $ "APMENU|MENU|MENUITEM"
	Return .F.
EndIf

If Upper(oXMLNode:REALNAME) $ "MENU|MENUITEM"
	
	If Upper(oXMLNode:REALNAME) == "MENUITEM"
		cFunction := oXMLNode:_FUNCTION:TEXT
		aAdd(aFunctions, cFunction)
	EndIf
	 
EndIf

For nI := 1 To nSize

	xNode := XMLGetChild(oXMLNode, nI)
	
	If ValType(xNode) == "A"
		
		For nJ := 1 To Len(xNode)
		
			U_GetXMLFunctions(xNode[nJ], @aFunctions)
			
		Next nJ
		
	ElseIf ValType(xNode) == "O"
		
		U_GetXMLFunctions(xNode, @aFunctions)
		
	EndIf
	
Next nI

Return .T.


/**************************************************************************************************
Função:
XMLToArr

Autor:
Tiago Bandeira Brasiliano

Data:
11/09/2014

Descrição:
Converte um arquivo XML de Menu (arquivo XNU) em um array multidimensional contendo os menus e
sub-menus.

Parâmetros:
oXMLNode => Nó do XML de onde partirá a busca pelas funções (normalmente o nó principal do XML).

Retorno:
aMenu    => Array contendo a estrutura do XML (XNU).
**************************************************************************************************/
User Function XMLToArr(oXMLNode)

Local nSize     := XMLChildCount(oXMLNode)
Local nI        := 0
Local nJ        := 0
Local cRet      := ""
Local cStatus   := ""
Local cTitulo   := ""
Local cFunction := ""
Local lUserFunc := .F.
Local lEnable   := .F.
Local xNode     := Nil
Local aMenu     := {}
Local aRet      := {}
Local cRealName := Upper(oXMLNode:REALNAME)
Local aSubNos   := {}

If !cRealName $ "APMENU|MENU|MENUITEM"
	Return {}
EndIf

// Obtem os sub nos
For nI := 1 To nSize

	xNode := XMLGetChild(oXMLNode, nI)
	
	If ValType(xNode) == "A"
		
		For nJ := 1 To Len(xNode)
		
			aRet := U_XMLToArr(xNode[nJ])
			
			If !Empty(aRet)
				aAdd(aSubNos, aRet)
			EndIf
		Next nJ
		
	ElseIf ValType(xNode) == "O"
		
		aRet := U_XMLToArr(xNode)
		
		If !Empty(aRet)
			aSubNos := aRet
		EndIf
			
	EndIf
	
Next nI

If cRealName == "APMENU"

	aMenu := aSubNos

ElseIf cRealName $ "MENU|MENUITEM"
	
	cRealName := Upper(oXMLNode:REALNAME)
	cStatus   := oXMLNode:_STATUS:TEXT
	cTitulo   := oXMLNode:_TITLE[1]:TEXT
	
	If cRealName == "MENUITEM"
		cFunction := oXMLNode:_FUNCTION:TEXT
		cStatus   := Upper(oXMLNode:_STATUS:TEXT)
		nType     := Val(oXMLNode:_TYPE:TEXT)
		cFunction := StrTran(StrTran(cFunction, "(", ""), ")", "")
		lUserFunc := (nType == 3) .Or. (PadL(cFunction, 2) == "U_")
		lEnable   := cStatus == "ENABLE" 
	EndIf
	
	aMenu := {aSubNos, cRealName, cStatus, cTitulo, cFunction, lUserFunc, lEnable}
	 
EndIf

Return aMenu


/**************************************************************************************************
Função:
SimplificaArr

Autor:
Tiago Bandeira Brasiliano

Data:
12/09/2014

Descrição:
Converte o um array contendo N níveis e sub-niveis em uma array simplificado.


Parâmetros:
aArrayIni => Array de multi-dimensoes que será convertido.

Retorno:
aArrayRet => Array simplificado no seguinte formato:
             aArrayRet[nx, 1] = Caminho do Menu
             aArrayRet[nx, 2] = Função
             aArrayRet[nx, 3] = User Function
             aArrayRet[nx, 4] = Habilitada  
**************************************************************************************************/
User Function SimplificaArr(aArrayIni)

Local aArrayRet := {}
Local cCaminho  := ""
Local cRet      := ""
Local aRet      := {}
Local aSub      := {}
Local aRetorno  := {}
Local nI        := 0
Local cFuncao   := ""
Local lUserFunc := Nil
Local lHabilit  := Nil

If ValType(aArrayIni) == "A"

	For nI := 1 To Len(aArrayIni)
		
		If ValType(aArrayIni[nI]) == "A"
			aRet := U_SimplificaArr(aArrayIni[nI])
			If !Empty(aRet)
				If Len(aRet) > 1
					aEval(aRet, {|x| aAdd(aSub, {x})})
				Else
					aAdd(aSub, aRet)
				EndIf
			EndIf
		Else
			cCaminho := aArrayIni[4] // [4] = Titulo
			If !Empty(aArrayIni[5]) // [5] = Função
				cFuncao   := aArrayIni[5]
				lUserFunc := aArrayIni[6]
				lHabilit  := aArrayIni[7]
			EndIf
			Exit
		EndIf
		
	Next nI
	
	If Empty(aSub) .And. !Empty(cCaminho)
		aAdd(aRetorno, {cCaminho, cFuncao, lUserFunc, lHabilit})
	Else
		For nI := 1 To Len(aSub)
			If !Empty(aSub[nI])
				aAdd(aRetorno, {cCaminho + Iif(Empty(cCaminho) .Or. Empty(aSub[nI,1,1]), "", " > ") + aSub[nI,1,1],;
				                aSub[nI,1,2],;
				                aSub[nI,1,3],;
				                aSub[nI,1,4]})
			EndIf
		Next nI
	EndIf
	
EndIf

Return aRetorno


/**************************************************************************************************
Função:
SA1DataInc

Autor:
Tiago Bandeira Brasiliano

Data:
09/10/2014

Descrição:
Atualiza a data de inclusão do cadastro de clientes (pois este campo estava sendo deixado em
branco). Para isto utilizarei o campo A1_USERLGI para obter a informação da data de inclusão
do registro.
O campo USERLGI é criptografado. Para descriptografar utilizo a função Embaralha. A mesma me
retorna da posição 1 até 15 os dados do usuário e da 16 até a 17 a data.
Porém a data é relativa ao dia 	01/01/96.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function SA1DataInc()

Local cDataLGI := ""
Local dDataInc := StoD("")

dbSelectArea("SA1")
SA1->(dbSetOrder(1)) // FILIAL + COD + LOJA

SA1->(dbGoTop())

While !SA1->(Eof())

	cDataLGI := Load2in4(Substr(Embaralha(SA1->A1_USERLGI,1),16))
	
	If !Empty(cDataLGI)
	
		dDataInc := CTOD("01/01/96") + cDataLGI
		
		If !Empty(dDataInc)
			RecLock("SA1", .F.)
			SA1->A1_DTNASC := dDataInc
			SA1->(msUnlock())
		EndIf
		
	EndIf

	SA1->(dbSkip())
EndDo

Alert("Campos de Data de Inclusão do Cliente atualizados com sucesso!")

Return .T.


/**************************************************************************************************
Função:
SA2DataInc

Autor:
Tiago Bandeira Brasiliano

Data:
09/10/2014

Descrição:
Atualiza a data de inclusão do cadastro de fornecedores (pois este campo estava sendo deixado em
branco). Para isto utilizarei o campo A2_USERLGI para obter a informação da data de inclusão
do registro.
O campo USERLGI é criptografado. Para descriptografar utilizo a função Embaralha. A mesma me
retorna da posição 1 até 15 os dados do usuário e da 16 até a 17 a data.
Porém a data é relativa ao dia 	01/01/96.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function SA2DataInc()

Local cDataLGI := ""
Local dDataInc := StoD("")

dbSelectArea("SA2")
SA2->(dbSetOrder(1)) // FILIAL + COD + LOJA

SA2->(dbGoTop())

While !SA2->(Eof())

	cDataLGI := Load2in4(Substr(Embaralha(SA2->A2_USERLGI,1),16))
	
	If !Empty(cDataLGI)
	
		dDataInc := CTOD("01/01/96") + cDataLGI
		
		If !Empty(dDataInc)
			RecLock("SA2", .F.)
			SA2->A2_DTINIV := dDataInc
			SA2->(msUnlock())
		EndIf
		
	EndIf

	SA2->(dbSkip())
EndDo

Alert("Campos de Data de Inclusão do Fornecedore atualizados com sucesso!")

Return .T.
