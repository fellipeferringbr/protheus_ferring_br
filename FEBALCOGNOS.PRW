#INCLUDE "TOTVS.CH"


/**************************************************************************************************	
Função:
FeBalCognos

Autor:
Tiago Bandeira Brasiliano

Data:
13/06/2017

Descrição:
Emite um relatório de balancete customizada da Ferring, contendo as contas contábeis do sistema
Cognos (este relatório foi desenvolvido inicialmente para envio à Matriz a pedido do Luiz Pegoraro
e com a ajuda do Bruno Vanderlei Pereira).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FeBalCognos()

Local cPerg      := "FEBALCOG"
Local cDirPad    := "C:\Temp\"
Local cTitulo    := "Balancete Cognos"
Local cNomeR     := "FEBALCOGNOS"
Local cDescr     := "Este rotina tem como finalidade criar um relatório Excel contendo os dados de balancete para o sistema Cognos."
Local cTipoArq   := "XML"
Local nOpcPad    := 1 // 1 = gerar arquivo e abrir / 2 = somente gerar aquivo em disco
Local cMsgProc   := "Aguarde. Gerando relatório de Balancete Cognos..."
Local aNaturezas := {}

Pergunte(cPerg, .F.)

U_XMLPerg(cPerg,; 
          cDirPad,; 
          {|lEnd, cArquivo| ImprimeRel(@lEnd, cArquivo)},; 
          cTitulo,; 
          cNomeR,; 
          cDescr,;
          cTipoArq,;
          nOpcPad,;
          cMsgProc)

Return .T.


/**************************************************************************************************
Função:
ImprimeRel

Autor:
Tiago Bandeira Brasiliano

Data:
13/06/2017

Descrição:
Imprime o relatório em Excel

Parâmetros:
lEnd     => Booleano usado para sair da rotina.
cArquivo => Nome do arquivo XML que será gerado.

Retorno:
Nenhum
**************************************************************************************************/
Static Function ImprimeRel(lEnd, cArquivo)

Local nQtdReg := 0
Local oXML    := Nil
Local cXML    := ""

Private cAliasTmp   := GetNextAlias()
Private oSCabec1    := Nil
Private oSTexto1    := Nil
Private oSData1     := Nil

//+----------------------------------------------------------------------+
//| Define os estilos que serão utilizados para as células               |
//+----------------------------------------------------------------------+
oSCabec1 := CellStyle():New("oSCabec1")
oSCabec1:SetHAlign("Left")
oSCabec1:SetVAlign("Bottom")
oSCabec1:SetFont("Calibri", 9, "#FFFFFF")
oSCabec1:SetInterior("#376091")

//+-----------------------------------------------------+
//|Gera os dados do relatório.                          |
//+-----------------------------------------------------+
GeraTmp()
dbSelectArea(cAliasTmp)
Count To nQtdReg
(cAliasTmp)->(dbGoTop())
ProcRegua(nQtdReg)
(cAliasTmp)->(dbGoTop())

If (cAliasTmp)->(Eof())
	MsgInfo("Não existem dados para os parâmetros informados.", "Atenção")
	Return .F.
EndIf

//+----------------------------------------------------------------------+
//| Cria o objeto xml excel                                              |
//+----------------------------------------------------------------------+
oXML := ExcelXML():New()

oXML:SetFolder(1)
oXML:SetFolderName("CONTRATOS")

//+----------------------------------------------------------------------+
//| Define a largura das colunas                                         |
//+----------------------------------------------------------------------+
oXML:SetColSize({"130", "130", "130", "130", "130", "130", "130", "130", "130", "130", "130"})

//+-----------------------------------------------------+
//| Imprime o relat¢rio a partir do arquivo temporário  |
//+-----------------------------------------------------+

ImprimeCabec(@lEnd, cArquivo, oXML)

While !(cAliasTmp)->(Eof())
    
	IncProc()
	
	ImprimeItem(@lEnd, cArquivo, @oXML)
    
    (cAliasTmp)->(dbSkip())
EndDo

