#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE BOLD .T.


/**************************************************************************************************
Função:
FeRank

Autor:
Tiago Bandeira Brasiliano

Data:
31/05/2016

Descrição:
Novo Relatório de Ranking de Vendas por Produto e Cliente, exibindo Nota por Nota.
Este relatório foi totalmente baseado no fonte anterior, porém utilizando a nova classe para
impressão de relatório em Excel e também reorganizando as funções (onde foram removidas as 
duplicidades de informações por exemplo).

Alterado por: Marcelo Klopfer Leme
Em: 24/08/2016
Alteração: Conforme solicitação da Ferring México, será criada uma nova rotina
que será startada via JOB, e chamará o fonte do RANKING.
Após a geração o arquivo gerado não mais será apresentado na tela, e sim gravado em um diretório pré-determinado.
Fonte Auxiliar: JOBRANK.PRW
Função Auxiliar: U_JOBRANK()
Parâmetros Auxiliares:
MV_JOBRANK - C - 100 - Diretório onde deverá ser gravado o arquivo gerado.

Parâmetros:
lJob      => Indica se relatório está sendo executado via Job (.T.) ou não (.F.). Default = .F.
cDir      => Diretório onde o relatório será gerado. Padrão = C:\Temp
lDirLocal => Indica se o diretório onde o progrma será gerado é local ou do server.

Retorno:
Nenhum
**************************************************************************************************/
User Function FeRank(lJob, cDir, lDirLocal)

Local cPerg       := "FRFAT003"

Default lJob      := .F.
Default cDir      := "C:\TEMP\"
Default lDirLocal := .T.

If !lJob
	
	If Pergunte(cPerg, .T.)
		Processa({|| ImprimeRanking(lJob, cDir, lDirLocal) } )
	EndIf

Else
	
	Pergunte(cPerg,.F.)
	MV_PAR01 := FIRSTDATE(DATE()) // Data Inicial
	MV_PAR02 := DATE()            // Data Final
	MV_PAR03 := SPACE(15)         // Do Produto
	MV_PAR04 := REPLICATE("Z",15) // Ate o Produto
	MV_PAR05 := SPACE(06)         // Do Cliente
	MV_PAR06 := REPLICATE("Z",06) // Ate o Cliente
	MV_PAR07 := SPACE(99)         // Tipos Cli.(Branco=Todos)
	MV_PAR08 := SPACE(99)         // Regiao(s) (Branco=Todos)
	MV_PAR09 := SPACE(06)         // Do Vendedor
	MV_PAR10 := REPLICATE("Z",06) // Ate o Vendedor
	MV_PAR11 := SPACE(99)         // UF(s) (Branco=Todos)
	MV_PAR12 := 1                 // Gera Duplicata
	MV_PAR13 := 1                 // Movimenta Estoque
	MV_PAR14 := 3                 // Apenas Devolucoes
	MV_PAR15 := SPACE(99)         // TES (Branco=Todos)
	MV_PAR16 := "01"              // De Filial
	MV_PAR17 := "05"              // Ate Filial
	Processa({|| ImprimeRanking(lJob, cDir, lDirLocal) } )

EndIf

Return .T.


/**************************************************************************************************
Função:
ImprimeRanking

Autor:
Tiago Bandeira Brasiliano

Data:
31/05/2016

Descrição:
Contém toda a lógica para a impressão do relatório do Ranking de Vendas.

Parâmetros:
lJob      => Indica se a função está sendo executada via job.
cDir      => Determina o diretório de impressão do arquivo.
lDirLocal => Indica se o diretório onde o progrma será gerado é local ou do server.

Retorno:
Nenhum
**************************************************************************************************/
Static Function ImprimeRanking(lJob, cDir, lDirLocal)

Local cFileName   := cDir + "RANKING_1_" + DToS(MV_PAR01) + "_" + DToS(MV_PAR02) + ".XML"

Private oXML      := ExcelXML():New()
Private oS01      := Nil
Private oS02      := Nil
Private oS03      := Nil
Private oS04      := Nil
Private oS05      := Nil
Private oS06      := Nil
Private oS07      := Nil
Private oS08      := Nil
Private oS09      := Nil
Private oS10      := Nil
Private oS11      := Nil
Private nFldCount := 0
Private lDebug    := .T.

//+----------------------------------------------------------------------+
//| Define os estilos que serão utilizados para as células               |
//+----------------------------------------------------------------------+
oS01 := CellStyle():New("oS01")
oS01:SetNumberFormat("#,##0")
oS01:SetHAlign("Right")

oS02 := CellStyle():New("oS02")
oS02:SetNumberFormat("#,##0")
oS02:SetHAlign("Left")

oS03 := CellStyle():New("oS03")
oS03:SetNumberFormat("_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-")
oS03:SetHAlign("Left")

oS04 := CellStyle():New("oS04")
oS04:SetFont("Calibri", 11, "#000000", ,)
oS04:SetNumberFormat("_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-")
oS04:SetHAlign("Left")

oS05 := CellStyle():New("oS05")
oS05:SetInterior("#538DD5", "Solid")
oS05:SetHAlign("Left")

oS06 := CellStyle():New("oS06")
oS06:SetInterior("#538DD5", "Solid")
oS06:SetNumberFormat("_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-")
oS06:SetHAlign("Left")

oS07 := CellStyle():New("oS07")
oS07:SetInterior("#538DD5", "Solid")
oS07:SetNumberFormat("_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-")
oS07:SetHAlign("Left")

oS08 := CellStyle():New("oS08")
oS08:SetFont("Calibri", 11, , BOLD)
oS08:SetHAlign("Left")

oS09 := CellStyle():New("oS09")
oS09:SetInterior("#E7E6E6", "Solid")
oS09:SetFont("Calibri", 11, , BOLD)
oS09:SetHAlign("Left")

oS10 := CellStyle():New("oS10")
oS10:SetNumberFormat("#,##0_ ;\-#,##0\ ")
oS10:SetHAlign("Right")

oS11 := CellStyle():New("oS11")
oS11:SetNumberFormat("_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-")
oS11:SetHAlign("Right")

//+----------------------------------------------------------------------+
//| Gera os folders do relatório                                         |
//+----------------------------------------------------------------------+
If MV_PAR14 <> 1 // Sem devoluções ou ambas
	FldVendaEDev("VENDA")
EndIf

If MV_PAR14 <> 2 // Sem devoluções ou ambas
	FldVendaEDev("DEVOL")
EndIf

FldVendaEDev("AMBAS")

FldProXCli()

FldCliente()

FldProduto()

FldTipoProd()

FldTPSales()

FldAnaTPSales()

FldCMED()

//+----------------------------------------------------------------------+
//| Gera a string contendo o código xml                                  |
//+----------------------------------------------------------------------+
oXML:GetXML(cFileName, lDirLocal)

/*****************
Alterado por Marcelo Klopfer Leme - 24/08/2016
Verifica quem está chamando a rotina.
*****************/
If !lJob
	MsgAlert("Foi gerada uma cópia do relatório na planilha " + cFileName)
EndIf

Return .T.


/**************************************************************************************************
Função:
FldVendaEDev

Autor:
Tiago Bandeira Brasiliano

Data:
31/05/2016

Descrição:
Função utilizada para criar tanto o folder contendo a relação das notas fiscais sem devolução, ou
seja, a relaçao de vendas quanto o folder contendo apenas as notas fiscais de devoluções.
Qual folder será gerado é definido pelo parâmetro cTipo.

Parâmetros:
cTipo => Indica qual o folder que será criado, podendo ser:
         "VENDA" = Cria o folder contendo os dados de vendas.
         "DEVOL" = Cria o folder contendo os dados de devoluções.
         "AMBAS" = Cria o folder contendo os dados de vendas e devoluções juntas.
**************************************************************************************************/
Static Function FldVendaEDev(cTipo)

Local nTotReg    := 0
//Local bQuery     := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.) , dbSelectArea("TMP_REL"), TMP_REL->(dbGoTop())}
Local cQuery     := ""
Local cMsg       := ""
Local cTitulo    := ""
Local cFldName   := ""
Local nFator     := 1
Local cProdCap   := AllTrim(GetNewPar("ES_PRODCAP", "50.001.001|50.002.001|50.002.003|50.002.006|50.009.001|"))
Local aProdCAP   := StrToKArr(cProdCap, "|")
Local nVlrSemRep := 0
Local nVlrCap    := 0
Local nVlrCom    := 0
	
If cTipo == "VENDA"
	cQuery   := QryVendas()
	cMsg     := "Consultando Vendas..."
	cFldName := "Rel Notas Fiscais Sem Devol"
	cTitulo  := "VENDAS - PERIODO: "
ElseIf cTipo == "DEVOL"
	cQuery   := QryDevolucoes()
	cMsg     := "Consultando Devoluções..."
	cFldName := "Relacao de Devolucoes"
	cTitulo  := "DEVOLUÇÕES - PERIODO: "
Else
	cQuery   := QryVendas(.T.)
	cQuery   += "UNION ALL " + CRLF
	cQuery   += QryDevolucoes(.T.)
	cQuery   += " ORDER BY DOC, SERIE, CODPROD "
	cMsg     := "Consultando Vendas Subtraídas as Devoluções..."
	cFldName := "Vendas Subtraídas as Devolucoes"
	cTitulo  := "VENDAS SUBTRAÍDAS AS DEVOLUÇÕES - PERIODO: "
EndIf


Iif(lDebug, Memowrite("C:\Temp\FRFAT003_" + cTipo + ".sql", cQuery), Nil)
//LjMsgRun(cMsg, "Aguarde...", bQuery)
If Select("TMP_REL") > 0
 TMP_REL->(dbCloseArea())
EndIf 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.)
dbSelectArea("TMP_REL")
TMP_REL->(dbGoTop())


oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A     B      C      D      E     F     G      H      I      J     K     L     M     N     O     P     Q     R     S     T      U     V     W      X      Y      Z      AA     AB     AC     AD     AE     AF     AG     AH     AI     AJ     AK     AL     AM     AN     AO     AP     AQ     AR     AS     AT     AU     AV     AW     AX     AY     AZ     BA     BB     BC     BD     BE     BF     BG     BH     BI     BJ     BK     BL     BM     BN     BO
//               1     2      3      4      5     6     7      8      9      10    11    12    13    14    15    16    17    18    19    20     21    22    23     24     25     26     27     28     29     30     31     32     33     34     35     36     37     38     39     40     41     42     43     44     45     46     47     48     49     50     51     52     53     54     55     56     57     58     59     60     61     62     63     64     65     66     67
oXML:SetColSize({"90", "355", "110", "130", "30", "50", "130", "130", "130", "75", "90", "30", "80", "70", "80", "70", "65", "60", "70", "240", "75", "75", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "120" })

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{cTitulo + DToC(MV_PAR01)+ " - " + DToC(MV_PAR02)}, oS05)
oXML:AddRow(,{"Código do Cliente", "Nome do Cliente", "Cnpj do Cliente", "Cidade", "UF", "DP Code", "DP Name", "Tipo do Cliente", "Número do Pedido", "Pedido Cliente", "Pedido IMS", "Tipo da Venda", "Data de Faturamento", "Número da Nota Fiscal", "Data da Efetivação da Devolução", "Número da NF de Devolução", "CFOP", "Código Produto", "Item Number", "Descricao Produto ", "Lote ", "Valid. Lote", "Quantidade", "% ICMS", "PMC", "Preço Fabrica", "Valor Total Mercadoria", "% Descontos Ped.", "Valores de Desc. Ped.", "% Repasse", "Valor Repasse", "Convênio", "Total Desconto NF", "Base ICMS", "Valor ICMS", "PIS", "COFINS", "DIFAL UF emitente", "DIFAL UF destinatário", "% DIFAL UF Origem", "% DIFAL UF Destinatário", "Base DIFAL destinatário", "Fundo Comb. Pobreza", "Aliq. ICMS complementar", "Valor Nota Fiscal", "Base Solidário", "Valor Solidário", "IPI", "Valor Unitário Líquido", "Valor Líquido Total", "Data Consolidada", "Motivo de Devolução", "Código EAN", "Código GGREM", "Emissão do Lote", "Percentual de Convênio", "Percentual de CAP", "Valor de CAP", "% Desc. Comercial", "Valor Desc. Comercial", "% Desc. Pregão", "Valor Desc. Pregão", "% Reajuste", "Valor Reajuste", "% Desc Total - % CAP", "'Valor Desc Total – Valor de CAP'", "Condição de Pagamento"}, oS06)

Count to nTotReg

TMP_REL->(DbGoTop())

