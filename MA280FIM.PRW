#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MA280FIM

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descri??o:
Ponto de Entrada Executado ap?s a rotina de Virada dos Saldos (Caminho: 
SIGAEST > Miscelaneas > Fechamento > Virada dos Saldos)

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MA280FIM()

//+-----------------------------------------------------+
//| Efetua grava??o de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.