//+----------------------------------------------------------------------+
//| Configura algumas opções da planilha, como o zoom e o grid           |
//+----------------------------------------------------------------------+
oXML:SetZoom(75)
oXML:SetPageSetup(/*nLayout*/, /*lHCenter*/, /*lVCenter*/, 0.4/*nTopMar*/, 0.4/*nBottomMar*/, 0.4/*nLeftMar*/, 0.4/*nRightMar*/, 0 /*nHeaderMar*/, 0/*nFooterMar*/)
oXML:SetPrintSetup(/*nPaperSize*/, 84/*nZoomScale*/,/*nFitWidth*/,/*nFitHeight*/,.T./*lValidPrinter*/)
//oXML:ShowGridLine(.F.)	
	
//+----------------------------------------------------------------------+
//| Gera a string contendo o código xml                                  |
//+----------------------------------------------------------------------+
cXML := oXML:GetXML(cArquivo)

(cAliasTmp)->(dbCloseArea())
          
Return .T.


/**************************************************************************************************
Função:
GeraTmp

Autor:
Tiago Bandeira Brasiliano

Data:
13/06/2017

Descrição:
Gera dados no arquivo temporario.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function GeraTmp()

If Select(cAliasTmp) > 0
	(cAliasTmp)->(dbCloseArea())
EndIf

BEGINSQL ALIAS cAliasTmp
    
    %NoParser%
    
    SELECT
	   ACCOUNT,
	   BUSINESS_UNIT,
	   SUM(PERIODO_ANTERIOR) AS PERIODO_ANTERIOR,
	   SUM(PERIODO_ATUAL) AS PERIODO_ATUAL,
	   SUM(SALDO_ATUAL) AS SALDO_ATUAL
	FROM (

		SELECT
		    //QRY1.CONTA AS CONTA_PROTHEUS,
			//QRY1.CUSTO AS CUSTO,
		    CT1__CTACO AS ACCOUNT,
			CASE WHEN SUBSTRING(CT1__CTACO, 1, 1) IN ('1','2','3','4') THEN '2354LE' ELSE ISNULL(CTT.CTT__CCCOG, '') END AS BUSINESS_UNIT,
			ROUND(SUM(QRY1.PERIODO_ANTERIOR), 2) AS PERIODO_ANTERIOR,
			ROUND(SUM(QRY1.PERIODO_ATUAL), 2) AS PERIODO_ATUAL,
			ROUND(SUM(QRY1.PERIODO_ANTERIOR) + SUM(QRY1.PERIODO_ATUAL), 2) AS SALDO_ATUAL
		FROM (
		      // VALOR DO PERIODO ATUAL PARA OS CENTROS DE CUSTO
		      SELECT
		          CT3.CT3_CONTA AS CONTA,
		          CT3.CT3_CUSTO AS CUSTO,
				  0 AS PERIODO_ANTERIOR,
				  SUM(CT3.CT3_DEBITO - CT3.CT3_CREDIT) AS PERIODO_ATUAL
			  FROM %Table:CT3% CT3
			  INNER JOIN %Table:CT1% CT1
			      ON CT1_CONTA = CT3_CONTA
			      AND CT1.%NotDel%
			  WHERE  CT3.%NotDel%
				 AND CT3_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			     AND CT3.CT3_CONTA BETWEEN %Exp:MV_PAR03% AND  %Exp:MV_PAR04%
			      AND CT1__CTACO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				 AND CT3.CT3_MOEDA = '01'
				 AND CT3.CT3_TPSALD = '1'
				  AND CT1.CT1__CTACO <> '' 
			      AND CT1.CT1__IC = '1'
		      GROUP BY CT3.CT3_CUSTO, CT3.CT3_CONTA
			  
			  UNION ALL
			  
			  // VALOR DO PERIODO ATUAL PARA O PLANO DE CONTAS
			  SELECT
			      CT7_CONTA AS CONTA,
				  ' ' AS CUSTO,
				  0 AS PERIODO_ANTERIOR,
				  (CT7_DEBITO - ISNULL (CT3_DEBITO, 0)) - (CT7_CREDIT - ISNULL (CT3_CREDIT, 0)) AS PERIODO_ATUAL
			  FROM (SELECT
			            CT7.CT7_CONTA,
						SUM(CT7.CT7_DEBITO) AS CT7_DEBITO,
						SUM(CT7.CT7_CREDIT) AS CT7_CREDIT
			        FROM %Table:CT7% CT7
			        INNER JOIN %Table:CT1% CT1
			            ON CT1_CONTA = CT7_CONTA
			            AND CT1.%NotDel%
					WHERE
					    CT7.%NotDel%
					    AND CT7_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
						AND CT7.CT7_CONTA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			            AND CT1__CTACO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
					    AND CT7.CT7_MOEDA = '01'
					    AND CT7.CT7_TPSALD = '1'
				        AND CT1.CT1__CTACO <> '' 
			            AND CT1.CT1__IC = '1'
					GROUP BY CT7.CT7_CONTA
			  ) CT7_ORIGINAL
			  LEFT JOIN (
			        SELECT
					    CT3.CT3_CONTA,
						SUM(CT3.CT3_DEBITO) AS CT3_DEBITO,
						SUM(CT3.CT3_CREDIT) AS CT3_CREDIT
			        FROM %Table:CT3% CT3
			        INNER JOIN %Table:CT1% CT1
			            ON CT1_CONTA = CT3_CONTA
			            AND CT1.%NotDel%
					WHERE
					    CT3.%NotDel%
						AND CT3_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
						AND CT3.CT3_CONTA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			            AND CT1__CTACO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND CT3.CT3_MOEDA = '01'
					    AND CT3.CT3_TPSALD = '1'
				        AND CT1.CT1__CTACO <> '' 
			            AND CT1.CT1__IC = '1'
					GROUP BY CT3.CT3_CONTA
			  ) CT3_ORIGINAL
			  ON CT7_ORIGINAL.CT7_CONTA = CT3_ORIGINAL.CT3_CONTA
				
			  UNION ALL
			  
			  // VALOR DO PERIODO ANTERIOR PARA OS CENTROS DE CUSTO
			  SELECT
			      CT3.CT3_CONTA AS CONTA,
				  CT3.CT3_CUSTO AS CUSTO,
				  SUM(CT3.CT3_DEBITO - CT3.CT3_CREDIT) AS PERIODO_ANTERIOR,
				  0 AS PERIODO_ATUAL
			  FROM %Table:CT3% CT3
			  INNER JOIN %Table:CT1% CT1
			      ON CT1_CONTA = CT3_CONTA
			      AND CT1.%NotDel%
			  WHERE CT3.%NotDel%
			      AND CT3_DATA < %Exp:MV_PAR01%
			      AND CT3.CT3_CONTA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			      AND CT1__CTACO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				  AND CT3.CT3_MOEDA = '01'
			      AND CT3.CT3_TPSALD = '1'
				  AND CT1.CT1__CTACO <> '' 
			      AND CT1.CT1__IC = '1'
			  GROUP BY CT3.CT3_CUSTO , CT3.CT3_CONTA
			  
			  UNION  ALL
			  
			  // VALOR DO PERIODO ANTERIOR PARA O PLANO DE CONTAS
			  SELECT
			      CT7_CONTA AS CONTA,
				  ' ' AS CUSTO,
				  (CT7_DEBITO - ISNULL (CT3_DEBITO, 0)) - (CT7_CREDIT - ISNULL (CT3_CREDIT, 0)) AS PERIODO_ANTERIOR,
			      0 AS PERIODO_ATUAL
			  FROM (SELECT
			            CT7.CT7_CONTA,
						SUM(CT7.CT7_DEBITO ) AS CT7_DEBITO,
						SUM(CT7.CT7_CREDIT ) AS CT7_CREDIT
			        FROM %Table:CT7% CT7
			        INNER JOIN %Table:CT1% CT1
			            ON CT1_CONTA = CT7_CONTA
			            AND CT1.%NotDel%
					WHERE CT7.%NotDel%
					    AND CT7_DATA < %Exp:MV_PAR01%
					    AND CT7.CT7_CONTA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			            AND CT1__CTACO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
					    AND CT7.CT7_MOEDA = '01'
					    AND CT7.CT7_TPSALD = '1'
				        AND CT1.CT1__CTACO <> '' 
			            AND CT1.CT1__IC = '1'
					GROUP BY CT7.CT7_CONTA ) CT7_ANTERIOR
			  LEFT JOIN (
			        SELECT
					    CT3.CT3_CONTA,
						SUM(CT3.CT3_DEBITO ) AS CT3_DEBITO,
						SUM(CT3.CT3_CREDIT ) AS CT3_CREDIT
			        FROM %Table:CT3% CT3
			        INNER JOIN %Table:CT1% CT1
			            ON CT1_CONTA = CT3_CONTA
			            AND CT1.%NotDel%
					WHERE CT3.%NotDel%
						AND CT3_DATA < %Exp:MV_PAR01%
					    AND CT3.CT3_CONTA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			            AND CT1__CTACO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND CT3.CT3_MOEDA = '01'
						AND CT3.CT3_TPSALD = '1'
				        AND CT1.CT1__CTACO <> '' 
			            AND CT1.CT1__IC = '1'
					GROUP BY CT3.CT3_CONTA ) CT3_ANTERIOR
		           ON CT7_ANTERIOR.CT7_CONTA = CT3_ANTERIOR.CT3_CONTA
		) QRY1
		LEFT JOIN %Table:CT1% CT1
		    ON CT1.CT1_CONTA = QRY1.CONTA
			AND CT1.%NotDel%
		LEFT JOIN %Table:CTT% CTT
		    ON CTT.CTT_CUSTO = QRY1.CUSTO
			AND CTT.%NotDel%
		GROUP BY
		    //CONTA,
		    //CUSTO,
		    CT1__CTACO,
			CTT__CCCOG
	) QRY2
	GROUP BY
	    ACCOUNT,
	    BUSINESS_UNIT
	ORDER BY
	    ACCOUNT,
	    BUSINESS_UNIT
   
ENDSQL

cQuery := GetLastQuery()[2]
MemoWrite("C:\Temp\FEBALCOGNOS.sql", cQuery)

Return .T.


/**************************************************************************************************
Função:
ImprimeCabec

Autor:
Tiago Bandeira Brasiliano

Data:
13/06/2017

Descrição:
Imprime o cabeçalho do relatório de Romaneio de Entrega.

Parâmetros:
lEnd      -> Booleano usado para sair da rotina.
cArquivo  -> Nome do arquivo XML que será gerado.
oXML      -> Objeto XML que está sendo criado.

Retorno:
Nenhum
**************************************************************************************************/
Static Function ImprimeCabec(lEnd, cArquivo, oXML)