While !TMP_REL->(Eof())
	
	nFator := Iif(cTipo == "AMBAS", TMP_REL->FATOR, 1)
	
	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os dados                                        |
	//+----------------------------------------------------------------------+
	oXML:AddRow(,{TMP_REL->CLIENTE + TMP_REL->LOJA,;                                      // 01 - Codigo do Cliente
	              TMP_REL->NOME,;                                                         // 02 - Nome do Cliente
	              Transform(TMP_REL->CGC, "@R 99.999.999/9999-99"),;                      // 03 - CNPJ do Cliente
	              TMP_REL->MUN,;                                                          // 04 - Mun
	              TMP_REL->EST,;                                                          // 05 - UF
	              TMP_REL->BPCODE,;                                                       // 06 - DP Code
	              TMP_REL->BPNAME,;                                                       // 07 - DP Name
	              TMP_REL->TIPO,;                                                         // 08 - Tipo do Cliente
	              TMP_REL->PEDIDO,;                                                       // 09 - Numero do Pedido
	              TMP_REL->PEDIDO_CLIENTE,;                                               // 10 - Pedido Clinte
	              TMP_REL->PEDIDO_IMS,;                                                   // 11 - Pedido IMS
	              Iif(TMP_REL->DCL == "S", "MP", TMP_REL->TIPO),;                         // 12 - Tipo da Venda
	              Iif(TMP_REL->FATOR = 1, DtoC(StoD(TMP_REL->EMISSAO)),;
	                                      DtoC(StoD(TMP_REL->DATAORI))),;                 // 13 - Data Faturamento (ou data da digitação da nota fiscal de origem para as devoluções)
	              Iif(TMP_REL->FATOR = 1, TMP_REL->DOC,;
	                                      TMP_REL->NFORI),;                               // 14 - Numero da Nota Fiscal (ou número da nota fiscal de origem para as devoluções)
	              Iif(TMP_REL->FATOR = 1, DtoC(StoD(TMP_REL->DATAORI)),;
	                                      DtoC(StoD(TMP_REL->EMISSAO))),;                 // 15 - Data da Efetivação da Devolução (data da digitação da nota de devolução no sistema)
	              Iif(TMP_REL->FATOR = 1, TMP_REL->NFORI,;
	                                      TMP_REL->DOC),;                                 // 16 - Número da NF de Devolução
	              TMP_REL->CF,;                                                           // 17 - CFOP
	              TMP_REL->CODPROD,;                                                      // 18 - Código Produto
	              TMP_REL->XITNUMB,;                                                      // 19 - Item Number
	              TMP_REL->DESCRI,;                                                       // 20 - Produto Descricao
	              TMP_REL->LOTE,;                                                         // 21 - Número do Lote
	              DtoC(StoD(TMP_REL->VALIDADE_LOTE)),;                                    // 22 - Validade Lote
	              TMP_REL->QUANT * nFator,;                                               // 23 - Quantidade
	              TMP_REL->PICM,;                                                         // 24 - ICMS
	              TMP_REL->PMC,;                                                          // 25 - PMC
	              TMP_REL->PRUNIT,;                                                       // 26 - Preco Fabrica
	              TMP_REL->VAL_TOTAL_LISTA * nFator,;                                     // 27 - Valor Total Mercadoria
	              TMP_REL->PERC_DESC_PEDIDO,;                                             // 28 - % Descontos Pedido
	              TMP_REL->VAL_DESC_PEDIDO * nFator,;                                     // 29 - Valores de Desc. Ped. (Desconto Comercial + Desconto Pregão). Ou seja: O desconto da NF - Convênio - Repasse - CAP
	              TMP_REL->PER_REP,;                                                      // 30 - % Repasse
	              TMP_REL->VAL_REP * nFator,;                                             // 31 - Valor Repasse
	              TMP_REL->VAL_CON * nFator,;                                             // 32 - Valor Convenio
	              TMP_REL->VAL_DESC_NF * nFator,;                                         // 33 - Total Desconto NF (Obtido da SD2: D2_DESCON).  - 2a Opção: (((TMP_REL->VAL_TOTAL_LISTA - (TMP_REL->VAL_REP)) * (TMP_REL->PERC_DESC_PEDIDO / 100)) + (TMP_REL->VAL_REP) + (TMP_REL->VAL_CON)) * nFator,;   // 33 - Total Desconto NF Cálculado. A pedido da Vivian foi efetuado este cálculo. Porém foi retornado a leitura diretamente da NF.
	              TMP_REL->BASEICM * nFator,;                                             // 34 - Base Icms
	              TMP_REL->VALICM * nFator,;                                              // 35 - Valor Icms
	              TMP_REL->PIS * nFator,;                                                 // 36 - Pis
	              TMP_REL->COFINS * nFator,;                                              // 37 - Cofins
	              TMP_REL->ICMSCOM * nFator,;                                             // 38 - Valor do ICMS complementar UF emitente
	              TMP_REL->DIFAL * nFator,;                                               // 39 - Valor do ICMS complementar UF destinatário
	              TMP_REL->PDORI,;                                                        // 40 - Percentual do DIFAL UF Origem
	              TMP_REL->PDDES,;                                                        // 41 - Percentual do Difal UF Destinatário
	              TMP_REL->BASEDES * nFator,;                                             // 42 - Base DIFAL destinatário
	              TMP_REL->FCP * nFator,;                                                 // 43 - Fundo de Combate a Pobreza (FCP)
	              TMP_REL->ALIQCMP,;                                                      // 44 - Aliq. ICMS complementar
	              TMP_REL->VALBRUT * nFator,;                                             // 45 - Valor da Nota Fiscal
	              TMP_REL->BASE_SOL * nFator,;                                            // 46 - Base Solidario
	              TMP_REL->ICMSRET * nFator,;                                             // 47 - Valor Solidario
	              TMP_REL->VALIPI * nFator,;                                              // 48 - Ipi
	              TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS / TMP_REL->QUANT * nFator,;         // 49 - Valor Liquido Unitario (Descontado os impostos)
	              TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS * nFator,;                          // 50 - Valor Liquido Total (Descontado os impostos)
	              DtoC(StoD(TMP_REL->DT_CONSOL)),;                                        // 51 - Data Consolidada (para as notas de vendas, será a data de emissão. Já para as devoluções, será a digitação do retorno)
	              TMP_REL->HISTDEV,;                                                      // 52 - Motivo da Devolução
	              TMP_REL->CODBAR,;                                                       // 53 - Código EAN
	              TMP_REL->CDGGREM,;                                                      // 54 - Código GGREM
	              DtoC(StoD(TMP_REL->FABRIC_LOTE)),;                                      // 55 - Emissão do Lote
	              TMP_REL->PER_CON,;                                                      // 56 - Percentual de Convênio
	              TMP_REL->PER_CAP,;                                                      // 57 - Percentual de CAP
	              TMP_REL->VAL_CAP * nFator,;                                             // 58 - Valor de CAP
	              TMP_REL->PER_COM,;                                                      // 59 - Percentual Comercial
	              TMP_REL->VAL_COM * nFator,;                                             // 60 - Valor Desconto Comercial
	              TMP_REL->PER_PRE,;                                                      // 61 - Percentual Pregão
	              TMP_REL->VAL_PRE * nFator,;                                             // 62 - Valor Desconto Pregão
	              TMP_REL->PER_REA,;                                                      // 63 - Percentual de Reajuste (O Reajuste de Desconto, é um percentual aplicado para um produto, quando mesmo é faturado em um ano seguinte ao fechamento de um contrato, para garantir que o preço de venda seja o mesmo da época do pregão, mesmo que a tabela de preço seja alterada)
	              TMP_REL->VAL_REA * nFator,;                                             // 64 - Valor de Reajuste
	              TMP_REL->PERC_DES_NF - TMP_REL->PER_CAP,;                               // 65 - % Desc Total - % CAP
	              (TMP_REL->VAL_DESC_NF - TMP_REL->VAL_CAP) * nFator,;                    // 66 - Valor Desc Total – Valor de CAP // (TMP_REL->VAL_DESC_PEDIDO * nFator) - TMP_REL->XVLRCAP,;      // 61 - Valor Desc Total – Valor de CAP
	              Posicione("SE4", 1, xFilial("SE4") + TMP_REL->CONDPAG, "E4_DESCRI")},;  // 67 - Descrição da Condição de Pagamento do Pedido
	              {oS02, oS02, oS04, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS03, oS03, oS04, oS04, oS04, oS03, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS04, oS04, oS04, oS04, oS03, oS03, oS04, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS04, oS02, oS02, oS02, oS02, oS02, oS03, oS03, oS04, oS03, oS04, oS03, oS04, oS03, oS04, oS03, oS04, oS02})
	//             01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    41    42    43    44    45    46    47    48    49    50    51    52    53    54    55    56    57    58    59    60    61    62    63    64    65    66    67
	TMP_REL->(DbSkip())
	
EndDo

//+----------------------------------------------------------------------+
//| Adiciona a linha com os totais                                       |
//+----------------------------------------------------------------------+ 
nTotReg := Iif(nTotReg == 0, 1, nTotReg)             
oXML:AddRow( ,{"TOTAL GERAL",,,,,,,,,,,,,,,,,,,,,,;
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,,,;     // 23 - Quantidade
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 27 - Valor Total Mercadoria
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 29 - Valor Desconto
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 31 - Valor Repasse
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 32 - Convênio
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 33 - Total Desconto NF
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 34 - Base ICMS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 35 - Valor ICMS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 36 - PIS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 37 - COFINS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 38 - Valor do ICMS complementar UF emitente
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,,;      // 39 - Valor do ICMS complementar UF destinatário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 42 - Base DIFAL destinatário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 43 - Fundo de Combate a Pobreza (FCP)
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 45 - Valor Nota Fiscal
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 46 - Vlr.Líquido
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;        // 47 - Base Solidário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 48 - IPI
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,,,,,,,; // 50 - Valor Líquido Total
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 58 - Valor de CAP
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 60 - Valor Desc. Comercial
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 62 - Valor Desc. Pregão
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,;       // 64 - Valor Reajuste de Desconto
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",},;      // 66 - Valor Desc Total – Valor de CAP
               {oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS07, oS06, oS07, oS06, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07})
//              01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30    31    32    33    34    35    36    37    38    39    40    41    42    43    44    45    46    47    48    49    50    51    52    53    54    55    56    57    58    59    60    61    62    63    64    65    66    67
TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldProXCli

Autor:
Tiago Bandeira Brasiliano

Data:
31/05/2016

Descrição:
Função utilizada para criar o folder contendo as informações de Produtos x Clientes.
**************************************************************************************************/
Static Function FldProXCli()

Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.) , dbSelectArea("TMP_REL"), TMP_REL->(dbGoTop())}
Local cQuery     := ""
Local cMsg       := ""
Local cTitulo    := ""
Local cFldName   := ""
Local cProduto   := ""
Local lImpSubCab := .T.

cQuery   := QryProdCli("PROXCLI")
cMsg     := "Consultando Produtos x Clientes..."
cFldName := "Rk - Prod-Cli - Abatidas Devol."
cTitulo  := "RANKING POR PRODUTO/CLIENTE - PERIODO: "

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_PROXCLI.sql", cQuery), Nil)
LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A      B      C      D    E     F      G     H      I     J     K     L     M     N     O     P     Q     R     S     T     U     V     W     X     Y     Z     AA
//               1      2      3      4    5     6      7     8      9     10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27
oXML:SetColSize({"100", "360", "80", "70", "65", "150", "70", "100", "90", "90", "90", "90", "65", "90", "65", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90" })

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{cTitulo + DToC(MV_PAR01)+ " - " + DToC(MV_PAR02)}, oS05)
oXML:AddRow(,{"Código do Cliente", "Nome do Cliente", "Código Produto", "UF", "BP Code", "BP Name", "Tipo Cliente", "CNPJ", "Quantidade", "PMC", "Preço Fábrica", "Valor Total Mercadoria", "% Descontos Pedido", "Valores de Desc. Ped.", "% Repasse", "Valor Repasse", "Convênio", "Total Desconto NF", "Valor ICMS", "PIS", "COFINS", "Valor Nota Fiscal", "Base Solidário", "Valor Solidário", "IPI", "Valor Unitário Líquido", "Valor Líquido"}, oS06)

TMP_REL->(DbGoTop())

cProduto := TMP_REL->CODPROD

While !TMP_REL->(Eof())

	If lImpSubCab
		oXML:AddRow(,{"Nome Produto:", TMP_REL->DESCRI, "Item Number:", TMP_REL->XITNUMB}, oS06)
		lImpSubCab := .F.
	EndIf
	
	nTotReg++

	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os dados                                        |
	//+----------------------------------------------------------------------+
	oXML:AddRow(,{TMP_REL->CLIENTE + "-" + TMP_REL->LOJA,;                                           // 01 - Código do Cliente
			      TMP_REL->NOME,;                                                                    // 02 - Nome do Cliente
			      TMP_REL->CODPROD,;                                                                 // 03 - Produto
			      TMP_REL->EST,;                                                                     // 04 - Estado
			      TMP_REL->BPCODE,;                                                                  // 05 - BP Code
			      TMP_REL->BPNAME,;                                                                  // 06 - BP Name
			      TMP_REL->TIPO,;                                                                    // 07 - Tipo Cliente
			      Transform(TMP_REL->CGC, "@R 99.999.999/9999-99"),;                                 // 08 - CNPJ
			      TMP_REL->QUANT ,;                                                                  // 09 - Quantidade
			      TMP_REL->PMC,;                                                                     // 10 - PMC 
			      TMP_REL->PRUNIT,;                                                                  // 11 - Preco Fabrica
			      TMP_REL->VAL_TOTAL_LISTA,;                                                         // 12 - Valor Total Mercadoria
			      TMP_REL->PERC_DESC_PEDIDO,;                                                        // 13 - % Descontos Ped.
			      TMP_REL->VAL_DESC_PEDIDO,;                                                         // 14 - Valores de Desc. Pedido (Desconto Comercial + Desconto de Pregão)
			      TMP_REL->PER_REP,;                                                                 // 15 - % Repasse
			      TMP_REL->VAL_REP,;                                                                 // 16 - Valor Repasse
			      TMP_REL->VAL_CON,;                                                                 // 17 - Convênio
			      TMP_REL->VAL_DESC_NF,;                                                             // 18 - Total Desconto NF (Obtido da SD2: D2_DESCON).  - 2a Opção: (((TMP_REL->VAL_TOTAL_LISTA - (TMP_REL->VAL_REP)) * (TMP_REL->PERC_DESC_PEDIDO / 100)) + (TMP_REL->VAL_REP) + (TMP_REL->VAL_CON)) * nFator,;   // 33 - Total Desconto NF Cálculado. A pedido da Vivian foi efetuado este cálculo. Porém foi retornado a leitura diretamente da NF.
	              TMP_REL->VALICM,;                                                                  // 19 - Valor ICMS
			      TMP_REL->PIS,;                                                                     // 20 - Pis
			      TMP_REL->COFINS,;                                                                  // 21 - COFINS
			      TMP_REL->VALBRUT,;                                                                 // 22 - Valor Nota Fiscal
			      TMP_REL->BASE_SOL,;                                                                // 23 - Base Solidario
			      TMP_REL->ICMSRET,;                                                                 // 24 - Valor Solidario
			      TMP_REL->VALIPI,;                                                                  // 25 - IPI
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS / TMP_REL->QUANT,;                             // 26 - Valor Unitario Liquido (Sem Impostos)
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS},;                                             // 27 - Valor Liquido (Sem Impostos)
			      {oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS03, oS04, oS04, oS04, oS03, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS04})
	//             01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27
	TMP_REL->(DbSkip())
	
	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os totais                                       |
	//+----------------------------------------------------------------------+ 
	If TMP_REL->CODPROD <> cProduto .Or. TMP_REL->(EoF())
	
		lImpSubCab := .T.
		cProduto   := TMP_REL->CODPROD
	
		oXML:AddRow( ,{"TOTAL PRODUTO",,,,,,,,;
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,,;  // Quantidade
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Total Mercadoria
		               "=(RC[+1] / (RC[-1] - RC[3])) * 100",;                        // % Desconto
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Desconto
		               "=(RC[1] / RC[-3]) * 100",;                                   // % Repasse
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Repasse
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Convênio
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Total Desconto NF
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor ICMS
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // PIS
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // COFINS
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Nota Fiscal
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Base Solidário
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Solidário
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // IPI
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Unitário Líquido (Sem Impostos)
		               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)"},;   // Valor Líquido Total (Sem Impostos)
		               {oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS07, oS06, oS07, oS06, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07})
		//              01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    
		nTotReg    := 0
		
		If !TMP_REL->(EoF())
			oXML:SkipLine()
		EndIf
		
	EndIf
	
EndDo

TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldCliente

Autor:
Tiago Bandeira Brasiliano

Data:
31/05/2016

Descrição:
Função utilizada para criar o folder contendo as informações agrupadas de Clientes.
**************************************************************************************************/
Static Function FldCliente()

Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.), dbSelectArea("TMP_REL"), TMP_REL->(dbEval({|| nTotReg++ })), TMP_REL->(dbGoTop())}
Local cQuery     := ""
Local cMsg       := ""
Local cTitulo    := ""
Local cFldName   := ""

