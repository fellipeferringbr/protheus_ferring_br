#include "totvs.ch"


/**************************************************************************************************
Função:
FeCopyFile

Autor:
Tiago Bandeira Brasiliano

Data:
10/01/2009

Descrição:
Efetua a copia de um arquivo entre o servidor e o Cliente, e vice-versa.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FeCopyFile()
Local cTipoArq 	:= "Todos os Arquivos (*.*)     | *.* |"
Local cArqOrig  := ""
Local cArqDest  := ""
Local cPathDest := ""
Local lContinua := .T.

//+-------------------------------------------------+
//| Abre a janela para seleção do arquivo de origem |
//+-------------------------------------------------+
While lContinua
	cArqOrig := cGetFile(cTipoArq,"Selecione o arquivo que será copiado",0,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)
	cArqDest := SubStr(cArqOrig,RAT("\",cArqOrig) + 1,Len(cArqOrig))
	
	If !Empty(cArqDest)
		If SubStr(cArqOrig,2,1) == ":"
			//+------------------------------------------------+
			//| Abre a janela para seleção da pasta de destino |
			//+------------------------------------------------+
			cPathDest := cGetFile(cTipoArq,"Selecione a pasta de destino",0,,.F., GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
			If !Empty(cPathDest)
				cPathDest := SubStr(cPathDest,1,RAT("\",cPathDest))
				Processa({|| CpyT2S(cArqOrig, cPathDest, .F.)}, "Aguarde", "Copiando arquivo" + cArqOrig + "...")
			EndIf
		Else
			//+------------------------------------------------+
			//| Abre a janela para seleção da pasta de destino |
			//+------------------------------------------------+
			cPathDest := cGetFile(cTipoArq,"Selecione a pasta de destino",0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
			If !Empty(cPathDest)
				cPathDest := SubStr(cPathDest,1,RAT("\",cPathDest))
				Processa({|| CpyS2T(cArqOrig, cPathDest, .F.)}, "Aguarde", "Copiando arquivo " + cArqOrig + "...")
			EndIf
		EndIf
	Else
		lContinua := .F.
	EndIf
EndDo
	
Return .T.