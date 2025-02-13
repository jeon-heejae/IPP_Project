/**
 * Object       : Inventory_Line.cls
 * Function     : 자재관리 - 생산현장 재고
 * Author       : Yohan.Kang.
 * Date         : 2015.6.6
 * Tester       : Inventory_LineTester.Cls
 * page			:
 *           Inventory_Line.page
 * Description  :  
 */
public with sharing class Inventory_Line {
	public List<cInventory> cIVs{
		get{
			if(cIVs==null){
				cIVs = new List<cInventory>();

				List<Inventory__c> IVs = [SELECT Item__c, Item__r.Standard__c
						, Item__r.Name
						, Name
						, CntInventory2__c
					FROM Inventory__c
					WHERE Warehouse__r.Type__c = '공정'
					AND CntInventory2__c>0
					Order by Item__c
				];

				

				string prevItemId;
				List<Inventory__c> TargetIVs;
				for(Inventory__c IV:IVs){
					//달라졌을때 리스트에 담는다.
					if(prevItemId<>null && prevItemId<>IV.ITem__c){
						cIVs.add(new cInventory(TargetIVs));
					}

					if(prevItemId==null || prevItemId<>IV.Item__c){
						TargetIVs = new List<Inventory__c>();
						TargetIVs.add(IV);
						prevItemId = IV.Item__c;
					}else{
						TargetIVs.add(IV);
					}
				}
				if(IVs.size()>0) cIVs.add(new cInventory(TargetIVs));
			}
			return cIVs;
		}
		private set;
	}
	private class cInventory{
		public String ItemName{
			get{
				if(IVs.size()>0) ItemName = IVs[0].Item__r.Name;
				else ItemName = '';
				return ItemName;
			}
			private set;
		}
		public String ItemStandard{
			get{
				if(IVs.size()>0) ItemStandard = IVs[0].Item__r.Standard__c;
				else ItemStandard = '';
				return ItemStandard;
			}
			private set;
		}
		public List<Inventory__c> IVs{get; set;}
		public Integer ITCntSum{
			get{
				ITCntSum = 0;
				if(IVs<>null){
					for(Inventory__c IV:IVs) ITCntSum += integer.valueOf(IV.CntInventory2__c);
				}
				return ITCntSum;
			}
			private set;
		}

		public cInventory(List<Inventory__c> gIVs){
			IVs = gIVs;
		}
	}

	public void TestMe(){
		List<cInventory> tcIVs = cIVs;

		system.debug(tcIVs[0].ItemName);
		system.debug(tcIVs[0].ItemStandard);
		system.debug('' + tcIVs[0].ITCntSum);
	}
}