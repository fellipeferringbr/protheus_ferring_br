#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MT215EXC

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descri??o:
Ponto de Entrada Executado ap?s a rotina de Refaz Saldo Acumulado (Caminho: 
SIGAEST > Miscelaneas > Acertos > Refaz Saldo Acumulado)

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT215EXC()

//+-----------------------------------------------------+
//| Efetua grava??o de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.