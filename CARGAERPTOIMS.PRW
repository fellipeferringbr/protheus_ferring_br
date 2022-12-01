#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"

#DEFINE P_CLIENTE  1
#DEFINE P_PRODUTO  2
#DEFINE P_CONDPAG  3
#DEFINE P_TIPPEDI  4
#DEFINE P_SITPEDI  5
#DEFINE P_PRCPROD  6
#DEFINE P_ESPNOTA  7
#DEFINE P_CONDCOM  8
#DEFINE P_DESCOND  9
#DEFINE P_ESTOQUE  10
#DEFINE P_CONDCLI  11
#DEFINE P_CARTCLI  12

#DEFINE P_NOME_ARQ 1
#DEFINE P_ARQ_PROC 2
#DEFINE P_ENVIO_OK 3
#DEFINE P_CODI_ARQ 4
#DEFINE P_FUNCTION 5
#DEFINE P_TOT_PROC 6
#DEFINE P_DESC_ARQ 7


/**************************************************************************************************
Função:
CargaERPtoIMS

Autor:
Juscelino Alves dos Santos (revisado por Tiago Bandeira Brasiliano)

Data:
19/08/2014

Descrição:
Rotina responsável por carregar os dados de integração que serão enviados do Protheus para o IMS
e também por salvar estas informações (arquivos de texto) nos diretórios do FTP que serão lidos
pelo sistema IMS.

Fluxo:

+------------------------------------+
| Schedule do Protheus executa o JOB | 
| da rotina IMSARQC a cada X horas   |
+------------------------------------+
|
V
+------------------------------------+
|    Função IMSARQC lê as tabelas    |
|    do Protheus buscando dados      |
|    que precisam ser integrados     |
+------------------------------------+
|
V
+------------------------------------+
|  São gerados os arquivos de texto  |
|  contendo estes dados.             |
+------------------------------------+
|
V
+------------------------------------+
|    Arquivos são salvos no FTP      |
|    de integração.                  |
+------------------------------------+
|
V
+------------------------------------+
| IMS lê o FTP de integração e grava |
| os dados em seu banco de dados.    |
+------------------------------------+

Parâmetros:
lIMSAuto => Indica se a rotina está sendo executada via Job ou chamada pelo menu (para que ela
faça a abertura da empresa e omissão das exibições em tela caso necessário).

Retorno:
Nenhum
**************************************************************************************************/
User Function CargaERPtoIMS(aParametros)

	Local cCodProc  := ""
	Local lIMSHab   := .F.
	Local nY        := 0
	Local lErrCarga := .F.
	Private nHdl       := 0
	Private aCargas    := {}
	//Private cPastaFerr := GetMV("ES_DIMSENV") //Integracao_IMS/Enviados/"    // Pasta no diretório do Protheus onde os arquivos serão salvos     
	//Private cPstErrEnv := GetMV("ES_DIMSERR") //Integracao_IMS/ErroEnvio/"    // Pasta no diretório do Protheus onde os arquivos serão salvos     
	Private lIMSAuto   := .F.

	Default aParametros := {.F., "01", "01", "000000"}    // 1=Rot. Aut. ; 2=Empresa ; 3=Filial ; 4 = Cod. Usuários

	lIMSAuto  := aParametros[1]

	// Prepara o ambiente quando foi executado via Job
	If lIMSAuto
		RPCSetType(3)
		RpcSetEnv(aParametros[2], aParametros[3], Nil, Nil, "FAT", Nil, {"SA1", "SA2", "SA3", "SB1", "SB8", "SBM", "SC5", "SC6", "SE4", "DA0", "DA1", "ACP"})
	EndIf
	
	cPastaFerr := GetMV("ES_DIMSENV") //Integracao_IMS/Enviados/"    // Pasta no diretório do Protheus onde os arquivos serão salvos     
	cPstErrEnv := GetMV("ES_DIMSERR") //Integracao_IMS/ErroEnvio/"    // Pasta no diretório do Protheus onde os arquivos serão salvos     

	lIMSHab  := GetNewPar("ES_IMSHAB", .F.)
	cCodProc := Upper(GetMv("ES_IMSARQ",,"CPTFVRNMOABD"))      // Opções de processamento dos Arquivos

	If !lIMSHab
		//Conout("Carga de arquivo desabilitada (Parâmetro ES_IMSHAB)")
		Return .F.	
	EndIf

	//+---------------------------------------------------------------------------+
	//| Criação do array aCargas. Este array possui informações dos arquivos      |
	//| que serão integrados no sistema IMS. Ele possui o seguinte formato:       |
	//+---------------------------------------------------------------------------+
	//| aCargas[nX, 1] => Nome do Arquivo gerado no FTP.                          |
	//| aCargas[nX, 2] => Indica se o arquivo poi processado ou não.              |
	//| aCargas[nX, 3] => Indica se o arquivo foi enviado com sucesso para o FTP. |
	//| aCargas[nX, 4] => Código do tipo de arquivo dentro o parâmetro ES_IMSARQ. |
	//| aCargas[nX, 5] => Função chamada para processar o arquivo.                |
	//| aCargas[nX, 6] => Total de Registros processados.                         |
	//| aCargas[nX, 7] => Descrição do arquivo.                                   |
	//+---------------------------------------------------------------------------+
	AAdd(aCargas, {"Carga_Clientes.txt"                     , .F., .F., "C", {|| CrgCliente()}, 0, "Clientes"                         })
	AAdd(aCargas, {"Carga_Produtos.txt"                     , .F., .F., "P", {|| CrgProduto()}, 0, "Produtos"                         })
	AAdd(aCargas, {"Condicao_Pagamento.txt"                 , .F., .F., "F", {|| CrgCondPag()}, 0, "Condição de Pagamentos"           })
	AAdd(aCargas, {"Carga_Tipo_Pedido_Venda.txt"            , .F., .F., "T", {|| CrgTipPedi()}, 0, "Tipos de Pedido de Venda"         })
	AAdd(aCargas, {"Carga_Situação_Pedido_Venda.txt"        , .F., .F., "V", {|| CrgSitPedi()}, 0, "Status de Pedidos de Venda"       })
	AAdd(aCargas, {"Carga_Precos_produtos.txt"              , .F., .F., "R", {|| CrgPrcProd()}, 0, "Aliquotas de Preços de Produto"   })
	AAdd(aCargas, {"Carga_Espelho_Nota_Fiscal.txt"          , .F., .F., "N", {|| CrgEspNota()}, 0, "Notas Fiscais"                    })
	AAdd(aCargas, {"Carga_Condicoes_Comerciais.txt"         , .F., .F., "M", {|| CrgCondCom()}, 0, "Condições Comerciais"             })
	AAdd(aCargas, {"Carga_Desconto_Condicoes_Comerciais.txt", .F., .F., "O", {|| CrgDesCond()}, 0, "Condições Comerciais de Descontos"})   
	AAdd(aCargas, {"Carga_Estoque_Armazem.txt"              , .F., .F., "A", {|| CrgEstoque()}, 0, "Estoque Armazem"                  })
	AAdd(aCargas, {"Condicao_Pagamento_Cliente.txt"         , .F., .F., "B", {|| CrgCondCli()}, 0, "Condição de Pagamento por Cliente"})
	AAdd(aCargas, {"Carga_Carteira_Clientes.txt"            , .F., .F., "D", {|| CrgCartCli()}, 0, "Carteira de Clientes"             })

	//+--------------------------------------------------------+
	//| Executa as funções de criação dos arquivos             |
	//+--------------------------------------------------------+
	For nY := 1 To Len (aCargas)

		If aCargas[nY, P_CODI_ARQ] $ cCodProc

			Eval(aCargas[nY, P_FUNCTION])

		EndIf

	Next nY

	//+---------------------------------------------------------------------------------+
	// Roberto - ERP Plus 04/02 - Efetua notificação por email do erro corrido
	// Efetua a carga dos arquivos gerados para o FTP     
	//| Incluida mensagem de workflow para avisar os usuários responsáveis sobre o      |
	//| problema na estrutura do arquivo      
	// | Efetua a chamada da função u_GdGrvZZD para gravação do log referente ao erro 
	// | da estrutura do arquivo
	//+---------------------------------------------------------------------------------+
	//if ! CargaFTP()
	//	lErrCarga := .T.
	//Endif

	CargaFTP()


	//+--------------------------------------------------------+
	//| Envia o e-mail (caso configurado) para os responsáveis |
	//| Sucesso na carga									   |
	//+--------------------------------------------------------+
	SendMailIMS(.T.) //.F.)

	//+--------------------------------------------------------+
	//| Envia o e-mail (caso configurado) para os responsáveis |
	//| Erro na carga								   |
	//+--------------------------------------------------------+
	//If lErrCarga = .T.
	//SendMailIMS(.T.)
	//Endif	

	//+--------------------------------------------------------+
	//| Fecha o ambiente                                       |
	//+--------------------------------------------------------+
	If lIMSAuto
		RpcClearEnv()
	EndIf

Return .T.


