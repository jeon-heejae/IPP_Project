/************************************************************************************
 * Description :
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2024-05-28     hs.jung          Create
*************************************************************************************/
public with sharing class EformsignUtils {
    private static final String CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    public static String generateRandomPassword(Integer length) {
        if (length <= 0) {
            return '';
        }

        String password = '';
        while (password.length() < length) {
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), CHARACTERS.length());
            password += CHARACTERS.substring(index, index + 1);
        }

        return password;
    }
}