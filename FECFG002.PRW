#include "totvs.ch"


/**************************************************************************************************
Função:
FECFG002

Autor:
Tiago Bandeira Brasiliano

Data:
31/10/2014

Descrição:
Este programa é utilizado para comparar a estrutura de dois diretórios de projetos, e apontar a
diferença entre os fontes do mesmo.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FECFG002()

Local oFont1    := Nil   
Local oDialog   := Nil
Local oImagem   := Nil
Local cLog      := ""
Local cArqLog   := "D:\TOTVS\COMPARA.CSV"
Local cTipoArq 	:= "Todos os Arquivos (*.*)     | *.* |"
Local bGravaArq := {|| Iif(!Empty(cLog), Eval({|| MemoWrite(cArqLog, cLog) ,Iif(nOpc == 1, ShellExecute("open", cArqLog, "", "", 1), Nil), MsgInfo("Arquivo gerado com sucesso!")}), Alert("Nenhum arquivo foi gerado!"))}
Local nOpc      := 1
Local cDir      := "C:\"
Local cPath1    := PadR(cDir, 250)
Local cPath2    := PadR(cDir, 250)
Local cExtensao := ""
Local cMsgProc  := "Aguarde. Gerando relatório..."
Local cTitulo   := "Comparação de Projetos"

oFont1 := TFont():New(,,16,,.T.) 

oDialog := MSDialog():New(0, 0, 240, 400, OemToAnsi(cTitulo),,,,,,CLR_WHITE,,,.T.,,,)

TSay():New(005,053,{|| "Comparação de Pastas de Projetos"},,,oFont1,,,,.T.)

//+---------------------------------------+
//| Get de inserção da pasta do Projeto 1 |
//+---------------------------------------+
TGroup():New(015,004,043,197," Projeto 1: "  ,oDialog,,,.T.)
TGet():New(024,008,bSetGet(cPath1),,171,010,,,,,,,,.T.)
TBtnBmp2():New(047,359,026,026,"SDUOPEN",,,,{|| cPath1 := cGetFile(cTipoArq,"Selecione o diretório de destino",0,cDir,.T.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_RETDIRECTORY, .F.)}, oDialog, "Obtem Projeto 1")

//+---------------------------------------+
//| Get de inserção da pasta do Projeto 2 |
//+---------------------------------------+
TGroup():New(045,004,072,197," Projeto 2: "  ,oDialog,,,.T.)
TGet():New(054,008,bSetGet(cPath2),,171,010,,,,,,,,.T.)
TBtnBmp2():New(107,359,026,026,"SDUOPEN",,,,{|| cPath2 := cGetFile(cTipoArq,"Selecione o diretório de destino",0,cDir,.T.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_RETDIRECTORY, .F.)}, oDialog, "Obtem Projeto 2")
                                                          
TGroup():New(082,004,113,095," Opções: ",oDialog,,,.T.)
oImagem := TBitmap():New(093,009, 32, 32, "MDIEXCEL",,.T.,oDialog,,,,,,,,,.T.,,,.T.)
TRadMenu():New(093,025,{"Gera arquivo + Abre","Somente gera arquivo"},bSetGet(nOpc), oDialog,,{|| oImagem:Load(Iif(nOpc == 1, "MDIEXCEL", "SALVAR"))},,,,,,065,011,,,,.T.)
     
//SButton():New(100, 110, 5, {|| Pergunte(cPerg, .T.)}) // Parametros
SButton():New(100, 140, 1, {|| Eval({|| Processa({|| cLog := U_ComparaProjetos(cPath1, cPath2)}, cMsgProc,, .T.), Eval(bGravaArq), oDialog:End()})} ) // Ok
SButton():New(100, 170, 2, {|| oDialog:End()})         // Cancela

ACTIVATE DIALOG oDialog CENTERED

Return .T.


/**************************************************************************************************
Função:
ComparaProjetos

Autor:
Tiago Bandeira Brasiliano

Data:
03/11/2014

Descrição:
Efetua a comparação entre dois projetos, demonstrando se existe diferença de fontes entre os
mesmos.

Parâmetros:
cPj1Path => Caminho do projeto 1 para comparação
cPj2Path => Caminho do projeto 2 para comparação

Retorno:
cLog     => Texto contendo as informações dos projetos (no formado CSV - separado por vírgula).
**************************************************************************************************/
User Function ComparaProjetos(cPj1Path, cPj2Path)

