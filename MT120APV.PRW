#include "rwmake.ch"
#include "topconn.ch"


/**************************************************************************************************
Fun??o:
MT120APV

Autor:
Desconhecido

Descri??o:
Manipula??o do grupo de aprova??o e saldo de pedido.

O ponto de Entrada: MT120APV ? respons?vel pela grava??o do Pedido de Compras e Autoriza??o de Entrega.

LOCALIZA??O: 
? executado em 2 pontos distintos sendo: 

1a) No Pedido de Compras, na fun??o: A120GRAVA  
       Neste ponto, nenhum par?metro ? passado para o Ponto de Entrada.  

2a) Na An?lise da Cota??o, na fun??o: MaAvalCOT   
      Neste ponto, ser?o passados os par?metros: 

      ParamIXB[1]  
      1a Posi??o: Fornecedor Vencedor 
      2a Posi??o: Loja Fornecedor Vencedor 
      3a Posi??o: C?digo da Condi??o de Pagamento  
      4a Posi??o: Filial de Entrega 
      
      
      ParamIXB[2] = Acols com campos e conte?do da SC8 

EM QUE PONTO: Ap?s a grava??o dos itens do pedido de compras, dentro da condi??o que gera o 
Bloqueio do PC na tabela SCR e pode ser utilizado para:

1. Manipular o grupo de aprova??o que ser? gravado na tabela SCR conforme as necessidades 
   do usu?rio.
2. e/ou Manipular o saldo do pedido, conforme as necessidades do usu?rio, na altera??o do pedido. 
    Aten??o: neste caso, deve-se restringir a execu??o da rotina atrav?s da vari?vel 'ALTERA'
    
Retorno:
{ExpC1,ExpC2}(array_of_record)
Retornar o grupo de aprova??o que ser? utilizado na grava??o do SCR.
Se n?o existir o Ponto de Entrada ou se o retorno n?o for do tipo caracter, usa o par?metro 
MV_PCAPROV do SX6.

Altera??es:
10/03/2015 - Leandro Fini
Adicionado o SEEK pelo ?ndice da tabela SAL numero 5 e 8 e parametrizado mensagens de aviso.
**************************************************************************************************/
User Function MT120APV()

	Local _AreaSAL	:= SAL->(GETAREA())
	Local _AreaSC1	:= SC1->(GETAREA())
	Local _cRet		:= ""
	Local _cPed		:= SC7->C7_NUM
	Local _cxCc		:= SC7->C7_CC
	Local _cCc		:= PADR(_cxCc,9)
	Local _cxItC	:= SC7->C7_ITEMCTA
	Local _Aprov	:= SC7->C7_APROV
	Local _cItC		:= PADR(_cxItC,9)
	Local _cNumSc   := SC7->C7_NUMSC
	Local _cNiv		:= "01"
	Local _cSCApro  := ""
   

	DbSelectArea("SC1")
	SC1->( DbSetOrder(1) )												    //C1_FILIAL+C1_NUM+C1_ITEM
	If SC1->( DbSeek( xFilial("SC1") + _cNumSc + "0001" ) )

		_cSCApro := Alltrim(Substr(SC1->C1_CODAPRO,1,7))
                        

		If  !EMPTY(_cItC)
			
			DbSelectarea('SAL')
			DbSetorder(6)
			If DbSeek(xFilial('SAL')+_cCc+_cItC+'01')
				
				_cRet := SAL->AL_COD
				
			Else
				DbSelectarea('SAL')
				DbSetorder(9)            //AL_FILIAL+AL_CC+AL_USER
				If DbSeek(xFilial('SAL')+_cCc+_cSCApro)
				
					_cRet := SAL->AL_COD
			 
				Else
					DbSelectarea('SAL')
					DbSetorder(8)        //AL_FILIAL+AL_CC+AL_APROV
					If DbSeek(xFilial('SAL')+_cCc+_Aprov)
				
						_cRet := SAL->AL_COD
					
					Elseif INCLUI .OR. ALTERA
					
					   //	MsgAlert("ATEN??O! O Centro de custo informado n?o bate com o grupo de aprova??o.")
					   //	MsgAlert("Favor alterar o pedido "+Alltrim(cValtoChar(_cPed))+" e revisar o aprovador!.")
					
					Endif
				
				Endif
			
			Endif
			
	
				
		Endif
		 

	Else

		If  !EMPTY(_cItC)
			
			DbSelectarea('SAL')
			DbSetorder(4)
			If DbSeek(xFilial('SAL')+_cCc+'01')
				
				_cRet := SAL->AL_COD
				
			Else
				DbSelectarea('SAL')
				DbSetorder(8)
				If DbSeek(xFilial('SAL')+_cCc+_Aprov)
				
					_cRet := SAL->AL_COD
			Else
				DbSelectarea('SAL')
				DbSetorder(5)
				If DbSeek(xFilial('SAL')+_cCc+_Aprov)  //AL_FILIAL+AL_CC+AL_COD
				
					_cRet := SAL->AL_COD
					
				Elseif INCLUI .OR. ALTERA
					
				   //	MsgAlert("ATEN??O! O Centro de custo n?o bate com o grupo de aprova??o informado.")
				   //	MsgAlert("Favor alterar o pedido e revisar o grupo de aprova??o!.")
					
				Endif
				
			Endif
			
			Endif
			
	
				
		Endif

	Endif



	If alltrim(_Aprov) <> ''

		_cRet	:= _Aprov
	
	Endif


	RestArea(_AreaSAL)
	RestArea(_AreaSC1)


Return _cRet