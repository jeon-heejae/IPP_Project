/**
 * Object 		: Inventory.trigger
 * Function 	:  
 * Author 		: Yohan.Kang.
 * Date 		: 2015. 3. 18
 * Tester 		: InventoryTester.cls
 * Description 	: 
 */
trigger Inventory on Inventory__c (before insert, before update
									, after insert, after update) 
{
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){
			//Name은 무조건 대분자.
			InventoryUtil.NameUpper(trigger.new);

			//TraceabilityPbaMaster_Code__c로 Item__c 연결
			InventoryUtil.UpdateReferencePbaMaster(trigger.new, trigger.oldmap);
			
			//TraceabilityProductMaster_Code__c 로 Item__c 연결
			InventoryUtil.UpdateReferenceProductMaster(trigger.new, trigger.oldmap);

			//TRA_PRODUCTBOX 처리, TraceabilityProductCodes__c 필드에 연계소스에서 자식 제품 코드만 들어가짐.
			InventoryUtil.UpdateProductBoxItemCode(trigger.new, trigger.oldmap);
			//생산공정과 연결 (없으면 생성) - pba_partlist__c, pba_partlist2__c로 작업
			InventoryUtil.UpdateRefProcessProduct(trigger.new, trigger.oldmap);
			
			//생산공정과 연결 (없으면 생성) - Assemset_Seq__c 로 작업
			InventoryUtil.UpdateRefProcessProduct2(trigger.new, trigger.oldmap);
			
			//생산공정과 연결 (없으면 생성) - smtset_Key__c 로 작업 - ProcessProduct__c.smtset_Key__c 값으로 ProcessProduct__c 와 연결함
			InventoryUtil.UpdateRefProcessProduct3(trigger.new, trigger.oldmap);
		}
	}
	if(trigger.isAfter){
		if(trigger.isInsert){
			//TRA_PRODUCTBOX 처리, Pba_spi_file__c 필드에 임시로 자식 제품 코드가 들어가진 것을 가지고 자식 제품의 ParentInventory 설정
			InventoryUtil.updateParentRefWhenProdBoxCreated(trigger.new);
		}	
		if(trigger.isUpdate){
			//재고의 창고가 공정으로 이동시 Oracle에 송신하기 위해서 필드값을 변경한다.
			InventoryUtil.decideDeletionAndTranceByWarehouseType(trigger.new, trigger.oldmap);
		}
		if(trigger.isInsert || trigger.isUpdate){
			//재고의 수량 변경 발생시 InventoryHistory__c개체에 내역을 쌓는다.
			InventoryUtil.InsertInventoryHistoryCheck(trigger.new, trigger.oldmap);
		}
	}
}