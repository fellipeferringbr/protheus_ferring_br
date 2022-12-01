/*******************
MEST001
Browse das Regras para Alocação de Lotes Automático
Marcelo Klopfer Leme - Farinelli Sistemas 
13/09/2016
*******************/
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

USER FUNCTION MEST001()
PRIVATE cCadastro := "Regras de Alocação de Lotes Automáticos"
PRIVATE cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
PRIVATE aRotina := {{"Pesquisar     ","AxPesqui"    ,0,1},;
                   {"Visualizar     ","U_MEST002(4)",0,2},;
                   {"Incluir        ","U_MEST002(1)",0,3},;
                   {"Alterar        ","U_MEST002(2)",0,4},;
                   {"Incluir. Prod. ","U_MEST004(1)",0,5},;
                   {"Excluir. Prod. ","U_MEST004(2)",0,5},;
                   {"Regra Padrão   ","U_MEST005()" ,0,5},;
                   {"Excluir        ","U_MEST002(3)",0,5},;
                   {"Relatório      ","U_REST002()" ,0,5}}

DBSELECTAREA("SZA")
DBSETORDER(1)
MBROWSE( 6,1,22,75,"SZA")

RETURN()
