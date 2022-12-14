#include "totvs.ch"
#include "fwmvcdef.ch"


/**************************************************************************************************
Classe:
ArqTrabalho

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Efetua a cria??o do arquivo de trabalho contendo as informa??es do header.
**************************************************************************************************/
CLASS ArqTrabalho

	DATA cAlias
	DATA aFields
	DATA aIndex
	DATA aOrder
	DATA cArqTmp

	METHOD New() CONSTRUCTOR
	METHOD AddField(cCampo, cTitulo, cDescricao, cTipo, nTamanho, nDecimal, cPicture, bValid, bWhen, aCombo, lObrigat, bInit, lBrowse)
	METHOD GetField(cCampo)
	METHOD AddIndex(aParCampos)
	METHOD CreateTrab()
	METHOD LoadIndex()
	METHOD GetIndex(nIndice)
	METHOD LoadTable(cAlias, lParSingleReg)
	METHOD LoadSX3Fields(cParAlias)
	METHOD CloseFile()
	METHOD TrbToStruct(nTipoStruct, cDescricao)
	METHOD TrbToHeader()
	METHOD TrbToColumns()
	METHOD TrbToCols()
	METHOD GetAlias()
	METHOD SetFieldOrder(cCampo, nOrdem)
	METHOD ReArrangeOrder()
	
ENDCLASS


/**************************************************************************************************
M?todo:
New

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Construtor da classe
**************************************************************************************************/
METHOD New() CLASS ArqTrabalho

Self:cAlias  := "TRB" + SubStr(GetNextAlias(), 4)
Self:aFields := {}
Self:aIndex  := {}
Self:aOrder  := {}
Self:cArqTmp := ""

Return Self


/**************************************************************************************************
M?todo:
AddField

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Adiciona campos ao arquivo de trabalho
**************************************************************************************************/
METHOD AddField(cCampo, cTitulo, cDescricao, cTipo, nTamanho, nDecimal, cPicture, bValid, bWhen, aCombo, lObrigat, bInit, lBrowse, cF3) CLASS ArqTrabalho

Default lBrowse := .T.

aAdd(Self:aFields, CampoDeArquivo():New(cCampo, cTitulo, cDescricao, cTipo, nTamanho, nDecimal, cPicture, bValid, bWhen, aCombo, lObrigat, bInit, lBrowse, cF3))
	
Return .T.


/**************************************************************************************************
M?todo:
GetField

Autor:
Tiago Bandeira Brasiliano

Data:
27/06/2014

Descri??o:
Retorna um dos campos do arquivo de trabalho
**************************************************************************************************/
METHOD GetField(cCampo, nPosCampo) CLASS ArqTrabalho

Local oCampoRet := Nil

nPosCampo := 0

If (nPosCampo := aScan(Self:aFields, {|x| AllTrim(x:cCampo) == AllTrim(cCampo)})) > 0
	oCampoRet := Self:aFields[nPosCampo]
EndIf

Return oCampoRet 


/**************************************************************************************************
M?todo:
AddIndex

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Par?metros:
xParCampos => Aceita uma string com o array no formato: "XX_CAMPO1+XX_CAMPO2+XX_CAMPO3"
              ou um array no formato: {"XX_CAMPO1", "XX_CAMPO2", "XX_CAMPO3"}
lValCampos => Valida se todos os campos que est?o sendo adicionados ao indice fazem parte dos
              campos j? adicionados. Valor default: .T.
              Este valor pode definido como false quando o ind?ce est? sendo definido antes
              da atribui??o dos campos. 

Descri??o:
Adiciona indice ao arquivo de trabalho
**************************************************************************************************/
METHOD AddIndex(xParCampos, lValCampos) CLASS ArqTrabalho

Local aCampos    := {}
Local nI         := 0
Local aParCampos := Iif(ValType(xParCampos) == "A", xParCampos, StrToKArr(xParCampos, "+"))

Default lValCampos := .T.
	
// Verifica se todos os campos do array est?o presentes no arquivo de trabalho
// Caso n?o esteja, remove o campos do indice (para que n?o ocorra nenhum erro
// na cria??o do arquivo de trabalho.
For nI := 1 To Len(aParCampos)
	If !lValCampos .Or. aScan(Self:aFields, {|x| AllTrim(Upper(x:cCampo)) == AllTrim(Upper(aParCampos[nI]))}) > 0
		aAdd(aCampos, aParCampos[nI])
	EndIf
