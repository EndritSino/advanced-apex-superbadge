public without sharing class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> activatedOrderIds = new Set<Id>();

        for ( Integer i=0; i<newList.size(); i++ ){

            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS
                    && oldList[i].Status == Constants.DRAFT_ORDER_STATUS ){

                activatedOrderIds.add(newList[i].Id);
            }
        }

        RollUpOrderItems(activatedOrderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        if (activatedOrderIds.size() == 0) {
            return;
        }

        Map<Id, Product2> productMap = new Map<Id, Product2>();
        for (OrderItem oi: [SELECT
                                Product2Id,
                                Product2.Quantity_Ordered__c,
                                Quantity
                            FROM OrderItem
                            WHERE OrderId IN :activatedOrderIds]) {

            productMap.put(oi.Product2Id, oi.Product2);
        }

        for (AggregateResult ar : [SELECT
                                        count(Id) totalNumberOfItems,
                                        Product2Id,
                                        SUM(Quantity) totalQuantity
                                    FROM OrderItem
                                    WHERE Product2Id IN :productMap.keySet()
                                    GROUP BY Product2Id]){

            Product2 prod = productMap.get((Id) ar.get('Product2Id'));
            prod.Quantity_Ordered__c = (Decimal) ar.get('totalQuantity');
        }

        update productMap.values();
    }
}