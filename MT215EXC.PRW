#include "totvs.ch"


/**************************************************************************************************
Função:
MT215EXC

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descrição:
Ponto de Entrada Executado após a rotina de Refaz Saldo Acumulado (Caminho: 
SIGAEST > Miscelaneas > Acertos > Refaz Saldo Acumulado)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT215EXC()

//+-----------------------------------------------------+
//| Efetua gravação de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.