Next nI

aAdd(Self:aIndex, aCampos)
	
Return .T.


/**************************************************************************************************
M?todo:
CreateTrab

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Cria o arquivo de trabalho.
**************************************************************************************************/
METHOD CreateTrab() CLASS ArqTrabalho

Local aStruct := {}

aEval(Self:aFields, {|x| aAdd(aStruct, {x:cCampo,;
	                                    x:cTipo,;
	                                    x:nTamanho,;
	                                    x:nDecimal,;
	                                    x:cTitulo})})

//+-----------------------------------------+
//| Crio o arquivo temporario               |
//+-----------------------------------------+
//Self:cArqTmp := CriaTrab(aStruct, .T.)
//dbUseArea(.T.,, Self:cArqTmp, Self:cAlias, .T., .F.)
	
Self:cArqTmp	:=	CriaTrab(NIL,.F.)
MsCreate(Self:cArqTmp,aCampos,"TOPCONN")
dbUseArea(.T.,'TOPCONN',cArqTmp,Self:cAlias,.T.,.F.)



Return .T.


/**************************************************************************************************
M?todo:
LoadIndex

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Carrega os indices atribu?dos para o arquivo de trabalho.
**************************************************************************************************/
METHOD LoadIndex() CLASS ArqTrabalho

Local nI     := 0
Local cIndex := ""

If Len(Self:aIndex) > 0

	For nI := 1 To Len(Self:aIndex)
		
		cIndex := U_ArrToStr(Self:aIndex[nI], "+")
		
		// Cria indice para o arquivo de trabalho
		IndRegua(Self:cAlias, Self:cArqTmp + AllTrim(Str(nI)), cIndex,,,"Indexando Registros...")
	
	Next nI
	
	// Seleciona o primeiro indice
	(Self:cAlias)->(dbClearIndex())
	(Self:cAlias)->(dbSetIndex(Self:cArqTmp + "1" + OrdBagExt()))
	
EndIf

//+-----------------------------------------+
//| Visualizo o arquivo temporario          |
//+-----------------------------------------+
(Self:cAlias)->(dbSetorder(1))
(Self:cAlias)->(dbGoTop())
		
Return .T.


/**************************************************************************************************
M?todo:
GetIndex

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Retorna uma string contendo os campos do indice especificado em nIndice
**************************************************************************************************/
METHOD GetIndex(nIndice) CLASS ArqTrabalho

Local cIndice := ""

If Len(Self:aIndex) >= nIndice
	cIndice := U_ArrToStr(Self:aIndex[1], "+")
EndIf
		
Return cIndice


/**************************************************************************************************
M?todo:
LoadTable

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Carrega os dados de uma tabela tempor?ria para um arquivo de trabalho.
**************************************************************************************************/
METHOD LoadTable(cParAlias, lParSingleReg, lShowRegua) CLASS ArqTrabalho

Local lContinua := .T.
Local nI        := 0
Local nTotReg   := 0
Local aAreaAtu  := (cParAlias)->(GetArea())

Default lParSingleReg := .F.
Default lShowRegua    := .F.

Self:LoadSX3Fields(cParAlias)

Self:ReArrangeOrder() // Reordena os campos antes da cria??o da tabela.

Self:CreateTrab()

//+--------------------------------------------+
//| Tranfiro a query para o temporario. Desta  |
//| forma consigo utiliz?-lo em uma MsSelect.  |
//+--------------------------------------------+

If lParSingleReg .And. !(cParAlias)->(Eof()) // Efetua a carga de um ?nico registro
	
	RecLock(Self:cAlias, .T.)
	For nI := 1 To (Self:cAlias)->(FCount())
		cCampo := (Self:cAlias)->(FieldName(nI))
		If (cParAlias)->(FieldPos(cCampo)) > 0
			(Self:cAlias)->&(cCampo) := (cParAlias)->&(cCampo)
		EndIf
	Next nI
	(Self:cAlias)->(msUnlock())

