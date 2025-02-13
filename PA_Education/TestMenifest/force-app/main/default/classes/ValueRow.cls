/**
 * @description       : Value 오브젝트 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             :
 * @last modified on  : 07-03-2020
 * @last modified by  : jonghyun.kim@daeunextier.com
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
 */
public class ValueRow {
    private Map<String,Object> row = null;

	public ValueRow() {
		row = new Map<String,Object>();
	}

	public ValueRow(Map<String,Object> vmap) {
        //    System.debug('ValueRow info = ' + vmap);
		row = vmap;
	}

	public ValueRow(ValueRow r) {
		row = r.getMap();
	}

	public ValueRow cloneCopy() {
		return new ValueRow(new Map<String,Object>(row));
	}

	public Map<String,Object> getMap() {
		return row;
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 가져온다.
     * 해당 key가 존재하지 않거나, key의 value가 null일 경우에는 defaultValue를 반환한다.
     * value가 배열 타입이라면 하부 데이터를 풀어서 문자열로 반환한다.
     * </p>
     *
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public String getString(String key) {
        Object obj = row.get(key);

        return String.valueOf(obj);
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 가져온다.
     * 해당 key가 존재하지 않거나, key의 value가 null일 경우에는 defaultValue를 반환한다.
     * value가 배열 타입이라면 하부 데이터를 풀어서 문자열로 반환한다.
     * </p>
     *
     * @param key 가져올 값의 key
     * @param defaultNullValue 리턴 값이 NULL일 경우 넘겨줘야 할 값
     * @return key에 해당하는 value
     */
    public String getString(String key, String defaultValue) {
        Object obj = row.get(key);

        if (obj == null) {
            return defaultValue;
        } else {
            return String.valueOf(obj);
        }
    }

    /**
     * <p>
     * key에 해당하는 value를 가져온다.
     * </p>
     *
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
	public Object get(String key) {
		return row.get(key);
	}

    /**
     * <p>
     * key에 해당하는 value를 가져온다.
     * 해당 key가 존재하지 않거나, key의 value가 null일 경우에는 defaultValue를 반환한다.
     * </p>
     *
     * @param key 가져올 값의 key
     * @param defaultValue 리턴 값이 NULL일 경우 넘겨줘야 할 값
     * @return key에 해당하는 value
     */
    public Object get(String key, Object defaultValue) {
        Object obj = row.get(key);

        if (obj == null) {
            return defaultValue;
        } else {
            return obj;
        }
    }

    public Object put(String key, Object value) {
		return row.put(key, value);
    }

    public void clear() {
		row.clear();
	}

}