cQuery   := QryProdCli("CLIENTE")
cMsg     := "Consultando Clientes..."
cFldName := "Rk - Clientes"
cTitulo  := "RANKING POR CLIENTE - PERÍODO: "

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_CLIENTES.sql", cQuery), Nil)
LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A      B      C      D    E     F      G     H      I     J     K     L     M     N     O     P     Q     R     S     T     U     V     W     X     Y     Z
//               1      2      3      4    5     6      7     8      9     10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26
oXML:SetColSize({"100", "360", "70", "65", "150", "70", "100", "90", "90", "90", "90", "65", "90", "65", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90" })

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{cTitulo + DToC(MV_PAR01)+ " - " + DToC(MV_PAR02)}, oS05)
oXML:AddRow(,{"Código do Cliente", "Nome do Cliente", "UF", "BP Code", "BP Name", "Tipo Cliente", "CNPJ", "Quantidade", "PMC", "Preço Fábrica", "Valor Total Mercadoria", "% Desconto", "Valor de Desconto", "% Repasse", "Valor Repasse", "Convênio", "Total Desconto NF", "Valor ICMS", "PIS", "COFINS", "Valor Nota Fiscal", "Base Solidário", "Valor Solidário", "IPI", "Valor Unitário Líquido", "Valor Líquido"}, oS06)

While !TMP_REL->(Eof())

	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os dados                                        |
	//+----------------------------------------------------------------------+
	oXML:AddRow(,{TMP_REL->CLIENTE + "-" + TMP_REL->LOJA,;                                           // 01 - Código do Cliente
			      TMP_REL->NOME,;                                                                    // 02 - Nome do Cliente
			      TMP_REL->EST,;                                                                     // 03 - Estado
			      TMP_REL->BPCODE,;                                                                  // 04 - BP Code
			      TMP_REL->BPNAME,;                                                                  // 05 - BP Name
			      TMP_REL->TIPO,;                                                                    // 06 - Tipo Cliente
			      Transform(TMP_REL->CGC, "@R 99.999.999/9999-99"),;                                 // 07 - CNPJ
			      TMP_REL->QUANT ,;                                                                  // 08 - Quantidade
			      TMP_REL->PMC,;                                                                     // 09 - PMC 
			      TMP_REL->PRUNIT,;                                                                  // 10 - Preco Fabrica
			      TMP_REL->VAL_TOTAL_LISTA,;                                                         // 11 - Valor Total Mercadoria
			      TMP_REL->PERC_DESC_PEDIDO,;                                                        // 12 - % Descontos Pedido
			      TMP_REL->VAL_DESC_PEDIDO,;                                                         // 13 - Valores de Desc. Ped. (Desconto Comercial + Desconto Pregão)
			      TMP_REL->PER_REP,;                                                                 // 14 - % Repasse
			      TMP_REL->VAL_REP,;                                                                 // 15 - Valor Repasse
			      TMP_REL->VAL_CON,;                                                                 // 16 - Convênio
			      TMP_REL->VAL_DESC_NF,;                                                             // 17 - Total Desconto NF (Obtido da SD2: D2_DESCON).  - 2a Opção: (((TMP_REL->VAL_TOTAL_LISTA - (TMP_REL->VAL_REP)) * (TMP_REL->PERC_DESC_PEDIDO / 100)) + (TMP_REL->VAL_REP) + (TMP_REL->VAL_CON)) * nFator,;   // 33 - Total Desconto NF Cálculado. A pedido da Vivian foi efetuado este cálculo. Porém foi retornado a leitura diretamente da NF.
	              TMP_REL->VALICM,;                                                                  // 18 - Valor ICMS
			      TMP_REL->PIS,;                                                                     // 19 - Pis
			      TMP_REL->COFINS,;                                                                  // 20 - COFINS
			      TMP_REL->VALBRUT,;                                                                 // 21 - Valor Nota Fiscal
			      TMP_REL->BASE_SOL,;                                                                // 22 - Base Solidario
			      TMP_REL->ICMSRET,;                                                                 // 23 - Valor Solidario
			      TMP_REL->VALIPI,;                                                                  // 24 - IPI
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS / TMP_REL->QUANT,;                             // 25 - Valor Unitario Liquido (Sem Impostos)
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS},;                                             // 26 - Valor Liquido (Sem Impostos)
			      {oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS03, oS04, oS04, oS04, oS03, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS04})
	//             01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26
	TMP_REL->(DbSkip())
	
EndDo

//+----------------------------------------------------------------------+
//| Adiciona a linha com os totais                                       |
//+----------------------------------------------------------------------+ 
oXML:AddRow( ,{"TOTAL GERAL",,,,,,,;
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,,;  // Quantidade
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Total Mercadoria
               "=(RC[+1] / (RC[-1] - RC[3])) * 100",;                        // % Desconto
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Desconto
               "=(RC[1] / RC[-3]) * 100",;                                   // % Repasse
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Repasse
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Convênio
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Total Desconto NF
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor ICMS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // PIS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // COFINS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Nota Fiscal
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Base Solidário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Solidário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // IPI
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Unitário Líquido
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)"},;   // Valor Líquido Total
               {oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS06, oS07, oS06, oS07, oS06, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07})
//              01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26
TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldProduto

Autor:
Tiago Bandeira Brasiliano

Data:
31/05/2016

Descrição:
Função utilizada para criar o folder contendo as informações agrupadas de Produtos.
Feito segunda a solicitação do Ercio Pallos, pedido dia 14/08/2013.
**************************************************************************************************/
Static Function FldProduto()

Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.), dbSelectArea("TMP_REL"), TMP_REL->(dbEval({|| nTotReg++ })), TMP_REL->(dbGoTop())}
Local cQuery     := ""
Local cMsg       := ""
Local cTitulo    := ""
Local cFldName   := ""

cQuery   := QryProdCli("PRODUTO")
cMsg     := "Consultando Produtos..."
cFldName := "Rk - Produto"
cTitulo  := "RANKING POR PRODUTO - PERÍODO: "

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_PRODUTO.sql", cQuery), Nil)
LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A     B     C      D     E     F     G     H     I     J     K     L     M     N     O     P     Q     R     S     T     U     V
//               1     2     3      4     5     6     7     8     9     10    11    12    13    14    15    16    17    18    19    20    21    22            
oXML:SetColSize({"90", "90", "300", "90", "90", "90", "90", "65", "90", "65", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90", "90" })

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{cTitulo + DToC(MV_PAR01)+ " - " + DToC(MV_PAR02)}, oS05)
oXML:AddRow(,{"Código Produto", "Item Number", "Nome do Produto", "Quantidade", "PMC", "Preço Fábrica", "Valor Total Mercadoria", "% Desconto", "Valor de Desconto", "% Repasse", "Valor Repasse", "Convênio", "Total Desconto NF", "Valor ICMS", "PIS", "COFINS", "Valor Nota Fiscal", "Base Solidário", "Valor Solidário", "IPI", "Valor Unitário Líquido", "Valor Líquido"}, oS06)

While !TMP_REL->(Eof())

	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os dados                                        |
	//+----------------------------------------------------------------------+
	oXML:AddRow(,{TMP_REL->CODPROD,;                                                                 // 01 - Código do Cliente
			      TMP_REL->XITNUMB,;                                                                 // 02 - Item Number
			      TMP_REL->DESCRI,;                                                                  // 03 - Nome do Produto
			      TMP_REL->QUANT ,;                                                                  // 04 - Quantidade
			      TMP_REL->PMC,;                                                                     // 05 - PMC 
			      TMP_REL->PRUNIT,;                                                                  // 06 - Preco Fabrica
			      TMP_REL->VAL_TOTAL_LISTA,;                                                         // 07 - Valor Total Mercadoria
			      TMP_REL->PERC_DESC_PEDIDO,;                                                        // 08 - % Desconto
			      TMP_REL->VAL_DESC_PEDIDO,;                                                         // 09 - Valor de Desconto
			      TMP_REL->PER_REP,;                                                                 // 10 - % Repasse
			      TMP_REL->VAL_REP,;                                                                 // 11 - Valor Repasse
			      TMP_REL->VAL_CON,;                                                                 // 12 - Convênio
			      TMP_REL->VAL_DESC_NF,;                                                             // 13 - Total Desconto NF (Obtido da SD2: D2_DESCON).  - 2a Opção: (((TMP_REL->VAL_TOTAL_LISTA - (TMP_REL->VAL_REP)) * (TMP_REL->PERC_DESC_PEDIDO / 100)) + (TMP_REL->VAL_REP) + (TMP_REL->VAL_CON)) * nFator,;   // 33 - Total Desconto NF Cálculado. A pedido da Vivian foi efetuado este cálculo. Porém foi retornado a leitura diretamente da NF.
	              TMP_REL->VALICM,;                                                                  // 14 - Valor ICMS
			      TMP_REL->PIS,;                                                                     // 15 - Pis
			      TMP_REL->COFINS,;                                                                  // 16 - COFINS
			      TMP_REL->VALBRUT,;                                                                 // 17 - Valor Nota Fiscal
			      TMP_REL->BASE_SOL,;                                                                // 18 - Base Solidario
			      TMP_REL->ICMSRET,;                                                                 // 19 - Valor Solidario
			      TMP_REL->VALIPI,;                                                                  // 20 - IPI
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS / TMP_REL->QUANT,;                             // 21 - Valor Unitario Liquido (Sem Impostos)
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS},;                                             // 22 - Valor Liquido (Sem Impostos)
			      {oS02, oS02, oS02, oS03, oS04, oS04, oS04, oS03, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS03, oS04, oS04, oS04, oS04, oS04, oS04})
	//             01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22 
	TMP_REL->(DbSkip())
	
EndDo

nTotReg := Iif(nTotReg == 0, 1, nTotReg)
oXML:AddRow( ,{"TOTAL PRODUTO",,,;
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",,,;  // 04 - Quantidade
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 07 - Valor Total Mercadoria
               "=(RC[+1] / (RC[-1] - RC[3])) * 100",;                        // % Desconto
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // Valor Desconto
               "=(RC[1] / RC[-3]) * 100",;                                   // % Repasse
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 11 - Valor Repasse
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 12 - Convênio
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 13 - Total Desconto NF
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 14 - Valor ICMS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 15 - PIS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 16 - COFINS
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 17 - Valor Nota Fiscal
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 18 - Base Solidário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 19 - Valor Solidário
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 20 - IPI
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;    // 21 - Valor Unitário Líquido
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)"},;   // 22 - Valor Líquido Total
               {oS06, oS06, oS06, oS06, oS06, oS06, oS07, oS06, oS07, oS06, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07, oS07})
//              01    02    03    04    05    06    07    08    09    10    11    12    13    14    15    16    17    18    19    20    21    22   
TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldTipoProd

Autor:
Tiago Bandeira Brasiliano

Data:
29/06/2016

Descrição:
Função utilizada para criar o folder contendo as informações agrupadas por tipo de produto.
**************************************************************************************************/
Static Function FldTipoProd()

Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.), dbSelectArea("TMP_REL"), TMP_REL->(dbEval({|| nTotReg++ })), TMP_REL->(dbGoTop())}
Local cQuery     := ""
Local cMsg       := ""
Local cTitulo    := ""
Local cFldName   := ""

cQuery   := QryTipoProd()
cMsg     := "Consultando Tipos de Produtos..."
cFldName := "Rk - TP"
cTitulo  := "RANKING POR TP - PERÍODO: "

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_TIPOPROD.sql", cQuery), Nil)
LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A     B      C     D      E     F
//               1     2      3     4      5     6
oXML:SetColSize({"75", "220", "50", "120", "90", "90" })

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{cTitulo + DToC(MV_PAR01)+ " - " + DToC(MV_PAR02)}, oS05)
oXML:AddRow(,{"Produto", "Descrição", "TP Code", "TP Name", "Quantidade", "Valor"}, oS06)