/**************************************************************************************************
Função:
CrgCliente

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados dos clientes para integração (Carga_Clientes.txt)

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgCliente()

	Local cArqTxt   := cPastaFerr + aCargas[P_CLIENTE, P_NOME_ARQ]
	Local cAliasTmp := GetNextAlias()
	Local cLinha    := ""
	Local cVlAux    := ""
	Local dDataFixa := StoD("20151231")

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Clientes....")

	aCargas[P_CLIENTE, P_TOT_PROC] := 0

	//+--------------------------------+
	//| Busca os dados para integração |
	//+--------------------------------+
	BEGINSQL ALIAS cAliasTmp

		%noParser%

		SELECT *
		FROM
		%Table:SA1% SA1
		WHERE
		A1_FILIAL = %xFilial:SA1%
		AND SA1.%notDel%
		AND A1_XIMS = 'S'
		ORDER BY
		A1_COD

	ENDSQL

	(cAliasTmp)->(DbGoTop())  

	If !(cAliasTmp)->(EoF())

		aCargas[P_CLIENTE, P_ARQ_PROC] := .T. 

		// Cabeçalho do Arquivo
		cLinha += "H"        
		cLinha += "CLIENTES"
		cLinha += " " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
		cLinha += "0003"  
		cLinha += CRLF
		FGravaTxt(cLinha)

		// Leitura de Grupos
		While !(cAliasTmp)->(EoF())

			// Registro de Corpo
			cLinha := ""
			cLinha += "C"                                                                            // Tipo de Registro
			cLinha += PadL((cAliasTmp)->A1_COD + (cAliasTmp)->A1_LOJA, 020)                          // Codigo do Cliente
			cLinha += PadL(AllTrim((cAliasTmp)->A1_NOME)	         , 080)                          // Descrição do Cliente
			cLinha += PadL((cAliasTmp)->A1_TABELA                    , 020)                          // CD_TP_CLIENTE (Ficou definido em reunião do dia 22/07/15 que este campo traria a informação do código da tabela de cliente)
			cLinha += Right((cAliasTmp)->A1_SATIV1                   , 002)                          // ( ? - Fazer DePara com a Tabela do Site) Ramo de Atividade   SX5==>TABELA T3 ==> TAMNHO DO CODIGO 6 CARAC HOJE ESTA ATE 000099
			cLinha += (cAliasTmp)->A1_PESSOA                                                         // Tipo de Pessoa
			cLinha += Iif(Empty((cAliasTmp)->A1_XICRED), "S", (cAliasTmp)->A1_XICRED)                // ( ? - Não Identifiquei ) Credito  (S/N)
			cLinha += PadR(AllTrim((cAliasTmp)->A1_TEL)              , 020)                          // Telefone ( ? - Inclui DDD)
			cLinha += PadR((cAliasTmp)->A1_TELEX                     , 020)                          // Telefone Alternativo( ? - Inclui DDD)
			cLinha += PadR((cAliasTmp)->A1_FAX                       , 020)                          // FAX ( ? - Inclui DDD)
			cLinha += PadR((cAliasTmp)->A1_HPAGE                     , 100)                          // Home Page
			cLinha += PadR((cAliasTmp)->A1_EMAIL                     , 100)                          // E-Mail
			cLinha += Replicate("0"                                  , 005)                          // Ramal  
			cLinha += Replicate("0", 3 - Len((cAliasTmp)->A1_DDD)) + (cAliasTmp)->A1_DDD             // DDD      
			cLinha += Replicate("0"                                  , 003)                          // DDD Alternativo
			cLinha += PadR((cAliasTmp)->A1_CGC                       , 015)                          // CGC do Cliente
			cLinha += PadR(AllTrim((cAliasTmp)->A1_INSCR)            , 015)                          // Inscrição Estadual
			cLinha += PadR(AllTrim((cAliasTmp)->A1_INSCRM)           , 015)                          // Inscrição Municipal
			cLinha += Space(30)                                                                      // ( ? - Não Identifiquei ) NR_EAN_LOCAL
			cLinha += Iif(Empty((cAliasTmp)->A1_SUFRAMA), "N", "S")                                  // ( ? - Verificar se esta correto ) ID_ZONA_FRANCA
			cLinha += SubStr((cAliasTmp)->A1_RG, 1, 13)                                              // RG
			cLinha += Space(10)                                                                      // ( ? - Não Identifiquei ) ORGAO_EMISSOR_RG
			cLinha += Iif(!Empty((cAliasTmp)->A1_CGC) .And. Len(AllTrim((cAliasTmp)->A1_CGC)) < 14, (cAliasTmp)->A1_CGC + Space(1), Space(15))  // CPF
			cLinha += Iif((cAliasTmp)->A1_MSBLQL == "2", "S", "N")                                   //  Ativo ou Não      
			cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp)->A1_DESC, 5, 2)))
			cLinha += Replicate("0",5-Len(cVlAux)) + cVlAux                                          // percentual de Desconto para o Cliente
			cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp)->A1_LC, 18, 2)))
			cLinha += Replicate("0", 18 - Len(cVlAux)) + cVlAux                                      //  ( ? - Verificar se esta correto leva ponto decimal ou não)  Valor Limite de Credito para o Cliente
			cLinha += Replicate("0", 20)                                                             // ???? Space(20) ( ? - Não Identifiquei ) CD_DIVISAO_PRODUTO      Fixo(Branco)
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICFU) , "N"            ,(cAliasTmp)->A1_XILICFU)  // ( ? - Não Identifiquei ) IC_LICENCA_FUNCIONAMENTO  (S/N)  VERIFICAR COM O CLIENTE S TEM OU NÃO
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICCM) , "N"            ,(cAliasTmp)->A1_XILICCM)  // ( ? - Não Identifiquei ) IC_LICENCA_COMERCIALIZACAO   (S/N)
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICPSI), "N"            ,(cAliasTmp)->A1_XILICPSI) // ( ? - Não Identifiquei ) IC_LICENCA_PSICOTROPICO  (S/N)
			cLinha += Space(60)                                                                      // ( ? - Duvida de qual campo :A1__GR / A1_GRPVEN ) CD_GRUPO_CLIENTE
			cLinha += (cAliasTmp)->A1_XIDTVFU                                                        // Dt.Valid. Lic. Funcionamento - tbb - 01/10/2015 - Alterada a regra a pedido da Vivian. Quando não houver data envia em branco.
			cLinha += (cAliasTmp)->A1_XIDTVCM                                                        // Dt.Valid. Lic. Comercialização - tbb - 01/10/2015 - Alterada a regra a pedido da Vivian. Quando não houver data envia em branco.
			cLinha += (cAliasTmp)->A1_XIDTVPS                                                        // Dt.Valid. Lic. Psicotrópicos - tbb - 01/10/2015 - Alterada a regra a pedido da Vivian. Quando não houver data envia em branco.
			cLinha += Replicate("0",18)                                                              //  ??? Space(18) ( ? - Não Identifiquei ) Valor pedido minimo
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICCR) , "N"            ,(cAliasTmp)->A1_XILICCR)  // ( ? - Não Identifiquei ) IC_LICENCA_CRF   (S/N)      VERIFICAR COM O CLIENTE S TEM OU NÃO
			cLinha += Iif(Empty((cAliasTmp)->A1_XIDTVCR) , Space(8)       ,(cAliasTmp)->A1_XIDTVCR)  // ( ? - Não Identifiquei ) DT_LICENCA_CRF
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICAN) , "N"            ,(cAliasTmp)->A1_XILICAN)  // ( ? - Não Identifiquei ) IC_LICENCA_ANVISA  (S/N)
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICSI) , "N"            ,(cAliasTmp)->A1_XILICSI)  // ( ? - Não Identifiquei ) IC_LICENCA_SIVISA  (S/N)
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICCS) , "N"            ,(cAliasTmp)->A1_XILICCS)  // ( ? - Não Identifiquei ) IC_LICENCA_CONTRATO_SOCIAL  (S/N)
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICTR) , "N"            ,(cAliasTmp)->A1_XILICTR)  // ( ? - Não Identifiquei ) IC_LICENCA_TARE  (S/N)
			cLinha += Iif(Empty((cAliasTmp)->A1_XILICIC) , "N"            ,(cAliasTmp)->A1_XILICIC)  // ( ? - Não Identifiquei ) IC_LICENCA_ISENCAO_ICMS (S/N)
			cLinha += Iif(Empty((cAliasTmp)->A1_XIDTVAN) , Space(8)       ,(cAliasTmp)->A1_XIDTVAN)  // ( ? - Não Identifiquei ) DT_LICENCA_ANVISA
			cLinha += Iif(Empty((cAliasTmp)->A1_XIDTVSI) , Space(8)       ,(cAliasTmp)->A1_XIDTVSI)  // ( ? - Não Identifiquei ) DT_LICENCA_SIVISA
			cLinha += Iif(Empty((cAliasTmp)->A1_XIDTVCS) , Space(8)       ,(cAliasTmp)->A1_XIDTVCS)  // ( ? - Não Identifiquei ) DT_LICENCA_CONTRATO_SOCIAL
			cLinha += Iif(Empty((cAliasTmp)->A1_XIDTVTR) , Space(8)       ,(cAliasTmp)->A1_XIDTVTR)  // ( ? - Não Identifiquei ) DT_LICENCA_TARE
			cLinha += Iif(Empty((cAliasTmp)->A1_XIDTVIC) , Space(8)       ,(cAliasTmp)->A1_XIDTVIC)  // ( ? - Não Identifiquei ) DT_LICENCA_ISENCAO_ICMS
			cLinha += Iif(Empty((cAliasTmp)->A1_XIREPAS) , "N"            ,(cAliasTmp)->A1_XIREPAS)  // ( ? - Não Identifiquei ) IC_POSSUI_REPASSE (S/N)
			cLinha += CRLF
			FGravaTxt(cLinha) 

			// Registro Tipo < D > 
			cLinha := ""
			cLinha += "D"                                                                            // Tipo de Registro
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_CGC),1,20) , 020)                          // ( ? - Não Identifiquei ) CD_ENDERECO (CODIGO cLinhaTE)
			cLinha += Replicate("0",10)                                                              // ??? Space(10) ( ? - Não Identifiquei ) PRAZO_ENTREGA (FIXO 00)
			cLinha += "N"                                                                            // ( ? - Não Identifiquei ) DIA_UTIL (S/N)  (Fixo N)
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_MUN),1,60) , 060)                          // ( ? - Não Identifiquei ) CIDADE         DADOS CADASTRAIS DO CLIENTE
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_EST),1,02) , 002)                          // ( ? - Não Identifiquei ) CD_ESTADO  DADOS CADASTRAIS DO CLIENTE
			cLinha += "BR"                                                                           // ( ? - Não Identifiquei ) CD_PAIS    <FIXO BR >
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_END),1,100), 100)                          // ( ? - Não Identifiquei ) LOGRADOURO DADOS CADASTRAIS DO CLIENTE
			cLinha += Space(30)                                                                      // ( ? - Não Identifiquei ) COMPLEMENTO DADOS CADASTRAIS DO CLIENTE
			cLinha += Space(20)                                                                      // ( ? - Não Identifiquei ) NUMERO       DADOS CADASTRAIS DO CLIENTE
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_CEP),1,08) , 008)                          // ( ? - Não Identifiquei ) CEP DADOS CADASTRAIS DO CLIENTE
			cLinha += "S"                                                                            // ( ? - Não Identifiquei ) ATIVO (S/N) < Fixo S > 
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_IBGE),1,10), 010)                          // ( ? - Não Identifiquei ) CD_IBGE_CIDADE  DADOS CADASTRAIS DO CLIENTE
			cLinha += CRLF                               
			FGravaTxt(cLinha)                            

			// Registro Tipo < B >  NÃO PRECISA INFORMAR   
			cLinha := ""   
			cLinha += "B"                                                                            // Tipo de Registro
			cLinha += Space(20)                                                                      // ( ? - Não Identifiquei ) CD_BU
			cLinha += Space(30)                                                                      // ( ? - Não Identifiquei ) CD_SETOR
			cLinha += CRLF		
			FGravaTxt(cLinha)

			aCargas[P_CLIENTE, P_TOT_PROC]++

			(cAliasTmp)->(DbSkip())

		EndDo

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgProduto

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados dos produtos para integração (Carga_Produtos.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgProduto()

	Local cArqTxt   := cPastaFerr + aCargas[P_PRODUTO, P_NOME_ARQ]
	Local cAliasTmp := GetNextAlias() 
	Local cLinha    := ""
	Local cVlAux    := ""
	Local nQuant    := 0

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Produtos...") 

	aCargas[P_PRODUTO, P_TOT_PROC] := 0

	BEGINSQL ALIAS cAliasTmp

		%noParser%

		SELECT
		B1_FILIAL,
		B1_COD,
		B1_DESC,
		B1_MSBLQL,
		B1_XIORIG,
		B1_XILISTA,
		B1_XITPPRO,
		B1_XIPSI,
		B1_CODBAR,
		B1_XIFULLB,
		B1_SEGUM,
		B1_QE
		FROM
		%Table:SB1% SB1
		WHERE
		B1_FILIAL = %xFilial:SB1%
		AND SB1.%notDel%
		AND B1_XIMS = 'S'
		ORDER BY
		B1_COD

	ENDSQL

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(EoF())

		aCargas[P_PRODUTO, P_ARQ_PROC] := .T.

		// Cabeçalho do Arquivo
		cLinha += "H"        
		cLinha += "PRDGESTOR"
		cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
		cLinha += "0003"  
		cLinha += CRLF   
		FGravaTxt(cLinha)

		// Leitura dos Produtos
		While !(cAliasTmp)->(EoF())

			// Registro de Corpo
			cLinha := ""
			cLinha += "C"                                                                            // Tipo de Registro
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->B1_COD) , 1, 020), 020)                       // Codigo do Produto
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->B1_DESC), 1, 060), 060)                       // Descrição do Produto
			cLinha += "N"                                                                            // ( ? - Não Identifiquei ) IC_KIT  (S/N) (fixo N)
			cLinha += Iif(AllTrim((cAliasTmp)->B1_MSBLQL) == '1', "N", "S")                          // ( ? - Não Identifiquei ) IC_ATIVO  (S/N)(fixo S)
			cLinha += Iif(Empty((cAliasTmp)->B1_XIORIG)  , "N"        , (cAliasTmp)->B1_XIORIG)      // ( ? - Não Identifiquei ) IC_ORIGEM  (N/I) 
			cLinha += Replicate("0", 020)                                                            // ???? Space(20) ( ? - Não Identifiquei )  CD_DIVISAO_PRODUTO(fixo branco)
			cLinha += Iif(Empty((cAliasTmp)->B1_XILISTA) , "N"        , (cAliasTmp)->B1_XILISTA)     // ( ?????? - Não Identifiquei - N(Negativa) / P(Positiva) / O(Outros))  IC_TIPO_LISTA - < Tirar duvida com o cliente >
			cVlAux := Iif(Empty((cAliasTmp)->B1_XITPPRO), "nrefriger", (cAliasTmp)->B1_XITPPRO)
			cLinha += PadL(cVlAux, 020)                                                              // ( ? - Não Identifiquei )  TP_PRODUTO  (Refriger ou nrefriger)
			cLinha += Space(20)                                                                      // ( ? - Não Identifiquei )  CD_BU_PRODUTO    <Fixo bRANCO>
			cLinha += Iif(Empty((cAliasTmp)->B1_XIPSI)   ,"N"         ,(cAliasTmp)->B1_XIPSI)        // ( ? - Não Identifiquei )  IC_PSICOTROPICO (S/N)
			cLinha += Space(20)                                                                      // ( ? - Não Identifiquei )  CD_GRUPO_PRODUTO  Colocar Espaço Branco
			cLinha += Replicate("0", 008)                                                            // ??? Space(8) ( ? - Não Identifiquei )  VL_FATOR_PIS  Colocar Espaço Branco
			cLinha += Replicate("0", 008)                                                            // ??? Space(8) ( ? - Não Identifiquei )  VL_FATOR_COFINS  Colocar Espaço Branco
			cLinha += CRLF   
			FGravaTxt(cLinha)   

			cLinha := ""
			cLinha += "I"                                                                            // Tipo de Registro
			cVlAux := RemPontos((cAliasTmp)->B1_CODBAR)
			cLinha += PadR(AllTrim(cVlAux), 128)                                                     // Space(128)// ( ? - Não Identifiquei ) CD_ID_PRODUTO - Cod. Barra
			cLinha += Replicate("0", 009)+"1"                                                        // ??? Space(10) ( ? - Não Identifiquei ) QT_UNIDADES    - Fixo < 1 >
			cLinha += Iif(Empty((cAliasTmp)->B1_XIFULLB) , "S"         , (cAliasTmp)->B1_XIFULLB)    // ( ? - Não Identifiquei ) VALIDAR_FULLBOX  (S/N)   Fixo <S>
			nQuant := Iif(B1_SEGUM == "CX" .And. B1_QE <> 0, B1_QE, 1)
			cLinha += StrZero(nQuant, 010)                                                           // ?????  Space(10) ( ? - Não Identifiquei ) QT_UNIDADES_FULLBOX   - Qunatida de caixa fechada informado no cadastro
			cLinha += "S"                                                                            // ( ? - Não Identifiquei ) IC_ATIVO  (S/N)    < S >
			cLinha += CRLF   
			FGravaTxt(cLinha)

			//IMS (informou que os registros tipo ( K / L ) não precisa ser gerado
			//cLinha        := ""
			//cLinha		+= "K"                                                                   // Tipo de Registro
			//cLinha		+= Space(20)                                                             // ( ? - Não Identifiquei ) CD_PRODUTO_KIT
			//cLinha		+= Space(10)                                                             // ( ? - Não Identifiquei ) QT_PRODUTO_KIT
			//cLinha		+= "N"                                                                   // ( ? - Não Identifiquei ) IC_ATIVO  (S/N)
			//cLinha		+= CRLF   
			//FGravaTxt( cLinha )   

			//cLinha        := ""		
			//cLinha		+= "L"  // Não envia                                                     // Tipo de Registro
			//cLinha		+= Space(20)                                                             // ( ? - Não Identifiquei ) CD_CLASSIFICACAO
			//cLinha		+= Space(2)                                                              // ( ? - Não Identifiquei ) NR_NIVEL_CLASSIFICACAO
			//cLinha		+= CRLF   
			//FGravaTxt( cLinha )

			aCargas[P_PRODUTO,  P_TOT_PROC]++
			(cAliasTmp)->(DbSkip())

		EndDo

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgCondPag

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados dos produtos para integração (Condicao_Pagamento.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgCondPag()

	Local cArqTxt   := cPastaFerr + aCargas[P_CONDPAG, P_NOME_ARQ]
	Local cAliasTmp	:= GetNextAlias()
	Local cLinha    := ""

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return
	EndIf

	//Conout("Aguarde, Consultando Condicao_Pagamento...")

	aCargas[P_CONDPAG, P_TOT_PROC] := 0

	BEGINSQL ALIAS cAliasTmp

		%noParser%

		SELECT *
		FROM
		%Table:SE4% SE4
		WHERE
		E4_FILIAL = %xFilial:SE4%
		AND SE4.%notDel%
		AND E4_XIMS = 'S'
		ORDER BY
		E4_CODIGO
	ENDSQL

	(cAliasTmp)->(DbGoTop())           

	If !(cAliasTmp)->(EoF())

		aCargas[P_CONDPAG, P_ARQ_PROC] := .T.

		// Cabeçalho do Arquivo
		cLinha += "H"        
		cLinha += "CONDPAGGST"
		cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
		cLinha += "0003"  
		cLinha += CRLF   
		FGravaTxt(cLinha)

		// Leitura das Condições de Pagamentos   
		While !(cAliasTmp)->(EoF())  

			// Registro de Corpo
			cLinha := ""
			cLinha += "C"                                                     // Tipo de Registro    
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->E4_CODIGO),1,20), 020) // Codigo da Condição de Pagamento
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->E4_DESCRI),1,20), 020) // Descrição da Condição de Pagamento
			cLinha += Replicate("0", 020)                                     // Quant. de Dias da Condição de Pagamento
			cLinha += "N"  //Iif(At(",",(cAliasTmp)->E4_COND)>0,"S","N")      // Parcelado? (S/N) - 26/06/2015 - tbb - fixado em "N" a pedido do Leonardo da IMS.
			cLinha += CRLF   
			FGravaTxt(cLinha)

			aCargas[P_CONDPAG, P_TOT_PROC]++

			(cAliasTmp)->(DbSkip())

		EndDo

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgTipPedi

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados dos tipos de pedido para integração (Carga_Tipo_Pedido_Venda.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgTipPedi()

	Local cArqTxt   := cPastaFerr + aCargas[P_TIPPEDI, P_NOME_ARQ]
	Local cLinha    := ""
	Local nX        := 0
	Local aTiposPed := {}

	//+-----------------------------------------+
	//| Tabela de Tipos de Pedido de Venda      |
	//+-----------------------------------------+    
	AAdd(aTiposPed, {"01", "Venda Normal"                })
	AAdd(aTiposPed, {"02", "Bonificação"                 })
	AAdd(aTiposPed, {"03", "Licitação"                   }) // Solution
	AAdd(aTiposPed, {"04", "Material promocional/Amostra"})

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.")
		Return
	EndIf

	//Conout("Aguarde, Consultando Carga_Tipo_Pedido_Venda...")  

	aCargas[P_TIPPEDI, P_TOT_PROC] := 0
	aCargas[P_TIPPEDI, P_ARQ_PROC] := .T.

	// Cabeçalho do Arquivo
	cLinha := ""
	cLinha += "H"        
	cLinha += "TPPEDGST"  
	cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
	cLinha += "0003"  
	cLinha += CRLF   
	FGravaTxt(cLinha)

	// Leitura das Condições de Pagamentos   
	For nX := 1 To Len(aTiposPed)

		// Registro de Corpo
		cLinha := ""
		cLinha += "C"                                                                 // Tipo de Registro    
		cLinha += AllTrim(aTiposPed[nX,1])+Space(20-Len(AllTrim(aTiposPed[nX,1])))    // Codigo do Tipo de Pedido de Venda
		cLinha += AllTrim(aTiposPed[nX,2])+Space(60-Len(AllTrim(aTiposPed[nX,2])))    // Descrição do Tipo de Pedido de Venda
		cLinha += "S"                                                                 // Tipo de Pedido de Venda Ativo (S/N)
		cLinha += CRLF   
		FGravaTxt(cLinha)

		aCargas[P_TIPPEDI, P_TOT_PROC]++

	Next nX

	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgSitPedi

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados de situação dos pedidos para o IMS (Carga_Situação_Pedido_Venda.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgSitPedi()

	Local cArqTxt    := cPastaFerr + aCargas[P_SITPEDI, P_NOME_ARQ]
	Local cAliasTmp  := GetNextAlias()
	Local cAliasTmp2 := GetNextAlias()
	Local cLinha     := ""
	Local cVlAux     := ""
	Local aStatus    := Array(56)    // aStatus[x,1] = Código | aStatus[x,2] = Descrição P/ Pedido | aStatus[x,3] = Descrição P/ Item

	//+---------------------------------------------------------+
	//| TABELA DE CÓDIGO DE STATUS IMS:                         |
	//| a posição de cada elemento do array será correspondente |
	//| ao código do status (vários elementos serão nulos)      |
	//+---------------------------------------------------------+
	//| 02 - EM ABERTO  (STATUS VERDE DO PROTHEUS)              |
	//| 04 - CANCELADO  (EXCLUÍDO DO PROTHEUS)                  |
	//| 05 - FATURADO   (STATUS VERMELHO DO PROTHEUS)           |
	//| 06 - RECUSADO   (ELIMINADO POR RESIDUO NO PROTHEUS)     |
	//| 07 - PARCIALMENTE ATENDIDO                              |
	//| 08 - ATENDIDO COM RESTRICOES (*NAO USADO NO PROTHEUS)   |
	//| 55 - BLOQUEADO  (BLOQUEADO REGRA OU VERBA NO PROTHEUS)  |
	//| 56 - LIBERADO   (STATUS AMARELHO DO PROTHEUS)           |
	//+---------------------------------------------------------+ 
	aStatus[2]  := {"02", "Pedido Aberto"               , "Item Aberto"               }
	aStatus[4]  := {"04", "Pedido Excluído"             , "Item Excluído"             }
	aStatus[5]  := {"05", "Pedido Faturado"             , "Item Faturado"             }
	aStatus[6]  := {"06", "Pedido Eliminado Por Residuo", "Item Eliminado Por Residuo"}
	aStatus[7]  := {"07", "Pedido Parcialmente Atendido", "Item Parcialmente Atendido"}
	aStatus[55] := {"55", "Pedido Bloqueado"            , "Item Bloqueado"            }
	aStatus[56] := {"56", "Pedido Liberado"             , "Item Liberado"             }

	nHdl    := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Situação_Pedido_Venda...")

	aCargas[P_SITPEDI, P_TOT_PROC] := 0

	//+-------------------------------------------------------------------------------------+
	//| Faço a busca dos pedidos que estão com o campo C5_XIMS = "S", ou seja, que tem      |
	//| origem no sistema IMS. A busca considera também os itens excluídos, pois existe     |
	//| a possibilidade de que os pedidos sejam integrados, e após isto sejam excluídos     |
	//| no Protheus. Além disto, pode ser que eles sejam excluídos mais de uma vez. Por     |
	//| isto eu garanto que apenas o último pedido excluído é que será considerado.         |
	//|                                                                                     |
	//| Lógica:                                                                             |
	//|                                       |(S) OBTEM O REGISTRO DELETADO MAIS RECENTE   |
	//|              |(S) REGISTRO DELETADO? <                                              |
	//| PEDIDO IMS? <                         |(N) CONSIDERA ESTE REGISTRO (MESMO QUE       |
	//|              |                             EXISTAM OUTROS REGISTROS DO MESMO PEDIDO | 
	//|              |                             DELETADOS)                               | 
	//|              |(N) NÃO GRAVA NO ARQUIVO                                              |
	//+-------------------------------------------------------------------------------------+
	cQuery := " SELECT " + CRLF
	cQuery += "    C5_FILIAL, " + CRLF
	cQuery += "    C5_NUM, " + CRLF
	cQuery += "    C5_CLIENTE, " + CRLF
	cQuery += "    C5_LOJACLI, " + CRLF
	cQuery += "    C5_CLIENTE, " + CRLF
	cQuery += "    C5_LOJACLI, " + CRLF
	cQuery += "    C5_BLQ, " + CRLF
	cQuery += "    C5_NOTA, " + CRLF
	cQuery += "    C5_LIBEROK, " + CRLF
	cQuery += "    C5_PEDIMS, " + CRLF
	cQuery += "    D_E_L_E_T_ AS DELETADO, " + CRLF
	cQuery += "    CASE WHEN EXISTS (SELECT C6_FILIAL " + CRLF
	cQuery += "                      FROM " + RetSQLName("SC6") + " SC6 " + CRLF 
	cQuery += "                      WHERE C6_FILIAL = SC5_01.C5_FILIAL " + CRLF
	cQuery += "                        AND C6_NUM = SC5_01.C5_NUM " + CRLF
	cQuery += "                        AND C6_QTDENT > 0 " + CRLF
	cQuery += "                        AND SC6.D_E_L_E_T_ = '' " + CRLF
	cQuery += "                        AND SC5_01.D_E_L_E_T_ = '') THEN 'S' ELSE 'N' END AS EXISTE_FAT " + CRLF
	cQuery += " FROM " + RetSQLName("SC5") + " SC5_01 " + CRLF
	cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' " + CRLF
	cQuery += "   AND C5_XIMS = 'S' " + CRLF
	cQuery += "   AND C5_PEDIMS <> '' " + CRLF
	// OBTENHO O PEDIDO QUE NÃO ESTA DELETADO
	cQuery += "   AND (SC5_01.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        OR " + CRLF
	// OU OBTENHO O ÚLTIMO ITEM DELETADO
	cQuery += "        (SC5_01.D_E_L_E_T_ = '*' " + CRLF
	// GARANTO QUE NÃO EXISTE UM ITEM NÃO DELETADO
	cQuery += "         AND NOT EXISTS(SELECT C5_FILIAL, C5_NUM " + CRLF
	cQuery += "                        FROM SC5010 SC5_02 " + CRLF
	cQuery += "                        WHERE SC5_02.C5_FILIAL = SC5_01.C5_FILIAL " + CRLF
	cQuery += "                           AND SC5_02.C5_NUM = SC5_01.C5_NUM " + CRLF
	cQuery += "                           AND SC5_02.D_E_L_E_T_ = ' ') " + CRLF
	//GARANTO QUE CASO EXISTA MAIS DE UM ITEM, SOMENTE O ÚLTIMO SERÁ CONSIDERADO
	cQuery += "         AND NOT EXISTS(SELECT C5_FILIAL, C5_NUM " + CRLF
	cQuery += " 	 	 			   FROM SC5010 SC5_02 " + CRLF
	cQuery += " 	 				   WHERE SC5_02.C5_FILIAL = SC5_01.C5_FILIAL " + CRLF
	cQuery += " 	 				      AND SC5_02.C5_NUM = SC5_01.C5_NUM " + CRLF
	cQuery += " 	 				      AND SC5_02.R_E_C_N_O_ > SC5_01.R_E_C_N_O_))) " + CRLF
	cQuery += " ORDER BY C5_NUM "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias &cAliasTmp

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(EoF())

		aCargas[P_SITPEDI, P_ARQ_PROC] := .T. 

		// Cabeçalho do Arquivo
		cLinha += "H"
		cLinha += "SITPEDGST"
		cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
		cLinha += "0003"
		cLinha += CRLF
		FGravaTxt(cLinha)

		// Leitura dos Produtos
		While !(cAliasTmp)->(EoF())

			// Itens do Pedido			
			cQuery := " SELECT " + CRLF
			cQuery += "    C6_FILIAL, " + CRLF
			cQuery += "    C6_NUM, " + CRLF
			cQuery += "    C6_CLI, " + CRLF
			cQuery += "    C6_LOJA, " + CRLF
			cQuery += "    C6_ITEM, " + CRLF
			cQuery += "    C6_PRODUTO, " + CRLF
			cQuery += "    C6_BLQ, " + CRLF
			cQuery += "    C6_NOTA, " + CRLF
			cQuery += "    C6_QTDVEN, " + CRLF
			cQuery += "    C6_QTDENT, " + CRLF 
			cQuery += "    SC6_01.D_E_L_E_T_ AS DELETADO" + CRLF
			cQuery += " FROM " + RetSQLName("SC6") + " SC6_01 " + CRLF
			cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' " + CRLF
			cQuery += "   AND C6_NUM = '" + (cAliasTmp)->C5_NUM + "' " + CRLF
			cQuery += "   AND C6_CLI = '" + (cAliasTmp)->C5_CLIENTE + "' " + CRLF
			cQuery += "   AND C6_LOJA = '" + (cAliasTmp)->C5_LOJACLI + "' " + CRLF
			cQuery += "   AND (SC6_01.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "        OR " + CRLF 
			cQuery += "        (SC6_01.D_E_L_E_T_ = '*' " + CRLF
			// GARANTO QUE NÃO EXISTE UM ITEM NÃO DELETADO
			cQuery += "         AND NOT EXISTS(SELECT C6_FILIAL, C6_NUM " + CRLF 
			cQuery += "                        FROM SC6010 SC6_02 " + CRLF 
			cQuery += "                        WHERE SC6_02.C6_FILIAL = SC6_01.C6_FILIAL " + CRLF 
			cQuery += "                           AND SC6_02.C6_NUM = SC6_01.C6_NUM " + CRLF
			cQuery += "                           AND SC6_02.C6_ITEM = SC6_01.C6_ITEM " + CRLF 
			cQuery += "                           AND SC6_02.C6_PRODUTO = SC6_01.C6_PRODUTO " + CRLF
			cQuery += "                           AND SC6_02.D_E_L_E_T_ = ' ') " + CRLF
			// GARANTO QUE CASO EXISTA MAIS DE UM ITEM, SOMENTE O ÚLTIMO SERÁ CONSIDERADO                  
			cQuery += "         AND NOT EXISTS(SELECT C6_FILIAL, C6_NUM " + CRLF 
			cQuery += " 	 	 			   FROM SC6010 SC6_02 " + CRLF 
			cQuery += " 	 				   WHERE SC6_02.C6_FILIAL = SC6_01.C6_FILIAL " + CRLF 
			cQuery += " 	 				      AND SC6_02.C6_NUM = SC6_01.C6_NUM " + CRLF 
			cQuery += " 	 				      AND SC6_02.C6_ITEM = SC6_01.C6_ITEM " + CRLF 
			cQuery += " 	 				      AND SC6_02.C6_PRODUTO = SC6_01.C6_PRODUTO " + CRLF 
			cQuery += " 	 				      AND SC6_02.R_E_C_N_O_ > SC6_01.R_E_C_N_O_))) " + CRLF
			cQuery += " ORDER BY C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO "  

			cQuery := ChangeQuery(cQuery)
			TcQuery cQuery New Alias &cAliasTmp2

			(cAliasTmp2)->(DbGoTop())           

			If (cAliasTmp2)->(EoF())     
				(cAliasTmp2)->(DbCloseArea())   
				(cAliasTmp)->(DbSkip()) 
				Loop
			EndIf

			If !Empty((cAliasTmp)->DELETADO)				
				nStatus := 4 // Excluído 				
			ElseIf Empty((cAliasTmp)->C5_NOTA) .And. Empty((cAliasTmp)->C5_LIBEROK) .And. Empty((cAliasTmp)->C5_BLQ)			
				nStatus := 2 // Aberto (Status Verde no Protheus)				
			ElseIf (cAliasTmp)->C5_NOTA == Replicate("X", TamSX3("C5_NOTA")[1])			
				nStatus := 6 // Eliminado por Resíduo (Status Vermelho no Protheus)					
			ElseIf !Empty((cAliasTmp)->C5_NOTA) .Or. (cAliasTmp)->C5_LIBEROK == "E" .And. Empty((cAliasTmp)->C5_BLQ)			
				nStatus := 5 // Faturado (Status Vermelho no Protheus)				
			ElseIf !Empty((cAliasTmp)->C5_LIBEROK) .And. Empty((cAliasTmp)->C5_NOTA) .And. Empty((cAliasTmp)->C5_BLQ) .And. (cAliasTmp)->EXISTE_FAT == "S"			
				nStatus := 7 // Parcialmente atendido (Status Amarelho no Protheus)				
			ElseIf !Empty((cAliasTmp)->C5_LIBEROK) .And. Empty((cAliasTmp)->C5_NOTA) .And. Empty((cAliasTmp)->C5_BLQ) .And. (cAliasTmp)->EXISTE_FAT <> "S"			
				nStatus := 56 // Liberado (Status Amarelho no Protheus)				
			ElseIf (cAliasTmp)->C5_BLQ == '1' .Or. (cAliasTmp)->C5_BLQ == '2'			
				nStatus := 55 // Bloqueado por Regra ou Verba (Status Azul ou Laranja no Protheus)			
			EndIf

			// Registro de Corpo
			cLinha  := PadR("C"                   , 001)    // TP_REGISTRO (Tipo de Registro)
			cLinha  += PadR((cAliasTmp)->C5_PEDIMS, 010)    // NR_PEDIDO_MKTPLACE (Número Pedido da IMS)
			cLinha  += PadR(aStatus[nStatus, 1]   , 002)    // CD_STATUS_PEDIDO
			cLinha  += PadR(aStatus[nStatus, 2]   , 100)    // DC_SITUACAO_PEDIDO
			cLinha  += PadR((cAliasTmp)->C5_NUM   , 020)    // NR_PEDIDO_GESTOR
			cLinha  += CRLF
			FGravaTxt(cLinha)

			// Itens do Pedido -  Registro Tipo < D >
			While !(cAliasTmp2)->(EoF())

				If !Empty((cAliasTmp2)->DELETADO)				
					nStatus := 4 // Excluído			
				ElseIf !Empty((cAliasTmp2)->C6_NOTA) .And. Empty((cAliasTmp2)->C6_BLQ)
					nStatus := 5 // Faturado (Status Vermelho no Protheus)				
				ElseIf Empty((cAliasTmp2)->C6_BLQ) .And. (cAliasTmp2)->C6_QTDENT > 0 .And. (cAliasTmp2)->C6_QTDENT < (cAliasTmp2)->C6_QTDVEN 			
					nStatus := 7 // Parcialmente atendido (Status Amarelho no Protheus)				
				ElseIf AllTrim((cAliasTmp2)->C6_BLQ) $ '1|2|S'			
					nStatus := 55 // Bloqueado por Regra ou Verba (Status Azul ou Laranja no Protheus)				
				ElseIf AllTrim((cAliasTmp2)->C6_BLQ) == 'R'		
					nStatus := 6  // Eliminado Por Resíduo					
				EndIf

				cVlAux := Num2Str(AllTrim(StrZero(Iif(nStatus == 5 .Or. nStatus == 7, (cAliasTmp2)->C6_QTDENT, (cAliasTmp2)->C6_QTDVEN), 7)))   

				cLinha := PadR("D"                     , 001)   // TP_REGISTRO (Tipo de Registro)
				cLinha += PadR((cAliasTmp2)->C6_PRODUTO, 128)   // CD_PRODUTO (Codigo do Produto)              
				cLinha += PadR(cVlAux                  , 007)   // NR_QUANTIDADE (Quant.do Produto)
				cLinha += PadR(aStatus[nStatus, 1]     , 002)   // CD_STATUS_ITEM
				cLinha += PadR(aStatus[nStatus, 3]     , 100)   // DC_SITUACAO_ITEM
				cLinha += DtoS(dDatabase)                       // DT_STATUS_ITEM
				cLinha += CRLF
				FGravaTxt(cLinha)

				(cAliasTmp2)->(DbSkip())
			EndDo

			(cAliasTmp2)->(DbCloseArea())

			aCargas[P_SITPEDI, P_TOT_PROC]++

			(cAliasTmp)->(DbSkip())

		EndDo

	EndIf

	(cAliasTmp)->(DbCloseArea())
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgPrcProd

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados da tabela de preço de produtos para o IMS (Carga_Precos_produtos.txt).
Após uma reunião em 22/07/2015, foi definido junto da Vivian (Ferring) e o Levi (IMS)
que seria alterado o layout desta carga.
Passaria a ser integradas as tabelas de desconto do Protheus referentes as diferentes aliquotas.


Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgPrcProd()

	Local cArqTxt    := cPastaFerr + aCargas[P_PRCPROD, P_NOME_ARQ]
	Local cAliasTmp  := GetNextAlias()
	Local cAliasTmp2 := GetNextAlias()
	Local cLinha     := ""
	Local cDesTmp    := ""
	Local cVlAux     := ""
	Local nPosPer    := 0
	Local nX         := 0
	Local aListaUF   := {}
	//Local aAreaSX5   := SX5->(GetArea())

	//+----------------------------------------------------------------------+
	//| Criação do array aListaUF. Este array contém o De-Para               |
	//| Entre as aliquotas de ICMS X código da aliquota no IMS x UF.         |
	//| Os preços de cada tabela de preço do Protheus (DA1) deverão ser      |
	//| replicados para cada um dos códigos IMS. Isto porque no sistema deles|
	//| existe uma validação que cruzará o código da tabela de preço com o   |
	//| código do estado (indice 01 do array). Se este código não existir    |
	//| na tabela não será possível para eles obter o preço de tabela.       |
	//| Este array segue o seguinte formato:                                 |
	//| Em 13/04/2016 foi feita uma alteração para que o array seja carregado|
	//| a partir da SX5. Desta forma as aliquotas não ficam mais fixas.      |
	//+----------------------------------------------------------------------+
	//| aListaUF[nX, 1] => Código da Alíquota dentro do IMS (p/ uso do IMS). |
	//| aListaUF[nX, 2] => Valor Percentual da Alíquota (apenas informativo).|
	//| aListaUF[nX, 3] => Descrição da Alíquota (apenas informativo).       |
	//| aListaUF[nX, 4] => Estados atendidos (apenas informativo).           |
	//+----------------------------------------------------------------------+
    /*
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) // FILIAL + TABELA + CHAVE
	If SX5->(MsSeek(xFilial("SX5") + "ZX")) // ZX = Tabela de Alíquotas ICMS para o IMS.

		While !SX5->(EoF()) .And. SX5->X5_FILIAL + SX5->X5_TABELA == xFilial("SX5") + "ZX"

			aAdd(aListaUF, {AllTrim(SX5->X5_CHAVE)                     ,; // Código da Aliquota no IMS
			Val(SubString(SX5->X5_DESCRI, 01, 05))     ,; // Valor da Alíquota (informativo)
			AllTrim(SubString(SX5->X5_DESCRI, 07, 06)) ,; // Descrição da Alíquota (informativo)
			AllTrim(SubString(SX5->X5_DESCRI, 14, 41))})  // Estados Atendidos pela alíquota (informativo)

			SX5->(DbSkip())

		EndDo

	Else

		Return .F.

	EndIf
*/
aContent := FWGetSX5( "ZX" )

