trigger ContactLevelUpdateTrigger on Contact (after update, after insert) {
    new ContactLevel_tr().run();
}