// Add transaction control
Savepoint sp = Database.setSavepoint();

Integer productCount = [SELECT Count() FROM Product2];
Integer pricebookCount = [SELECT Count() FROM PricebookEntry];
product2Extension ext = new product2Extension(new apexPages.standardController(new Product2()));
ext.addRows();
ext.addRows();
ext.productsToInsert[0].productRecord.Name = 'TestTestTest';
ext.productsToInsert[0].productRecord.Family = 'Entree';
ext.productsToInsert[0].pricebookEntryRecord.UnitPrice = 1;
ext.productsToInsert[0].pricebookEntryRecord.IsActive = true;
ext.productsToInsert[0].productRecord.Initial_Inventory__c = 10;
ext.save();

system.assert( productCount+1 == [SELECT Count() FROM Product2] );
system.assert( pricebookCount+1 == [SELECT Count() FROM PricebookEntry]);

Database.rollback(sp);