While !TMP_REL->(Eof())

	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os dados                                        |
	//+----------------------------------------------------------------------+
	oXML:AddRow(,{TMP_REL->XITNUMB,;                                  // 01 - Produto (Número do Item)
			      TMP_REL->DESCRI,;                                   // 02 - Descrição
			      TMP_REL->BPCODE,;                                   // 03 - TP Code
			      TMP_REL->BPNAME,;                                   // 04 - TP Name
			      TMP_REL->QUANT ,;                                   // 05 - Quantidade
			      TMP_REL->VAL_LIQ_TOTAL_SEM_IMPOSTOS},;              // 06 - Valor
			      {oS02, oS02, oS02, oS02, oS03, oS04})
	//             01    02    03    04    05    06
	
	TMP_REL->(DbSkip())
	
EndDo

nTotReg := Iif(nTotReg == 0, 1, nTotReg)
oXML:AddRow( ,{"TOTAL GERAL",,,,;
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)",;   // 05 - Quantidade
               "=SUBTOTAL(9,R[-" + AllTrim(Str(nTotReg)) + "]C:R[-1]C)"},;  // 06 - Valor
               {oS06, oS06, oS06, oS06, oS06, oS07})
//              01    02    03    04    05    06

TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldTPSales

Autor:
Tiago Bandeira Brasiliano

Data:
29/06/2016

Descrição:
Função utilizada para criar o folder contendo as informações de vendas por tipo de produto e de 
acordo com uma visão gerencial solicitada pela Matriz da Ferring.
Esta aba foi solicitada pelo Eduardo Cota conforme requisição da matriz.
**************************************************************************************************/
Static Function FldTPSales()

Local nValor      := 0
Local nTotReg     := 0
Local nI          := 0
Local bQuery      := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.), dbSelectArea("TMP_REL"), TMP_REL->(dbEval({|| nTotReg++ })), TMP_REL->(dbGoTop())}
Local cQuery      := ""
Local cMsg        := ""
Local cFldName    := ""
Local cConta      := ""
Local cQuantidade := ""
Local cXML        := ""
Local cValor      := ""
Local lImpLinha   := .T.
Local aAccounts   := {{"5010", "GROSS_SALES"},;    // Tabela de Classificação dos itens da planilha onde: 5010 = Venda Bruta Sem Impostos (Ou Líquido + Descontos)  
	                  {"5020", "COM_DISC"},;       //                                                     5020 = Descontos Comercial de Venda (Politica Comercial)
	                  {"5030", "NON_COM_DISC"},;   //                                                     5030 = Desconto Não comercial (CAP = Coeficiente de Alteração de Preço)). Desconto Obrigatório para o Governo   
	                  {"5014", "COM_DISC_OVER"}}   //                                                     5014 = Desconto Comercial Acima da política (Concedidos durante o pregão por exemplo)
                                                   //                                                     5040 = Provisão Sob Devoluções = Não considerados neste momento. Será feito manualmente
                                                   // O segundo item do array é o campo da query correspondente ao valor.

cQuery   := QryTPSales()
cMsg     := "Consultando TP Sales..."
cFldName := "TP Sales"

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_TPSALES.sql", cQuery), Nil)

LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A      B      C      D      E      F      G      H      I      J      K      L      M      N      O
//               1      2      3      4      5      6      7      8      9      10     11     12     13     14     15
oXML:SetColSize({"125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125"})

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{"Ship to Customer", "Business Unit", "Business Partner", "Account Code", "Item Number", "Item Description", "Product Group GF", "YTD Quantity", "YTD Reporting Amount in '000", "YTD Invoiced Amount in '000", "Invoicing Currency", "Error", "Error Description", "Warning", "Warning Description"}, oS08)

While !TMP_REL->(Eof())

	If !Empty(TMP_REL->BUSINESS_PARTNER)

		//+---------------------------------------------------------------------------------+
		//| Para cada uma linhas das query, varre todos os tipos de contas (5010, 5020,     |
		//| 5030, 5014, etc) dividinos as informações de faturamento para cada uma delas.   |
		//| Isto é feito, pois cada registro da query, irá gerar na planilha os registros:  |
		//| 5010 - Venda Bruta (ou Venda Líquida + Descontos Comerciais e Não comerciais).  |
		//| 5020 - Desconto Comercial.                                                      |
		//| 5030 - Desconto não Comercial (CAP).                                            |
		//| 5014 - Desconto Acima da Política de Descontos da Ferring (Desc.  de Pregão).   |
		//+---------------------------------------------------------------------------------+
		For nI := 1 To Len(aAccounts)
		
			cConta      := aAccounts[nI, 1]
			nValor      := TMP_REL->&(aAccounts[nI, 2])
			lImpLinha   := .F.
			cQuantidade := Iif(cConta == "5010", Transform(TMP_REL->YTD_QUANTITY, "@R 9999999999"), "")
			
			If nValor <> 0 // Não imprime na planilha linhas com valores zerados para a conta
	
				lImpLinha := .T.
				
				//+------------------------------------------------------------------------+
				//| Converte os valores de desconto em valores negativos e também converte |
				//| o valor em milhares ('000) com 4 casas decimais, ou seja:              |
				//| O valor 4.022.233,3800 ficará como: 4022,2333800.                      |
				//+------------------------------------------------------------------------+
	  			cValor := StrTran(Transform(Iif(cConta $ "5020|5030|5014", -1, 1) * nValor / 1000, "@R 999999999.9999999"), ",", ".")
	  			
	  		EndIf
	  		
	  		If lImpLinha
	  		
	  			//+----------------------------------------------------------------------+
				//| Adiciona a linha com os dados                                        |
				//+----------------------------------------------------------------------+
				oXML:AddRow(,{AllTrim(TMP_REL->SHIP_TO_CUSTOMER),;                          // 01 - Ship to Customer
						      AllTrim(TMP_REL->BUSINESS_UNIT),;                             // 02 - Business Unit
						      AllTrim(TMP_REL->BUSINESS_PARTNER),;                          // 03 - Business Partner
						      AllTrim(cConta),;                                             // 04 - Account Code
						      AllTrim(TMP_REL->ITEM_NUMBER),;                               // 05 - Item Number
						      AllTrim(TMP_REL->ITEM_DESCRIPTION),;                          // 06 - Item Description
						      AllTrim(TMP_REL->PRODUCT_GROUP),;                             // 07 - Product Group GF
						      Iif(Empty(cQuantidade), "", Val(cQuantidade)),;               // 08 - YTD Quantity
						      Val(cValor),;                                                 // 09 - YTD Reporting Amount in '000
						      Val(cValor) ,;                                                // 10 - YTD Invoiced Amount in '000
						       AllTrim(TMP_REL->INV_CURRENCY),;                             // 11 - Invoicing Currency
						      TMP_REL->ERROR,;                                              // 12 - Error
						      AllTrim(TMP_REL->ERROR_DESCRIPTION),;                         // 13 - Error Description
						      AllTrim(TMP_REL->WARNING),;                                   // 14 - Warning
						      AllTrim(TMP_REL->WARNING_DESCRIPTION)},;                      // 15 - Warning Description
						      {oS02, oS02, oS02, oS02, oS02, oS02, oS02, Nil, Nil, Nil, oS02, Nil, oS02, oS02, oS02})
				//             01    02    03    04    05    06    07    08   09   10   11    12    13    14    15
				
			EndIf
			
		Next nI
		
	EndIf

	TMP_REL->(dbSkip())
	
EndDo

TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldAnaTPSales

Autor:
Tiago Bandeira Brasiliano

Data:
17/10/2017

Descrição:
Função utilizada para criar o folder contendo as informações analíticas de vendas por tipo de 
produto e de acordo com uma visão gerencial solicitada pela Matriz da Ferring.
**************************************************************************************************/
Static Function FldAnaTPSales()

Local nValor      := 0
Local nTotReg     := 0
Local nI          := 0
Local bQuery      := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.), dbSelectArea("TMP_REL"), TMP_REL->(dbEval({|| nTotReg++ })), TMP_REL->(dbGoTop())}
Local cQuery      := ""
Local cMsg        := ""
Local cFldName    := ""
Local cConta      := ""
Local cQuantidade := ""
Local cXML        := ""
Local cValor      := ""
Local lImpLinha   := .T.
Local aAccounts   := {{"5010", "GROSS_SALES"},;    // Tabela de Classificação dos itens da planilha onde: 5010 = Venda Bruta Sem Impostos (Ou Líquido + Descontos)  
	                  {"5020", "COM_DISC"},;       //                                                     5020 = Descontos Comercial de Venda (Politica Comercial)
	                  {"5030", "NON_COM_DISC"},;   //                                                     5030 = Desconto Não comercial (CAP = Coeficiente de Alteração de Preço)). Desconto Obrigatório para o Governo   
	                  {"5014", "COM_DISC_OVER"}}   //                                                     5014 = Desconto Comercial Acima da política (Concedidos durante o pregão por exemplo)
                                                   //                                                     5040 = Provisão Sob Devoluções = Não considerados neste momento. Será feito manualmente
                                                   // O segundo item do array é o campo da query correspondente ao valor.

cQuery   := QryAnaTPSales()
cMsg     := "Consultando TP Sales Analítico..."
cFldName := "TP Sales Analitico"

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_TPSALESANA.sql", cQuery), Nil)

LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A      B      C      D      E      F      G      H      I      J      K      L      M      N      O      P      Q      R      S      T
//               1      2      3      4      5      6      7      8      9      10     11     12     13     14     15     16     17     18     19     20
oXML:SetColSize({"125", "125", "125", "125", "125","125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125", "125"})

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{"Documento", "Emissao", "Cliente", "Loja",  "Produto", "Ship to Customer", "Business Unit", "Business Partner", "Account Code", "Item Number", "Item Description", "Product Group GF", "YTD Quantity", "YTD Reporting Amount in '000", "YTD Invoiced Amount in '000", "Invoicing Currency", "Error", "Error Description", "Warning", "Warning Description"}, oS08)

While !TMP_REL->(Eof())

	If !Empty(TMP_REL->BUSINESS_PARTNER)

		//+---------------------------------------------------------------------------------+
		//| Para cada uma linhas das query, varre todos os tipos de contas (5010, 5020,     |
		//| 5030, 5014, etc) dividinos as informações de faturamento para cada uma delas.   |
		//| Isto é feito, pois cada registro da query, irá gerar na planilha os registros:  |
		//| 5010 - Venda Bruta (ou Venda Líquida + Descontos Comerciais e Não comerciais).  |
		//| 5020 - Desconto Comercial.                                                      |
		//| 5030 - Desconto não Comercial (CAP).                                            |
		//| 5014 - Desconto Acima da Política de Descontos da Ferring (Desc.  de Pregão).   |
		//+---------------------------------------------------------------------------------+
		For nI := 1 To Len(aAccounts)
		
			cConta      := aAccounts[nI, 1]
			nValor      := TMP_REL->&(aAccounts[nI, 2])
			lImpLinha   := .F.
			cQuantidade := Iif(cConta == "5010", Transform(TMP_REL->YTD_QUANTITY, "@R 9999999999"), "")
			
			If nValor <> 0 // Não imprime na planilha linhas com valores zerados para a conta
	
				lImpLinha := .T.
				
				//+------------------------------------------------------------------------+
				//| Converte os valores de desconto em valores negativos e também converte |
				//| o valor em milhares ('000) com 4 casas decimais, ou seja:              |
				//| O valor 4.022.233,3800 ficará como: 4022,2333800.                      |
				//+------------------------------------------------------------------------+
	  			cValor := StrTran(Transform(Iif(cConta $ "5020|5030|5014", -1, 1) * nValor / 1000, "@R 999999999.9999999"), ",", ".")
	  			
	  		EndIf
	  		
	  		If lImpLinha
	  		
	  			//+----------------------------------------------------------------------+
				//| Adiciona a linha com os dados                                        |
				//+----------------------------------------------------------------------+
				oXML:AddRow(,{AllTrim(TMP_REL->DOC),;                                       // 01 - Ship to Customer
						      AllTrim(TMP_REL->EMISSAO),;                                   // 02 - Ship to Customer
						      AllTrim(TMP_REL->CLIENTE),;                                   // 03 - Ship to Customer
						      AllTrim(TMP_REL->LOJA),;                                      // 04 - Ship to Customer
						      AllTrim(TMP_REL->PRODUCT_CODE),;                              // 05 - Ship to Customer
						      AllTrim(TMP_REL->SHIP_TO_CUSTOMER),;                          // 06 - Ship to Customer
						      AllTrim(TMP_REL->BUSINESS_UNIT),;                             // 07 - Business Unit
						      AllTrim(TMP_REL->BUSINESS_PARTNER),;                          // 08 - Business Partner
						      AllTrim(cConta),;                                             // 09 - Account Code
						      AllTrim(TMP_REL->ITEM_NUMBER),;                               // 10 - Item Number
						      AllTrim(TMP_REL->ITEM_DESCRIPTION),;                          // 11 - Item Description
						      AllTrim(TMP_REL->PRODUCT_GROUP),;                             // 12 - Product Group GF
						      Iif(Empty(cQuantidade), "", Val(cQuantidade)),;               // 13 - YTD Quantity
						      Val(cValor),;                                                 // 14 - YTD Reporting Amount in '000
						      Val(cValor) ,;                                                // 15 - YTD Invoiced Amount in '000
						       AllTrim(TMP_REL->INV_CURRENCY),;                             // 16 - Invoicing Currency
						      TMP_REL->ERROR,;                                              // 17 - Error
						      AllTrim(TMP_REL->ERROR_DESCRIPTION),;                         // 18 - Error Description
						      AllTrim(TMP_REL->WARNING),;                                   // 19 - Warning
						      AllTrim(TMP_REL->WARNING_DESCRIPTION)},;                      // 20 - Warning Description
						      {oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, oS02, Nil, Nil, Nil, oS02, Nil, oS02, oS02, oS02})
				//             01    02    03    04    05    06    07    08   09   10   11    12    13    14    15    16   17    18    19    20
				
			EndIf
			
		Next nI
		
	EndIf

	TMP_REL->(dbSkip())
	