For nx:=1 to len(aContent)
	if aContent[nx,1]==xFilial("SX5")
		aAdd(aListaUF, {AllTrim(aContent[nx,3])                     ,; // Código da Aliquota no IMS
		Val(SubString(aContent[nx,4], 01, 05))     ,; // Valor da Alíquota (informativo)
		AllTrim(SubString(aContent[nx,4], 07, 06)) ,; // Descrição da Alíquota (informativo)
		AllTrim(SubString(aContent[nx,4], 14, 41))})  // Estados Atendidos pela alíquota (informativo)
	Endif
next nx

if len(aListaUF)==0
  return(.f.)
Endif

nHdl := FCreate(cArqTxt)

If nHdl == -1
	//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
Return .F.
EndIf

//Conout("Aguarde, Consultando Carga_Precos_produtos...")

aCargas[P_PRCPROD, P_TOT_PROC] := 0

cQuery := ""
cQuery := " SELECT * "
cQuery += " FROM " + RetSQLName("DA0")+" DA0 "
cQuery += " WHERE DA0_ATIVO = '1' "
cQuery += "   AND DA0_XIMS = 'S' "
cQuery += "   AND DA0.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY DA0_CODTAB "

cQuery := ChangeQuery(cQuery)

cAliasTmp:="_TMP1"
TcQuery cQuery New Alias &cAliasTmp
TcSetField(cAliasTmp,"DA0_DATDE","D",8,0)
TcSetField(cAliasTmp,"DA0_DATATE","D",8,0)
(cAliasTmp)->(DbGoTop())