Else // Efetua a carga de todo o arquivo tempor?rio para um arquivo de trabalho
	
	dbSelectArea(cParAlias)
	Count To nTotReg
	
	If lShowRegua
		ProcRegua(nTotReg)
	EndIf
	
	(cParAlias)->(dbGoTop())
	
	While !(cParAlias)->(Eof())
		
		RecLock(Self:cAlias, .T.)
		
		For nI := 1 To (Self:cAlias)->(FCount())
		
			cCampo := (Self:cAlias)->(FieldName(nI))
			
			If (cParAlias)->(FieldPos(cCampo)) > 0
				(Self:cAlias)->&(cCampo) := (cParAlias)->&(cCampo)
			EndIf
			
		Next nI
		
		(Self:cAlias)->(msUnlock())
		
		(cParAlias)->(dbSkip())
		
		If lShowRegua
			IncProc()
		EndIf
		
	EndDo
	
EndIf

Self:LoadIndex()

RestArea(aAreaAtu)
	
Return .T.


/**************************************************************************************************
M?todo:
LoadSX3Fields

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Carrega as informa??es do dicion?rio (SX3).
Isto ser? feito no caso do arquivo tempor?rio que ir? alimentar o arquivo de trabalho possua 
campos que estejam no dicion?rio.
**************************************************************************************************/
METHOD LoadSX3Fields(cParAlias) CLASS ArqTrabalho

Local nI       := 0
//Local aAreaSX3 := SX3->(GetArea())

For nI := 1 To (cParAlias)->(FCount())

	cCampo := (cParAlias)->(FieldName(nI))

	//+-------------------------------------------------------------+
	//| Gero o arquivo de trabaho a partida da query tempor?ria.    |
	//+-------------------------------------------------------------+
    /*
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) // CAMPO
	If SX3->(dbSeek(cCampo))
	
		Self:AddField(AllTrim(X3_CAMPO),; 
		              X3_TITULO,;
		              X3_DESCRIC,;
		              X3_TIPO,;
		              X3_TAMANHO,;
		              X3_DECIMAL,;
		              X3_PICTURE,;
		              Iif(Empty(X3_VALID), Nil, &("{|| " + X3_VALID + "}")),;  // TODO: Inserir a valida??o do usu?rio
		              Iif(Empty(X3_WHEN), Nil, &("{|| " + X3_WHEN + "}")),;
		              Iif(Empty(X3_CBOX), Nil, StrToKArr(X3_CBOX, ";")),;
		              X3Obrigat(X3_CAMPO),;
		              Iif(Empty(X3_RELACAO), Nil, &("{|| " + X3_RELACAO + "}")))
	EndIf
*/

Self:AddField(AllTrim(GetSX3Cache(cCampo,"X3_CAMPO")),; 
		            GetSX3Cache(cCampo,"X3_TITULO")  ,;
		            GetSX3Cache(cCampo,"X3_DESCRIC")  ,;
		             GetSX3Cache(cCampo,"X3_TIPO") ,;
		             GetSX3Cache(cCampo,"X3_TAMANHO") ,;
		             GetSX3Cache(cCampo,"X3_DECIMAL") ,;
		             GetSX3Cache(cCampo,"X3_PICTURE") ,;
		              Iif(Empty(GetSX3Cache(cCampo,"X3_VALID")), Nil, &("{|| " +GetSX3Cache(cCampo,"X3_VALID")  + "}")),;  // TODO: Inserir a valida??o do usu?rio
		              Iif(Empty(GetSX3Cache(cCampo,"X3_WHEN")), Nil, &("{|| " + GetSX3Cache(cCampo,"X3_WHEN")  + "}")),;
		              Iif(Empty(X3Cbox() ), Nil, StrToKArr(X3Cbox() , ";")),;
		              X3Obrigat(cCampo),;
		              Iif(Empty(GetSX3Cache(cCampo,"X3_RELACAO")), Nil, &("{|| " + GetSX3Cache(cCampo,"X3_RELACAO")  + "}")))


Next nI

//RestArea(aAreaSX3)

Return .T.


/**************************************************************************************************
M?todo:
CloseFile

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Fecha o arquivo de trabaho e excluir os arquivos do disco.
**************************************************************************************************/
METHOD CloseFile() CLASS ArqTrabalho
local nI
If Select(Self:cAlias) > 0
	(Self:cAlias)->(dbCloseArea())
