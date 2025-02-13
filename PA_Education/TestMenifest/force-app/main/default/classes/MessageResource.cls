/**
 * @description       : 인터페이스 시스템 메시지 클래스
 * @author            : jonghyun.kim@daeunextier.com
 * @group             : 
 * @last modified on  : 2024-01-08
 * @last modified by  : jamespark@daeucna.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   07-03-2020   jonghyun.kim@daeunextier.com   Initial Version
 * 1.1   2023-11-06   jamespark@daeucna.com          메시지 변수 추가
**/
public class MessageResource {
    
    public static final String MSG_DATA_FORMAT_1_ERR ='요청 파라메터에 데이터 타입이 맞지 않습니다.(항목명={0}, 데이터 타입={1}, 형식={2})';
    public static final String MSG_DATA_FORMAT_2_ERR ='응답 데이터에 데이터 타입이 일치하지 않습니다.(항목명={0}, 데이터 타입={1}, 형식={2})';
    public static final String MSG_DATA_FORMAT_3_ERR ='요청 파라메터에 데이터 타입이 맞지 않습니다.(항목명={0}, 데이터 타입={1})';
    public static final String MSG_DATA_FORMAT_4_ERR ='응답 데이터에 데이터 타입이 일치하지 않습니다.(항목명={0}, 데이터 타입={1})';

    public static final String MSG_DATA_REQUIRED_0_ERR = '요청 파라메터에 필수항목이 누락되어 있습니다.';
    public static final String MSG_DATA_REQUIRED_1_ERR = '요청 파라메터에 필수항목이 누락되어 있습니다.(항목명={0})';
    public static final String MSG_DATA_REQUIRED_2_ERR = '응답 데이터에 필수항목이 누락되어 있습니다.(항목명={0})';
    public static final String MSG_NOT_FOUND_PARAMETER_ERR = '요청 파라메터를 찾을 수 없습니다. 파라메터 확인 후 다시 시도해 주십시오.';
    public static final String MSG_INVALID_PARAMETER_ERR = '요청 파라메터가 JSON 형식에 맞지 않습니다. 파라메터 확인 후 다시 시도해 주십시오.';
    public static final String MSG_NOT_FOUND_GROUP_FIELD_ERR = 'COUNT함수를 실행하기 위한 그룹필드가 지정되지 않았습니다.(테이블명:{0})';
    public static final String MSG_INVALID_JSON_STRUCTURE_ERR = '요청하신 파라메터의 데이터 구조가 인터페이스 정의내용과 일치하지 않습니다.';

    public static final String MSG_NOT_FOUND_IF_ID_ERR = '지정되지 않은 인터페이스ID입니다. 인터페이스ID 확인 후 다시 시도해주세요.';
    public static final String MSG_NOT_FOUND_CONFIG_ERR = '인터페이스 설정정보를 찾을 수 없습니다. 개발사에 문의바랍니다.';
    public static final String MSG_NOT_FOUND_PLAN_ERR = '인터페이스 실행계획 및 대상 테이블 정보를 찾을 수 없습니다. 개발사에 문의바랍니다.';
    public static final String MSG_NOT_FOUND_TB_CONFIG_ERR = '조회할 테이블 정보가 설정되지 않아 오류가 발생했습니다. 개발사에 문의 바랍니다.';
    public static final String MSG_NOT_FOUND_SUB_QUERY_ERR = '하위 쿼리에 대한 정보를 찾을 수 없습니다. 개발사에 문의바랍니다.';
    public static final String MSG_NOT_FOUND_SUB_ID_ERR = '하위 쿼리에 연결할 ID를 찾을 수 없습니다. 개발사에 문의바랍니다.(필드명:{0}.{1}, 맵핑명:{2})';

    public static final String MSG_NOT_FOUND_CLS_PATH_ERR = '개발자 클래스 실행 중 오류가 발생했습니다.';

    public static final String MSG_FIAL_INSERT_ERR   = '요청하신 데이터를 저장하는데 실패했습니다. 개발사에 문의바랍니다.';
    public static final String MSG_FIAL_INSERT_ERR_2 = '이미 존재하는 레코드 입니다. DML TYPE을 정확히 입력하세요.';
    public static final String MSG_FIAL_UPDATE_ERR   = '요청하신 데이터를 수정하는데 실패했습니다. 개발사에 문의바랍니다.';
    public static final String MSG_FIAL_UPDATE_ERR_2 = '존재하지 않는 레코드를 수정할 수 없습니다. 수정하려는 레코드 아이디의 값을 확인하세요.';
    public static final String MSG_FIAL_DELETE_ERR   = '요청하신 데이터를 삭제하는데 실패했습니다. 개발사에 문의바랍니다.';
    public static final String MSG_FIAL_DELETE_ERR_2 = '존재하지 않는 레코드를 삭제할 수 없습니다. 삭제하려는 레코드 아이디의 값을 확인하세요.';

    public static final String MSG_NOT_FOUND_OBJ_ERR = '존재하지 않는 오브젝트 입니다. 정확한 오브젝트 API 명칭을 확인하세요.';
    public static final String MSG_NOT_FOUND_PARAMETER_DATA_ERR = '처리할 요청 파라메터의 데이터가 없습니다. 파라메터 확인 후 다시 시도해 주십시오.';

    public static final String MSG_NOT_FOUND_CODE_ERR = '정의되지 않은 {0} 입니다. 정확한 코드값을 확인하세요.';

    public static String getMessage(String msg, String[] args) {
        if(args != null) {
            for(Integer i = 0; i < args.size(); i++) {
                msg = msg.replace('{'+i+'}', args[i]);
            }
        }

        System.debug('Meesage resource = ' + msg);

        return msg;
    }
    
    public static String getMessageStrArr(String msg, String[] args) {
        String strArr = '[';
        if (args != null) {
            for (String str : args) {
                strArr += str;
                strArr += ', ';
            }

            if (strArr.endsWith(', ')) {
                strArr = strArr.substring(0, strArr.length() -2);
            }
        }
        strArr += ']';
        msg += strArr;
        return msg;
    }
}