If !(cAliasTmp)->(EoF())

	aCargas[P_PRCPROD, P_ARQ_PROC] := .T.

	// Cabeçalho do Arquivo
	cLinha		+= "0"
	cLinha		+= "PRECOGST "
	cLinha		+= FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
	cLinha		+= "0003"
	cLinha		+= CRLF
	FGravaTxt(cLinha)

	// Leitura dos Produtos
	While !(cAliasTmp)->(EoF())

		// Itens do Pedido
		cQuery := ""
		cQuery := " SELECT * "
		cQuery += " FROM " + RetSQLName("DA1")+" DA1 "
		cQuery += " WHERE DA1_FILIAL = '" + (cAliasTmp)->DA0_FILIAL + "' "
		cQuery += "   AND DA1_CODTAB = '" + (cAliasTmp)->DA0_CODTAB + "' "
		cQuery += "   AND DA1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY DA1_CODTAB,DA1_CODPRO "
		cQuery := ChangeQuery(cQuery)

		TcQuery cQuery New Alias &cAliasTmp2
		(cAliasTmp2)->(DbGoTop())
		If (cAliasTmp2)->(EoF())
			(cAliasTmp2)->(DbCloseArea())
			(cAliasTmp)->(DbSkip())
			Loop
		EndIf

		// Registro de Corpo
		cLinha := ""
		cLinha += "1"                                           // Tipo de Registro
		cLinha += PadR(AllTrim((cAliasTmp)->DA0_CODTAB), 020)   // Codigo da Tabela - CD_VERSAO_LISTA
		cLinha += Dtos((cAliasTmp)->DA0_DATDE)                  // Data de Vigencia Inicio da DT_INICIO_VIGENCIA
		cLinha += Dtos(Ctod("31/12/2060"))                      // Data de Vigencia Final daDT_TERMINO_VIGENCIA
		cLinha += Iif((cAliasTmp)->DA0_ATIVO == "1", "S", "N")
		cLinha += "N"
		cLinha += CRLF
		FGravaTxt(cLinha)
		lLista := .T.

		// Itens do Pedido -  Registro Tipo < D >
		If !(cAliasTmp2)->(EoF())

			While !(cAliasTmp2)->(EoF())

				For nX := 1 To Len(aListaUF)

					cLinha := ""
					cLinha += "2"                                                         // Tipo de Registro
					cLinha += PadR(SubStr(AllTrim((cAliasTmp2)->DA1_CODPRO),1,128), 128)  // Codigo do Produto - CD_PRODUTO
					cLinha += aListaUF[nX, 1]                                             // Codgio de Aliquota - CD_ALIQUOTA
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp2)->DA1_PRCVEN,13,2)))
					cLinha += Replicate("0",13-Len(cVlAux)) + cVlAux                      // Preço de Lista - VL_PRECO_LISTA
					cLinha += Iif((cAliasTmp2)->DA1_ATIVO='1', "S", "N")                  //  Ativo - ATIVO
					cLinha += CRLF
					FGravaTxt(cLinha)

				Next nI

				(cAliasTmp2)->(DbSkip())

			EndDo

		EndIf

		(cAliasTmp2)->(DbCloseArea())
		aCargas[P_PRCPROD, P_TOT_PROC]++
		(cAliasTmp)->(DbSkip())

	EndDo

EndIf

(cAliasTmp)->(DbCloseArea())
FClose(nHdl)

RestArea(aAreaSX5)

Return .T.


