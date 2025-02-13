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
public class ValueObject {

    /**
     * max dump size
     */
    @TestVisible
    private static final Integer MAX_LOG_DUMP_SIZE = 10;

    /**
     * ValueObject의 size가 이 건수 단위가 될 때 로그를 찍는다.
     */
    @TestVisible
    private static final Integer CHECK_AMOUNT_UNIT_SIZE = 2000;


    /**
     * ValueObject에 담을 수 있는 최대 row 수 디폴트 값
     */
    @TestVisible
    private static final Integer MAX_ROWS = 200000;
    
    @TestVisible
	private List<ValueRow> tbl = new List<ValueRow>();

	/**
	 * ValueObject의 명칭
	 */
    @TestVisible
    private String voName = '';

    /**
     * ValueObject에 담을 수 있는 최대 row 수
     */
    @TestVisible
    private Integer maxRows = MAX_ROWS;
    
    /**
     * <p>
     * <strong>ValueObject</strong>의 default 컨스트럭터(Constructor).
     * </p>
     */
    public ValueObject() {
    }

    /**
     * 최대 담을 수 있는 row 수를 지정하여 생성하는 컨스트럭터
     * @param max 최대 row 수
     */
    public ValueObject(Integer max) {
    	maxRows = max;
    }
    
    /**
     * <p>
     * <strong>ValueObject</strong>의 Name을 지정할 수 있는 Constructor
     *
     * @param voName ValueObject의 Name.
     */
    public ValueObject(String name) {
        voName = name;
    }

    /**
     * <p>
     * <strong>ValueObject</strong>의 Name을 지정할 수 있는 Constructor
     *
     * @param name ValueObject의 Name.
     * @param max 최대 row 수
     */
    public ValueObject(String name, Integer max) {
        voName = name;
        maxRows = max;
    }
    
    /**
     * ValueObject의 Listf를 리턴한다.
     */
    public List<ValueRow> getList(){
        return tbl;
    }

    /**
     * <p>
     * <strong>ValueObejct</strong>의 Name을 리턴한다
     * </p>
     *
     * @return <strong>ValueObejct</strong>의 Name : default는 "anonymous"이다.
     */
    public String getName() {
        return voName;
    }

    /**
     * <p>
     * <strong>ValueObejct</strong>의 크기를 리턴한다
     * </p>
     */
    public Integer getSize() {
        return tbl.size();
    }
    /**
     * <p>
     * Value에 String값을 저장한다.<br>
     * : default인 0번 Index를 가지는 Row에 저장한다.
     * </p>
     *
     * @param key   저장할 값의 key
     * @param value boolean value
     */
    public void set(String key, String value) {
        set(0, key, value);
    }

    /**
     * <p>
     * Value에 Object(String)값을 저장한다.<br>
     * : default인 0번 Index를 가지는 Row에 저장한다.
     * </p>
     *
     * @param key   저장할 값의 key
     * @param value Object(String) value
     */
    public void set(String key, Object value) {
        set(0, key, value);
    }
    
    /**
     * <p>
     * Value에 Object(String)값을 저장한다.
     * </p>
     * 
     * @param idx
     * @param key
     * @param value
     */
    public void set(Integer idx, String key, Object value) {
    	ValueRow row = null;
    	
    	if(idx < tbl.size() && tbl.get(idx) != null) {
    		row = tbl.get(idx);
        } else {
            row = this.createRowInstance();
            this.addValueRow(idx, row);
        }

        row.put(key, value);
    }
    
    public void addValueRow(Integer idx, ValueRow row) {
        if (row == null) {
            row = createRowInstance();
        }
        
    	tbl.add(idx, row);
    }

    /**
	 * Map으로부터 ValueRow를 생성하여 row를 추가한다.
	 * @param map
	 */
	public void addMap(Map<String,Object> dmap) {
        ValueRow vr = new ValueRow(dmap);
        tbl.add(vr);
    }

    /**
     * <p>
     * <strong>TABLE</strong>의 <strong>Row</strong> 인스턴스 생성한다.
     * </p>
     *
     * @return Row 인스턴스
     */
    @TestVisible
	private ValueRow createRowInstance() {
        return new ValueRow();
    }

    /**
     * <p>
     * 0번의 Index를 갖는 Row를 리턴한다.
     * </p>
     *
     * @return Row Data
     * @deprecated
     */
	public ValueRow getValueRow() {
        return tbl.get(0);
    }

    /**
     * <p>
     * 해당 Index를 갖는 Row를 {@link java.util.HashMap} 형태로 리턴한다.
     * </p>
     *
     * @param idx 가져올 Row의 Index
     * @throws IndexOutOfBoundsException 해당 Index가 기 존재하는 Row의 Index 범위를 벗어 나는 경우
     */
	public ValueRow getValueRow(Integer idx) {
        return tbl.get(idx);
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 리턴한다.
     * </p>
     *
     * @param idx 가져올 값의 Row의 인덱스
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public String getString(String key) {
        return getValueRow(0).getString(key, null);
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 리턴한다.
     * </p>
     *
     * @param idx 가져올 값의 Row의 인덱스
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public void setString(String key, String value) {
        getValueRow(0).put(key, value);
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 리턴한다.
     * </p>
     *
     * @param idx 가져올 값의 Row의 인덱스
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public String getString(Integer idx, String key) {
        return getValueRow(idx).getString(key, null);
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 리턴한다.
     * </p>
     *
     * @param idx 가져올 값의 Row의 인덱스
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public Map<String, Object> getMap() {
        return getValueRow(0).getMap();
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 리턴한다.
     * </p>
     *
     * @param idx 가져올 값의 Row의 인덱스
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public Map<String, Object> getMap(Integer idx) {
        return getValueRow(idx).getMap();
    }

    /**
     * <p>
     * 해당 Index의 Row을 삭제한다.
     * </p>
     *
     * @param idx 삭제하고자 하는 Row의 Index
     * @return 삭세된 row
     */
    public ValueRow remove(Integer idx) {
        return tbl.remove(idx);
    }

    /**
     * <p>
     * Key에 해당하는 String형의 Data를 리턴한다.
     * </p>
     *
     * @param idx 가져올 값의 Row의 인덱스
     * @param key 가져올 값의 key
     * @return key에 해당하는 value
     */
    public void removeMap(String key) {
        getValueRow(0).getMap().remove(key);
    }
}