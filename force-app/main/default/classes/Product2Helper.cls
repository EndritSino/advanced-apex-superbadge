public class Product2Helper {

    /**
     * @name COLLABORATION_GROUP
     * @description List of CollaborationGroup used in both business and test logic
    **/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST' + Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    /**
     * @name afterUpdate
     * @description called by product2 Trigger on After Update
     * @param List<Product2> newList
     * @param List<Product2> oldList
    **/
    public static void AfterUpdate(List<Product2> oldList, List<Product2> newList){
        List<Product2> prodToAnnounce = new List<Product2>();
        Map<String, Inventory_Setting__mdt> inventorySettingsMap = new Map<String, Inventory_Setting__mdt>();

        for (Inventory_Setting__mdt inventorySetting : [SELECT
                                                            Low_Quantity_Alert__c,
                                                            QualifiedApiName,
                                                            DeveloperName,
                                                            MasterLabel
                                                        FROM Inventory_Setting__mdt]) {

            inventorySettingsMap.put(inventorySetting.DeveloperName, inventorySetting);
        }

        for (Product2 newProd: newList) {
            if ( String.isNotBlank(newProd.Family)
                    && newProd.Quantity_Remaining__c < inventorySettingsMap.get(newProd.Family).Low_Quantity_Alert__c ) {
                prodToAnnounce.add(newProd);
            }
        }

        postAlerts(prodToAnnounce);
    }

    /**
     * @name postAlerts
     * @description called by product2 Trigger on After Update
     * @param List<Product2> productList
    **/
    public static void PostAlerts(List<Product2> productList){

        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();

        for ( Product2 prod : productList ){
            ConnectApi.AnnouncementInput announcement = new ConnectApi.AnnouncementInput();

            announcement.ExpirationDate = System.today().addDays(1);
            announcement.SendEmails = false;
            announcement.ParentId = COLLABORATION_GROUP[0].Id;

            ConnectApi.MessageBodyInput bodyMessage = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput messageText = new ConnectApi.TextSegmentInput();
            messageText.Text = prod.Name + ' - ' + Constants.INVENTORY_LEVEL_LOW;

            bodyMessage.MessageSegments = new List<ConnectApi.TextSegmentInput>{ messageText };
            announcement.Body = bodyMessage;

            toPost.add(announcement);
        }

        AnnouncementQueueable q = new AnnouncementQueueable();
        q.toPost = toPost;

        System.enqueueJob(q);
    }
}