Local nI        := 1
Local aProjeto1 := MultiToUni(U_GetAllDir(cPj1Path))
Local aProjeto2 := MultiToUni(U_GetAllDir(cPj2Path))
Local aCompara  := FundeProj(aProjeto1, aProjeto2)
Local cStatus   := ""
Local cPj1Path  := ""
Local cPj1File  := ""
Local cPj1Size  := ""
Local cPj1Date  := ""
Local cPj1Time  := ""
Local cPj2Path  := ""
Local cPj2File  := ""
Local cPj2Size  := ""
Local cPj2Date  := ""
Local cPj2Time  := ""
Local cLog      := ""

cLog += "STATUS;DIRETORIO PROJETO1;ARQUIVO PROJETO 1;DATA PJ 1;HORA PJ 1;;DIRETORIO PROJETO2;ARQUIVO PROJETO 2;DATA PJ 2;HORA PJ 2" + CRLF 

For nI := 1 To Len(aCompara)

	cPj1Path := aCompara[nI,1,1]
	cPj1File := aCompara[nI,1,2]
	cPj1Size := aCompara[nI,1,3]
	cPj1Date := Iif(Empty(aCompara[nI,1,4]), "", DtoC(aCompara[nI,1,4]))
	cPj1Time := aCompara[nI,1,5]
	cPj2Path := aCompara[nI,2,1]
	cPj2File := aCompara[nI,2,2]
	cPj2Size := aCompara[nI,2,3]
	cPj2Date := Iif(Empty(aCompara[nI,2,4]), "", DtoC(aCompara[nI,2,4]))
	cPj2Time := aCompara[nI,2,5]
	
	cStatus := ""
	
	If Empty(cPj1File)
		cStatus := "N1"
	ElseIf Empty(cPj2File)
		cStatus := "N2"
	ElseIf (cPj1Date > cPj2Date) .Or. (cPj1Date == cPj2Date .And. cPj1Time > cPj2Time)
		cStatus := "A1"
	ElseIf (cPj2Date > cPj1Date) .Or. (cPj1Date == cPj2Date .And. cPj2Time > cPj1Time)
		cStatus := "A2"
	ElseIf cPj1Size <> cPj2Size
		cStatus := "TD"
	ElseIf cPj1Date == cPj2Date .And. cPj2Time == cPj1Time
		cStatus := "IG"
	EndIf
	
	cLog += cStatus + ";" + cPj1Path + ";" + cPj1File + ";" + cPj1Date + ";" + cPj1Time + ";;" + cPj2Path + ";" + cPj2File + ";" + cPj2Date + ";" + cPj2Time + CRLF	
	
Next nI

cLog += CRLF
cLog += "LEGENDA:;;;;;;;;;" + CRLF
cLog += "N1;Não existe no Projeto 1;;;;;;;;" + CRLF
cLog += "N2;Não existe no Projeto 2;;;;;;;;" + CRLF
cLog += "A1;Projeto 1 Mais Atual;;;;;;;;" + CRLF
cLog += "A2;Projeto 2 Mais Atual;;;;;;;;" + CRLF
cLog += "TD;Tamanho Diferente;;;;;;;;" + CRLF
cLog += "IG;Fontes Iguais;;;;;;;;" + CRLF

Return cLog
 

/**************************************************************************************************
Função:
GetAllDir

Autor:
Tiago Bandeira Brasiliano

Data:
03/11/2014

Descrição:
Retorna todos os arquivos e sub-diretórios de um determinado diretório.

Parâmetros:
cDir  => Define o diretório raiz onde será efetuada a busca.

Retorno:
Nenhum
**************************************************************************************************/
User Function GetAllDir(cDir)

Local aArquivos := {}
Local aArqRet   := {}
Local nI        := 0

aArquivos := Directory(cDir + "*.*", "D")

