#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Fun??o:
IntegraSharepoint

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Execucao da Gravacao via ExecAuto dos registros gravados na Tabela de Entrada da Integracao 
via Web Service. 

Par?metros:
cTransacao => N?mero da Transa??o
cProcesso  => C?digo do Processo
aDadosOut  => Retorna (via refer?ncia) um array de 3 dimens?es (X, Y e Z) com os dados de retorno 
              do webservice, onde:
              Vetor X = Cada elemento deste vetor representa um registro de retorno (como se 
                        fossem as linhas de uma consulta SQL). Ex: Uma consulta a um cadastro
                        de clientes retornaria um ?nico elemento neste vetor.
              Vetor Y = Cada elemento deste vetor representa os campos dentro do registro (como
                        as colunas de uma consulta SQL).
              Vetor Z = Cada elemento deste vetor representa uma propriedade do campo, podendo ser:
                        aDadosOut[X,Y,1] = cRegistro  => N?mero do Registro a qual o campo pertence
                        aDadosOut[X,Y,1] = cSequencia => Sequ?ncia do campo dentro do registro
                        aDadosOut[X,Y,1] = cTpCpo     => Tipo de Campo: C=Caracter;N=Num?rico,etc
                        aDadosOut[X,Y,1] = cNomeCpo   => Nome do Campo. Ex: A1_COD, C5_NUM, etc
                        aDadosOut[X,Y,1] = cValor     => Valor do campo (em caracter)

cMensagem  => Retorna a mensagem do processamento do ws (caso exista). Dever? ser passada como 
              refer?ncia.

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou n?o (.F.)
**************************************************************************************************/
User Function IntegraSharepoint(aParametros)

Local cTransacao  := ""
Local cProcesso   := ""
Local aDadosOut   := {}
Local cMensagem   := ""
Local cAliasTmp   := GetNextAlias()
Local oIntegracao := ClsIntegracao():New()
Local lContinua   := .T.
	
Private lSPAuto   := .F.

Default aParametros := {.F., "01", "01", "000000"}    // 1=Rot. Aut. ; 2=Empresa ; 3=Filial ; 4 = Cod. Usu?rios

lSPAuto := aParametros[1]

//+--------------------------------------------------------+
//| Prepara o ambiente quando for executado via Job        |
//+--------------------------------------------------------+
If lSPAuto
//	RPCSetType(3)
	RpcSetEnv("01", "01", Nil, Nil, "FAT", Nil, {"SA1", "SA2", "SA3", "SB1", "SB8", "SBM", "SC5", "SC6", "SE4", "DA0", "DA1", "ACP"})
EndIf

If !lSPAuto
	lContinua := MsgYesNo("Esta rotina ir? efetuar o processamento de TODAS as integra??es pendentes. Deseja prosseguir?", "Aten??o")
EndIf

//+--------------------------------------------------------+
//| Efetua a integra??o de todos os itens n?o integados.   |
//+--------------------------------------------------------+
If lContinua
	
	If lSPAuto
		oIntegracao:ProcessaLote()
	Else	
		Processa({|| oIntegracao:ProcessaLote()}, "Aguarde", "Processando registros ainda n?o integrados")
	EndIf
	
EndIf

//+--------------------------------------------------------+
//| Fecha o ambiente                                       |
//+--------------------------------------------------------+
If lSPAuto
	RpcClearEnv()
EndIf
	
Return .T.