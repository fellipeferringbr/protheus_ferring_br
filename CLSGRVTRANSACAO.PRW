#include "totvs.ch"
#include "msobject.ch"

#define  ALIAS "PA0"

/**************************************************************************************************
Função:
ClsGrvTransacao

Descrição:
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

Descrição:
Classe responsável por efetuar a gravação dos campos na tabela de integração via webservice.
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
Método:
New

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descrição:
Construtor da Classe.

Parâmetros:
cParAlias => Define o alias padrão da classe, definindo desta forma se será gerada uma transação de
             entrada de dados no Protheus, ou uma transação de saída de dados do Protheus. Os valores
             validos para o parâmetro são:
             PA0 - Tabela de Entrada de dados no Protheus.
             PA1 - Tabela de Saída de dados do Protheus para outro sistema.

Retorno:
Self   => Instância do objeto criado.
**************************************************************************************************/
Method New(cParAlias) Class ClsGrvTransacao

Default cParAlias := ALIAS

::aDados  := {}
::cAlias  := cParAlias
	
Return Self


/**************************************************************************************************
Método:
AddReg

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descrição:
Inclui um novo registro para gravação na tabela de trasanções.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Method AddReg(cCampo, cValor) Class ClsGrvTransacao

Aadd(::aDados, {})

Return .T.


/**************************************************************************************************
Método:
AddCampo

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descrição:
Inclui um campo para gravação.

Parâmetros:
cCampo  => Nome do campo.
cValor  => Valor do campo.
nIndice => Indice do registro onde os campos estão sendo adicionados (default = último registro).

Retorno:
Nenhum
**************************************************************************************************/
Method AddCampo(cCampo, cValor, nIndice) Class ClsGrvTransacao

Default nIndice := Len(::aDados)

Aadd(::aDados[nIndice], {cCampo, cValor})

Return .T.


/**************************************************************************************************
Método:
Gravar

Autor:
Tiago Bandeira Brasiliano

Data:
26/08/2015

Descrição:
Grava um novo registro na tabela de integração a partir dos campos adicionados a classe.

Parâmetros:
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