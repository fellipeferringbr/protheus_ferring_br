#include "rwmake.ch"
#include "topconn.ch"


/**************************************************************************************************
Função:
MT120APV

Autor:
Desconhecido

Descrição:
Manipulação do grupo de aprovação e saldo de pedido.

O ponto de Entrada: MT120APV é responsável pela gravação do Pedido de Compras e Autorização de Entrega.

LOCALIZAÇÃO: 
É executado em 2 pontos distintos sendo: 

1a) No Pedido de Compras, na função: A120GRAVA  
       Neste ponto, nenhum parâmetro é passado para o Ponto de Entrada.  

2a) Na Análise da Cotação, na função: MaAvalCOT   
      Neste ponto, serão passados os parâmetros: 

      ParamIXB[1]  
      1a Posição: Fornecedor Vencedor 
      2a Posição: Loja Fornecedor Vencedor 
      3a Posição: Código da Condição de Pagamento  
      4a Posição: Filial de Entrega 
      
      
      ParamIXB[2] = Acols com campos e conteúdo da SC8 

EM QUE PONTO: Após a gravação dos itens do pedido de compras, dentro da condição que gera o 
Bloqueio do PC na tabela SCR e pode ser utilizado para:

1. Manipular o grupo de aprovação que será gravado na tabela SCR conforme as necessidades 
   do usuário.
2. e/ou Manipular o saldo do pedido, conforme as necessidades do usuário, na alteração do pedido. 
    Atenção: neste caso, deve-se restringir a execução da rotina através da variável 'ALTERA'
    
Retorno:
{ExpC1,ExpC2}(array_of_record)
Retornar o grupo de aprovação que será utilizado na gravação do SCR.
Se não existir o Ponto de Entrada ou se o retorno não for do tipo caracter, usa o parâmetro 
MV_PCAPROV do SX6.

Alterações:
10/03/2015 - Leandro Fini
Adicionado o SEEK pelo índice da tabela SAL numero 5 e 8 e parametrizado mensagens de aviso.
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
					
					   //	MsgAlert("ATENÇÃO! O Centro de custo informado não bate com o grupo de aprovação.")
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
					
				   //	MsgAlert("ATENÇÃO! O Centro de custo não bate com o grupo de aprovação informado.")
				   //	MsgAlert("Favor alterar o pedido e revisar o grupo de aprovação!.")
					
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