#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Fun??o:
FeConvenio

Autor:
Desconhecido.

Revisado Por:
Tiago Bandeira Brasiliano

Data da Revis?o:
09/10/2017

Descri??o:
Fun??o respons?vel pelo c?lculo do valor de Conv?nio do Pedido (Desonera??o de ICMS).
Para isto, ele utiliza a tabela customziada SZ9, que cont?m os valores de conv?nio para os
Produtos x Clientes.
Inicialmente esta rotina efetuava apenas a alimenta??o do campo C5__PERC (Percentual de Conv?nio).
Por?m em 10/2017 foram inseridos novos campos (tbb) nos itens do pedido (C6_XPERCON e C6_XVALCON)
que tamb?m passaram a ser alimentados pela rotina.
Para n?o prejudicar nenhum fonte legado, a alimenta??o do campo C5__PERC foi mantida.

Uso:
Chamado pela valida??o do campo: C6_PRODUTO
Alimenta o campo: C5__PERC e C6_XPERCON.

Par?metros:
cCliente  => C?digo do Cliente.
cLoja     => Loja do Cliente.
cProduto  => C?digo do Produto

Retorno:
nConvenio => Valor de Conv?nio para o Produto x Cliente
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