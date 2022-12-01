#include "totvs.ch"


/**************************************************************************************************
Função:
AF010INC

Autor:
Tiago Bandeira Brasiliano

Data:
21/10/2014

Descrição:
Ponto de Entrada Executado após as gravações da rotina de inclusão de Ativos (Caminho: 
SIGAATF > Atualizações > Cadastros > Ativos > Incluir)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AF010INC()

//+-----------------------------------------------------+
//| Efetua gravação de auditoria customizada da Ferring |
//+-----------------------------------------------------+
U_GrLog(ProcName(), cModulo, __cUserID, dDatabase, Time(), cEmpAnt, cFilAnt)

Return .T.