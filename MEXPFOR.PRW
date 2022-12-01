#INCLUDE "RWMAKE.CH"
#Include "PROTHEUS.CH"

USER FUNCTION MEXPFOR()
PRIVATE nHdl
PRIVATE oDirExp
PRIVATE cDirExp := SPACE(100)
//PRIVATE xServidor := ALLTRIM(GETMV("MV_EXPFORS"))
//PRIVATE xLogin    := ALLTRIM(GETMV("MV_EXPFORL"))
//PRIVATE xSenha    := ALLTRIM(GETMV("MV_EXPFORP"))
//PRIVATE xDirUP    := ALLTRIM(GETMV("MV_EXPFORD"))
PRIVATE xServidor := ALLTRIM("ferring.agence.com.br")
PRIVATE xLogin    := ALLTRIM("ferring")
PRIVATE xSenha    := ALLTRIM("@Ferring@")
PRIVATE xDirUP    := ALLTRIM("/fornecedor/")
PRIVATE cRootFTP
PRIVATE cDirFTP

RPCSetType(3)
RpcSetEnv("01", "01", Nil, Nil, "05", Nil, {"SA2"})
MEXPFOR1()
RpcClearEnv()

RETURN()

STATIC FUNCTION MEXPFOR1()
LOCAL nTamLin, cLin, cCpo
LOCAL cPath := ""

SA2->(DBSETORDER(1))
SA2->(DBGOTOP())


//cDirExp := "\EXPFORNE\"+"FORNECEDOR"+DTOS(dATE())+".CSV"   - 20.07.17 - Alterado por Franklin porque eles querem `.txt`
cDirExp := "\EXPFORNE\"+"FORNECEDOR"+DTOS(dATE())+".txt"
nHdl  := fCreate(cDirExp)
WHILE SA2->(!EOF())
	
	IF SUBSTR(SA2->A2_COD,1,1) $ "012345678"
		cLin := ALLTRIM(SA2->A2_COD) + ";" + ALLTRIM(SA2->A2_LOJA) + ";" + ALLTRIM(SA2->A2_TIPO) + ";" + ALLTRIM(SA2->A2_CGC) + ";"
		cLin += ALLTRIM(SA2->A2_NOME) + ";" + ALLTRIM(SA2->A2_PFISICA) + ";" + ALLTRIM(SA2->A2_END) + ";" + ALLTRIM(SA2->A2_BAIRRO) + ";"  
		cLin += ALLTRIM(SA2->A2_EST) + ";" + ALLTRIM(SA2->A2_COD_MUN) + ";" + ALLTRIM(SA2->A2_MUN) + ";" + ALLTRIM(SA2->A2_CEP) + ";" 
		cLin += ALLTRIM(SA2->A2_EMAIL) + ";"   
		cLin += ALLTRIM(SA2->A2_DDD) + ";" + ALLTRIM(SA2->A2_TEL) + ";" + ALLTRIM(SA2->A2_BANCO) + ";" + ALLTRIM(SA2->A2_AGENCIA) + ";" 
		cLin += ALLTRIM(SA2->A2_NUMCON) + ";" + ALLTRIM(SA2->A2_INSCR) + ";" + ALLTRIM(SA2->A2_INSCRM) + ";" + ALLTRIM(SA2->A2_MSBLQL) + ";" + CHR(13)+CHR(10)
		FWRITE(nHdl,cLin,Len(cLin))
	ENDIF
	SA2->(DBSKIP())
ENDDO

FCLOSE(nHdl)

FTPDisconnect()
/************
1 - Servidor FTP
2 - Porta de Conexao
3 - Login
4 - Senha
************/
IF !FTPConnect(xServidor,,xLogin,xSenha)
	lRet := .F.
ELSE
	
	IF FTPDirChange(ALLTRIM(xDirUP))
	//	IF !FTPUpLoad(cDirExp, xDirUP + ("FORNECEDOR"+DTOS(DATE())+".CSV"))   - alterado por Franklin porque a empresa quer `.txt`
		IF !FTPUpLoad(cDirExp, xDirUP + ("FORNECEDOR"+DTOS(DATE())+".txt"))
			lRet := .F.
		ELSE
			lRet := .T.
		ENDIF
	ENDIF
ENDIF

RETURN()