EndDo

TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
FldCMED

Autor:
Tiago Bandeira Brasiliano

Data:
30/06/2016

Descrição:
Função utilizada para criar o folder contendo as informações para a CMED.
**************************************************************************************************/
Static Function FldCMED()

Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP_REL") > 0, TMP_REL->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_REL",.F.,.T.), dbSelectArea("TMP_REL"), TMP_REL->(dbEval({|| nTotReg++ })), TMP_REL->(dbGoTop())}
Local cQuery     := ""
Local cMsg       := ""
Local cTitulo    := ""
Local cFldName   := ""

cQuery   := QryCMED()
cMsg     := "Consultando dados CMED..."
cFldName := "CMED"

Iif(lDebug, Memowrite("C:\Temp\FRFAT003_CMED.sql", cQuery), Nil)
LjMsgRun(cMsg, "Aguarde...", bQuery)

oXML:SetFolder(++nFldCount)
oXML:SetFolderName(cFldName)

//+----------------------------------------------------------------------+
//| Ajusta o tamanho das colunas do folder da planilha                   |
//+----------------------------------------------------------------------+
// coluna:       A      B     C      D     E     F
//               1      2     3      4     5     6
oXML:SetColSize({"180", "50", "50", "110", "70", "100" })

//+----------------------------------------------------------------------+
//| Adiciona as linhas de cabeçalho                                      |
//+----------------------------------------------------------------------+
oXML:AddRow(,{"Cod. GGREM", "Ano", "Mês", "Tipo Cliente Anvisa", "Quantidade", "Faturamento R$"}, oS09)

While !TMP_REL->(Eof())

	//+----------------------------------------------------------------------+
	//| Adiciona a linha com os dados                                        |
	//+----------------------------------------------------------------------+
	oXML:AddRow(,{TMP_REL->CDGGREM,;             // 01 - Código do Cliente
			      TMP_REL->ANO,;                 // 02 - Nome do Cliente
			      TMP_REL->MES,;                 // 03 - Estado
			      TMP_REL->TIPO,;                // 04 - Tipo Cliente
			      TMP_REL->QUANT ,;              // 05 - Quantidade
			      TMP_REL->VALOR},;              // 06 - Valor Liquido
			      {oS02, oS02, oS02, oS02, oS10, oS11})
	//             01    02    03    04    05    06
	TMP_REL->(DbSkip())
	
EndDo

TMP_REL->(dbCloseArea())

Return .T.


/**************************************************************************************************
Função:
QryVendas

Descrição:
Retorna a query que busca as informações de vendas.

Parâmetros:
lSubQuery => Indica se a query retornada será utilizada como uma sub-query. Default = .F.

Retorno:
cQuery    => String contendo a query de busca de vendas.
**************************************************************************************************/
Static Function QryVendas(lSubQuery)

Local cQuery := ""
Local cProdPisCof := GetNewPar("ES_PRODPIS", "'52.001.002','54.001.001'") // Produto que deverão ter o PIS e COFINS impressos no Ranking
Local cGrupPisCof := GetNewPar("ES_GRUPPIS", "'50.017','50.020'")        // Grupo de Produtos que deverão ter o PIS e COFINS impressos no Ranking

Default lSubQuery := .F.

cQuery += "SELECT" + CRLF
cQuery += " VAL_TOTAL_LISTA - VAL_DESC_NF - VALICM - VALIPI - PIS - COFINS - DIFAL - ICMSCOM - FCP AS VAL_LIQ_TOTAL_SEM_IMPOSTOS," + CRLF
cQuery += " * " + CRLF
cQuery += "FROM(" + CRLF   
cQuery += "SELECT" + CRLF
cQuery += " 1 AS FATOR," + CRLF
cQuery += " D2_XPERCON AS PER_CON," + CRLF
cQuery += " D2_XPERREP AS PER_REP," + CRLF
cQuery += " D2_XPERCAP AS PER_CAP," + CRLF
cQuery += " D2_XPERCOM AS PER_COM," + CRLF
cQuery += " D2_XPERPRE AS PER_PRE," + CRLF
cQuery += " D2_XPERREA AS PER_REA," + CRLF
cQuery += " D2_XVALCON AS VAL_CON," + CRLF
cQuery += " D2_XVALREP AS VAL_REP," + CRLF
cQuery += " D2_XVALCAP AS VAL_CAP," + CRLF
cQuery += " D2_XVALCOM AS VAL_COM," + CRLF
cQuery += " D2_XVALPRE AS VAL_PRE," + CRLF
cQuery += " D2_XVALREA AS VAL_REA," + CRLF
cQuery += " D2_CLIENTE  AS CLIENTE," + CRLF
cQuery += " D2_LOJA AS LOJA," + CRLF
cQuery += " A1_NOME AS NOME," + CRLF
cQuery += " A1_CGC CGC," + CRLF
cQuery += " A1_EST EST," + CRLF
cQuery += " A1_MUN MUN," + CRLF
cQuery += " A1_XFICSA AS BPCODE," + CRLF
cQuery += " X5_DESCRI AS BPNAME," + CRLF
cQuery += " A1__TIPO AS TIPO," + CRLF
cQuery += " D2_PEDIDO AS PEDIDO," + CRLF
cQuery += " D2_EMISSAO AS EMISSAO," + CRLF
cQuery += " D2_EMISSAO AS DT_CONSOL," + CRLF // tbb - 22/80/2017 - Inclusão de Data Consolidade (para as notas de saída, será a emissão. Já para as entradas, será a data de digitação)
cQuery += " D2_DOC AS DOC," + CRLF
cQuery += " D2_SERIE AS SERIE," + CRLF
cQuery += " '' AS NFORI," + CRLF
cQuery += " '' AS DATAORI," + CRLF
cQuery += " D2_CF AS CF," + CRLF
cQuery += " D2_COD AS CODPROD," + CRLF
cQuery += " B1_XITEMNU AS XITNUMB," + CRLF
cQuery += " B1_DESC AS DESCRI," + CRLF
cQuery += " B1_GRPFERR AS GRPFERR," + CRLF
cQuery += " B1_CDGGREM AS CDGGREM," + CRLF
cQuery += " D2_QUANT AS QUANT," + CRLF
cQuery += " D2_PRCVEN AS VAL_UNIT_LIQ," + CRLF
cQuery += " D2_QUANT * D2_PRCVEN AS VAL_TOTAL_LIQ," + CRLF
cQuery += " D2_PICM AS PICM," + CRLF
cQuery += " DA1_PMC AS PMC," + CRLF
cQuery += " D2_PRUNIT AS PRUNIT," + CRLF
cQuery += " CASE WHEN D2_QUANT = 0 THEN D2_TOTAL ELSE D2_QUANT * D2_PRUNIT END AS VAL_TOTAL_LISTA," + CRLF
cQuery += " D2_XPERCOM + D2_XPERPRE + D2_XPERREA AS PERC_DESC_PEDIDO," + CRLF // Percentual de Desconto do Pedido = Percentual de Desconto Comercial + Percentual de Desconto de Pregão (ou seja, será o Desconto da NF - CAP - Convênio - Repasse)
cQuery += " D2_DESC AS PERC_DES_NF," + CRLF
cQuery += " D2_DESCON AS VAL_DESC_NF," + CRLF
cQuery += " D2_XVALCOM + D2_XVALPRE + D2_XVALREA AS VAL_DESC_PEDIDO," + CRLF // Descontos do Pedido = Desconto Comercial + Desconto de Pregão. Ou seja: É o mesmo que o Desconto da NF - Repasse - Convênio - CAP
cQuery += " D2_BASEICM AS BASEICM," + CRLF
cQuery += " D2_VALICM AS VALICM," + CRLF
cQuery += " CASE WHEN D2_COD IN(" + cProdPisCof + ")"
cQuery += "  OR SUBSTRING(D2_COD,1,6) IN(" + cGrupPisCof + ")"
cQuery += "  OR (SUBSTRING(D2_COD,1,6) IN('52.001','54.001') AND D2_EMISSAO >= '20120101')"
cQuery += "  OR (SUBSTRING(D2_COD,1,6) IN('50.015') AND D2_EMISSAO BETWEEN '20120101' AND '20140723') THEN" + CRLF 
cQuery += "   D2_VALIMP5" + CRLF
cQuery += " ELSE  " + CRLF
cQuery += "   0" + CRLF
cQuery += " END AS COFINS,	" + CRLF
cQuery += " CASE WHEN D2_COD IN(" + cProdPisCof + ")"
cQuery += "  OR SUBSTRING(D2_COD,1,6) IN(" + cGrupPisCof + ")"
cQuery += "  OR (SUBSTRING(D2_COD,1,6) IN('52.001','54.001') AND D2_EMISSAO >= '20120101')"
cQuery += "  OR (SUBSTRING(D2_COD,1,6) IN('50.015') AND D2_EMISSAO BETWEEN '20120101' AND '20140723') THEN" + CRLF 
cQuery += "   D2_VALIMP6" + CRLF
cQuery += " ELSE  " + CRLF
cQuery += "   0" + CRLF
cQuery += " END AS PIS,	" + CRLF
cQuery += " D2_LOTECTL AS LOTE," + CRLF
cQuery += " D2_VALBRUT AS VALBRUT," + CRLF
cQuery += " D2_BRICMS AS BASE_SOL," + CRLF
cQuery += " D2_ICMSRET AS ICMSRET," + CRLF
cQuery += " D2_VALIPI AS VALIPI," + CRLF
cQuery += " D2_ICMSCOM AS ICMSCOM," + CRLF // Valor do ICMS complementar UF emitente
cQuery += " D2_DIFAL AS DIFAL," + CRLF     // Valor do ICMS complementar UF destinatário
cQuery += " D2_PDORI AS PDORI," + CRLF     // Percentual do DIFAL UF Origem
cQuery += " D2_PDDES AS PDDES," + CRLF     // Percentual do Difal UF Destinatário
cQuery += " D2_BASEDES AS BASEDES," + CRLF // Base DIFAL destinatário
cQuery += " D2_ALIQCMP AS ALIQCMP," + CRLF // Aliq. ICMS complementar
cQuery += " A1__REGIAO AS REGIAO," + CRLF
cQuery += " A1_VEND AS VEND," + CRLF
cQuery += " D2_TIPO AS TIPOP," + CRLF
cQuery += " C5_XIDLICI AS DCL," + CRLF
cQuery += " C5_MENANEX AS PEDIDO_CLIENTE, " + CRLF
cQuery += " C5_PEDIMS AS PEDIDO_IMS, " + CRLF
cQuery += " ISNULL(B8_DTVALID, '') AS VALIDADE_LOTE, " + CRLF
cQuery += " ISNULL(B8_DTFABR, '') AS FABRIC_LOTE, " + CRLF
cQuery += " ISNULL(CD2_VFCP, '') AS FCP, " + CRLF
cQuery += " C5_CONDPAG AS CONDPAG, " + CRLF
cQuery += " '' AS HISTDEV, " + CRLF
cQuery += " B1_CODBAR AS CODBAR " + CRLF
cQuery += "FROM " + RetSQLName("SD2") + " SD2" + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SC6' ) + " SC6 ON SC6.D_E_L_E_T_ = ' ' AND C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEMPV AND C6_FILIAL = D2_FILIAL " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SC5' ) + " SC5 ON SC5.D_E_L_E_T_ = ' ' AND C5_NUM = D2_PEDIDO AND C5_FILIAL = D2_FILIAL " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SB1' ) + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_COD = D2_COD " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SA1' ) + " SA1 ON SA1.D_E_L_E_T_ = ' ' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA" + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SF4' ) + " SF4 ON SF4.D_E_L_E_T_ = ' ' AND F4_CODIGO = D2_TES " + CRLF         
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SX5' ) + " SX5 ON SX5.D_E_L_E_T_ = ' ' AND X5_TABELA = 'ZF' AND X5_CHAVE = A1_XFICSA " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SB8' ) + " SB8 ON SB8.D_E_L_E_T_ = ' ' AND B8_FILIAL = D2_FILIAL AND B8_PRODUTO = D2_COD AND B8_LOCAL = D2_LOCAL AND B8_LOTECTL = D2_LOTECTL" + CRLF    
cQuery += " LEFT JOIN  "	+ RetSqlName( 'CD2' ) + " CD2 ON CD2.D_E_L_E_T_ = ' ' AND CD2_FILIAL = D2_FILIAL AND CD2_DOC = D2_DOC AND CD2_SERIE = D2_SERIE AND CD2_CODPRO = D2_COD AND CD2_ITEM = D2_ITEM AND CD2_CODCLI = D2_CLIENTE AND CD2_LOJCLI = D2_LOJA AND CD2_IMP = 'CMP' AND CD2_TPMOV = 'S'" + CRLF // TBB - 29/07/2016 - Adicionado o join para obter o imposto de FCP (Fundo de Combate a pobreza)
cQuery += " LEFT JOIN  "	+ RetSqlName( 'DA1' ) + " DA1 ON DA1.D_E_L_E_T_ = ' ' AND DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1_CODTAB = C5_TABELA AND DA1_CODPRO = D2_COD" + CRLF // TBB - 19/08/2016 - Adicionado o join para obter o Prexo Máximo ao Consumidor diretamente da tabela de preço, conforme solicitado pelo Bruno. 
cQuery += "WHERE D2_FILIAL >= '" + mv_par16 + "' AND D2_FILIAL <='" + mv_par17 + "' " + CRLF
cQuery += " AND D2_EMISSAO BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "'" + CRLF     	
cQuery += " AND SD2.D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + xFilial("SB1") + "' AND  A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
cQuery += " AND F4_FILIAL = '" + xFilial("SF4") + "'" + CRLF
cQuery += " AND C5_FILIAL = D2_FILIAL" + CRLF
cQuery += " AND C6_FILIAL = D2_FILIAL" + CRLF
cQuery += " AND D2_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'" + CRLF
cQuery += " AND A1_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'" + CRLF
cQuery += " AND D2_TIPO <> 'D'" + CRLF
//cQuery += "  AND (D2_QUANT <> 0 OR D2_TIPO IN ('I','C'))" + CRLF // Adicionadas as notas de complemente de ICMS (I) ou Complemente de Valor (C)
cQuery += " AND ((D2_TIPO = 'C' AND D2_PRCVEN > 0) OR" + CRLF      // Nota complementar de Preço (C)
cQuery += "      (D2_TIPO = 'I' AND D2_VALICM > 0) OR" + CRLF      // Nota complementar de ICMS (I)
cQuery += "      (D2_TIPO = 'I' AND D2_ICMSRET > 0) OR" + CRLF      // Nota complementar de ICMS ST (I) RODRIGO 30/08/18 - AVSYSTEM FERRING
cQuery += "      (D2_TIPO <> 'D' AND D2_QUANT > 0"                 // Para as demais notas, apenas com quantidade e que movimentem estoque de acordo com o parametro
cQuery += Iif(mv_par13 == 1, " AND F4_ESTOQUE = 'S'))", Iif(mv_par13 == 2, " AND F4_ESTOQUE = 'N'))", "))")) + CRLF

