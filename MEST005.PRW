/************
MEST005
Rotina que irá copiar a regra padrão para todos os clientes
Marcelo Klopfer Leme
25/10/2016
************/
#Include "PROTHEUS.CH"

USER FUNCTION MEST005()

IF MSGYESNO("<<< Atenção >>>           -                    <<< Atenção >>> "+CHR(10)+CHR(13)+;
	"<<< Deseja atualizar todos os clientes com a REGRA PADRÃO? >>> "+CHR(10)+CHR(13)+;
	"<<< Atenção >>>           -                    <<< Atenção >>> ")
	
	lRet := .T.
	PROCESSA({|| MEST05A()},"Atualizando regras para todos os cliente.","Aguarde!")
ENDIF
RETURN()

STATIC FUNCTION MEST05A()
cQuery := "DELETE "+RetSqlName("SZB")+" WHERE ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB_CLIENTE <> '999999' "
TCSQLEXEC(cQuery)

cQuery := "SELECT * FROM "+RetSqlName("SZA")+" ZA "
cQuery += "WHERE ZA.D_E_L_E_T_ = '' AND ZA_CLIENTE <> '999999' "
cQuery += "ORDER BY ZA_CLIENTE "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSZA', .F.,.T.)

cQuery := "SELECT * FROM "+RetSqlName("SZB")+" ZB "
cQuery += "WHERE ZB.D_E_L_E_T_ = '' AND ZB_CLIENTE = '999999' "
cQuery += "ORDER BY ZB_PRODUTO "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSZB', .F.,.T.)
WHILE TSZB->(!EOF())
	
	TSZA->(DBGOTOP())
	WHILE TSZA->(!EOF())
		INCPROC()
		RECLOCK("SZB",.T.)
		SZB->ZB_FILIAL  := XFILIAL("SZB")
		SZB->ZB_CLIENTE := TSZA->ZA_CLIENTE
		SZB->ZB_LOJA    := TSZA->ZA_LOJA
		SZB->ZB_PRODUTO := TSZB->ZB_PRODUTO
		SZB->ZB_DESCRI  := TSZB->ZB_DESCRI
		SZB->ZB_RGPUBLI := TSZB->ZB_RGPUBLI
		SZB->ZB_RGPRIVA := TSZB->ZB_RGPRIVA
		MSUNLOCK()
		TSZA->(DBSKIP())
	ENDDO
	TSZB->(DBSKIP())
ENDDO
TSZB->(DBCLOSEAREA())
TSZA->(DBCLOSEAREA())
RETURN()
