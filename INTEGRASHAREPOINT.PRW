#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
IntegraSharepoint

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Execucao da Gravacao via ExecAuto dos registros gravados na Tabela de Entrada da Integracao 
via Web Service. 

Parâmetros:
cTransacao => Número da Transação
cProcesso  => Código do Processo
aDadosOut  => Retorna (via referência) um array de 3 dimensões (X, Y e Z) com os dados de retorno 
              do webservice, onde:
              Vetor X = Cada elemento deste vetor representa um registro de retorno (como se 
                        fossem as linhas de uma consulta SQL). Ex: Uma consulta a um cadastro
                        de clientes retornaria um único elemento neste vetor.
              Vetor Y = Cada elemento deste vetor representa os campos dentro do registro (como
                        as colunas de uma consulta SQL).
              Vetor Z = Cada elemento deste vetor representa uma propriedade do campo, podendo ser:
                        aDadosOut[X,Y,1] = cRegistro  => Número do Registro a qual o campo pertence
                        aDadosOut[X,Y,1] = cSequencia => Sequência do campo dentro do registro
                        aDadosOut[X,Y,1] = cTpCpo     => Tipo de Campo: C=Caracter;N=Numérico,etc
                        aDadosOut[X,Y,1] = cNomeCpo   => Nome do Campo. Ex: A1_COD, C5_NUM, etc
                        aDadosOut[X,Y,1] = cValor     => Valor do campo (em caracter)

cMensagem  => Retorna a mensagem do processamento do ws (caso exista). Deverá ser passada como 
              referência.

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou não (.F.)
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

Default aParametros := {.F., "01", "01", "000000"}    // 1=Rot. Aut. ; 2=Empresa ; 3=Filial ; 4 = Cod. Usuários

lSPAuto := aParametros[1]

//+--------------------------------------------------------+
//| Prepara o ambiente quando for executado via Job        |
//+--------------------------------------------------------+
If lSPAuto
//	RPCSetType(3)
	RpcSetEnv("01", "01", Nil, Nil, "FAT", Nil, {"SA1", "SA2", "SA3", "SB1", "SB8", "SBM", "SC5", "SC6", "SE4", "DA0", "DA1", "ACP"})
EndIf

If !lSPAuto
	lContinua := MsgYesNo("Esta rotina irá efetuar o processamento de TODAS as integrações pendentes. Deseja prosseguir?", "Atenção")
EndIf

//+--------------------------------------------------------+
//| Efetua a integração de todos os itens não integados.   |
//+--------------------------------------------------------+
If lContinua
	
	If lSPAuto
		oIntegracao:ProcessaLote()
	Else	
		Processa({|| oIntegracao:ProcessaLote()}, "Aguarde", "Processando registros ainda não integrados")
	EndIf
	
EndIf

//+--------------------------------------------------------+
//| Fecha o ambiente                                       |
//+--------------------------------------------------------+
If lSPAuto
	RpcClearEnv()
EndIf
	
Return .T.