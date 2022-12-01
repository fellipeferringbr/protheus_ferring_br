#INCLUDE "RWMAKE.CH"
/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё BCNPJCli Ё Autor Ё ROBERTO CARLOS RAMOS  Ё Data Ё08/09/2008Ё╠╠
╠╠цддддддддддеддддддддддадддддддеддддддддбддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁLocacao   ЁAlocacao Recursos ЁContato Ё roberto.carlos@totvs.com.br    Ё╠╠
╠╠цддддддддддеддддддддддддддддддаддддддддадддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao ЁEsta rotina ira verificar no momento da confirmacao do campoЁ╠╠
╠╠Ё          ЁCNPJ do cliente se existe a base do mesmo cadastrada.       Ё╠╠
╠╠Ё          ЁInforma ao usuАrio que ira manter o mesmo numero(A1_COD) do Ё╠╠
╠╠Ё          Ёcliente e faz uma sugestao da proxima loja. Se o Cliente	  Ё╠╠
╠╠Ё          Ёprecisar ele pode alterar a loja do Cliente(A1_LOJA).		  Ё╠╠
╠╠Ё          ЁA rotina deve ser chamada via validaГЦo do Usuario no campo Ё╠╠
╠╠Ё          ЁA1_CGC no dicionario. 			                          Ё╠╠
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
User Function bCNPJCli()
/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё 				Declaracao de Variaveis                    Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Private nRetorno:= .T.
Private cCodCli	:= M->A1_COD
Private CodLoja	:= M->A1_LOJA
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Grava o Ambiente Atual                    Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Private aArea	:= GetArea()
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё		 Abre o Arquivo de Trabalho do Cadastro de Clientes		Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSelectArea("SA1")             
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё		  Indica Qual o Indice Escolhido (A1_FILIAL+A1_CGC)		Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSetOrder(3)
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё			Acessa Diretamente o Registro(CNPJ) do Cliente	 	Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
dbSeek(xFilial("SA1")+SubStr(M->A1_CGC,1,8))
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё  Procura Base do CNPJ e Verifica se o Codigo e Diferente	Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
If Found() .and. cCodCli <> SA1->A1_COD
	/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё		Armazena nas Variaveis o Codigo e Loja do Cliente      Ё
	  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cCodCli	:= SA1->A1_COD
	CodLoja := SA1->A1_LOJA
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё	Retorna o Ultimo Numero Disp. do Codigo(A1_COD) do Cliente	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	RollBackSX8()
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 	 Mensagem de Advertencia Sobre o CNPJ do Cliente	 	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	cMsg := "Foi identificado que a base do CNPJ deste cliente jА "
	cMsg += "encontra-se cadastrada. O sistema mantИm o mesmo cСdigo"
	cMsg += " e posiciona na prСxima loja disponivИl para este cliente."
	cMsg += "Caso necessite alterar clicar no campo loja acima e altere."
	MsgInfo(cMsg)
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё	Indica Qual o Indice Escolhido (A1_FILIAL+A1_COD+A1_LOJA)	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSetOrder(1) 
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё		Acessa Diretamente o Registro(COD+LOJA) do Cliente	 	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	dbSeek(xFilial("SA1")+cCodCli+CodLoja)	
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 	   Procura e Armazena a Ultima Loja do Cliente			Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	While SA1->(!Eof()) .And. cCodCli == SA1->A1_COD
		SA1->(RecLock("SA1",.F.))
		CodLoja := SA1->A1_LOJA
		SA1->(MsUnLock())
		SA1->(dbSkip())
		Loop
	End
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 	Define a Proxima Loja Disponivel do Cliente			 	Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//	CodLoja := StrZero(Val(CodLoja)+1,2)
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  ЁCarrega Conteudo correto dos Cpos de Codigo e Loja do ClienteЁ
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
	M->A1_COD	:=	cCodCli	
//	M->A1_LOJA	:=	CodLoja 
	M->A1_LOJA	:=	StrZero(Val(CodLoja)+1,2)
	/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  Ё 				Retorna ao Campo do CNPJ(A1_CNPJ)			Ё
	  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//	nRetorno	:= .F.    
Endif
/*зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Restaura o Ambiente Atual                 Ё
  юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
RestArea(aArea)   

Return(nRetorno)