/**************************************************************************************************
Função:
CrgEspNota

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados dos espelhos de notas para o IMS (Carga_Espelho_Nota_Fiscal.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgEspNota()

	Local cArqTxt    := cPastaFerr + aCargas[P_ESPNOTA, P_NOME_ARQ]
	Local cAliasTmp  := GetNextAlias() 
	Local cLinha     := ""
	Local cVlAux     := ""
	Local nVlTot     := 0
	Local nVlTotBICM := 0
	Local nVlTotP    := 0
	Local nVlTotBIPI := 0  
	Local nVlICM     := 0      
	Local nVlIPI     := 0
	Local lFlag      := .F.
	Local cTransTmp  := ""
	Local cCNPJTmp   := ""
	Local cDataIni   := DTOS(DATE()-30)
	Local cDataFim   := DTOS(DATE())

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Espelho_Nota_Fiscal...")

	aCargas[P_ESPNOTA, P_TOT_PROC] := 0

	cQuery := "SELECT C5.* FROM "+RetSqlName("SF2")+" F2 " 
	cQuery += "INNER JOIN "+RetSqlName("SC5")+" C5 ON C5_FILIAL = F2.F2_FILIAL AND C5.D_E_L_E_T_ = '' AND C5.C5_XIMS = 'S' " 
	cQuery += "AND C5.C5_NOTA = F2.F2_DOC AND C5.C5_SERIE = F2.F2_SERIE " 
	cQuery += "WHERE F2.F2_EMISSAO >= '"+cDataIni+"' AND F2.F2_EMISSAO <= '"+cDataFim+"' AND F2.D_E_L_E_T_ = '' " 
	cQuery += "ORDER BY F2_DOC "
	cQuery := ChangeQuery(cQuery)

	cAliasTmp0:="_TMP0"
	TcQuery cQuery New Alias &cAliasTmp0

	(cAliasTmp0)->(DbGoTop())

	If !(cAliasTmp0)->(EoF()) 

		// Cabeçalho do Arquivo
		cLinha		+= "00"
		cLinha		+= "INVOIC" 
		cLinha		+= FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
		cLinha		+= SubStr(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]),1,35)+Space(35-Len(AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]))) // ID_REMETENTE
		cLinha		+= Space(35)                                                             // ??? ID_DESTINATARIO
		cLinha		+= Space(314)                                                            // ??? RESERVADO
		cLinha		+= CRLF
		FGravaTxt(cLinha)

		// Leitura dos Produtos
		While !(cAliasTmp0)->(EoF())

			aCargas[P_ESPNOTA, P_ARQ_PROC] := .T. 

			// Verifica a Existencia da NOTA FISCAL
			cQuery := ""
			cQuery := " SELECT * "
			cQuery += " FROM " + RetSQLName("SD2")+" SD2 "
			cQuery += " WHERE D2_FILIAL = '" + (cAliasTmp0)->C5_FILIAL + "' AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += " AND D2_PEDIDO = '"+(cAliasTmp0)->C5_NUM + "' "
			cQuery += " AND D2_CLIENTE = '"+(cAliasTmp0)->C5_CLIENTE + "' "
			cQuery += " AND D2_LOJA = '"+(cAliasTmp0)->C5_LOJACLI + "' "
			cQuery += " AND D2_TIPO = 'N' "
			cQuery += " AND EXISTS ("
			cQuery += "  SELECT B1_COD "
			cQuery += "  FROM " + RetSQLName("SB1")+" SB1 "
			cQuery += "  WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD=SD2.D2_COD )"
			cQuery += " ORDER BY  D2_DOC,D2_ITEM"   
			cQuery := ChangeQuery(cQuery)   

			cAliasTmp1 := "_TMP1"
			TcQuery cQuery New Alias &cAliasTmp1    

			(cAliasTmp1)->(DbGoTop())           

			If (cAliasTmp1)->(EoF())  
				(cAliasTmp1)->(DbCloseArea())   
				(cAliasTmp0)->(DbSkip()) 
				Loop
			EndIf

			// Carrega dados da NOTA para uma QUERY COMPLETA de TODOS os ITENS da NOTA
			_ctmpFil := (cAliasTmp1)->D2_FILIAL
			_ctmpDoc := (cAliasTmp1)->D2_DOC
			_ctmpSer := (cAliasTmp1)->D2_SERIE
			_ctmpCli := (cAliasTmp1)->D2_CLIENTE
			_ctmpLoj := (cAliasTmp1)->D2_LOJA    
			(cAliasTmp1)->(DbCloseArea())      

			// Cabeçalho da NOTA
			cQuery := ""
			cQuery := " SELECT * "
			cQuery += " FROM " + RetSQLName("SF2")+" SF2 "
			cQuery += " WHERE F2_FILIAL = '" + _ctmpFil + "' AND SF2.D_E_L_E_T_ = ' '  AND F2_TIPO='N' "
			cQuery += " AND F2_DOC = '" + _ctmpDoc + "' "
			cQuery += " AND F2_SERIE = '" + _ctmpSer + "' "
			cQuery += " AND F2_CLIENTE = '" + _ctmpCli + "' "
			cQuery += " AND F2_LOJA = '" + _ctmpLoj + "' "
			cQuery += " ORDER BY F2_DOC "
			cQuery := ChangeQuery(cQuery)

			cAliasTmp := "_TMP3"
			TcQuery cQuery New Alias &cAliasTmp   
			TcSetField(cAliasTmp,"F2_DTENTR" ,"D",8,0)
			TcSetField(cAliasTmp,"F2_EMISSAO","D",8,0)
			(cAliasTmp)->(DbGoTop())

			// Itens do Pedido
			cQuery := " SELECT * "
			cQuery += " FROM " + RetSQLName("SD2")+" SD2 "
			cQuery += " WHERE D2_FILIAL = '" + (cAliasTmp)->F2_FILIAL + "' AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += " AND D2_DOC = '"+(cAliasTmp)->F2_DOC + "' "
			cQuery += " AND D2_SERIE = '"+(cAliasTmp)->F2_SERIE + "' "
			cQuery += " AND D2_CLIENTE = '"+(cAliasTmp)->F2_CLIENTE + "' "
			cQuery += " AND D2_LOJA = '"+(cAliasTmp)->F2_LOJA + "' "
			cQuery += " AND EXISTS ("
			cQuery += "   SELECT B1_COD "
			cQuery += "   FROM " + RetSQLName("SB1")+" SB1 "
			cQuery += "   WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD=SD2.D2_COD )"
			cQuery += " ORDER BY  D2_DOC,D2_ITEM"
			cQuery := ChangeQuery(cQuery)

			cAliasTmp1 := "_TMP1"
			TcQuery cQuery New Alias &cAliasTmp1
			(cAliasTmp1)->(DbGoTop())           

			If (cAliasTmp1)->(EoF())     
				(cAliasTmp1)->(DbCloseArea())   
				(cAliasTmp)->(DbCloseArea())   
				(cAliasTmp0)->(DbSkip()) 
				Loop
			EndIf

			DbSelectArea("SC5")
			SC5->(DbSetOrder(1)) // FILIAL + NUMERO
			SC5->(MsSeek(xFilial("SC5") + (cAliasTmp1)->D2_PEDIDO))

			// Registro de Corpo              
			cLinha := ""
			cLinha += "01"                                                                                     //  Tipo de Registro - TP_REGISTRO
			cLinha += Right(StrZero(Val((cAliasTmp)->F2_DOC),10),6)                                            //  Num.da Nota Fiscal  -  NR_NOTA_FISCAL* 
			cLinha += (cAliasTmp)->F2_SERIE                                                                    //  Serie da Nota Fiscal  - SERIE_NOTA_FISCAL*
			cLinha += Space(2)                                                                                 // ??? Sub Serie da Nota Fiscal  - SUB_SERIE_NOTA_FISCAL*
			cLinha += "031"                                                                                    // ??? Função Mensagem de Operação - FUNCAO_MENSAGEM
			cLinha += Dtos(Ctod("  /  /  "))                                                                   // ??? Data de Despacho - DT_DESPACHO
			cLinha += Dtos((cAliasTmp)->F2_DTENTR)                                                             // ??? Data de Entrega  - DT_ENTREGA
			cLinha += Dtos((cAliasTmp)->F2_EMISSAO)                                                            // Data de Emissão      - DT_EMISSAO*
			cLinha += "000"                                                                                    // ??? Cod.Natureza Fiscal - CD_NATUREZA_OPERACAO
			cLinha += PadR(AllTrim(SC5->C5_MENANEX), 15)                                                       // ??? Numero do Pedido de Compra - NR_PEDIDO_COMPRADOR
			cLinha += Replicate("0",13)                                                                        // ??? Codigo EAN do Comprador - CD_EAN_COMPRADOR
			cCNPJTmp := Posicione("SA1",1,xFilial("SA1")+(cAliasTmp)->F2_CLIENTE+(cAliasTmp)->F2_LOJA,"A1_CGC")
			cLinha += PadR(SubStr(AllTrim(cCNPJTmp), 1, 014), 014)                                             // ??? CNPJ do Comprador - NR_CNPJ_COMPRADOR*
			cLinha += Replicate("0",13)                                                                        // ??? Codigo EAN Local de Entrega - CD_EAN_LOCAL_ENTREGA
			cLinha += Replicate("0",14)                                                                        // ??? CNPJ do Local de Entrega - NR_CNPJ_LOCAL_ENTREGA
			cLinha += Replicate("0",13)                                                                        // ??? Codigo EAN Emissor da Nota Fiscal - CD_EAN_EMISSOR_NOTA_FISCAL
			cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]                                                                              // ??? CNPJ do Emissor da Nota Fiscal - NR_CNPJ_EMISSOR_NOTA_FISCAL
			cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]                                                                           // Estado do Emissor da Nota  -  UF_EMISSOR_NOTA_FISCAL
			cLinha += Strzero(Val(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_INSC'})[1][2]),20)                                                            // Inscrição Estadual do Emissor da Nota - NR_IE_EMISSOR_NOTA_FISCAL
			cLinha += Replicate("0",13)                                                                        // ??? Codigo EAN do Destinatario  - CD_EAN_DESTINATARIO
			cLinha += PadR(SubStr(AllTrim(cCNPJTmp), 1, 014), 014)                                             // ??? CNPJ do Destinatario  - CD_EAN_DESTINATARIO
			cLinha += Replicate("0",13)                                                                        // ??? Codigo EAN de Pagamento  - CD_EAN_PAGTO
			cLinha += PadR(SubStr(AllTrim(cCNPJTmp), 1, 014), 014)                                             // ??? CNPJ do Pagamento  - NR_CNPJ_PAGTO
			cLinha += Replicate("0",13)                                                                        // ??? Codigo EAN do Fornecedor - CD_EAN_FORNECEDOR
			cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]                                                                              // ??? CNPJ do Fornecedor - NR_CNPJ_FORNECEDOR
			cTransTmp := SC5->C5_TRANSP                                                         	           // nf saida
			cTransTmp := Posicione("SA4",1,xFilial("SA4")+Iif(Empty(cTransTmp),'003011',cTransTmp),"A4_CGC")   // CONDIÇÃO TEMPORARIA 
			cLinha += PadR(SubStr(AllTrim(cTransTmp), 1, 014), 014)                                            // ??? CNPJ da Trasnportadora - NR_CNPJ_TRANSPORTADORA
			cLinha += Space(35)                                                                                // ??? Nome da Trasnportadora - NM_TRANSPORTADORA
			cLinha += Iif((cAliasTmp)->F2_TPFRETE="C","CIF",Iif((cAliasTmp)->F2_TPFRETE="F","FOB","   "))      // ??? Condição de Entrega da Trasnportadora(CIF/FOB) - CD_CONDICAO_ENTREGA
			cLinha += Replicate("0",08)                                                                        // ??? Numero da Embalagem    - NR_EMBALAGEM
			cLinha += Space(3)                                                                                 // ??? Tipo da Embalagem - TP_EMBALAGEM
			cLinha += Strzero(Val((cAliasTmp1)->D2_CF),06)                                                     // ??? Numero do CFOP    - NR_CFOP
			cLinha += PadR(SC5->C5_PEDIMS, 20)                                                                 // ??? Numero do Pedido Fornecedor - NR_PEDIDO_FORNECEDOR
			cLinha += Iif((cAliasTmp)->F2_TIPO="N","01","  ")                                                  // ??? Tipo da Nota 01-Venda / 02-Bonificação / 03-Cancelmento / 04-Devolução / 05-Retorno / 06-Aviso / 07-Transferencia - TP_NOTA_FISCAL*
			cLinha += Space(17)                                                                                // ??? Numero do Prazo de Pagamento  -  NR_PRAZO_PAGTO_MEDIO
			cLinha += Space(60)                                                                                // ??? Status do Faturamento do Pedido -  STATUS_NF
			cLinha += Space(70)                                                                                //     Reservado
			cLinha += CRLF   
			FGravaTxt(cLinha)

			// Registro de Corpo              
			cLinha := ""
			cLinha += "02"                                                                                          //  Tipo de Registro - TP_REGISTRO
			cLinha += StrZero(1, 02)                                                                                //  ??? Num.da pARC.Pagam.  -  NR_PARCELA_PAGTO*
			cLinha += StrZero(1, 03)                                                                                //  ??? Id.Parc.Pagam.      -  ID_PARCELA_PAGTO
			cLinha += Dtos((cAliasTmp)->F2_EMISSAO + 30)                                                            //  ??? Data Parc. -  DT_PAGTO_PARCELA*
			cLinha += Replicate("0", 05)                                                                            //  ??? Perc.Pagam. -  PERC_PAGTO_PARCELA
			cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp)->F2_VALBRUT, 18, 2)))
			cLinha += Replicate("0", 18 - Len(cVlAux)) + cVlAux                                                     //  ??? Valor de Pagamento -  VL_PAGTO_PARCELA                                      
			cLinha += Space(362)                                                                                    //     Reservado
			cLinha += CRLF
			FGravaTxt(cLinha)

			// Itens da Nota -  Registro Tipo < 03 >
			If !(cAliasTmp1)->(EoF()) 

				lFlag := .T.

				While !(cAliasTmp1)->(EoF())

					cLinha := ""
					cLinha += "03"                                                                                  // Tipo de Registro    
					cLinha += StrZero(Val((cAliasTmp1)->D2_ITEM), 6)                                                // Numero do Item - NR_LINHA_ITEM*
					cLinha += PadR(SubStr(AllTrim((cAliasTmp1)->D2_COD), 1, 014), 014)                              // Codigo do Produto - CD_PRODUTO*
					cLinha += PadR(SubStr(AllTrim((cAliasTmp1)->D2_CF), 1, 014) , 014)                              // ??? Codigo de Classificação Fiscal - CD_CLASSIFICACAO_FISCAL
					cLinha += Space(20)                                                                             // ??? Numero do Lote - NR_LOTE
					cLinha += Space(03)                                                                             // ??? Ident. Quantidade - ID_QUANTIDADE
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_QUANT,18)))
					cLinha += cVlAux                                                                                // Quant.do Produto Vendida - NR_QUANTIDADE*
					cLinha += PadR(SubStr(AllTrim((cAliasTmp1)->D2_UM), 1, 003) , 003)                              // ??? Unidade de Medida - UN_MEDIDA
					cLinha += Replicate("0",15)                                                                     // ??? Valor de Saldo de Pedido - VL_SALDO_PEDIDO
					cLinha += Space(03)                                                                             // ??? Ident. Tratamento de Saldo - ID_TRATAMENTO_SALDO
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_TOTAL,18,2)))
					cLinha += cVlAux                                                                                // ??? Valor Liquido do Item - VL_LIQUIDO_ITEM
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_PRCVEN,15,2)))
					cLinha += cVlAux                                                                                // ??? Valor do Preço Unitario do Item - VL_PRECO_UNITARIO*
					cLinha += Replicate("0",09)                                                                     // ??? Valor Base Preço Unitario - VL_BASE_PRECO_UNITARIO
					cLinha += PadR(SubStr(AllTrim((cAliasTmp1)->D2_UM), 1, 003) , 003)                              // ??? Unidade de Medida do Item - UN_MEDIDA_ITEM
					cLinha += Space(03)                                                                             // ??? Num. CFOP Antigo - NR_CFOP_ANTIGO
					cLinha += Space(02)                                                                             // ??? Cod.de Tributo Estadual - CD_TRIB_ESTADUAL
					cLinha += Space(03)                                                                             // ??? Cod.de Tributo Federal - CD_TRIB_FEDERAL
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_PICM,5,2)))
					cLinha += cVlAux                                                                                // ??? Perc. Aliquota ICMS - PERC_ALIQ_ICMS
					cLinha += Replicate("0",05)                                                                     // ??? Perc. Redução ICMS - PERC_REDUCAO_ICMS
					cLinha += Space(03)                                                                             // ??? Cod.Tipo Trib. ICMS - CD_TP_TRIB_ICMS
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_BASEICM,18,2)))
					cLinha += cVlAux                                                                                // ??? Valor Base ICMS - VL_BASE_CALC_ICMS
					cLinha += Replicate("0",05)                                                                     // ??? Perc. ICMS SUBSTITUICAO - PERC_ICMS_SUBSTITUICAO
					cLinha += Space(03)                                                                             // ??? Cod.Tipo Trib. ICMS SUBSTITUICAO - CD_TP_TRIB_ICMS_SUBSTITUICAO
					cLinha += Replicate("0",18)                                                                     // ??? Valor Base ICMS SUBSTITUICAO - VL_BASE_CALC_ICMS_SUBST
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_IPI,5,2)))
					cLinha += cVlAux                                                                                // ??? Perc. Aliquota IPI - PERC_IPI
					cLinha += Space(03)                                                                             // ??? Cod.Trib. IPI - CD_TRIB_IPI
					cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp1)->D2_BASEIPI,18,2)))
					cLinha += cVlAux                                                                                // ??? Valor Base IPI - VL_BASE_CALC_IPI
					cLinha += Replicate("0",10)                                                                     // ??? Perc.Desc.Repasse ICMS - PERC_DESC_REPASSE_ICMS
					cLinha += Replicate("0",10)                                                                     // ??? Perc.Desc.Comercial  - PERC_DESC_COMERCIAL*
					cLinha += StrZero(Val((cAliasTmp1)->D2_CF),6)                                                   // ??? Numero do CFOP - NR_CFOP
					cLinha += Space(03)                                                                             // ??? Cod.Sit.Tributado Atual - CD_SIT_TRIB_ATUAL
					cLinha += Replicate("0",18)                                                                     // ??? Valor Desconto Zona Franca - VL_DESCONTO_ZONA_FRANCA
					cLinha += Space(119)                                                                            //     Reservado
					cLinha += CRLF   
					FGravaTxt(cLinha)

					nVlTot     += (cAliasTmp1)->D2_TOTAL     
					nVlTotBICM += (cAliasTmp1)->D2_BASEICM 
					nVlTotBIPI += (cAliasTmp1)->D2_BASEIPI 
					nVlICM     += (cAliasTmp1)->D2_VALICM
					nVlIPI     += (cAliasTmp1)->D2_VALIPI
					(cAliasTmp1)->(DbSkip())

				EndDo

				nVlTotP+=(cAliasTmp)->F2_VALBRUT

			EndIf

			(cAliasTmp1)->(DbCloseArea()) 
			(cAliasTmp)->(DbCloseArea())

			aCargas[P_ESPNOTA, P_TOT_PROC]++ 

			(cAliasTmp0)->(DbSkip()) 

		EndDo

		If lFlag

			// Sumário da NOTA
			cLinha := ""
			cLinha += "04"                                                              // Tipo de Registro - TP_REGISTRO
			cLinha += Replicate("0", 18)                                                // ??? Numero do Peso Total Bruto - NR_PESO_BRUTO_TOTAL
			cLinha += Replicate("0", 18)                                                // ??? Numero da Cubagem Total  - NR_CUBAGEM_TOTAL
			cVlAux := Num2Str(AllTrim(StrZero(nVlTot, 18, 2)))
			cLinha += cVlAux                                                            // ??? Soma de todos os ITENS - VL_TOT_LINHA_ITEM
			cLinha += Replicate("0", 18)                                                // ??? Valor Desconto Nota Fiscal  - VL_DESC_NOTA_FISCAL
			cLinha += Replicate("0", 18)                                                // ??? Valor Pago Antecipadamente  - VL_PAGO_ANTECIPADAMENTE
			cVlAux := Num2Str(AllTrim(StrZero(nVlTotP, 18, 2)))
			cLinha += cVlAux                                                            // ??? Valor Total Pago - VL_TOT_PAGAR
			cLinha += Space(3)                                                          // ??? Codigo de Tributação ICMS  CD_TRIB_ICMS
			cVlAux := Num2Str(AllTrim(StrZero(nVlTotBICM, 18, 2)))
			cLinha += cVlAux                                                            // ??? Valor Base de Calculo de ICMS - VL_BASE_CALC_ICMS
			cVlAux := Num2Str(AllTrim(StrZero(nVlICM, 18, 2)))
			cLinha += cVlAux                                                            // ??? Valor Total de ICMS - VL_ICMS
			cLinha += Space(3)                                                          // ??? Codigo de Tributação ICMS REDUCAO - CD_TRIB_ICMS_REDUCAO
			cLinha += Replicate("0", 18)                                                // ??? Valor Base Calc. ICMS REDUCAO  - VL_BASE_CALC_ICMS_REDUCAO
			cLinha += Replicate("0", 18)                                                // ??? Valor ICMS REDUCAO Trib. - VL_ICMS_REDUCAO_TRIB
			cLinha += Space(3)                                                          // ??? Codigo de Tributação ICMS SUBSTITUIÇÃO - CD_TRIB_ICMS_SUBSTITUICAO
			cLinha += Replicate("0", 18)                                                // ??? Valor Base Calc. ICMS ICMS SUBSTITUIÇÃO - VL_BASE_CALC_ICMS_SUBST
			cLinha += Replicate("0", 18)                                                // ??? Valor ICMS SUBSTITUIÇÃO - VL_ICMS_SUBSTITUICAO
			cLinha += Space(3)                                                          // ??? Codigo de Tributação IPI - CD_TRIB_IPI
			cVlAux := Num2Str(AllTrim(StrZero(nVlTotBIPI, 18, 2)))
			cLinha += cVlAux                                                            // ??? Valor Base Calc. IPI - VL_BASE_CALC_IPI
			cVlAux := Num2Str(AllTrim(StrZero(nVlIPI, 18, 2)))
			cLinha += cVlAux                                                            // ??? Valor Total de IPI - VL_IPI
			cLinha += Space(134)                                                        // Reservado
			cLinha += CRLF   
			FGravaTxt(cLinha)

		EndIf

	EndIf

	(cAliasTmp0)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgCondCom

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados de condições comerciais para o IMS (Carga_Condicoes_Comerciais.txt).
Esta arquivo é baseado no cadastro de Grupo de Clientes do Protheus (tabela ACY). Esta informação
é vinculada ao cliente através do campo A1_GRPVEN.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgCondCom()

	Local cArqTxt    := cPastaFerr + aCargas[P_CONDCOM, P_NOME_ARQ] 
	Local cAliasTmp	 := GetNextAlias()  
	Local cAliasTmp2 := GetNextAlias() 
	Local cLinha     := ""
	Local cQuery     := ""

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Condicoes_Comerciais...")  

	aCargas[P_CONDCOM, P_TOT_PROC] := 0

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("ACY") + " ACY "
	cQuery += " WHERE ACY.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ACY_GRPVEN "   

	cQuery := ChangeQuery(cQuery)

	cAliasTmp := "_TMP1"
	TcQuery cQuery New Alias &cAliasTmp
	(cAliasTmp)->(DbGoTop())           

	If !(cAliasTmp)->(EoF()) 

		aCargas[P_CONDCOM, P_ARQ_PROC] := .T.

		cLinha += "0"        
		cLinha += "CONDICOM" 
		cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2] + " "
		cLinha += "0003"  
		cLinha += CRLF   
		FGravaTxt(cLinha)

		// Leitura dos Grupos de Condições Comerciais
		While !(cAliasTmp)->(EoF())          

			If Val((cAliasTmp)->ACY_GRPVEN) < 100 .And. (cAliasTmp)->ACY_GRPVEN <> "000011" // Exceção para a condição 000011 (SEM DESCONTO COMERCIAL) 

				(cAliasTmp)->(DbSkip()) 
				Loop

			EndIf   

			// Registro de Corpo              
			cLinha := ""
			cLinha += "1"                                                                // Tipo de Registro    
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->ACY_GRPVEN), 1, 020), 020)        // Codigo da Condição Comercial CD_COND_COMERCIAL
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->ACY_DESCRI), 1, 060), 060)        // Nome da Condição Comercial  NM_COND_COMERCIAL
			cLinha += Iif((cAliasTmp)->ACY_GRPVEN == "000011", "N", "S")                 // Permitir a alteração do desconto no momento do pedido <S> - <N>  - DESCONTO_VARIAVEL - tbb - 18/09/2015 - alterado de S para N a pedido da Vivian sempre que for o grupo SEM DESONTO COMERCIAL (000011).
			cLinha += "N"                                                                // Permitir alterar o Pazo de Pagamento <S> - <N>  -  PRAZO_VARIAVEL
			cLinha += "P"                                                                // Aplicação de Desconto <C> Desconto na Condição - <P> Desconto no Produto - <A> Ambos - APLICACAO_DESCONTO
			cLinha += "A"                                                                // Direito de Acesso <C> Cliente - <V> Interno - <A> Ambos - DIREITO_ACESSO
			cLinha += "N"                                                                // Permite Preço de Empenho <S> - <N>  - PERMITE_PRECO_EMPENHO
			cLinha += "N"                                                                // Requer Aprovação  <S> - <N>  - REQUER_APROVACAO
			cLinha += "N"                                                                // Validade variavel <S> - <N>  - VALIDADE_VARIAVEL
			cLinha += "0"                                                                // Semana Limite <0> - SEMANA_LIMITE
			cLinha += "S"                                                                // Se a condição esta ATIVA ou NÃO ATIVOV <S> - <N> - ATIVO
			cLinha += CRLF   
			FGravaTxt(cLinha)   

			// Registro de Corpo -  Registro Tipo < 2 >
			//+-------------------------------------------------------------------+
			//|tbb - 22/06/2015                                                   |
			//|Replicado (a pedido da Vivian) este registro para todos os estados |
			//+-------------------------------------------------------------------+
			dbSelectArea("SX5")
			SX5->(dbSetOrder(1)) // FILIAL + TABELA
			SX5->(msSeek(xFilial("SX5") + "12")) // Tabela 12 = Estados

			While !SX5->(EoF()) .And. SX5->X5_FILIAL + SX5->X5_TABELA == xFilial("SX5") + "12"

				If AllTrim(SX5->X5_CHAVE) <> "EX" // Desconsidera o "estado" Estrangeiro

					cLinha := ""
					cLinha += "2"                            // Tipo de Registro
					cLinha += AllTrim(SX5->X5_CHAVE)         // UF
					cLinha += Replicate("0", 007)            // DESC_PADRAO
					cLinha += Replicate("0", 007)            // DESC_LIM_INFERIOR
					cLinha += Replicate("0", 007)            // DESC_LIM_SUPERIOR
					cLinha += Replicate("0", 007)            // DESC_FINANCEIRO
					cLinha += Replicate("0", 005)            // PRAZO_PAGTO_INFERIOR
					cLinha += Replicate("0", 005)            // PRAZO_PAGTO_SUPERIOR
					cLinha += "S"                            // Se estar ATIVO ou NÃO - ATIVO
					cLinha += CRLF   
					FGravaTxt(cLinha)

				EndIf

				SX5->(DbSkip())

			EndDo

			// Registro de Corpo -  Registro Tipo < 3 >
			cQuery := " SELECT * "
			cQuery += " FROM " + RetSQLName("SA1")+" SA1 "
			cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += "     AND A1_XIMS = 'S' "
			cQuery += "     AND A1_GRPVEN = '" + (cAliasTmp)->ACY_GRPVEN + "' "
			cQuery += " ORDER BY SA1.A1_COD "   
			cQuery := ChangeQuery(cQuery)

			cAliasTmp2 := "_TMP2"
			TcQuery cQuery New Alias &cAliasTmp2

			(cAliasTmp2)->(DbGoTop())              
			// Query de Clientes (Fim)

			//_avetcli:={}
			If !(cAliasTmp2)->(EoF()) 

				While !(cAliasTmp2)->(EoF())   

					If AllTrim((cAliasTmp)->ACY_GRPVEN) <> AllTrim((cAliasTmp2)->A1_GRPVEN)

						(cAliasTmp2)->(DbSkip()) 
						Loop

					EndIf

					// Registro de Corpo
					cLinha := ""
					cLinha += "3"                                                         // Tipo de Registro  
					cLinha += PadL((cAliasTmp2)->A1_COD+(cAliasTmp2)->A1_LOJA, 020)       // Codigo do Cliente
					cLinha += Iif((cAliasTmp2)->A1_MSBLQL="2","S","N")                    //  Ativo ou Não      
					cLinha += CRLF   
					FGravaTxt(cLinha)   

					(cAliasTmp2)->(DbSkip())

				EndDo 

			EndIf   

			(cAliasTmp2)->(DbCloseArea())

			// Registro de Corpo -  Registro Tipo < 3 > - Não precisa ENVIAR 

			// Registro de Corpo -  Registro Tipo < 4 > - Duvida dos CAMPOS

			// Registro de Corpo -  Registro Tipo < 5 > - Não precisa ENVIAR 

			aCargas[P_CONDCOM, P_TOT_PROC]++

			(cAliasTmp)->(DbSkip()) 

		EndDo

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgDesCond

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados de descontos das condições comerciais para o IMS 
(Carga_Desconto_Condicoes_Comerciais.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgDesCond()

	Local cArqTxt    := cPastaFerr + aCargas[P_DESCOND, P_NOME_ARQ]
	Local cAliasTmp	 := GetNextAlias()
	Local cAliasTmp1 := GetNextAlias()
	Local cAliasTmp2 := GetNextAlias()
	Local cLinha     := ""
	Local cQuery     := ""
	Local cVlAux     := ""
	Local cVlMin     := ""
	Local cVlMax     := ""
	Local lFlagCab   := .F.
	Local lFlagSCab  := .F.

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Desconto_Condicoes_Comerciais...")

	aCargas[P_DESCOND, P_TOT_PROC] := 0

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("ACY")+" ACY "
	cQuery += " WHERE ACY.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ACY_GRPVEN "   

	cQuery := ChangeQuery(cQuery)

	cAliasTmp := "_TMP1"

	TcQuery cQuery New Alias &cAliasTmp
	(cAliasTmp)->(DbGoTop())           
	If !(cAliasTmp)->(EoF()) 

		// Leitura dos Grupos de Condições Comerciais
		While !(cAliasTmp)->(EoF())        

			If Val((cAliasTmp)->ACY_GRPVEN) < 100 .And. (cAliasTmp)->ACY_GRPVEN <> "000011" // Exceção para a condição 000011 (SEM DESCONTO COMERCIAL)
				(cAliasTmp)->(DbSkip()) 
				Loop
			EndIf   

			cQuery := " SELECT * "
			cQuery += " FROM " + RetSQLName("ACO")+" ACO "
			cQuery += " WHERE ACO.D_E_L_E_T_ = ' ' "
			cQuery += " AND ACO_DATATE = '' "
			cQuery += " AND ACO_GRPVEN = '"+(cAliasTmp)->ACY_GRPVEN+"' AND ACO_XIMS = 'S' "
			cQuery += " ORDER BY ACO_CODREG "
			cQuery := ChangeQuery(cQuery)

			cAliasTmp1 := "_TMP2"
			TcQuery cQuery New Alias &cAliasTmp1
			TcSetField(cAliasTmp1,"ACO_DATDE" ,"D",8,0)
			TcSetField(cAliasTmp1,"ACO_DATATE","D",8,0)

			(cAliasTmp1)->(DbGoTop())

			If (cAliasTmp1)->(EoF())
				(cAliasTmp1)->(DbCloseArea())   
				(cAliasTmp)->(DbSkip()) 
				Loop
			EndIf

			(cAliasTmp1)->(DbGoTop())

			If !(cAliasTmp1)->(EoF())

				_codgrum := ""

				// Leitura dos Descontos Cabeçalho
				While !(cAliasTmp1)->(EoF()) 

					// Leitura dos Descontos Itens
					cQuery := " SELECT * "
					cQuery += " FROM " + RetSQLName("ACP")+" ACP "
					cQuery += " WHERE ACP_CODREG = '" + (cAliasTmp1)->ACO_CODREG + "' AND ACP.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY ACP_CODREG,ACP_CODPRO "
					cQuery := ChangeQuery(cQuery)

					cAliasTmp2 := "_TMP3"
					TcQuery cQuery New Alias &cAliasTmp2
					(cAliasTmp2)->(DbGoTop())

					If (cAliasTmp2)->(EoF())

						(cAliasTmp2)->(DbCloseArea())   
						(cAliasTmp1)->(DbSkip()) 
						Loop

					EndIf

					(cAliasTmp2)->(DbGoTop())           

					If !(cAliasTmp2)->(EoF()) 

						lFlagSCab := .F.

						// Leitura dos Descontos Cabeçalho
						While !(cAliasTmp2)->(EoF()) 

							// Cabeçalho do Arquivo Principal
							If !lFlagCab

								aCargas[P_DESCOND, P_ARQ_PROC] := .T.

								cLinha := ""
								cLinha += "0"        
								cLinha += "LISTADES" 
								cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2] + Space(1)
								cLinha += "0003"  
								cLinha += CRLF   
								FGravaTxt(cLinha)

								lFlagCab := .T. 

							EndIf

							If !lFlagSCab

								// Registro de Corpo  < Tipo (1) >
								cLinha := ""
								cLinha += "1"                                                            // Tipo de Registro    
								cLinha += PadR(SubStr(AllTrim((cAliasTmp1)->ACO_CODREG), 1, 020), 020)   // Codigo do Desconto Casdatrado CD_VRS_COND_COMERCIAL
								cLinha += Dtos((cAliasTmp1)->ACO_DATDE)                                  // DT_INICIO_VIGENCIA
								cLinha += Dtos(Ctod("31/12/2060"))                                       // DT_FINAL_VIGENCIA
								cLinha += "S"                                                            // Se estar ATIVO ou NÃO - ATIVO
								cLinha += CRLF   
								FGravaTxt(cLinha)

								lFlagSCab := .T.

							EndIf

							// Registro de Corpo -  Registro Tipo < 2 >
							cLinha := ""
							cLinha += "2"                                                            // Tipo de Registro    
							cLinha += PadR(SubStr(AllTrim((cAliasTmp)->ACY_GRPVEN) , 1, 020), 020)   // Codigo do Desconto Comercial CD_COND_COMERCIAL
							cLinha += PadR(SubStr(AllTrim((cAliasTmp2)->ACP_CODPRO), 1, 020), 020)   // Codigo do Produto
							cVlAux := Num2Str(AllTrim(StrZero((cAliasTmp2)->ACP_PERDES,5,2)))
							cVlMin := Num2Str(AllTrim(StrZero(0,5,2)))
							cVlMax := Num2Str(AllTrim(StrZero(99.99,5,2)))
							cLinha += cVlAux                                                        // Percentual de Desconto PERC_DESCONTO
							cLinha += cVlMin                                                        // Desconto Minimo    - PERC_DESC_MIN 
							cLinha += cVlAux                                                        // Desconto de Venda  - PERC_DESC_VENDA
							cLinha += cVlMax                                                        // Desconto de Venda  - PERC_DESC_MAX
							cLinha += "S"                                                           // Se estar ATIVO ou NÃO - ATIVO
							cLinha += CRLF   
							FGravaTxt(cLinha)   
							cLinha      := ""

							(cAliasTmp2)->(DbSkip())

						EndDo

						(cAliasTmp2)->(DbCloseArea())

					EndIf

					(cAliasTmp1)->(DbSkip())

				EndDo

				(cAliasTmp1)->(DbCloseArea())   

			EndIf 

			aCargas[P_DESCOND, P_TOT_PROC]++

			(cAliasTmp)->(DbSkip())

		EndDo

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgEstoque

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados de saldos em estoque para o IMS (Carga_Estoque_Armazem.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgEstoque()

	Local cArqTxt   := cPastaFerr + aCargas[P_ESTOQUE, P_NOME_ARQ]
	Local cAliasTmp := GetNextAlias()
	Local cLinha    := ""                                 
	Local aTLoad    := {}
	Local cFilTemp  := ";;"

	nHdl          := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Estoque_Armazem...")

	aCargas[P_ESTOQUE, P_TOT_PROC] := 0

	/*
	SELECT
	Z4_FILIAL AS FILIAL,
	Z4_PRODUTO AS PRODUTO,
	Z4_LOTE AS LOTE,
	Z4_VALIDAD AS VALIDADE,
	SUM(Z4_QTDE) AS SALDO
	FROM %Table:SZ4% SZ4
	WHERE 
	Z4_FILIAL NOT IN ('02', '03')
	AND Z4_DTARQ = %Exp:DtoS(dDatabase)%
	AND Z4_STATUS = 'DIS'  // tbb - 29/10/2015 - inserido a pedido da Vivian esta validação para enviar somente itens disponíveis.
	AND SZ4.%NotDel%
	GROUP BY
	Z4_FILIAL,
	Z4_PRODUTO,
	Z4_LOTE,
	Z4_VALIDAD
	ORDER BY
	Z4_FILIAL,
	Z4_PRODUTO,
	Z4_LOTE
	*/

