#include "totvs.ch"


/**************************************************************************************************
Função:
MA280FIM

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descrição:
Ponto de Entrada Executado após a rotina de Virada dos Saldos (Caminho: 
SIGAEST > Miscelaneas > Fechamento > Virada dos Saldos)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MA280FIM()

//+-----------------------------------------------------+
//| Efetua gravação de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.