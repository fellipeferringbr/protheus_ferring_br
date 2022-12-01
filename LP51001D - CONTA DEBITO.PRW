#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP-510/002ºAutor  ³Franklin Wilker     º Data ³  20/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³Lancamentos Credito                                         º±±
±±º          ³Fornecedores:		   	                                      º±±
±±º          ³000164 - FERRING GMBH                                       º±±
±±º          ³001772 - AEROPORTOS BRASIL - VIRACOPOS S.A.                 º±±
±±º          ³000023 - FERRING INTERNACIONAL CENTER SA                    º±±
±±º          ³000027 - UNITRADE ASSESS.COMERCIO EXTERIOR LTDA             º±±
±±º          ³SEC-SP - SECRETARIA DA FAZENDA SAO PAULO                    º±±
±±º          ³999999 - UNIAO						                      º±±
±±º          ³Naturezas: 								                  º±±
±±º          ³1401 - ADTO IMPORTACAO               		                  º±±
±±º          ³4023 - OUTROS CUSTOS                 		                  º±±
±±º          ³5001 - COMPRA PRODUTO VR BRUTO - T/P 		                  º±±
±±º          ³2463 - ICMS NA IMPORTACAO                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³LP's - importaçao do eic no financeiro off line             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LP51001D()

Local _cRetC1 := ""

IF ALLTRIM(SED->ED_CODIGO) == "4023"   .and. ALLTRIM(SA2->A2_COD) == "000164"
	_cRetC1 := "11441449"
ELSEIF ALLTRIM(SED->ED_CODIGO) == "1401"   .and. ALLTRIM(SA2->A2_COD) == "001772"
	_cRetC1 := "11411401"
ELSEIF ALLTRIM(SED->ED_CODIGO) == "1401"   .and. ALLTRIM(SA2->A2_COD) == "000027"
	_cRetC1 := "11411401"
ELSEIF ALLTRIM(SED->ED_CODIGO) == "1401"   .and. ALLTRIM(SA2->A2_COD) == "999999"
	_cRetC1 := "11411401"
ELSEIF ALLTRIM(SED->ED_CODIGO) == "2463"   .and. ALLTRIM(SA2->A2_COD) == "SEC-SP"
	_cRetC1 := "51115002"
ELSEIF ALLTRIM(SED->ED_CODIGO) == "5001"   .and. ALLTRIM(SA2->A2_COD) == "000023"
	_cRetC1 := "11511501"
	
ELSEIF  ALLTRIM(SA2->A2_COD) == "MF-SRF" .AND. ALLTRIM(SE2->E2_PREFIXO)=="EIC"   //Farinelli(24.10.16) Acrescentado Regra para Multa e Juros do EIC
	_cRetC1 := "81438422" 

ELSEIF  ALLTRIM(SA2->A2_COD) == "MF-SRF"
	_cRetC1 := "11411401"
	
	
ELSEIF  ALLTRIM(SA2->A2_COD) == "001283"
	_cRetC1 := "11441449" 
	
	ELSEIF  ALLTRIM(SA2->A2_COD) == "000654"
	_cRetC1 := "11441449"       
	
	ELSEIF  ALLTRIM(SA2->A2_COD) == "001591"
	_cRetC1 := "11441449"  
	
	
ENDIF
Return(_cRetC1)     
