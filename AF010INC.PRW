#include "totvs.ch"


/**************************************************************************************************
Fun??o:
AF010INC

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descri??o:
Ponto de Entrada Executado ap?s as grava??es da rotina de inclus?o de Ativos (Caminho: 
SIGAATF > Atualiza??es > Cadastros > Ativos > Incluir)

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AF010INC()

//+-----------------------------------------------------+
//| Efetua grava??o de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.