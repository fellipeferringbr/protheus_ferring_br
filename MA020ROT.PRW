#Include "Protheus.ch"


/**************************************************************************************************
Fun??o:
MA020ROT

Autor:
Leandro Silva

Descri??o:
Ponto de Entrada respons?vel por incluir novas op??es no browse de Cadastro de Fornecedores.

**************************************************************************************************/
User Function MA020ROT()

Local aRotUser := {}

aAdd(aRotUser, { 'Libera Fornecedor'  , 'U_M020Desbl("SA2", SA2->(recno()), 4)', 0, 4 } )
aAdd(aRotUser, { 'Bloqueia Fornecedor', 'U_M020Bloq("SA2", SA2->(recno()), 4)' , 0, 4 } )

Return aRotUser