//+----------------------------------------------------+
//| Monta cabeçalho do relatório                       |
//+----------------------------------------------------+
oXML:AddRow("15", {"Event:", "Actuals Third Party " + AllTrim(Str(Year(MV_PAR02))) + AllTrim(Str(Month(MV_PAR02))), "Start date:", DtoC(MV_PAR01) ,"End date:",	DtoC(MV_PAR02)})
oXML:AddRow("15", {"Entity:", "BR000", "Currency:", "BRL"})
oXML:SkipLine()
oXML:AddRow("15", {"!do not modify the columns name or order"})
oXML:AddRow("15", {"Account", "Business Unit", "Business Partner", "Product group GF name", "Product group GF code", "BUC row name", "YTD Amount in K (Reporting currency)", "Error", "Error desc.", "Warning", "WARNING_DESC"})

Return .T.


/**************************************************************************************************
Função:
ImprimeItem

Autor:
Tiago Bandeira Brasiliano

Data:
13/06/2017

Descrição:
Imprime os itens do relatório de Romaneio de Entrega.

Parâmetros:
lEnd     => Booleano usado para sair da rotina.
cArquivo => Nome do arquivo XML que será gerado.
oXML     => Objeto de XML do relatório.

Retorno:
Nenhum
**************************************************************************************************/
Static Function ImprimeItem(lEnd, cArquivo, oXML)
    
oXML:AddRow("15",{(cAliasTmp)->ACCOUNT,;
                  (cAliasTmp)->BUSINESS_UNIT,;
                  "",;
                  "",;
                  "",;
                  "",;
                  (cAliasTmp)->SALDO_ATUAL,;
                  "",;
                  "",;
                  "",;
                  ""})

Return .T.

