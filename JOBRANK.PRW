#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
JOBRANK

Autor:
Tiago Bandeira Brasiliano em 06/04/2017

Data:
18/05/2018

Descrição:
Rotina responsável pela geração automática da planinha de Ranking de Vendas e disponibilização 
do mesmo para a Ferring México.
A mesma deve ser executada via job uma vez por dia (horário inicial definido: 19h00).
Inicialmente esta função havia sido desenvolvida para efetuar a geração deste arquivo e a cópia
diretamente para um FTP, porém isto foi modificado por questões técnicas.
Atualmente a rotina gera o arquivo de Ranking, uma vez por dia, diretamente em uma pasta do 
Protheus_Data (definida pelo parâmetro ES_DIRRANK. Default: FTPRANKING).
Após a cópia para esta pasta, existe um Job no banco de dados do México (Servidor: FEMX0004\FEMX0004,
Job: CopiaArquivo_BR) que verifica qual o último arquivo dentro desta pasta de "ENVIADOS" e efetua 
a cópia para o diretório \\FEMX0004\E\FTP\EXTERNOS\SSIS\ (diretório local do México).

Parâmetros:
aParâmetros => Parâmetros que serão passado pelo Schedule informando os dados para preparação
               do ambiente (opcional).
               
Retorno:
Nenhum.
**************************************************************************************************/
User Function JOBRANK(aParametros)

Local cDir       := ""
Local cDirEnv    := ""

Default aParametros :=  {"01", "01", "000000"}    // 1=Empresa ; 2=Filial ; 3=Cod. Usuários 

//+---------------------------------------------+
//| Prepara o ambiente para uso                 |
//+---------------------------------------------+
RPCSetType(3)
RpcSetEnv(aParametros[1], aParametros[2], Nil, Nil, "FAT", Nil, {"SA1", "SA2", "SC5", "SC6", "SF2", "SD2", "SF1", "SD1"})

//+---------------------------------------------+
//| Definição dos diretórios da rotina.         |
//+---------------------------------------------+
cDir       := GetNewPar("ES_DIRRANK", "\FTPRANKING\")
cDirEnv    := cDir + "ENVIADOS\"

//+---------------------------------------------+
//| Cria diretórios da rotina.                  |
//+---------------------------------------------+
MakeDir(cDir)
MakeDir(cDirEnv)

ConOut("JOB-RANKING: Iniciando JOB do Ranking de Vendas")

//+---------------------------------------------------------------+
//| Cria o arquivo do ranking  de vendas no diretório do servidor |
//+---------------------------------------------------------------+
//U_RankingNovo(.T., cDirEnv, .F.)
U_FeRank(.T., cDirEnv, .F.)
ConOut("JOB-RANKING: Finalizado JOB do Ranking de Vendas")

//+---------------------------------------------+
//| Fecha o ambiente do Protheus.               |
//+---------------------------------------------+
RpcClearEnv()

Return .T.