If Len(aArquivos) > 0  
	For nI := 1 To Len(aArquivos)
		
		// Não considera as pastas de sistema: \. e \..
		If aArquivos[nI, 5] == "D" .And. AllTrim(aArquivos[nI, 1]) $ ".#.."
			Loop
		EndIf
		
		// Pesquisa por sub-diretórios
		If aArquivos[nI, 5] == "D"
			aSubArq := U_GetAllDir(cDir + aArquivos[nI,1] + "\")
			
			If Len(aSubArq) > 0
				aAdd(aArquivos[nI], aSubArq)
			EndIf
		EndIf
		
		// Adiciona o conteúdo a variável de retorno
		aAdd(aArqRet, aArquivos[nI])	
	Next nI
EndIf

Return aArqRet


/**************************************************************************************************
Função:
MultiToUni

Autor:
Tiago Bandeira Brasiliano

Data:
05/11/2014

Descrição:
Transforma uma array multidimensional contendo as informações das pastas e arquivos, em um array
unidimensional.

Parâmetros:
aMultiDir  => Array multidimensional contendo os diretórios e arquivos.

Retorno:
aUniDimen  => Array unidimensional contendo os diretórios e informações dos arquivos, onde:
              aUniDimen[x,1] = Diretório do arquivo.
              aUniDimen[x,2] = Nome do arquivo.
              aUniDimen[x,3] = Tamanho do arquivo.
              aUniDimen[x,4] = Data da última alteração.
              aUniDimen[x,5] = Hora da última alteração.
              aUniDimen[x,6] = Tipo do arquivo.
              aUniDimen[x,7] = Campo adicional utilizado para outros controles.
**************************************************************************************************/
Static Function MultiToUni(aMultiDir)

Local nI,nJ       := 0
Local aUniDimen := {}
Local aSubArray := {}

For nI := 1 To Len(aMultiDir)
	
	If Len(aMultiDir[nI]) == 6
		
		//Obtem de forma recursiva as sub-pastas/arquivos
		aSubArray := MultiToUni(aMultiDir[nI,6])
		
		If Len(aSubArray) > 0
			For nJ := 1 To Len(aSubArray)
				aSubArray[nJ, 1] := aMultiDir[nI, 1] + "\" + aSubArray[nJ, 1]
				aAdd(aUniDimen, aSubArray[nJ])
			Next nJ
		EndIf
		
	Else
	     
		aSize(aMultiDir[nI], Len(aMultiDir[nI]) + 2)
		aIns(aMultiDir[nI], 1)
		aMultiDir[nI, 1] := "" 
		aAdd(aUniDimen, aMultiDir[nI])
	
	EndIf
	
Next nI

Return aUniDimen


/**************************************************************************************************
Função:
FundeProj

Autor:
Tiago Bandeira Brasiliano

Data:
05/11/2014

Descrição:
Obtem dois arrays contendo informações de projetos, e cria um terceiro array com a fusão destes
dois projetos. Este array de fusão já virá ordenado e relacionando os mesmos arquivos na mesma
posição do array. Quando um arquivo existir em um projeto e não existir no outro, a posição do
outro projeto será deixada em branco.

Parâmetros:
aProjeto1  => Array unidimensional contendo informações do projeto 1
aProjeto2  => Array unidimensional contendo informações do projeto 2

Retorno:
aCompara   => Array contendo a fusão entre os dois projetos (para posterior comparação)
**************************************************************************************************/
Static Function FundeProj(aProjeto1, aProjeto2)

Local aFusao     := {}
Local cFullPath1 := ""
Local cFullPath2 := ""
Local nMaxSize   := Max(Len(aProjeto1), Len(aProjeto2))
Local nI         := 1

While nI <= nMaxSize

	If nI > Len(aProjeto1)
		aSize(aProjeto1, nI)
		aProjeto1[nI] := {"","","","","","",""}
		
		nI++
		nMaxSize := Max(Len(aProjeto1), Len(aProjeto2))
		
		Loop
	ElseIf nI > Len(aProjeto2)
		aSize(aProjeto2, nI)
		aProjeto2[nI] := {"","","","","","",""}
		
		nI++
		nMaxSize := Max(Len(aProjeto1), Len(aProjeto2))
		
		Loop
	EndIf
	
	cFullPath1 := aProjeto1[nI, 1] + aProjeto1[nI, 2]
	cFullPath2 := aProjeto2[nI, 1] + aProjeto2[nI, 2] 
	
	If cFullPath1 > cFullPath2
		aSize(aProjeto1, Len(aProjeto1) + 1)
		aIns(aProjeto1, nI)
		aProjeto1[nI] := {"","","","","","",""}
	Elseif cFullPath2 > cFullPath1
		aSize(aProjeto2, Len(aProjeto2) + 1)
		aIns(aProjeto2, nI)
		aProjeto2[nI] := {"","","","","","",""}
	EndIf

	nI++	
	nMaxSize := Max(Len(aProjeto1), Len(aProjeto2))
		
EndDo

For nI := 1 To Max(Len(aProjeto1), Len(aProjeto2))
	aAdd(aFusao, {aProjeto1[nI], aProjeto2[nI]})
Next nI

Return aFusao
