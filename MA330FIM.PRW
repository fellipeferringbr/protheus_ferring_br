#include "totvs.ch"


/**************************************************************************************************
Função:
MA330FIM

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descrição:
Ponto de Entrada Executado após a rotina de Recalculo de Custo Médio (Caminho: 
SIGAEST > Miscelaneas > Recalculo > Custo Médio)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MA330FIM()

//+-----------------------------------------------------+
//| Efetua gravação de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.