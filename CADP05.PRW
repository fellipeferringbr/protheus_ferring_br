#INCLUDE "rwmake.ch"

/************************************************************************************************************
* Programa......:	CADP05
* Objetivo......: 	Cadastro de Conflitos Protheus x Relatorio de Auditoria - Tabela P05
* Autor.........:   José Augusto P. Alves
* Data..........:   07/12/2021
* Alterado......:   
*/                  

*-------------------
User Function CADP05
*-------------------

Private cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Private cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "P05"

dbSelectArea("P05")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Conflitos Protheus",cVldExc,cVldAlt)

Return
