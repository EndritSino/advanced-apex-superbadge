public without sharing class ChartHelper {

    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();

        AggregateResult[] aggregateResultList = [
            SELECT
                Family,
                SUM(Quantity_Remaining__c) remainingQuantity
            FROM Product2
            WHERE Quantity_Remaining__c > 0
            AND IsActive = true
            GROUP BY Family
        ];

        for (AggregateResult ar: [SELECT
                                    Family,
                                    SUM(Quantity_Remaining__c) remainingQuantity
                                FROM Product2
                                WHERE Quantity_Remaining__c > 0
                                AND IsActive = true
                                GROUP BY Family]) {
            cht.add(
                new ChartData(
                    (String) ar.get('Family'),
                    (Decimal) ar.get('remainingQuantity')
                )
            );
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }
}