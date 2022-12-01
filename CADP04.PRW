#INCLUDE "rwmake.ch"

/************************************************************************************************************
* Programa......:	CADP04
* Objetivo......: 	Cadastro de Funções Protheus - Tabela P04
* Autor.........:   José Augusto P. Alves
* Data..........:   07/12/2021
* Alterado......:   
*/                  

*-------------------
User Function CADP04
*-------------------

Private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P04"

dbSelectArea("P04")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Funções Protheus",cVldExc,cVldAlt)

Return
