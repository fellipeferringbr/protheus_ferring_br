#Include "Protheus.ch"


/**************************************************************************************************
Função:
MA020ROT

Autor:
Leandro Silva

Descrição:
Ponto de Entrada responsável por incluir novas opções no browse de Cadastro de Fornecedores.

**************************************************************************************************/
User Function MA020ROT()

Local aRotUser := {}

aAdd(aRotUser, { 'Libera Fornecedor'  , 'U_M020Desbl("SA2", SA2->(recno()), 4)', 0, 4 } )
aAdd(aRotUser, { 'Bloqueia Fornecedor', 'U_M020Bloq("SA2", SA2->(recno()), 4)' , 0, 4 } )

Return aRotUser