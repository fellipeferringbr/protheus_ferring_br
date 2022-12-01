/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNAB_REAL       º       ³Microsiga           º Data ³  13/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PROGRAMA PARA GRAVAR O CNPJ OU CPF CONFORME CONFIGURACAO         º±±
±±º          ³ DO CNAB DO BANCO REAL, POSICOES 221 A 234.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

// TRATAMENTO PARA POSICAO 221 A 229 DO LAYOUT REAL.REM - REGISTRO DETALHE
 
User Function CNPJ_REAL()
_cRet:=" "

If empty(SA1->A1_CGC)    // Cliente não tem CNPJ
	MSGSTOP("Cliente sem CNPJ ou CPF ==> "+TRIM(SA1->A1_COD)+SA1->A1_LOJA)
	_cRet := "000000000"
ElseIf LEN(SA1->A1_CGC)==14  // CNPJ
	_cRet := SUBS(SA1->A1_CGC,1,8)+SUBS(SA1->A1_CGC,9,1)
Else // só pode ser CPF
	_cRet := SUBS(SA1->A1_CGC,1,9)
Endif

                         
RETURN(_cRet)



// TRATAMENTO PARA POSICAO 230 A 232 DO LAYOUT REAL.REM - REGISTRO DETALHE

User Function CNPJFILIAL_REAL()
_cRet:=" "

IF(EMPTY(SA1->A1_CGC) .OR. LEN(SA1->A1_CGC)<>14)  // CPF ou sem cadastro CNPJ
	_cRet:="000"
Else // CNPJ
	_cRet:=SUBS(SA1->A1_CGC,10,3)
Endif

                         
RETURN(_cRet)


