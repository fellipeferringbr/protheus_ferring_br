#include "totvs.ch"


/**************************************************************************************************
Fun??o:
AF030GRV

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descri??o:
Ponto de Entrada Executado ap?s as grava??es da rotina de baixa de ativo fixo (Caminho: 
SIGAATF > Atualiza??es > Movimentos > Baixas > Baixar)

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AF030GRV()

//+-----------------------------------------------------+
//| Efetua grava??o de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.