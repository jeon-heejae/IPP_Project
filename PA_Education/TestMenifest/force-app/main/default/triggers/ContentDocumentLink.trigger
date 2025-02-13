/**
 * Created by 최지수 on 2022-12-23.
 */

trigger ContentDocumentLink on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ContentDocumentLink_tr().run();
}