#include 'protheus.ch'
#INCLUDE 'rwmake.ch'
#include 'TOPCONN.CH'

/*/{Protheus.doc} MT140ROT
//Ponto de Entrada para manipulação do Menu - Pre-Nota
@type function
@version 2.0 / FERRING
@return Nil
/*/

User Function MT140ROT

aRetorno := {}    

AAdd( aRetorno, { "Impor. XML"         , "u_PreNotaXML", 2, 0 } )// Cleyton Leal   - 24/02/2014
AAdd( aRetorno, { "Visual.Rej.Pre-Nota", "U_FCOMA001('P')", 2, 0 } )// Luiz Junior QS - 28/01/2020

Return( aRetorno )