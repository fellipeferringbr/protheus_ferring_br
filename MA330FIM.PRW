#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MA330FIM

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descri??o:
Ponto de Entrada Executado ap?s a rotina de Recalculo de Custo M?dio (Caminho: 
SIGAEST > Miscelaneas > Recalculo > Custo M?dio)

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MA330FIM()

//+-----------------------------------------------------+
//| Efetua grava??o de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.