trigger ContactLevelUpdateTrigger on Contact (after update) {
    new ContactLevel_tr().run();
}