/**
 * 인터페이스 Helper 클래스
 */
public class InterfaceHelper {
    public InterfaceHelper() {}

    /**
     * 인터페이스 전달전 데이터 유효성을 체크함
     * 
     * @params data = 유효성 체크할 데이터
     * @params props = 데이터 속성 정보
     */
    /*
    Test Class 사용 하지 않아 제거 함. 2020.11.19
    public static String validation(Object datas, INTERFACE_SERVICE_DETAIL__C props, String in_out_type) {
        String msg = '';
        
        msg = isFormat(datas, props.TARGET_COLUMN_TYPE__C, props.REQUEST_COLUMN_FORMAT__C, props.SOURCE_COLUMN__C , in_out_type); // 데이터 타입체크
        msg += isRequired(datas, props.SOURCE_COLUMN_REQUIRE_YN__C, props.SOURCE_COLUMN__C , in_out_type); // 필수여부 체크

        return msg;
    }
    */
    /**
     * 데이터 포맷 일치여부 체크
     * 
     * @params data 검증할 데이터
     * @params type 데이터 타입
     * @params format 데이터 형식(날짜, 숫자에 대한 형식)
     * @return 체크결과(true, false)
     */
    public static String isFormat(Object data, String type, String format, String fieldID, String in_out_type) {
        String val = MetaDataHelper.getString2Object(data, format);
        String msg = '';
        
        try {
            MetaDataHelper.isValidaton2Object(val, type);
        } catch(Exception e) {
            //if(msg != null) { 
            if(in_out_type == 'IN') msg = MessageResource.getMessage(MessageResource.MSG_DATA_FORMAT_3_ERR, new List<String>{fieldID, type}) +' : ' + msg;
            else msg = MessageResource.getMessage(MessageResource.MSG_DATA_FORMAT_4_ERR, new List<String>{fieldID, type}) +' : ' + msg;
            //}
            System.debug(msg); 
        }

        return msg;
    }

    /**
     * 데이터 길이 체크(추후, 데이터 크기를 체크할 경우에 적용할 예정임)
     * 
     * @params data 검증할 데이터
     * @params cond 조건
     * @return 체크결과(true, false)
     */
    public static String isLength(Object data, String cond) {
        return null;
    }

    /**
     * 데이터 필수여부 체크
     * 
     * @params data 검증할 데이터
     * @params cond 조건
     * @return 체크결과(true, false)
     */
    public static String isRequired(Object data, String cond, String fieldID, String in_out_type) {
        String msg = '';
        String val = MetaDataHelper.getString2Object(data, null);

        if(cond == null) cond = 'N';

        if(cond == 'Y' && (val == null || val == '')) {
            if(in_out_type == 'IN') msg = MessageResource.getMessage(MessageResource.MSG_DATA_REQUIRED_1_ERR, new List<String>{fieldID});
            else msg = MessageResource.getMessage(MessageResource.MSG_DATA_REQUIRED_2_ERR, new List<String>{fieldID});
        }

        return msg;
    }

}