If !Empty(mv_par07) //Filtrar os Tipos de Clientes
	cQuery += " AND A1__TIPO IN (" + mv_par07 + ") "+CRLF
EndIf
If !Empty(mv_par08) //Filtrar as Regioes
	cQuery += " AND A1__REGIAO IN (" + mv_par08 + ") "+CRLF
EndIf
cQuery += " AND A1_VEND BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + CRLF

If !Empty(mv_par11) //Filtrar as UFs
	cQuery += " AND A1_EST IN (" + mv_par11 + ") "+CRLF
EndIf

If mv_par12 = 1 // GERA FINANCEIRO
	cQuery += " AND F4_DUPLIC = 'S' "+CRLF
EndIf

If mv_par12 = 2 // GERA FINANCEIRO
	cQuery += " AND F4_DUPLIC = 'N' "+CRLF
EndIf

If !Empty(mv_par15) //TES
	cQuery += " AND D2_TES IN (" + mv_par15 + ") "+CRLF      
EndIf

cQuery += ") TEMP_1" + CRLF
If !lSubQuery // Não inclui o ORDER BY quando for uma sub-query
	cQuery += "ORDER BY DOC, SERIE, CODPROD"
EndIf

Return cQuery


/**************************************************************************************************
Função:
QryDevolucoes

Descrição:
Retorna a query que busca as informações de devolução.

Parâmetros:
lSubQuery => Indica se a query retornada será utilizada como uma sub-query. Default = .F.

Retorno:
cQuery    => String contendo a query de busca de devoluções.
**************************************************************************************************/
Static Function QryDevolucoes(lSubQuery)

Local cQuery := ""
Local cProdPisCof := GetNewPar("ES_PRODPIS", "'52.001.002','54.001.001'") // Produto que deverão ter o PIS e COFINS impressos no Ranking
Local cGrupPisCof := GetNewPar("ES_GRUPPIS", "'50.017','50.020'")        // Grupo de Produtos que deverão ter o PIS e COFINS impressos no Ranking

Default lSubQuery := .F.

//+----------------------------------------------------+
//| Devolucoes: Início                                 |
//+----------------------------------------------------+
cQuery += "SELECT" + CRLF
cQuery += " VAL_TOTAL_LISTA - VAL_DESC_NF - VALICM - VALIPI - PIS - COFINS - DIFAL - ICMSCOM - FCP AS VAL_LIQ_TOTAL_SEM_IMPOSTOS," + CRLF
cQuery += " * " + CRLF
cQuery += "FROM(" + CRLF
cQuery += "SELECT" + CRLF
cQuery += " -1 AS FATOR," + CRLF
cQuery += " D2_XPERCON AS PER_CON," + CRLF
cQuery += " D2_XPERREP AS PER_REP," + CRLF
cQuery += " D2_XPERCAP AS PER_CAP," + CRLF
cQuery += " D2_XPERCOM AS PER_COM," + CRLF
cQuery += " D2_XPERPRE AS PER_PRE," + CRLF
cQuery += " D2_XPERREA AS PER_REA," + CRLF
cQuery += " ROUND(D2_XVALCON * (D1_QUANT / D2_QUANT), 2) AS VAL_CON," + CRLF
cQuery += " ROUND(D2_XVALREP * (D1_QUANT / D2_QUANT), 2) AS VAL_REP," + CRLF
cQuery += " ROUND(D2_XVALCAP * (D1_QUANT / D2_QUANT), 2) AS VAL_CAP," + CRLF
cQuery += " ROUND(D2_XVALCOM * (D1_QUANT / D2_QUANT), 2) AS VAL_COM," + CRLF
cQuery += " ROUND(D2_XVALPRE * (D1_QUANT / D2_QUANT), 2) AS VAL_PRE," + CRLF
cQuery += " ROUND(D2_XVALREA * (D1_QUANT / D2_QUANT), 2) AS VAL_REA," + CRLF
cQuery += " D1_FORNECE AS CLIENTE," + CRLF
cQuery += " D1_LOJA AS LOJA," + CRLF
cQuery += " A1_NOME AS NOME," + CRLF
cQuery += " A1_CGC CGC," + CRLF
cQuery += " A1_EST EST," + CRLF
cQuery += " A1_MUN MUN," + CRLF
cQuery += " A1_XFICSA AS BPCODE," + CRLF
cQuery += " X5_DESCRI AS BPNAME," + CRLF
cQuery += " A1__TIPO AS TIPO," + CRLF
cQuery += " D1_PEDIDO AS PEDIDO," + CRLF
cQuery += " D1_DTDIGIT AS EMISSAO," + CRLF   // D1_EMISSAO AS EMISSAO - tbb - A data de digitação passou a ser considerada como data de emissão a pedido do Bruno em 30/08/2016 
cQuery += " D1_DTDIGIT AS DT_CONSOL," + CRLF // tbb - 22/80/2017 - Inclusão de Data Consolidade (para as notas de saída, será a emissão. Já para as entradas, será a data de digitação)
cQuery += " D1_DOC AS DOC," + CRLF
cQuery += " D1_SERIE AS SERIE," + CRLF
cQuery += " D1_NFORI AS NFORI," + CRLF
cQuery += " ISNULL(D2_EMISSAO, '') AS DATAORI," + CRLF
cQuery += " D1_CF AS CF," + CRLF
cQuery += " D1_COD AS CODPROD," + CRLF
cQuery += " B1_XITEMNU AS XITNUMB," + CRLF
cQuery += " B1_DESC AS DESCRI," + CRLF
cQuery += " B1_GRPFERR AS GRPFERR," + CRLF
cQuery += " B1_CDGGREM AS CDGGREM," + CRLF
cQuery += " D1_QUANT AS QUANT," + CRLF
cQuery += " D2_PRCVEN AS VAL_UNIT_LIQ," + CRLF
cQuery += " D1_QUANT * D2_PRCVEN AS VAL_TOTAL_LIQ," + CRLF
cQuery += " D1_PICM AS PICM," + CRLF
cQuery += " DA1_PMC AS PMC," + CRLF
cQuery += " D2_PRUNIT AS PRUNIT," + CRLF
cQuery += " D1_QUANT * D2_PRUNIT AS VAL_TOTAL_LISTA," + CRLF
cQuery += " D2_XPERCOM + D2_XPERPRE AS PERC_DESC_PEDIDO," + CRLF
cQuery += " D2_DESC AS PERC_DES_NF," + CRLF
cQuery += " D1_VALDESC AS VAL_DESC_NF," + CRLF
cQuery += " ROUND((D2_XVALCOM + D2_XVALPRE) * (D1_QUANT / D2_QUANT), 2) AS VAL_DESC_PEDIDO," + CRLF // Descontos do Pedido = Desconto Comercial + Desconto de Pregão. Ou seja: É o mesmo que o Desconto da NF - Repasse - Convênio - CAP
cQuery += " D1_BASEICM AS BASEICM," + CRLF
cQuery += " D1_VALICM AS VALICM," + CRLF
cQuery += " CASE WHEN D1_COD IN(" + cProdPisCof + ")"
cQuery += "  OR SUBSTRING(D1_COD,1,6) IN(" + cGrupPisCof + ")"
cQuery += "  OR (SUBSTRING(D1_COD,1,6) IN('52.001','54.001') AND D1_DTDIGIT >= '20120101')"
cQuery += "  OR (SUBSTRING(D1_COD,1,6) IN('50.015') AND D1_DTDIGIT BETWEEN '20120101' AND '20140723') THEN" + CRLF 
cQuery += "   D1_VALIMP5" + CRLF
cQuery += " ELSE  " + CRLF
cQuery += "   0" + CRLF
cQuery += " END AS COFINS,	" + CRLF
cQuery += " CASE WHEN D1_COD IN(" + cProdPisCof + ")"
cQuery += "  OR SUBSTRING(D1_COD,1,6) IN(" + cGrupPisCof + ")"
cQuery += "  OR (SUBSTRING(D1_COD,1,6) IN('52.001','54.001') AND D1_DTDIGIT >= '20120101')"
cQuery += "  OR (SUBSTRING(D1_COD,1,6) IN('50.015') AND D1_DTDIGIT BETWEEN '20120101' AND '20140723') THEN" + CRLF 
cQuery += "   D1_VALIMP6" + CRLF
cQuery += " ELSE  " + CRLF
cQuery += "   0" + CRLF
cQuery += " END AS PIS,	" + CRLF
cQuery += " D1_LOTECTL AS LOTE," + CRLF
cQuery += " D1_TOTAL - SD1.D1_VALDESC + D1_ICMSRET AS VALBRUT," + CRLF
cQuery += " D1_BRICMS AS BASE_SOL," + CRLF
cQuery += " D1_ICMSRET AS ICMSRET," + CRLF
cQuery += " D1_VALIPI AS VALIPI," + CRLF
cQuery += " D1_ICMSCOM AS ICMSCOM," + CRLF // Valor do ICMS complementar UF emitente
cQuery += " D1_DIFAL AS DIFAL," + CRLF     // Valor do ICMS complementar UF destinatário
cQuery += " D1_PDORI AS PDORI," + CRLF     // Percentual do DIFAL UF Origem
cQuery += " D1_PDDES AS PDDES," + CRLF     // Percentual do Difal UF Destinatário
cQuery += " D1_BASEDES AS BASEDES," + CRLF // Base DIFAL destinatário
cQuery += " D1_ALIQCMP AS ALIQCMP," + CRLF // Aliq. ICMS complementar
cQuery += " A1__REGIAO AS REGIAO," + CRLF
cQuery += " A1_VEND AS VEND," + CRLF
cQuery += " D1_TIPO AS TIPOP," + CRLF
cQuery += " C5_XIDLICI AS DCL," + CRLF
cQuery += " C5_MENANEX AS PEDIDO_CLIENTE, " + CRLF
cQuery += " C5_PEDIMS AS PEDIDO_IMS, " + CRLF
cQuery += " ISNULL(B8_DTVALID, '') AS VALIDADE_LOTE, " + CRLF
cQuery += " ISNULL(B8_DTFABR, '') AS FABRIC_LOTE, " + CRLF
cQuery += " ISNULL(CD2_VFCP, '') AS FCP, " + CRLF
cQuery += " C5_CONDPAG AS CONDPAG, " + CRLF
cQuery += " F1_HIST AS HISTDEV, " + CRLF
cQuery += " B1_CODBAR AS CODBAR " + CRLF
cQuery += "FROM " + RetSQLName("SD1") + " SD1" + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SF1' ) + " SF1 ON SF1.D_E_L_E_T_ = ' ' AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_FILIAL = D1_FILIAL " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SD2' ) + " SD2 ON SD2.D_E_L_E_T_ = ' ' AND D2_DOC = D1_NFORI AND D2_SERIE = D1_SERIORI AND D2_ITEM = D1_ITEMORI AND D2_FILIAL = D1_FILIAL " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SC6' ) + " SC6 ON SC6.D_E_L_E_T_ = ' ' AND C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEMPV AND C6_FILIAL = D2_FILIAL " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SC5' ) + " SC5 ON SC5.D_E_L_E_T_ = ' ' AND C5_NUM = D2_PEDIDO AND C5_FILIAL = D2_FILIAL " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SB1' ) + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_COD = D2_COD " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SA1' ) + " SA1 ON SA1.D_E_L_E_T_ = ' ' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA" + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SF4' ) + " SF4 ON SF4.D_E_L_E_T_ = ' ' AND F4_CODIGO = D2_TES " + CRLF                       
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SX5' ) + " SX5 ON SX5.D_E_L_E_T_ = ' ' AND X5_TABELA = 'ZF' AND X5_CHAVE = A1_XFICSA " + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'SB8' ) + " SB8 ON SB8.D_E_L_E_T_ = ' ' AND B8_FILIAL = D1_FILIAL AND B8_PRODUTO = D1_COD AND B8_LOCAL = D1_LOCAL AND B8_LOTECTL = D1_LOTECTL" + CRLF
cQuery += " LEFT JOIN  "	+ RetSqlName( 'CD2' ) + " CD2 ON CD2.D_E_L_E_T_ = ' ' AND CD2_FILIAL = D2_FILIAL AND CD2_DOC = D2_DOC AND CD2_SERIE = D2_SERIE AND CD2_CODPRO = D2_COD AND CD2_ITEM = D2_ITEM AND CD2_CODCLI = D2_CLIENTE AND CD2_LOJCLI = D2_LOJA AND CD2_IMP = 'CMP' AND CD2_TPMOV = 'S'" + CRLF // TBB - 29/07/2016 - Adicionado o join para obter o imposto de FCP (Fundo de Combate a pobreza)
cQuery += " LEFT JOIN  "	+ RetSqlName( 'DA1' ) + " DA1 ON DA1.D_E_L_E_T_ = ' ' AND DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1_CODTAB = C5_TABELA AND DA1_CODPRO = D2_COD " + CRLF // TBB - 19/08/2016 - Adicionado o join para obter o Prexo Máximo ao Consumidor diretamente da tabela de preço, conforme solicitado pelo Bruno.
cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " AND D1_FILIAL >= '" + mv_par16 +"' AND D1_FILIAL <= '"+ mv_par17 +"'" + CRLF  
cQuery += " AND D1_DTDIGIT BETWEEN '" + DToS(mv_par01) + "' AND '" + DToS(mv_par02) + "'" + CRLF
cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' AND A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
cQuery += " AND F4_FILIAL = '" + xFilial("SF4")+"'" + CRLF
cQuery += " AND D1_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQuery += " AND A1_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQuery += " AND D1_TIPO = 'D' " + CRLF
If !Empty(mv_par07) //Filtrar os Tipos de Clientes
	cQuery += " AND A1__TIPO IN (" + mv_par07 + ") " + CRLF
