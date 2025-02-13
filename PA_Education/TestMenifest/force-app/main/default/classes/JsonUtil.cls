/**
 * @description       : JSON Util 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             : 
 * @last modified on  : 07-03-2020
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
**/
public class JsonUtil {
    public JsonUtil() {}

    public static ValueObject getJsonParameter(String jsonString) {
        ValueObject vo = new ValueObject();
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        vo.addMap(data);

        return vo;
    }

}