EndIf

If !Empty(Self:cArqTmp)

	FErase(Self:cArqTmp + GetDBExtension())
	
	For nI := 1 To Len(Self:aIndex)
		FErase(Self:cArqTmp + AllTrim(Str(nI)) + OrdBagExt())
	Next nI

EndIf

Return .T.


/**************************************************************************************************
M?todo:
TrbToStruct

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Retorna as informa??es da classe para a estrutura que ser? utilizada pelo MVC.
**************************************************************************************************/
METHOD TrbToStruct(nTipoStruct, cDescricao) CLASS ArqTrabalho

Local oStruct     := FWFormStruct(nTipoStruct, Self:cAlias)
Local aUnico      := Iif(Empty(Self:aIndex), {}, Self:aIndex[1]) // Considera o primeiro indico como PK 
Local nI          := 0
Local cOrdemCampo := ""
Local aHelpCampo  := {}
Local cTipoCampo  := ""

DEFAULT cDescricao	:= ""

If nTipoStruct == 1 // Estrutura Para o ModelDef
	
	// Adiciona a tabela a Estrutura
	oStruct:AddTable(Self:cAlias, aUnico , cDescricao)
	
	// Adiciona os ?ndices
	For nI := 1 To Len(Self:aIndex)
		
		oStruct:AddIndex(nI,;                                // Index Order
		                 AllTrim(Str(nI)),;                  // Index Id
		                 U_ArrToStr(Self:aIndex[nI], "+"),;  // Chave
		                 U_ArrToStr(Self:aIndex[nI], "+"),;
		                 "",;
		                 "",;
		                 .T.)   // Descri??o
	
	Next nI
	
	// Adiciona os campos
	For nI := 1 To Len(Self:aFields)
		oStruct:AddField(Self:aFields[nI]:cTitulo,;
		                 Self:aFields[nI]:cDescricao,;
		                 Self:aFields[nI]:cCampo,;
		                 Self:aFields[nI]:cTipo,;
		                 Self:aFields[nI]:nTamanho,;
		                 Self:aFields[nI]:nDecimal,;
		                 FwBuildFeature( STRUCT_FEATURE_VALID, Self:aFields[nI]:bValid ),;
		                 FwBuildFeature( STRUCT_FEATURE_WHEN, Self:aFields[nI]:bWhen ),;
		                 Self:aFields[nI]:aCombo,;
		                 Self:aFields[nI]:lObrigat,; 
		                 FwBuildFeature( STRUCT_FEATURE_INIPAD, Self:aFields[nI]:bInit ))
	Next nI
	
Else // Estrutura para o ViewDef
	
	// Adiciona os campos
	For nI := 1 To Len(Self:aFields)
		
		cOrdemCampo := StrZero(nI, 2)
		aHelpCampo  := {}
		cTipoCampo  := Iif(!Empty(Self:aFields[nI]:aCombo), "COMBO", Iif(Self:aFields[nI]:cTipo == "L", "CHECK", "GET"))
		
		oStruct:AddField(Self:aFields[nI]:cCampo,;
		                 cOrdemCampo,;
		                 Self:aFields[nI]:cTitulo,;
		                 Self:aFields[nI]:cDescricao,;
		                 aHelpCampo,;
		                 cTipoCampo,;
		                 Self:aFields[nI]:cPicture,;
		                 Nil,; // bPictVar (Bloco da Picture)
		                 Self:aFields[nI]:cF3,; // cLookUp (Consuta F3)
		                 ,;    // lCanChange (Indica se ? edit?vel)
		                 ,;    // cFolder (Pasta do Campo)
		                 ,;    // cGroup (Agrugapmento do Campo)
		                 Self:aFields[nI]:aCombo)
		                 
	Next nI

EndIf

Return oStruct


/**************************************************************************************************
M?todo:
TrbToHeader

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Retorna as informa??es dos campos do arquivo de trabalho j? no formato para ser utilizado no 
aHeader de uma MsNewGetDados.
**************************************************************************************************/
METHOD TrbToHeader() CLASS ArqTrabalho

Local aHeader := {}

