/**
 * @name orderTrigger
 * @description
**/
trigger OrderTrigger on Order (after update) {

    OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
}