EndIf
If !Empty(mv_par08) //Filtrar as Regioes
	cQuery += " AND A1__REGIAO IN (" + mv_par08 + ") " + CRLF
EndIf
cQuery += " AND A1_VEND BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + CRLF

If !Empty(mv_par11) //Filtrar as UFs
	cQuery += " AND A1_EST IN (" + mv_par11 + ") " + CRLF
EndIf

If mv_par12 = 1 // GERA FINANCEIRO
	cQuery += " AND F4_DUPLIC = 'S' " + CRLF
EndIf

If mv_par12 = 2 // GERA FINANCEIRO
	cQuery += " AND F4_DUPLIC = 'N' " + CRLF
EndIf

If mv_par13 = 1 // movimenta estoque
	cQuery += " AND F4_ESTOQUE = 'S'" + CRLF
EndIf

If mv_par13 = 2 // movimenta estoque
	cQuery += " AND F4_ESTOQUE = 'N' " + CRLF
EndIf

If !Empty(mv_par15) //TES
	cQuery += " AND D1_TES IN (" + mv_par15 + ")" + CRLF
EndIf
cQuery += ") TEMP_1" + CRLF

Return cQuery


/**************************************************************************************************
Função:
QryProdCli

Data:
31/05/2016

Descrição:
Retorna a query específica para o folder do ranking de produto x cliente. Este ranking basicamente
obtém as informações das planilhas de vendas e devoluções e aglutina estes dados.

Parâmetros:
cTipo => Indica qual o tipo de query está sendo executada. Isto é usado para que a mesma query
         possa ser utilizada para diferentes folders, efetuando desta forma o agrupamento dos
         dados de maneiras diferentes, podendo ser:
         "PRODUTO" = Utilizado pelo folder de Produto
         "CLIENTE" = Utilizado pelo folder de Cliente.
         "PROXCLI" = Utilizado pelo folder de Produto x Clientes
         

Retorno:
cQuery    => String contendo a query.
**************************************************************************************************/
Static Function QryProdCli(cTipo)

Local cQuery := ""
			      
cQuery += "SELECT " + CRLF
If cTipo $ "CLIENTE|PROXCLI"
	cQuery += " CLIENTE," + CRLF
	cQuery += " LOJA," + CRLF
	cQuery += " NOME," + CRLF
	cQuery += " CGC," + CRLF
	cQuery += " BPCODE," + CRLF
	cQuery += " BPNAME," + CRLF
	cQuery += " EST," + CRLF
	cQuery += " TIPO," + CRLF
EndIf
If cTipo $ "PRODUTO|PROXCLI"
	cQuery += " CODPROD," + CRLF
	cQuery += " XITNUMB," + CRLF
	cQuery += " DESCRI," + CRLF
EndIf
cQuery += " SUM(FATOR * QUANT) AS QUANT," + CRLF
cQuery += " SUM(FATOR * PMC) AS PMC," + CRLF        // PMC - Preço Máximo ao Consumidor
cQuery += " SUM(FATOR * PRUNIT) AS PRUNIT," + CRLF    // Preço de Fábrica
cQuery += " CASE WHEN SUM(QUANT) = 0 THEN SUM(FATOR * PRUNIT) ELSE SUM(FATOR * VAL_TOTAL_LISTA) END AS VAL_TOTAL_LISTA," + CRLF
cQuery += " CASE WHEN SUM(QUANT) = 0 THEN SUM(FATOR * PMC) ELSE SUM(FATOR * (QUANT * PMC)) END AS TOTAL_PMC," + CRLF
//cQuery += " SUM(FATOR * ((VAL_TOTAL_LISTA - VAL_REP) * (PERC_DESC_PEDIDO / 100))) / NULLIF( SUM(FATOR * (VAL_TOTAL_LISTA - VAL_REP)), 0) * 100 AS PERC_DESC_PEDIDO," + CRLF // O valor percentual é obtido através de cálulos devido ao agrupamento.
cQuery += " (1 - (SUM(FATOR * VAL_TOTAL_LIQ) / NULLIF( SUM(FATOR * (VAL_TOTAL_LIQ + VAL_COM + VAL_PRE)), 0))) * 100 AS PERC_DESC_PEDIDO," + CRLF // O valor percentual é obtido através de cálulos devido ao agrupamento.
cQuery += " SUM(FATOR * VAL_DESC_PEDIDO) AS VAL_DESC_PEDIDO, " + CRLF
cQuery += " SUM(FATOR * VAL_DESC_NF) AS VAL_DESC_NF, " + CRLF
cQuery += " SUM(VAL_REP) / NULLIF(SUM(VAL_TOTAL_LISTA), 0) * 100 AS PER_REP," + CRLF  // TODO: VERIFICAR COMO SERÁ OBTIDO O PERCENTUAL DE REPASSE            // Obtém o percentual de repasse através de cálculo, pois o agrupamento pode ser feito com valores diferentes
cQuery += " SUM(FATOR * VAL_REP) AS VAL_REP," + CRLF
cQuery += " SUM(FATOR * VAL_CON) AS VAL_CON," + CRLF
cQuery += " SUM(FATOR * PIS) AS PIS," + CRLF
cQuery += " SUM(FATOR * COFINS) AS COFINS," + CRLF
cQuery += " SUM(FATOR * DIFAL) AS DIFAL," + CRLF
cQuery += " SUM(FATOR * ICMSCOM) AS ICMSCOM," + CRLF
cQuery += " SUM(FATOR * FCP) AS FCP," + CRLF
cQuery += " SUM(FATOR * BASE_SOL) AS BASE_SOL," + CRLF
cQuery += " SUM(FATOR * ICMSRET) AS ICMSRET," + CRLF
cQuery += " SUM(FATOR * VALBRUT) AS VALBRUT," + CRLF
cQuery += " SUM(FATOR * VALICM) AS VALICM," + CRLF
cQuery += " SUM(FATOR * BASEICM) AS BASEICM," + CRLF
cQuery += " SUM(FATOR * VALIPI) AS VALIPI," + CRLF
cQuery += " SUM(FATOR * VAL_LIQ_TOTAL_SEM_IMPOSTOS) AS VAL_LIQ_TOTAL_SEM_IMPOSTOS" + CRLF


cQuery += "FROM ( " + CRLF

If MV_PAR14 <> 1 // SEM Devoluções ou Ambas (2 ou 3)
	cQuery += QryVendas(.T.)
EndIf

If MV_PAR14 == 3 // Ambas
	cQuery += "UNION ALL " + CRLF
EndIf

If MV_PAR14 <> 2 // APENAS Devoluções ou Ambas (1 ou 3)
	cQuery += QryDevolucoes(.T.)
EndIf

cQuery += ") AS TEMP_A " + CRLF
cQuery += "GROUP BY " + CRLF
If cTipo $ "CLIENTE|PROXCLI"
	cQuery += " CLIENTE," + CRLF
	cQuery += " LOJA," + CRLF
	cQuery += " NOME," + CRLF
	cQuery += " CGC," + CRLF
	cQuery += " BPCODE," + CRLF
	cQuery += " BPNAME," + CRLF
	cQuery += " EST," + CRLF
	cQuery += " TIPO" + CRLF
	cQuery += Iif(cTipo == "PROXCLI", ",", "")
EndIf
If cTipo $ "PRODUTO|PROXCLI"
	cQuery += " CODPROD," + CRLF
	cQuery += " DESCRI," + CRLF
	cQuery += " XITNUMB" + CRLF
EndIf
cQuery += "ORDER BY " + CRLF
If cTipo $ "PRODUTO|PROXCLI"
	cQuery += " CODPROD," + CRLF
	cQuery += " VAL_REP DESC" + CRLF
	If cTipo == "PROXCLI"
		cQuery += " ,CLIENTE+LOJA" + CRLF
	EndIf
Else
	cQuery += " VAL_REP DESC," + CRLF
	cQuery += " CLIENTE+LOJA" + CRLF
EndIf

Return cQuery


/**************************************************************************************************
Função:
QryTipoProd

Data:
29/06/2016

Descrição:
Retorna a query específica para o folder do ranking por tipo de produtos (aglutinadas).

Parâmetros:
Nenhum   

Retorno:
cQuery    => String contendo a query.
**************************************************************************************************/
Static Function QryTipoProd()

Local cQuery := ""
			      
cQuery += "SELECT" + CRLF
cQuery += " XITNUMB," + CRLF
cQuery += " DESCRI," + CRLF
cQuery += " BPCODE," + CRLF
cQuery += " BPNAME," + CRLF
cQuery += " SUM(FATOR * QUANT) AS QUANT," + CRLF
cQuery += " SUM(FATOR * VAL_LIQ_TOTAL_SEM_IMPOSTOS) AS VAL_LIQ_TOTAL_SEM_IMPOSTOS" + CRLF
cQuery += "FROM ( " + CRLF
cQuery += QryVendas(.T.)
cQuery += "UNION ALL " + CRLF
cQuery += QryDevolucoes(.T.)
cQuery += ") AS TEMP_A " + CRLF
cQuery += "GROUP BY" + CRLF
cQuery += " XITNUMB," + CRLF
cQuery += " DESCRI," + CRLF
cQuery += " BPCODE," + CRLF
cQuery += " BPNAME " + CRLF
cQuery += "ORDER BY" + CRLF
cQuery += " XITNUMB DESC," + CRLF
cQuery += " BPCODE" + CRLF

Return cQuery


/**************************************************************************************************
Função:
QryTPSales

Data:
15/06/2016

Descrição:
Retorna a query específica para o folder de TP Sales. Este ranking basicamente obtém as informações 
das planilhas de vendas e devoluções e aglutina estes dados de acordo com a necessidade.

Parâmetros:
Nenhum

Retorno:
cQuery    => String contendo a query de busca de devoluções.
**************************************************************************************************/
Static Function QryTPSales()

Local cQuery := ""

cQuery += "SELECT" + CRLF
cQuery += " '100006' AS SHIP_TO_CUSTOMER," + CRLF          // FIXO
cQuery += " '2354' AS BUSINESS_UNIT," + CRLF               // FIXO
cQuery += " BUSINESS_PARTNER," + CRLF                      // DEFINICAO FICSA
cQuery += " PRODUCT_CODE," + CRLF                          // CODIGO DO ITEM DE PRODUTO
cQuery += " ITEM_NUMBER," + CRLF                           // NUMERO DO ITEM
cQuery += " ITEM_DESCRIPTION," + CRLF                      // DESCRIÇÃO DO PRODUTO
cQuery += " PRODUCT_GROUP," + CRLF                         // GRUPO DO PRODUTO FERRING
cQuery += " SUM(YTD_QUANTITY) AS YTD_QUANTITY," + CRLF     // QUANTIDADE FATURADA

cQuery += " SUM(VAL_DESC_COMERCIAL) AS COM_DISC," + CRLF   // DESCONTO COMERCIAL (DESCONTO COMERCIAL + REAJUSTE DE DESCONTO)
cQuery += " SUM(VAL_CAP) AS NON_COM_DISC," + CRLF          // DESCONTO NÃO COMERCIAL (CAP)
cQuery += " SUM(VAL_DESC_OVER) AS COM_DISC_OVER," + CRLF   // DESCONTO COMERCIAL ACIMA DA POLÍTICA DE VENDAS (DESCONTO PREGÃO)

cQuery += " SUM(GROSS_SALES) AS GROSS_SALES," + CRLF       // VENDA BRUTA
cQuery += " SUM(NET_SALES) AS NET_SALES," + CRLF           // VENDA LIQUIDA
cQuery += " 'BRL' AS INV_CURRENCY," + CRLF                 // FIXO
cQuery += " 0 AS ERROR," + CRLF                            // FIXO
cQuery += " '' AS ERROR_DESCRIPTION," + CRLF               // FIXO
cQuery += " '' AS WARNING," + CRLF                         // FIXO
cQuery += " '' AS WARNING_DESCRIPTION " + CRLF             // FIXO
cQuery += "FROM (" + CRLF 
cQuery += "  SELECT" + CRLF
cQuery += "    BPCODE AS BUSINESS_PARTNER," + CRLF
cQuery += "    CODPROD AS PRODUCT_CODE," + CRLF
cQuery += "    XITNUMB AS ITEM_NUMBER," + CRLF
cQuery += "    DESCRI AS ITEM_DESCRIPTION," + CRLF
cQuery += "    GRPFERR AS PRODUCT_GROUP," + CRLF
cQuery += "    SUM(FATOR * QUANT) AS YTD_QUANTITY," + CRLF
cQuery += "    SUM(FATOR * VAL_CAP) AS VAL_CAP," + CRLF
cQuery += "    SUM(FATOR * VAL_COM + VAL_REA) AS VAL_DESC_COMERCIAL," + CRLF
cQuery += "    SUM(FATOR * VAL_PRE) AS VAL_DESC_OVER," + CRLF
//cQuery += "    SUM(FATOR * (VAL_LIQ_TOTAL_SEM_IMPOSTOS + (VAL_DESC_NF - VAL_REP - VAL_CON))) AS GROSS_SALES," + CRLF // VENDA BRUTA - IMPOSTOS (OU VENDA LIQUIDA + DESCONTO DO PEDIDO)
cQuery += "    SUM(FATOR * (VAL_LIQ_TOTAL_SEM_IMPOSTOS + VAL_COM + VAL_REA + VAL_PRE + VAL_CAP)) AS GROSS_SALES," + CRLF // VENDA LÍQUIDA (SEM OS IMPOSTOS) + DESCONTOS COMERCIAL + REAJUSTE DESCONTO + DESCONTO DE PREGAO + CAP
cQuery += "    SUM(FATOR * VAL_LIQ_TOTAL_SEM_IMPOSTOS) AS NET_SALES" + CRLF // VENDA LIQUIDA (VENDA BRUTA - MENOS DESCONTOS E IMPOSTOS)
cQuery += "  FROM (" + CRLF