aEval(Self:aFields, {|x| aAdd(aHeader, {x:cTitulo,;
                                        x:cCampo,;
                                        x:cPicture,;
                                        x:nTamanho,;
                                        x:nDecimal,;
                                        x:bValid,;
                                        ,;  // Usado
                                        x:cTipo,;
                                        ,; // F3
                                        ,; // Context
                                        U_ArrToStr(x:aCombo, ";"),;
                                        x:bInit,;
                                        x:bWhen})})

Return aHeader


/**************************************************************************************************
M?todo:
TrbToFields

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Retorna as informa??es dos campos do arquivo de trabalho j? no formato para ser utilizado nas 
colunas de uma FwMBrowse.
**************************************************************************************************/
METHOD TrbToColumns() CLASS ArqTrabalho

Local aColumns := {}
Local lBrowse  := .F.
Local nI       := 0
//Local aAreaSX3 := SX3->(GetArea())

//dbSelectArea("SX3")
//SX3->(dbSetOrder(2)) // CAMPO 

For nI := 1 To Len(Self:aFields)

	lBrowse := .F.
	//If Self:aFields[nI]:lBrowse .Or. (SX3->( dbSeek( AllTrim( Self:aFields[nI]:cCampo ) ) ) .And. SX3->X3_BROWSE <> "N")
    If Self:aFields[nI]:lBrowse .Or. (!empty(AllTrim(GetSX3Cache( AllTrim( Self:aFields[nI]:cCampo ),"X3_TITULO"))).And. AllTrim(GetSX3Cache(AllTrim( Self:aFields[nI]:cCampo ),"X3_BROWSE")) <> "N")
		lBrowse := .T.
	EndIf
	
	If lBrowse
		aAdd(aColumns, { Self:aFields[nI]:cTitulo,;
                         &("{|| " + Self:cAlias + "->" + Self:aFields[nI]:cCampo + "}"),;
                         Self:aFields[nI]:cTipo,;
                         Self:aFields[nI]:cPicture,;
                         ,;
                         Self:aFields[nI]:nTamanho,;
                         Self:aFields[nI]:nDecimal,;
                         ,; // Permite edi??o
                         Self:aFields[nI]:bValid})
	EndIf
	
Next nI

//RestArea(aAreaSX3)

Return aColumns


/**************************************************************************************************
M?todo:
TrbToCols

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Retorna as informa??es dos campos do arquivo de trabalho j? no formato para ser utilizado aCols
de uma GetDados.
**************************************************************************************************/
METHOD TrbToCols() CLASS ArqTrabalho
local nI
Local aCols     := {}
Local aAreaTrb  := {}

If Select(Self:cAlias) > 0
	
	aAreaTrb := (Self:cAlias)->(GetArea())
	dbSelectArea(Self:cAlias)
	(Self:cAlias)->(dbGoTop())
	
	While !(Self:cAlias)->(Eof())
		
		aLinha := {}
		
		For nI := 1 To (Self:cAlias)->(FCount())
			aAdd(aLinha, (Self:cAlias)->&(FieldName(nI)))
		Next nI
		aAdd(aLinha, .F.) // Flag de delete
		
		aAdd(aCols, aLinha)
	
		(Self:cAlias)->(dbSkip())
	EndDo
	
	RestArea(aAreaTrb)
	
EndIf

Return aCols


/**************************************************************************************************
M?todo:
GetAlias

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Retorna o Alias do arquivo de trabalho.
**************************************************************************************************/
METHOD GetAlias() CLASS ArqTrabalho
Return Self:cAlias


/**************************************************************************************************
M?todo:
SetFieldOrder

Autor:
Tiago Bandeira Brasiliano

Data:
21/03/2017

Descri??o:
Define uma nova ordem para um campo do arquivo de trabalho.
Esta fun??o ? util por exemplo quando se precisa alterar a ordem dos campos para apresenta??o no
browse.

Par?metros:
cCampo  -> Nome do campo que ter? a ordem alterada (nada ser? feito caso o campo ainda n?o exista).
nOrdem  -> Nova ordem do campo dentro da lista de campos

Retorno:
Nenhum
**************************************************************************************************/
METHOD SetFieldOrder(cCampo, nOrdem) CLASS ArqTrabalho

aAdd(Self:aOrder, {cCampo, nOrdem})

Return .T.