// Mesma lógica da query utilizado pelo relatório de Match de Estoque BOMI.
BEGINSQL ALIAS cAliasTmp

		Column VALIDADE As Date

		%noParser%

		SELECT
		B1_FILIAL AS FILIAL,
		B1_COD AS PRODUTO,
		'' AS LOTE,
		1999999999 AS SALDO
		FROM %Table:SB1% SB1
		WHERE 
		B1_FILIAL = %xFilial:SB1%
		AND LEFT(B1_COD,2) = '50' AND B1_MSBLQL = '2'
		AND SB1.%NotDel%
		ORDER BY
		B1_FILIAL , 
		B1_COD

ENDSQL

cLinha := ""

(cAliasTmp)->(DbGoTop())

If !(cAliasTmp)->(EoF())

	cLinha += PadR("H"        , 01)
	cLinha += PadR("ESTGEST"  , 07)
	cLinha += PadL(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2], 15)
	cLinha += PadR("0003"     , 04)
	cLinha += CRLF

	FGravaTxt(cLinha)

	While !(cAliasTmp)->(EoF())

		If cFilTemp <> (cAliasTmp)->FILIAL

			cFilTemp := (cAliasTmp)->FILIAL
			cCNPJTmp := ""
			cDescFil := ""

			// Obtém o CNPJ da filial
			//			U_GetFilFerring(@cCNPJTmp, cEmpAnt, (cAliasTmp)->FILIAL, "M0_FILIAL", @cDescFil)
			U_GetFilFerring(@cCNPJTmp, cEmpAnt, cFilAnt , "M0_FILIAL", @cDescFil)

			aCargas[P_ESTOQUE, P_ARQ_PROC] := .T.

			// Registro do Corpo (cabeçalho exibido para cada filial do Protheus)
			cLinha  := ""
			cLinha  += PadR("C"              , 001)   // Tipo de Registro
			cLinha  += PadR(AllTrim(cCNPJTmp), 020)   // Código da Planta do Centro Fornecedor
			cLinha  += PadR(AllTrim(cDescFil), 020)   // Nome do Centro Fornecedor
			cLinha  += PadR("SP"             , 002)   // UF do armazém (Filial)
			cLinha  += CRLF

			FGravaTxt(cLinha)

		EndIf

		// Registro dos Detalhes -  Registro Tipo < 2 >
		cLinha := ""
		cLinha += PadR("I"                          , 001)   // Tipo de Registro
		cLinha += PadR(AllTrim((cAliasTmp)->PRODUTO), 020)   // Código do Produto
		cLinha += Strzero((cAliasTmp)->SALDO        , 010)   // Quantidade do Produto
		cLinha += PadR('99999999999999999999'      , 020)   // Número do Lote do Produto
		cLinha += "20491231"                // Validade do Lote
		cLinha += CRLF
		FGravaTxt(cLinha)

		aCargas[P_ESTOQUE, P_TOT_PROC]++

		(cAliasTmp)->(DbSkip())

	EndDo

