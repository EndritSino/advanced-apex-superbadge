@isTest
private class Product2Tests {

    @isTest private static void Product2Extension_UnitTest(){

        PageReference pageRef = Page.Product2New;

        Product2 prod = new Product2(
            Name='Test Product',
            IsActive= true
        );
        ApexPages.StandardController controller = new ApexPages.StandardController(prod);

        Test.startTest();

        Product2Extension ext = new Product2Extension(controller);
        //System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS);

        ext.addRows();
        //System.assertEquals(2 * Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        System.assert(2 * Constants.DEFAULT_ROWS == ext.productsToInsert.size());

        for(Integer i=0; i< Constants.DEFAULT_ROWS; i++) {

            Product2 newProduct = new Product2(
                Name='Product'+i,
                Initial_Inventory__c = 10,
                IsActive=true,
                Family= Constants.PRODUCT_FAMILY.get(math.mod(i,4)).getValue()
            );
            ext.productsToInsert.get(i).productRecord = newProduct;

            PriceBookEntry entry = new PriceBookEntry(UnitPrice = 100, isActive=true);
            ext.productsToInsert.get(i).pricebookEntryRecord = entry;            
        }

        ext.save();
        ext.GetFamilyOptions();
        ext.GetInventory();

        List<Product2> selectedProd = [SELECT Id FROM Product2];
        System.assert(Constants.DEFAULT_ROWS == selectedProd.size());

        Test.stopTest();
    }

    @isTest private static void Product2Trigger_UnitTest() {

        Product2 newProduct = TestDataFactory.constructProducts(1).get(1);
        insert newProduct;

        CollaborationGroup c = TestDataFactory.ConstructCollaborationGroup();
        insert c;

        Test.startTest();

        newProduct.Quantity_Ordered__c = 96;
        update newProduct;

        Test.stopTest();
    }
}