public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        Savepoint sp = Database.setSavePoint();
        try {
            List<Product2> soProduct2ToInsertList = new List<Product2>();
            List<PriceBookEntry> soPricebookEntriesToInsertList = new List<PriceBookEntry>();

            for (ProductWrapper pw: productsToInsert) {
                if ( String.isNotBlank(pw.productRecord.Name)
                        && String.isNotBlank(pw.productRecord.Family)
                            && pw.productRecord.Initial_Inventory__c != null
                                && pw.productRecord.Initial_Inventory__c != 0
                                    && pw.pricebookEntryRecord.isActive
                                        && pw.pricebookEntryRecord.UnitPrice != null
                                            && pw.pricebookEntryRecord.UnitPrice != 0) {

                    soProduct2ToInsertList.add(pw.productRecord);
                }
            }

            if (soProduct2ToInsertList.size() == 0) {
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No products found to insert!'));
                return null;
            }

            insert soProduct2ToInsertList;

            for (ProductWrapper pw: productsToInsert) {
                if (pw.productRecord.Id != null) {

                    pw.pricebookEntryRecord.Product2Id = pw.productRecord.Id;
                    pw.pricebookEntryRecord.PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    pw.pricebookEntryRecord.IsActive = true;

                    soPricebookEntriesToInsertList.add(pw.pricebookEntryRecord);
                }
            }

            insert soPricebookEntriesToInsertList;

            //If successful clear the list and display an informational message
            System.debug(productsToInsert.size()+' Inserted');
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
            System.debug(Constants.ERROR_MESSAGE + ' - Error: ' + e.getMessage());
            Database.rollBack(sp);
        }
        return null;
    }

    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> result = new List<SelectOption>();

        result.add(new SelectOption('', Constants.SELECT_ONE));

        for (Schema.PicklistEntry familyOption: Constants.PRODUCT_FAMILY) {
            result.add(new SelectOption(familyOption.getValue(), familyOption.getLabel()));
        }

        return result;
    }

    public class ProductWrapper {

        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}

        public ProductWrapper(){
            this.productRecord =  new Product2(Initial_Inventory__c =0);
            this.pricebookEntryRecord = new PriceBookEntry(Unitprice=0.0);
        }
    }
}