#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "DBINFO.ch"
#INCLUDE "Tbiconn.ch"
#INCLUDE "RWMAKE.CH"
#DEFINE CRLF CHR(13)+CHR(10)

User Function MPROCSDD

Local aArea 	:= GetArea()
Local aAreaSDD 	:= SDD->(GetArea())
Local aAreaSB8 	:= SBF->(GetArea())
//Local _aCab 	:= {}
//Local _aItens 	:= {}
//Local cNumSD7	:= SD7->D7_NUMERO
//Local cProdSD7	:= SD7->D7_PRODUTO
Local cAliasTrb	:= GetNextAlias()
Local cQuery	:= ""
Local nX		:= 0
//Local nPosTipo	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D7_TIPO"})
//Local nPosEst	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D7_ESTORNO"})
//Local nPosSeq	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D7_SEQ"})
Local cCod       := ''
Local cLocal     := ''
Local cLoteCtl   := ''
Local cNumLote   := ''
Local cNumSerie  := ''
Local cLocaliza  := ''
Local nQuant     := 0
Local nSaldo     := 0
Local nQtOri     := 0
//Local lEntrou	:= .F.
Local lUsaLuft	:= GetMV("ES_INTOPLO")		 // Se usa armazem Luft

//Variáveis do projeto de inclusão da AGV
Local cFileName := ""
Local oEmail
Local oTexto
Local cDestEML := ""
Local cTexto := ""   


Private _cDescOper := ""
//Fim - Variáveis do projeto de inclusão da AGV

Private _cLAmostra := GetMv("ES_LAMOSTR")
Private _cLRejeica := GetMv("ES_LREJEIC")
Private _cLCQ      := GetMv("MV_CQ")                                     

lBloqueia := .F.       
DbSelectArea("SDD")
cCod       := M->DD_PRODUTO
cLocal     := M->DD_LOCAL
cLoteCtl   := M->DD_LOTECTL
cNumLote   := M->DD_NUMLOTE
cNumSerie  := M->DD_NUMSERI
cLocaliza  := M->DD_LOCALIZ
nQuant     := M->DD_QUANT
nSaldo     := M->DD_SALDO
nQtOri     := M->DD_QTDORIG 


IF FunName() != "MATA215" //Inclusão em 11/08/2020-Brunna Alves QSdoBrasil para que ao executar a rotina Refaz Acumulados não seja executado o ponto de entrada 

if "BLOQUEAR" $ cCadastro  
	lBloqueia := .T.
Endif

//msgalert("chamando MT275TOK")
 
//Condição inclusa para a inclusão da AGV como operador logístico.
If GETMV("MV_XUSAAGV")
	cFileName := "BL"+ SUBSTR(DTOS(dDataBase),7,4) + SUBSTR(DTOS(dDataBase),5,2) + "_" + STRTRAN(TIME(),":") +".TXT"

	oTexto := EPARQTXT():NEW( Alltrim(GETMV("MV_XOUTAGV"))+ cFileName )
	oTexto:CRIARTXT()

	If lBloqueia
		oTexto:INCLINHA( 	PADR( SDD->DD_PRODUTO , 15) +;
		                    PADR( SDD->DD_LOTECTL , 20 ) +;
		                    "B" +;
		                	SPACE(11)  +;
							SPACE(5) )
							
		cTexto += "O lote "+ SDD->DD_LOTECTL +", quantidade "+ Alltrim(STR(SDD->DD_QUANT)) +", do produto "+ Alltrim(SDD->DD_PRODUTO) +" foi Lote Bloqueado em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName
	Else
		oTexto:INCLINHA( 	PADR( SDD->DD_PRODUTO , 15) +;
		                    PADR( SDD->DD_LOTECTL , 20 ) +;
		                    "L" +;
		                	SPACE(11)  +;
							SPACE(5) )
							
		cTexto += "O lote "+ SDD->DD_LOTECTL +", quantidade "+ Alltrim(STR(SDD->DD_QUANT)) +", do produto "+ Alltrim(SDD->DD_PRODUTO) +" foi Lote Liberado em "+ SUBSTR(DTOS(dDataBase),7,2) +"/"+ SUBSTR(DTOS(dDataBase),5,2) +"/"+ SUBSTR(DTOS(dDataBase),1,4) +" as "+ Time() +" Arquivo Gerado: "+  cFileName +CHR(13)+CHR(10) +CHR(13)+CHR(10) +"Realizado por: "+ cUserName	
	Endif	
	oTexto:FECHATXT()
	
	// Cria registro no monitor de integração.
	u_FEGrvZZD(cFileName,, IIF(lBloqueia,"B","L") , "" ,"", .F.,"SDD", SDD->DD_PRODUTO , SDD->DD_LOTECTL )
	
	//Atualiza status do registro
	SDD->(Reclock("SDD",.F.))
	SDD->DD_XDENVOL := dDataBase
	SDD->DD_XHENVOL := Time()
	SDD->DD_XAENVOL := cFileName
	SDD->(MsUnlock())
	
	//Envia arquivo para o FTP do Operador Logístico
	If U_FESTA006( "D3Q" , "BL*.TXT" , "MPROCSDD" , "Interface Status Lotes" )
		// Envia e-mail de notificação
		cDestEML := U_RETMAILTO("D3Q")	
	
		oEmail := CONEMAIL():NEW( GETMV("MV_RELSERV") , GETMV("MV_RELACNT") , GETMV("MV_RELPSW") )
		If oEmail:CONECTAR()
		    oEmail:ENVIAR( GETMV("MV_RELACNT") , cDestEML , "Interface Status Lotes" , cTexto ,  )
		    oEmail:DESCONEC()
		Endif
	Endif
Else
	IF lUsaLuft //.and.  cLocal  = _cLCQ
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ chama a funcao que gera o arquivo de integracao	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		IF lBloqueia
		   U_FCFGM001(.T.,5,SDD->(RECNO())) 
		   Msgalert("Bloqueio de Lote efetuado com sucesso","Bloq. Lote") 
		Else 
		   U_FCFGM001(.F.,6,SDD->(RECNO())) 
		   Msgalert("Liberação de Lote efetuado com sucesso","Libera Lote") 
		Endif   
		
	Endif
Endif

Endif

RestArea(aAreaSB8)
RestArea(aAreaSDD)
RestArea(aArea)

Return(.T.)
