#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
FeConvenio

Autor:
Desconhecido.

Revisado Por:
Tiago Bandeira Brasiliano

Data da Revisão:
09/10/2017

Descrição:
Função responsável pelo cálculo do valor de Convênio do Pedido (Desoneração de ICMS).
Para isto, ele utiliza a tabela customziada SZ9, que contém os valores de convênio para os
Produtos x Clientes.
Inicialmente esta rotina efetuava apenas a alimentação do campo C5__PERC (Percentual de Convênio).
Porém em 10/2017 foram inseridos novos campos (tbb) nos itens do pedido (C6_XPERCON e C6_XVALCON)
que também passaram a ser alimentados pela rotina.
Para não prejudicar nenhum fonte legado, a alimentação do campo C5__PERC foi mantida.

Uso:
Chamado pela validação do campo: C6_PRODUTO
Alimenta o campo: C5__PERC e C6_XPERCON.

Parâmetros:
cCliente  => Código do Cliente.
cLoja     => Loja do Cliente.
cProduto  => Código do Produto

Retorno:
nConvenio => Valor de Convênio para o Produto x Cliente
**************************************************************************************************/
User Function FeConvenio(cCliente, cLoja, cProduto)

Local aAreaSZ9  := SZ9->(GetArea())
Local nConvenio := 0

DbSelectArea("SZ9")
SZ9->(DbSetOrder(1)) // Z9_FILIAL + Z9_CLIENTE + Z9_LOJA + Z9_PROD1                                                                                                                           

If SZ9->(MsSeek(xFilial("SZ9") + cCliente + cLoja + cProduto))

	nConvenio := SZ9->Z9_CONVENI //Valor do convenio cadastrado na tabela customizada

EndIf

RestArea(aAreaSZ9)
    
Return nConvenio