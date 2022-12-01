#INCLUDE "RWMAKE.CH"
/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё BCNPJFor Ё Autor Ё ROBERTO CARLOS RAMOS  Ё Data Ё08/09/2008Ё╠╠
╠╠цддддддддддеддддддддддадддддддеддддддддбддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁLocacao   ЁAlocacao Recursos ЁContato Ё roberto.carlos@totvs.com.br    Ё╠╠
╠╠цддддддддддеддддддддддддддддддаддддддддадддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao ЁEsta rotina ira verificar no momento da confirmacao do campoЁ╠╠
╠╠Ё          ЁCNPJ do Fornecedor se existe a base do mesmo cadastrada.    Ё╠╠
╠╠Ё          ЁInforma ao usuАrio que ira manter o mesmo numero(A2_COD) do Ё╠╠
╠╠Ё          ЁFornecedor e faz uma sugestao da proxima loja. Se precisar  Ё╠╠
╠╠Ё          Ёele pode alterar a loja do Fornecedor(A2_LOJA).		  	  Ё╠╠
╠╠Ё          ЁA rotina deve ser chamada via validaГЦo do Usuario no campo Ё╠╠
╠╠Ё          ЁA2_CGC no dicionario. 			                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё FERRING PHARMACEUTICALS                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё			ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   Analista	 Ё  Data  Ё Bops Ё Motivo da Alteracao                    Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё              Ё  /  /  Ё      Ё                                        Ё╠╠
╠╠Ё              Ё  /  /  Ё      Ё                                        Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/   
User Function bCNPJFor()
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё 				Declaracao de Variaveis                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Private nRetorno:= .T.
Private cCodFor	:= M->A2_COD
Private CodLoja	:= M->A2_LOJA
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Grava o Ambiente Atual                    Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Private aArea	:= GetArea()
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё		 Abre o Arquivo de Trabalho do Cadastro de Fornecedor	Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSelectArea("SA2")             
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё		  Indica Qual o Indice Escolhido (A2_FILIAL+A2_CGC)		Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSetOrder(3)
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё		Acessa Diretamente o Registro(CNPJ) do Fornecedor	 	Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSeek(xFilial("SA2")+SubStr(M->A2_CGC,1,8))
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё  Procura Base do CNPJ e Verifica se o Codigo e Diferente	Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
If Found() .and. cCodFor <> SA2->A2_COD
	/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё		Armazena nas Variaveis o Codigo e Loja do Fornecedor   Ё
	  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cCodFor	:= SA2->A2_COD
	CodLoja := SA2->A2_LOJA
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  ЁRetorna o Ultimo Numero Disp. do Codigo(A2_COD) do FornecedorЁ
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	RollBackSX8()
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 	 Mensagem de Advertencia Sobre o CNPJ do Fornecedor	 	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cMsg := "Foi identificado que a base do CNPJ deste Fornecedor jА "
	cMsg += "encontra-se cadastrada. O sistema mantИm o mesmo cСdigo"
	cMsg += " e posiciona na prСxima loja disponivИl para este Fornecedor."
	cMsg += "Caso necessite alterar clicar no campo loja acima e altere."
	MsgInfo(cMsg)
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё	Indica Qual o Indice Escolhido (A2_FILIAL+A2_COD+A2_LOJA)	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSetOrder(1) 
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё		Acessa Diretamente o Registro(COD+LOJA) do Fornecedor	 	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSeek(xFilial("SA2")+cCodFor+CodLoja)	
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 	   Procura e Armazena a Ultima Loja do Fornecedor			Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	While SA2->(!Eof()) .And. cCodFor == SA2->A2_COD
		SA2->(RecLock("SA2",.F.))
		CodLoja := SA2->A2_LOJA
		SA2->(MsUnLock())
		SA2->(dbSkip())
		Loop
	End
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 	Define a Proxima Loja Disponivel do Fornecedor			Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//	CodLoja := StrZero(Val(CodLoja)+1,2)
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCarrega Conteudo correto dos Cpos de Cod.e Loja do FornecedorЁ
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	M->A2_COD	:=	cCodFor	
	M->A2_LOJA	:=	StrZero(Val(CodLoja)+1,2)
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 				Retorna ao Campo do CNPJ(A2_CNPJ)			Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//	nRetorno	:= .F.    
Endif
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Restaura o Ambiente Atual                 Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
RestArea(aArea)   

Return(nRetorno)