/**************************************************************************************************
M?todo:
ReArrangeOrder

Autor:
Tiago Bandeira Brasiliano

Data:
21/03/2017

Descri??o:
Fun??o auxilizar para reordena??o da posi??o dos campos dentro do array de campos.

Par?metros:
Nenhum.

Retorno:
Nenhum
**************************************************************************************************/
METHOD ReArrangeOrder() CLASS ArqTrabalho

Local nI      := 0
Local nPosAtu := 0
Local oCampo  := Nil
Local cCampo  := ""
Local nOrdem  := 0

For nI := 1 To Len(Self:aOrder)
	
	cCampo := Self:aOrder[nI, 1]
	nOrdem := Self:aOrder[nI, 2]
		
	oCampo := Self:GetField(cCampo, @nPosAtu) // Verifica se o nome do campo existe

	If oCampo <> Nil
				
		//+--------------------------------------------------------------+
		//| Verifica se a ordem informada ? maior do que o tamanho total |
		//| do array. Se for, define como ordem o tamanho do array.      |
		//+--------------------------------------------------------------+
		nOrdem := Min(nOrdem, Len(Self:aFields))
		
		//+--------------------------------------------------------------+
		//| Deleta o campo em sua posi??o atual.                         |
		//+--------------------------------------------------------------+
		aDel(Self:aFields, nPosAtu)
		
		//+--------------------------------------------------------------+
		//| Insere o campo em sua nova posi??o.                          |
		//+--------------------------------------------------------------+
		aIns(Self:aFields, nOrdem)
		Self:aFields[nOrdem] := oCampo
		
	EndIf
	
Next nI

Return .T.


/**************************************************************************************************
Classe:
CampoDeArquivo

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Obejto contendo informa??es de um campo.
**************************************************************************************************/
CLASS CampoDeArquivo

	DATA cCampo
	DATA cTitulo
	DATA cDescricao
	DATA cTipo
	DATA nTamanho
	DATA nDecimal
	DATA cPicture
	DATA bValid
	DATA bWhen
	DATA aCombo
	DATA lObrigat
	DATA bInit
	DATA lBrowse
	DATA cF3

	METHOD New() CONSTRUCTOR

ENDCLASS


/**************************************************************************************************
M?todo:
New

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Construtor da classe
**************************************************************************************************/
METHOD New(cCampo, cTitulo, cDescricao, cTipo, nTamanho, nDecimal, cPicture, bValid, bWhen, aCombo, lObrigat, bInit, lBrowse, cF3) CLASS CampoDeArquivo

Default cF3     := ""

Self:cCampo     := cCampo
Self:cTitulo    := cTitulo
Self:cDescricao := cDescricao
Self:cTipo      := cTipo
Self:nTamanho   := nTamanho
Self:nDecimal   := nDecimal
Self:cPicture   := cPicture
Self:bValid     := bValid
Self:bWhen      := bWhen
Self:aCombo     := aCombo
Self:lObrigat   := lObrigat
Self:bInit      := bInit
Self:lBrowse    := lBrowse
Self:cF3        := cF3

Return Self


/**************************************************************************************************
Fun??o:
ArrToStr

Autor:
Tiago Bandeira Brasiliano

Data:
09/08/2013

Descri??o:
Converte um array de textos em uma ?nica vari?vel de texto.
Exemplo: 
Local aTeste := {"XXX_FILIAL", "XXX_COD", "XXX_DESCRIC"}
Local cTeste := ArrToStr(aTeste, "+")

Conte?do de cTeste: ""XXX_FILIAL+XXX_COD+XXX_DESCRIC""

Par?metros:
aArray     -> Array contendo as informa??es que ser?o convertidas em uma ?nica vari?vel de texto.
cStringSep -> String de Separa??o.

Retorno
cRetorno   -> Vari?vel de texto contendo os campos do array.
**************************************************************************************************/
User Function ArrToStr(aArray, cStringSep)

Local cRetorno := ""

If !Empty(aArray)
	aEval(aArray, {|x| cRetorno += Iif(Empty(x), "", x + cStringSep) } )
	cRetorno := Iif( !Empty(cRetorno) .And. Right(cRetorno, 1) == cStringSep, Left(cRetorno, Len(cRetorno) - 1), cRetorno)
EndIf
	
Return cRetorno