cQuery += QryVendas(.T.)

cQuery += "UNION ALL " + CRLF

cQuery += QryDevolucoes(.T.)

cQuery += "  ) AS TEMP_A" + CRLF
cQuery += "  GROUP BY" + CRLF
cQuery += "     BPCODE," + CRLF
cQuery += "     TIPO," + CRLF
cQuery += "     CODPROD," + CRLF
cQuery += "     XITNUMB," + CRLF
cQuery += "     DESCRI," + CRLF
cQuery += "     GRPFERR " + CRLF
cQuery += ") AS TEMP_B " + CRLF
cQuery += "GROUP BY" + CRLF
cQuery += " BUSINESS_PARTNER," + CRLF
cQuery += " PRODUCT_CODE," + CRLF
cQuery += " ITEM_NUMBER," + CRLF
cQuery += " ITEM_DESCRIPTION," + CRLF
cQuery += " PRODUCT_GROUP " + CRLF
cQuery += "ORDER BY" + CRLF
cQuery += " ITEM_NUMBER," + CRLF
cQuery += " BUSINESS_PARTNER" + CRLF

Return cQuery


/**************************************************************************************************
Função:
QryAnaTPSales

Data:
15/06/2016

Descrição:
Retorna a query específica para o folder Analítico de TP Sales. Este ranking basicamente obtém as
informações das planilhas de vendas e devoluções e aglutina estes dados de acordo com a necessidade.

Parâmetros:
Nenhum

Retorno:
cQuery    => String contendo a query de busca de devoluções.
**************************************************************************************************/
Static Function QryAnaTPSales()

Local cQuery := ""

cQuery += "SELECT" + CRLF
cQuery += " '100006' AS SHIP_TO_CUSTOMER," + CRLF          // FIXO
cQuery += " '2354' AS BUSINESS_UNIT," + CRLF               // FIXO
cQuery += " DOC," + CRLF
cQuery += " EMISSAO," + CRLF
cQuery += " CLIENTE," + CRLF
cQuery += " LOJA," + CRLF
cQuery += " BUSINESS_PARTNER," + CRLF                      // DEFINICAO FICSA
cQuery += " PRODUCT_CODE," + CRLF                          // CODIGO DO ITEM DE PRODUTO
cQuery += " ITEM_NUMBER," + CRLF                           // NUMERO DO ITEM
cQuery += " ITEM_DESCRIPTION," + CRLF                      // DESCRIÇÃO DO PRODUTO
cQuery += " PRODUCT_GROUP," + CRLF                         // GRUPO DO PRODUTO FERRING
cQuery += " SUM(YTD_QUANTITY) AS YTD_QUANTITY," + CRLF     // QUANTIDADE FATURADA
cQuery += " SUM(VAL_DESC_COMERCIAL) AS COM_DISC," + CRLF   // DESCONTO COMERCIAL
cQuery += " SUM(VAL_CAP) AS NON_COM_DISC," + CRLF          // DESCONTO NÃO COMERCIAL (CAP)
cQuery += " SUM(VAL_DESC_OVER) AS COM_DISC_OVER," + CRLF   // DESCONTO COMERCIAL ACIMA DA POLÍTICA DE VENDAS (DESCONTO PREGÃO)
cQuery += " SUM(GROSS_SALES) AS GROSS_SALES," + CRLF       // VENDA BRUTA
cQuery += " SUM(NET_SALES) AS NET_SALES," + CRLF           // VENDA LIQUIDA
cQuery += " 'BRL' AS INV_CURRENCY," + CRLF                 // FIXO
cQuery += " 0 AS ERROR," + CRLF                            // FIXO
cQuery += " '' AS ERROR_DESCRIPTION," + CRLF               // FIXO
cQuery += " '' AS WARNING," + CRLF                         // FIXO
cQuery += " '' AS WARNING_DESCRIPTION " + CRLF             // FIXO
cQuery += "FROM (" + CRLF 
cQuery += "  SELECT" + CRLF
cQuery += "    DOC," + CRLF
cQuery += "    EMISSAO," + CRLF
cQuery += "    CLIENTE," + CRLF
cQuery += "    LOJA," + CRLF
cQuery += "    BPCODE AS BUSINESS_PARTNER," + CRLF
cQuery += "    CODPROD AS PRODUCT_CODE," + CRLF
cQuery += "    XITNUMB AS ITEM_NUMBER," + CRLF
cQuery += "    DESCRI AS ITEM_DESCRIPTION," + CRLF
cQuery += "    GRPFERR AS PRODUCT_GROUP," + CRLF
cQuery += "    SUM(FATOR * QUANT) AS YTD_QUANTITY," + CRLF
cQuery += "    SUM(FATOR * VAL_CAP) AS VAL_CAP," + CRLF
cQuery += "    SUM(FATOR * (VAL_COM + VAL_REA)) AS VAL_DESC_COMERCIAL," + CRLF
cQuery += "    SUM(FATOR * VAL_PRE) AS VAL_DESC_OVER," + CRLF
//cQuery += "    SUM(FATOR * (VAL_LIQ_TOTAL_SEM_IMPOSTOS + (VAL_DESC_NF - VAL_REP - VAL_CON))) AS GROSS_SALES," + CRLF // VENDA BRUTA - IMPOSTOS (OU VENDA LIQUIDA + DESCONTO DO PEDIDO)
cQuery += "    SUM(FATOR * (VAL_LIQ_TOTAL_SEM_IMPOSTOS + VAL_COM + VAL_REA + VAL_PRE + VAL_CAP)) AS GROSS_SALES," + CRLF // VENDA LÍQUIDA (SEM OS IMPOSTOS) + DESCONTOS COMERCIAL + REAJUSTE DESCONTO + DESCONTO DE PREGAO + CAP
cQuery += "    SUM(FATOR * VAL_LIQ_TOTAL_SEM_IMPOSTOS) AS NET_SALES" + CRLF // VENDA LIQUIDA (VENDA BRUTA - MENOS DESCONTOS E IMPOSTOS)
cQuery += "  FROM (" + CRLF

cQuery += QryVendas(.T.)

cQuery += "UNION ALL " + CRLF

cQuery += QryDevolucoes(.T.)

cQuery += "  ) AS TEMP_A" + CRLF
cQuery += "  GROUP BY" + CRLF
cQuery += "     DOC," + CRLF
cQuery += "     EMISSAO," + CRLF
cQuery += "     CLIENTE," + CRLF
cQuery += "     LOJA," + CRLF
cQuery += "     BPCODE," + CRLF
cQuery += "     TIPO," + CRLF
cQuery += "     CODPROD," + CRLF
cQuery += "     XITNUMB," + CRLF
cQuery += "     DESCRI," + CRLF
cQuery += "     GRPFERR " + CRLF
cQuery += ") AS TEMP_B " + CRLF
cQuery += "GROUP BY" + CRLF
cQuery += " DOC," + CRLF
cQuery += " EMISSAO," + CRLF
cQuery += " CLIENTE," + CRLF
cQuery += " LOJA," + CRLF
cQuery += " BUSINESS_PARTNER," + CRLF
cQuery += " PRODUCT_CODE," + CRLF
cQuery += " ITEM_NUMBER," + CRLF
cQuery += " ITEM_DESCRIPTION," + CRLF
cQuery += " PRODUCT_GROUP " + CRLF
cQuery += "ORDER BY" + CRLF
cQuery += " ITEM_NUMBER," + CRLF
cQuery += " BUSINESS_PARTNER" + CRLF

Return cQuery


/**************************************************************************************************
Função:
QryCMED

Data:
29/06/2016

Descrição:
Retorna a query específica para o folder contendo os dados para a CMED.

Parâmetros:
Nenhum   

Retorno:
cQuery    => String contendo a query.
**************************************************************************************************/
Static Function QryCMED()

Local cQuery := ""
// Removido este controle dos 6 meses retroativos a pedido do Bruno da Silva dos Santos. O mesmo disse que fará este controle manualmente.
//Local dDataIni := MonthSub(MV_PAR02, 6) // O relatório exibe informações para os últimos 6 meses, contados a partir da data informada no parâmetro Até.
//Local dDataBkp := MV_PAR01
//MV_PAR01 := dDataIni // Altero a data inicial que foi informado no parâmetro apenas para esta query.
		      
cQuery += "SELECT" + CRLF
cQuery += " CDGGREM," + CRLF
cQuery += " SUBSTRING(DT_CONSOL, 1, 4) AS ANO," + CRLF
cQuery += " SUBSTRING(DT_CONSOL, 5, 2) AS MES," + CRLF
cQuery += " ISNULL(X5_CHAVE, '') AS TIPO," + CRLF
cQuery += " SUM(FATOR * QUANT) AS QUANT," + CRLF
cQuery += " SUM(FATOR * (VALBRUT - ICMSRET)) AS VALOR " + CRLF // tbb - 22/08/2017 - Alterado a forma de cálculo do valor de faturamento, que passa a ser: Valor da Nota Fiscal - Valor de Repasse
cQuery += "FROM (" + CRLF
cQuery += QryVendas(.T.)
// Inicialmente foi definido que não serão consideradas as devoluções para este folder.
// Adicionar as duas linhas abaixo caso seja definido que as devoluções devam ser consideradas.
// Revisão: Em 15/08/2016 o usuário Bruno da Silva dos Santos definiu que as devoluções
// deverão sim ser consideradas, então foram removidos os comentários das duas linhas abaixo.
cQuery += "UNION ALL " + CRLF
cQuery += QryDevolucoes(.T.)
cQuery += " ) AS TEMP_A " + CRLF
cQuery += "LEFT JOIN " + RetSqlName('SX5') + " SX5" + CRLF
cQuery += "  ON X5_FILIAL = '" + xFilial("SX5") + "'" + CRLF
cQuery += "  AND X5_TABELA = 'Z2'" + CRLF
cQuery += "  AND X5_DESCRI = TEMP_A.TIPO" + CRLF
cQuery += "  AND SX5.D_E_L_E_T_ = '' " + CRLF
cQuery += "GROUP BY" + CRLF
cQuery += " CDGGREM," + CRLF
cQuery += " SUBSTRING(DT_CONSOL, 1, 4)," + CRLF
cQuery += " SUBSTRING(DT_CONSOL, 5, 2)," + CRLF
cQuery += " X5_CHAVE" + CRLF
cQuery += "ORDER BY" + CRLF
cQuery += " CDGGREM," + CRLF
cQuery += " ANO," + CRLF
cQuery += " MES," + CRLF
cQuery += " TIPO" + CRLF

//MV_PAR01 := dDataBkp // Restauro a data do parâmetro

Return cQuery


/**************************************************************************************************
Função:
ExecutaRotina

Autor:
Tiago Bandeira Brasiliano

Data:
31/08/2017

Descrição:
Executa uma rotina diretamente pela tela inicial do Protheus (sem a necessidade de login).

Parâmetros:
bRotina  => Bloco de código contendo a rotina que será executada.
lTela    => Abre uma pré-tela para a rotina (necessário para rotinas com browse por exemplo). Default = .F.
cEmpresa => Código da Empresa que será aberta.
cFilPar  => Código da Filial.
cUser    => Nome do usuário (login).
cSenhaU  => Senha do usuário.
cModulo  => Módulo do sistema.

Retorno:
Nenhum
**************************************************************************************************/
User Function ExecutaRotina(bRotina, lTela, cEmpresa, cFilPar, cUser, cSenhaU, cModulo)

Private oMainWnd := Nil

Default lTela    := .F.
Default cEmpresa := "01"
Default cFilPar  := "01"
Default cUser    := ""
Default cSenhaU  := ""
Default cModulo  := "FAT"

If RpcSetEnv(cEmpresa, cFilPar, cUser, cSenhaU, cModulo, GetEnvServer(), {"SF2", "SD2", "SF1", "SD1", "SA1", "SA2", "SE4", "SB1"})
	
	__cInternet := Nil
	
	InitPublic()
	SetsDefault()
	
	If lTela
		DEFINE WINDOW oMainWnd FROM 001,001 TO 400,500 TITLE OemToAnsi( FunName() )
		ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bRotina ) , oMainWnd:End() )
	
	Else
		Eval(bRotina)
	EndIf
	
	RpcClearEnv()
	
EndIf

Return .T.


/**************************************************************************************************
Função:
TesteRanking

Autor:
Tiago Bandeira Brasiliano

Data:
31/08/2017

Descrição:
Executa o ranking de vendas sem a necessidade de efetuar login no sistema (para testes).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
/*Removido - Driele Pinheiro - Erpplus 23/01/2020*/ 
/*User Function TesteRanking()

U_ExecutaRotina({|| U_FeRank()}, , "99", "01", "admin", "a")
	
Return .T.*/
