public class Constants {

    public static final Integer DEFAULT_ROWS = 5;

    public static final String SELECT_ONE = 'Select One';
    public static final String INVENTORY_LEVEL_LOW = 'Has a low inventory';

    public static final List<Schema.PicklistEntry> PRODUCT_FAMILY = Product2.Family.getDescribe().getPicklistValues();

    public static final String DRAFT_ORDER_STATUS = 'Draft';
    public static final String ACTIVATED_ORDER_STATUS = 'Activated';

    public static final String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements';
    public static final String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';

    // Hardcoded value of the Standard Pricebook Id
    public static final Id STANDARD_PRICEBOOK_ID = '01s2o000001fAcLAAU';
}