#include "totvs.ch"


/**************************************************************************************************
Fun??o:
AF010GRV

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descri??o:
Ponto de Entrada Executado ap?s as grava??es da rotina de altera??o de Ativos (Caminho: 
SIGAATF > Atualiza??es > Cadastros > Ativos > Alterar)

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AF010GRV()

//+-----------------------------------------------------+
//| Efetua grava??o de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.