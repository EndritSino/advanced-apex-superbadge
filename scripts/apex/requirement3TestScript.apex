Map<Id,Product2> beforeProductMap = new Map<Id,Product2>([SELECT Id FROM Product2]);
Map<Id,PricebookEntry> beforePricebookEntryMap = new Map<Id,PricebookEntry>([SELECT Id FROM PricebookEntry]);
product2Extension ext = new product2Extension(new apexPages.standardController(new Product2()));
ext.addRows();

Integer toSave = 3;
for ( Integer i=0;i<toSave;i++){
    ext.productsToInsert[i].productRecord.Name = 'DELETE ME '+i;
    ext.productsToInsert[i].productRecord.Family = 'Entree';
    ext.productsToInsert[i].productRecord.IsActive = true;
    ext.productsToInsert[i].productRecord.Initial_Inventory__c = 99;
    ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 1;
}
ext.save();

Map<Id,Product2> afterProductMap = new Map<Id,Product2>([SELECT Id FROM Product2]);
system.assertEquals( beforeProductMap.size() + toSave, afterProductMap.size() );

Map<Id,PricebookEntry> afterPricebookEntryMap = new Map<Id,PricebookEntry>([SELECT Id FROM PricebookEntry]);
system.assert( beforePricebookEntryMap.size() + toSave== afterPricebookEntryMap.size() );

List<Product2> productsToDelete = new List<Product2>();
for ( Id i : afterProductMap.keySet() ){
    if ( !beforeProductMap.containsKey(i) ){
        productsToDelete.add(afterProductMap.get(i) );
    }
}
delete productsToDelete;