EndIf

(cAliasTmp)->(DbCloseArea())
FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgCondCli

Autor:
Tiago Bandeira Brasiliano (a partir da função do Juscelino Alves)

Data:
21/07/2015

Descrição:
Efetua a carga dos dados de condições de pagamento por cliente para o IMS 
(Condicao_Pagamento_Cliente.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgCondCli()

	Local cArqTxt   := cPastaFerr + aCargas[P_CONDCLI, P_NOME_ARQ]
	Local cAliasTmp := GetNextAlias()
	Local cLinha    := ""
	Local cQuery    := ""

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Condicao_Pagamento_Cliente...")

	aCargas[P_CONDCLI, P_TOT_PROC] := 0

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SE4") + " SE4 "
	cQuery += " WHERE E4_FILIAL = '" + xFilial("SE4") + "' AND SE4.D_E_L_E_T_ = ' '   AND  E4_XIMS = 'S'  "
	cQuery += " ORDER BY SE4.E4_CODIGO  "   

	cQuery := ChangeQuery(cQuery)

	cAliasTmp := "_TMP1"
	TcQuery cQuery New Alias &cAliasTmp

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(EoF()) 

		// Cabeçalho do Arquivo
		cLinha := ""
		cLinha += "H"
		cLinha += "CONDPAGXCLI"
		cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]
		cLinha += "0003"
		cLinha += CRLF
		FGravaTxt(cLinha)

		// Leitura das Condições de Pagamentos   
		While !(cAliasTmp)->(EoF())         

			cAliasTmp1 := "_TMP2"

			cQuery := " SELECT * "
			cQuery += " FROM " + RetSQLName("SA1") + " SA1 "
			cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.D_E_L_E_T_ = ' ' AND A1_COND = '" + (cAliasTmp)->E4_CODIGO+"'  AND A1_XIMS = 'S' "
			cQuery += " ORDER BY SA1.A1_COD "   
			cQuery := ChangeQuery(cQuery)
			TcQuery cQuery New Alias &cAliasTmp1

			(cAliasTmp1)->(DbGoTop())           

			If !(cAliasTmp1)->(EoF()) 

				// Leitura das Condições de Pagamentos por Clientes 
				While !(cAliasTmp1)->(EoF())

					aCargas[P_CONDCLI, P_ARQ_PROC] := .T.

					// Registro de Corpo
					cLinha := ""
					cLinha += "C"                                                         // Tipo de Registro    
					cLinha += PadR(SubStr(AllTrim((cAliasTmp)->E4_CODIGO), 1, 020), 020)  // Codigo da Condição de Pagamento
					cLinha += (cAliasTmp1)->A1_CGC                                        // CNPJ do Cliente 
					cLinha += CRLF   
					FGravaTxt(cLinha)

					aCargas[P_CONDCLI, P_TOT_PROC]++

					(cAliasTmp1)->(DbSkip())

				EndDo

			EndIf

			(cAliasTmp1)->(DbCloseArea()) 
			(cAliasTmp)->(DbSkip())

		EndDo 

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
CrgCartCli

Autor:
Tiago Bandeira Brasiliano

Data:
04/04/2016

Descrição:
Efetua a carga dos dados de carteira de clientes para o IMS 
(Carga_Carteira_Clientes.txt).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CrgCartCli()

	Local cArqTxt   := cPastaFerr + aCargas[P_CARTCLI, P_NOME_ARQ]
	Local cAliasTmp := GetNextAlias()
	Local cLinha    := ""
	Local cVendAnt  := "%$%$%$"

	nHdl := FCreate(cArqTxt)

	If nHdl == -1
		//Conout("O arquivo de nome " + cArqTxt + " não pode ser executado! Verifique os parâmetros.")
		Return .F.
	EndIf

	//Conout("Aguarde, Consultando Carga_Carteira_Clientes...")

	aCargas[P_CARTCLI, P_TOT_PROC] := 0

	BEGINSQL ALIAS cAliasTmp

		%NoParser%

		SELECT
		A1_FILIAL,
		A1_VEND,
		A3_NOME,
		A1_COD,
		A1_LOJA,
		A1_GRPVEN,
		A1_MSBLQL,
		ACY_DESCRI
		FROM %Table:SA1% SA1
		INNER JOIN %Table:SA3% SA3
		ON SA3.%NotDel%
		AND A3_FILIAL = %xFilial:SA3%
		AND A3_COD = A1_VEND
		INNER JOIN %Table:ACY% ACY
		ON ACY.%NotDel%
		AND ACY_FILIAL = %xFilial:ACY%
		AND ACY_GRPVEN = A1_GRPVEN
		WHERE
		SA1.%NotDel%
		ORDER BY
		A1_FILIAL,
		A1_VEND,
		A1_COD,
		A1_LOJA

	ENDSQL

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(EoF()) 

		//+------------------------------------------+
		//| Cabeçalho do Arquivo = 0                 |
		//+------------------------------------------+
		cLinha := "0"            // TP_REGISTRO
		cLinha += "CARTECLI"     // ID_ARQUIVO
		cLinha += FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]    // CNPJ_GESTOR
		cLinha += "0003"         // CD_MKT
		cLinha += CRLF
		FGravaTxt(cLinha)

		// Leitura das Condições de Pagamentos   
		While !(cAliasTmp)->(EoF())

			If (cAliasTmp)->A1_VEND <> cVendAnt

				cVendAnt := (cAliasTmp)->A1_VEND

				aCargas[P_CARTCLI, P_ARQ_PROC] := .T.

				//+------------------------------------------+
				//| Registro de Corpo = 1                    |
				//+------------------------------------------+
				cLinha := "1"                                                       // TP_REGISTRO    
				cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_VEND), 1, 020), 020)  // CD_CARTEIRA
				cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A3_NOME), 1, 060), 060)  // NM_CARTEIRA
				cLinha += "S"                                                       // ATIVO ("S"/"N")
				cLinha += CRLF   
				FGravaTxt(cLinha)

			EndIf

			//+------------------------------------------+
			//| Registro Detalhe do Cliente = 2          |
			//+------------------------------------------+
			cLinha := "2"                                                                             // TP_REGISTRO    
			cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_COD + (cAliasTmp)->A1_LOJA), 1, 020), 020)  // CD_CLIENTE
			cLinha += Iif((cAliasTmp)->A1_MSBLQL == "1", "N", "S")                                    // ATIVO ("S"/"N") 
			cLinha += CRLF   
			FGravaTxt(cLinha)

			//+------------------------------------------+
			//| Registro Detalhe Condição Comercial = 3  |
			//| Este tipo de registro foi removido da    |
			//| carga segundo orientação do Leonado da   |
			//| IMS (que nos disse que a Ferring não     |
			//| utiliza estas informações).              |
			//+------------------------------------------+
			//cLinha := "3"                                                         // TP_REGISTRO    
			//cLinha += PadR(SubStr(AllTrim((cAliasTmp)->A1_GRPVEN), 1, 020), 020)  // CD_COND_COMERCIAL
			//cLinha += "S"                                                         // ATIVO ("S"/"N")
			//cLinha += CRLF   
			//FGravaTxt(cLinha)

			aCargas[P_CARTCLI, P_TOT_PROC]++

			(cAliasTmp)->(DbSkip())

		EndDo 

	EndIf

	(cAliasTmp)->(DbCloseArea()) 
	FClose(nHdl)

