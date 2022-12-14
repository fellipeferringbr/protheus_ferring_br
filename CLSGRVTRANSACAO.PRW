#include "totvs.ch"
#include "msobject.ch"

#define  ALIAS "PA0"

/**************************************************************************************************
Fun??o:
ClsGrvTransacao

Descri??o:
Dummy function.
**************************************************************************************************/
User Function ClsGrvTransacao()
Return .T.


/**************************************************************************************************
Classe:
ClsGrvTransacao

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descri??o:
Classe respons?vel por efetuar a grava??o dos campos na tabela de integra??o via webservice.
**************************************************************************************************/
Class ClsGrvTransacao

Data aDados
Data cAlias

Method New(cParAlias)
Method AddReg()
Method AddCampo(cCampo, cValor)
Method Gravar()
	
EndClass


/**************************************************************************************************
M?todo:
New

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descri??o:
Construtor da Classe.

Par?metros:
cParAlias => Define o alias padr?o da classe, definindo desta forma se ser? gerada uma transa??o de
             entrada de dados no Protheus, ou uma transa??o de sa?da de dados do Protheus. Os valores
             validos para o par?metro s?o:
             PA0 - Tabela de Entrada de dados no Protheus.
             PA1 - Tabela de Sa?da de dados do Protheus para outro sistema.

Retorno:
Self   => Inst?ncia do objeto criado.
**************************************************************************************************/
Method New(cParAlias) Class ClsGrvTransacao

Default cParAlias := ALIAS

::aDados  := {}
::cAlias  := cParAlias
	
Return Self


/**************************************************************************************************
M?todo:
AddReg

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descri??o:
Inclui um novo registro para grava??o na tabela de trasan??es.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Method AddReg(cCampo, cValor) Class ClsGrvTransacao

Aadd(::aDados, {})

Return .T.


/**************************************************************************************************
M?todo:
AddCampo

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descri??o:
Inclui um campo para grava??o.

Par?metros:
cCampo  => Nome do campo.
cValor  => Valor do campo.
nIndice => Indice do registro onde os campos est?o sendo adicionados (default = ?ltimo registro).

Retorno:
Nenhum
**************************************************************************************************/
Method AddCampo(cCampo, cValor, nIndice) Class ClsGrvTransacao

Default nIndice := Len(::aDados)

Aadd(::aDados[nIndice], {cCampo, cValor})

Return .T.


/**************************************************************************************************
M?todo:
Gravar

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descri??o:
Grava um novo registro na tabela de integra??o a partir dos campos adicionados a classe.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Method Gravar() Class ClsGrvTransacao

Local nI  := 0
Local nJ  := 0

DbSelectArea(::cAlias)
(::cAlias)->(DbSetOrder(1))	// XXX_FILIAL, XXX_PROC, XXX_TRANS, XXX_REG, XXX_SEQ

For nI := 1 To Len(::aDados)

	RecLock(::cAlias, .T.)
	
	For nJ := 1 to Len(::aDados[nI])
		Replace &(::cAlias + "->" + ::aDados[nI, nJ, 01]) With ::aDados[nI, nJ, 02]
	Next nI
	
	MsUnLock()
	
Next nI

Return .T.