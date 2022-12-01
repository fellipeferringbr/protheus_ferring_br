#INCLUDE "rwmake.ch"

/************************************************************************************************************
* Programa......:	CADP01
* Objetivo......: 	Cadastro de Atividades - Tabela P01
* Autor.........:   José Augusto P. Alves
* Data..........:   07/12/2021
* Alterado......:   
*/                  

*-------------------
User Function CADP01
*-------------------

Private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P01"

dbSelectArea("P01")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Atividades",cVldExc,cVldAlt)

Return
