/****************************************************************************************
* File Name   : BarcodeGeneratorTester
* Description : 
* Copyright   : Copyright © 1995-2016 SAMSUNG All Rights Reserved
* Author      : yohan.kang
* Target      : BarcodeGenerator.cls
* Modification Log
* ===============================================================
* Ver  Date        Author    	Modification
* ===============================================================
  1.0 
****************************************************************************************/
@isTest
private class BarcodeGeneratorTester{
	@isTest
	static void itShould(){
		BarcodeGenerator.TestMe();
	}
}