Return .T.


/**************************************************************************************************
Função:
FGravaTxt

Autor:
Juscelino Alves dos Santos

Descrição:
Efetua a gravação de uma string em um arquivo de texto.

Parâmetros:
cLinha => String contendo os dados que serão gravados no arquivo.

Retorno:
lRet => .T. caso a gravação tenha ocorrido com sucesso e .F. caso contrário.
**************************************************************************************************/
Static Function FGravaTxt(cLinha)

	Local lRet := .T.

	If FWrite(nHdl, cLinha, Len(cLinha)) != Len(cLinha)
		//Conout("Ocorreu um erro na gravacao do arquivo")
		lRet := .F.
	EndIf

Return lRet


/**************************************************************************************************
Função:
Num2Str

Autor:
Tiago Bandeira Brasiliano

Data:
21/07/2015

Descrição:
Converte uma String numérica do formato do Protheus para uma string em um formato aceito de
acordo com os padrões de integração da IMS (removendo a vírgula ou o ponto decimal).

Parâmetros:
cValEnt => String contendo o valor que será convertido. Exemplo: 192.75
nTamFin => Tamanho final da string (será preenchido com zeros a esquerda para atingir este
tamanho (por default será mantido o tamanho da própria string).
Retorno:
cRetorno => String já convertida para o formato de integração. Exemplo: 019275
**************************************************************************************************/
Static Function Num2Str(cValEnt, nTamFin)

	Local cRetorno  := ""

	Default cValEnt := ""
	Default nTamFin := Len(cValEnt)

	cRetorno := RemPontos(cValEnt)
	cRetorno := Replicate("0", nTamFin - Len(cRetorno)) + cRetorno

Return cRetorno


/**************************************************************************************************
Função:
RemPontos

Autor:
Tiago Bandeira Brasiliano

Data:
21/07/2015

Descrição:
Remove pontuação de uma string (".", "," e " ").

Parâmetros:
cVarEnt  => String de entrada que terá a pontuação removida.

Retorno:
cRetorno => String de retorno já convertida, ou seja, sem a pontuação.
**************************************************************************************************/
Static Function RemPontos(cVarEnt)

	Local cRetorno := StrTran(StrTran(StrTran(cVarEnt, " ", ""), ",", ""), ".", "")

Return cRetorno


/**************************************************************************************************
Função:
CargaFTP

Autor:
Juscelino Alves dos Santos

Descrição:
Efetua a carga dos arquivos processados para o FTP de Integração.
Estes arquivos gravados no FTP serão futuramente lidos pelo sistema IMS para gerar as
informações em sua base de dados.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function CargaFTP()

	Local nTentativa := 0
	Local cURLFTP    := GetMV("ES_IMSFTP" , , "162.44.221.132") // Endereço do FTP 
	Local cUserFTP   := GetMV("ES_IMSUSER", , "ImsFer")         // Usuario do FTP (Ambiente de Teste: ImsFer_t)
	Local cPassFTP   := GetMV("ES_IMSPSW" , , "F39j23")         // Senha do FTP (Ambiente de Teste: K63v54)
	Local cDirFTPIMS := "/Cargas_NFs/"                          // Pasta da IMS no FTP para enviar os ARQUIVOS
	Local cPathRaiz  := ""
local nX
	FTPDisconnect()

	//Faz a conexao com o FTP
	While nTentativa <= 5

		If FTPConnect(cURLFTP, , cUserFTP, cPassFTP) 
			Exit
		EndIf      

		nTentativa++

		If nTentativa > 5
			//Conout("Atenção, não foi possível efetuar a conexão com o servidor FTP da IMS. Verifique os parâmetros ES_IMSFTP, ES_IMSUSER e ES_IMSPSW com as informações de acesso.")
			Return .F.
		EndIf

	EndDo   

	//Acessa o diretorio de envio
	cPathRaiz  := FTPGETCURDIR()
	cDirFTPIMS := cPathRaiz + cDirFTPIMS
	FTPDirChange(cDirFTPIMS)
	
	//msgalert("efetuando upload")

	For nX := 1 To Len(aCargas)
		lErrEmv := .F.
		_cTPIOper := ""
		cNOP := ""

		If aCargas[nX, P_ARQ_PROC]

			If !FTPUpLoad(cPastaFerr + aCargas[nX, P_NOME_ARQ], cDirFTPIMS + aCargas[nX, P_NOME_ARQ])
              //  msgalert("erro no upload")
				lErrEmv := .T.
				_cTPIOper := "IQT"
				cNOP := "2"
				//Conout("Não consegui Enviar a " + aCargas[nX, P_NOME_ARQ])
				aCargas[nX, P_ENVIO_OK] := .F.
				// Roberto - ERP Plus - 04/02
				// Transfere arquivos para pasta de não enviados
				_cFileOri := cPastaFerr + aCargas[nX, P_NOME_ARQ]
				_cFileNew := cPstErrEnv + aCargas[nX, P_NOME_ARQ]

				FRename(_cFileOri,_cFileNew)
				//ferase(_cFileNew)


			Else
			 //  msgalert("Conseguiu fazer upload")

				lErrEmv := .F.
				_cTPIOper := "IQV"
				cNOP := "1"
				//Conout(aCargas[nX, P_NOME_ARQ] + " enviada com sucesso!")
				aCargas[nX, P_ENVIO_OK] := .T.

			EndIf    

			// Roberto - ERP Plus - 04/02
			// Grava o log quando houver erro na carga do arquivo
			// Transfere arquivos para pasta de não enviados
			_cDescOper := U_DescOper(_cTPIOper)
			//u_FEGrvZZD("",8,_cTPIOper,"","2", .F.,_cTPIOper) 
			u_FEGrvZZD(aCargas[nX, P_NOME_ARQ],8,_cTPIOper,"",cNOP, .F.,_cTPIOper) 

		EndIf   

	Next nX

Return .T.


/**************************************************************************************************
Função:
SendMailIMS

Autor:
Juscelino Alves dos Santos

Descrição:
Rotina de envio de e-mail contendo os arquivos enviados para o FTP e também os status.
Utilizada apenas para auxiliar os testes. Após os testes o parâmetros de e-mail deverá ser deixado
em branco para que a função não fique enviando as cargas para os usuários.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function SendMailIMS(lErrocrg)

	Local cEmailResp := AllTrim(GetMv("ES_IMSRESP", , ""))   // Criar PRAMETRO com os E-MAILS que irão receber o Relatorio.
	Local cSenha     := AllTrim(GetMV("MV_RELPSW" ))
	Local cMailServ  := AllTrim(GetMV("MV_RELSERV"))
	Local cConta     := AllTrim(GetMV("MV_RELACNT"))
	Local cContaAuth := AllTrim(GETMV("MV_RELFROM", , ""))
	Local cDe        := cContaAuth
	Local cPara      := ""
	Local cAssunto   := ""                                                                                                                                                            
	Local cAnexo     := ""                     
	Local cCorpo     := "<HTML><Body><Table Aling=Left border=0>"
	Local cMailError := ""
	Local nX         := 0
	Local lConectou  := .F.                                                                                                                                                                        
	Local lEnviado   := .F.
    Local oServer  
Local oMessage
Local nErr      	:= 0
Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local cSMTPAddr 	:= GetNewPar("MV_RELSERV","")	// ENDERECO SMTP
Local cUserId     	:= GetNewPar("MV_RELAUSR","")	// USUARIO PARA AUTENTICACAO SMTP
Local cPass     	:= GetNewPar("MV_RELAPSW","")	// SENHA PARA AUTENTICA SMTP
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO                                                   
Local lSSL 			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local cFrom 		:= GetNewPar("MV_RELFROM","") 	// EMAIL REMENTE DOS ALERTAS
local  _nZ

	//cPara    := cEmailResp 
	cPara    := u_RetMailTo("IQT")
    // Roberto - ERP Plus - 04/02
	// Efetua a tratavida do corpo do e-mail de acordo com retorno do Upload
	For _nZ := 1 To Len(aCargas)
		cAnexo := ""
		cCorpo := ""
	   // msgalert("email ok ")
		If aCargas[_nZ, P_ENVIO_OK]
			cAnexo := cPastaFerr + aCargas[_nZ, P_NOME_ARQ] + Iif(_nZ < Len(aCargas), ",", "") 
			cCorpo := "<TR><TD> " + aCargas[_nZ, P_DESC_ARQ] + " : " + AllTrim(Str(aCargas[_nZ, P_TOT_PROC])) + "</TD></TR>"
			cAssunto := "Relatorio de Acompanhamento dos Arquivos IMS X PROTHEUS"
		Else
			// Arquivos com erros  
		//	msgalert("email erro")
			cAnexo := cPastaFerr + aCargas[_nZ, P_NOME_ARQ] + Iif(_nZ < Len(aCargas), ",", "") 
			cCorpo  := "<TR><TD> " + aCargas[_nZ, P_DESC_ARQ] + " : " + AllTrim(Str(aCargas[_nZ, P_TOT_PROC])) + "</TD></TR>"
			cAssunto := "Arquivos IMS X PROTHEUS - Erro na carga de arquivos"
		EndIf    

		//Next nX

		//if lErrocrg       
		//		cAssunto := "Relatorio de Acompanhamento dos Arquivos IMS X PROTHEUS"
		//Else
		//cAssunto := "Arquivos IMS X PROTHEUS - Erro na carga de arquivos"
		//Endif

		cCorpo	 +=	"</TABLE></BODY></HTML>"      

		// Tempo apos a conexão
		//Conout("TEMPORIZANDO O PROCESSAMENTO NO SERVIDOR - INICIO ")
		For nX := 1 to 500
		Next nX

		//Conout("TEMPORIZANDO O PROCESSAMENTO NO SERVIDOR - FINAL ") 
        // Objeto de Email
        oServer := tMailManager():New()

        // Usa SSL, TLS ou nenhum na inicializacao
        If lSSL
            oServer:SetUseSSL(lSSL)		
        ElseIf lTLS
            oServer:SetUseTLS(lTLS)	
        Endif

		While !lConectou

		//	CONNECT SMTP SERVER cMailServ ACCOUNT cConta PASSWORD cSenha RESULT lConectou
            nErr := oServer:init("",cMailServ,cConta,cSenha,,nSMTPPort)
            If nErr <> 0	
                //alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar: 	
            else
                lConectou:=.t.    
            Endif
			nX++

			If nX > 9
				Exit
			EndIf

		EndDo

		If lConectou
			//Conout("conectou no servidor") 
		Else
			//Conout("não conectou no servidor")
		EndIf

        
        If oServer:SetSMTPTimeout(nSMTPTime) != 0
           // alert("Falha ao definir timeout") // Falha ao definir timeout
           // Return(.F.)
        EndIf

        
        nErr := oServer:smtpConnect()
        If nErr <> 0	
           // alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar:		
            oServer:SMTPDisconnect()
           // Return(.F.)
        EndIf

                
        // Realiza autenticacao no servidor
        If lAutentica
            nErr := oServer:smtpAuth(cConta, cSenha)
            If nErr <> 0		
                //alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
                oServer:SMTPDisconnect() 
            EndIf
        EndIf
                    // Cria uma nova mensagem (TMailMessage)
            oMessage := tMailMessage():new()
            oMessage:clear()        
            cMensagem :=cCorpo
                        // Dados da mensagem		
            oMessage:cFrom		:= cDe  
            oMessage:cBCC     	:=  cUser 
            oMessage:cTo     	:=  cPara 
            oMessage:cSubject	:= AllTrim(cAssunto)
            oMessage:cBody   	:= cMensagem
            if !Empty(cAnexo)
            oMessage:AttachFile(cAnexo ) 					
            EndIf          

            nErr := oMessage:send(oServer)
            If nErr <> 0		
               // alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
                oServer:SMTPDisconnect() 
            EndIf

            // Desconecta do Servidor
            oServer:smtpDisconnect() 
             Sleep( 1000 ) // Para o processamento por 1 segundo
 /*
		nX  := 0                            

		While !lEnviado   

			If !Empty(cAnexo)

				//Conout("ENVIO DE E-MAIL COM ANEXO")

				SEND MAIL FROM AllTrim(cDe);
				TO AllTrim(cPara);
				SUBJECT AllTrim(cAssunto);
				BODY cCorpo FORMAT TEXT;
				ATTACHMENT cAnexo;
				RESULT lEnviado

				If !(lEnviado)

					GET MAIL ERROR cMailError  
					//Conout("ERROR : " + cMailError)

				EndIf           

			Else 

				//Conout("ENVIO DE E-MAIL SEM ANEXO")

				SEND MAIL FROM AllTrim(cDe);                                          
				TO AllTrim(cPara);
				SUBJECT	AllTrim(cAssunto);
				BODY cCorpo FORMAT TEXT;
				RESULT lEnviado

				If !(lEnviado)

					GET MAIL ERROR cMailError  
					//Conout("ERROR : " + cMailError)

				EndIf

			EndIf

			nX++

			If nX > 2     
				Exit
			EndIf

		EndDo                                                                   

		DISCONNECT SMTP SERVER

		//Conout("TEMPORIZANDO")

		// Tempo apos a conexão
		For _t:=1 to 500
		Next _t
		//Conout("FIM DA TEMPORIZAÇÃO")

		DISCONNECT SMTP SERVER

		If lConectou .And. lEnviado
			//Conout("E-mail Enviado com Sucesso!")
		Else
			//Conout("E-mail nao foi Enviado. Contate o Administrador da Rede.")
		EndIf     
         */
// Zera a variaval para novo envio
lEnviado := .F.
lConectou := .F.

Next _nZ

Return .T.


USER FUNCTION IMSENVIO()
	U_CargaERPtoIMS({.T., "01", "08", "000000"})
	REUTNR
