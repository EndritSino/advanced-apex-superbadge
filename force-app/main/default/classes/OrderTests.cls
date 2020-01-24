@isTest
private class OrderTests {

    @TestSetup
    private static void SetupTestData(){
        TestDataFactory.InsertTestData(10);
    }

    @isTest private static void OrderUpdate_UnitTest(){

        Map<Id, Order> orderMap = new Map<Id, Order>([
            SELECT
                OrderNumber,
                Status
            FROM Order
        ]);
        System.assertNotEquals(0, orderMap.size());

        Map<Id, Product2> productMapBefore = new Map<Id, Product2>([
            SELECT
                Name,
                Quantity_Ordered__c
            FROM Product2
            WHERE Id IN (SELECT Product2Id FROM OrderItem WHERE OrderId IN :orderMap.keySet())
        ]);
        System.assertNotEquals(0, productMapBefore.size());

        Test.startTest();

        for (Order o: orderMap.values()) {
            o.Status = Constants.ACTIVATED_ORDER_STATUS;
        }

        update orderMap.values();

        Test.stopTest();

        orderMap = new Map<Id, Order>([
            SELECT
                OrderNumber,
                Status
            FROM Order
        ]);
        System.assertNotEquals(0, orderMap.size());

        Map<Id, Product2> productMapAfter = new Map<Id, Product2>([
            SELECT
                Name,
                Quantity_Ordered__c
            FROM Product2
            WHERE Id IN (SELECT Product2Id FROM OrderItem WHERE OrderId IN :orderMap.keySet())
        ]);
        System.assertNotEquals(0, productMapAfter.size());

        for (Order o: orderMap.values()) {
            System.assertEquals(Constants.ACTIVATED_ORDER_STATUS, o.Status);
        }

        for (Id prodId : productMapBefore.keySet()) {
            Product2 originalProd = productMapBefore.get(prodId);
            Product2 updatedProd = productMapAfter.get(prodId);

            TestDataFactory.VerifyQuantityOrdered(originalProd, updatedProd, Constants.DEFAULT_ROWS);
        }
    }

    @isTest private static void OrderExtension_UnitTest(){}
}