public with sharing class SecurityManagerController {
    
    //해시함수를 사용한 암호화 -> 단방향이므로 복호화가 불가능.
    /* 작동원리: 
        비밀 키와 메시지를 결합하여 해시 함수(SHA-256)를 통해 해시 값을 생성.
        동일한 비밀 키를 사용한 수신자가 데이터를 수신한 후, 동일한 과정으로 해시 값을 생성.
        수신자가 생성한 해시 값과 송신자의 해시 값을 비교해 데이터가 변경되지 않았는지 확인. */
    public static final String MACENCRIPTION='HmacSHA256'; 
    public static final String MD5='MD5';

    private String generateMD5Digest(String messagePayload){ //MD5 해쉬함수로 인코딩(암호화화) 후 Hex코드로 변환
        // public static final String MD5='MD5';
        // String messagePayload='hello';
        // System.debug('md5:'+EncodingUtil.convertToHex(Crypto.generateDigest(MD5,Blob.valueOf(messagePayload))));
        //base64로 인코딩하면 인터페이스를 보낼때 주소에 들어가면 안되는 문자열이 생기는 경우가 있음
        //이것을 방지하기 위해 hex코드로 변환
        return EncodingUtil.convertToHex(Crypto.generateDigest(MD5,Blob.valueOf(messagePayload)));
    }

    private String generateSalt(){ //랜덤 Integer 값 생성 후 문자열로 
        //System.debug('salt: '+String.valueOf(Crypto.getRandomInteger()));
        return String.valueOf(Crypto.getRandomInteger());
    }

    private String generateTimeStamp(Datetime datetimeValue){
        //1000으로 나누는 이유: 밀리초 단위위로 반환된 것을 초 단위로 바꾸기 위함.
        return string.valueOf(datetimeValue.getTime() / 1000); 
    }

    /* 
    requestType: 요청의 종류(GET, POST, PUT 등)
    contentMD5: 요청 본문(body)의 MD5 해시 값(내용의 무결성을 보장)
    contentType: 요청의 Content-Type 헤더 값(예: application/json)
    salt: 추가적인 무작위 데이터(보안을 강화하기 위한 값)
    timestamp: 요청 시간(타임스탬프 값, 중복 공격 방지)
    endpoint: 요청의 대상 API 경로 또는 URL */
    
    /* 용도: 
        무결성 확인:요청이 전송 중에 변조되지 않았는지 확인합니다. 클라이언트와 서버는 동일한 방식으로 서명을 생성한 뒤 이를 비교합니다.
        인증 및 권한 부여:서버는 서명을 통해 요청이 신뢰할 수 있는 클라이언트에서 생성된 것임을 확인합니다. 
        이는 주로 API 키 또는 비밀 키와 함께 사용됩니다.
        재전송 공격 방지: timestamp와 salt 값을 조합하여 요청이 특정 시간 내에서만 유효하도록 제한합니다. 
        이를 통해 동일한 요청을 반복적으로 전송하는 재전송 공격을 방지할 수 있습니다. */

    //반환된 값을 HMAC-SHA256 또는 RSA 서명 방식으로 암호화.
    private String generateSignature(String requestType, String contentMD5, String contentType, String salt,
        String timestamp, String endpoint){
            return String.valueof(''+requestType+'\n' + contentMD5 + '\n' + contentType + '\n' + salt + '\n' + timestamp + '\n' + endpoint);
    }

    /* 
    일반적으로 principal은 인증된 사용자 이름, 계정 ID, API 키, 또는 클라이언트 식별자 같은 정보를 포함합니다.
    서버는 요청을 수신했을 때 principal을 사용하여 누가 요청했는지 식별하고, 해당 사용자나 시스템에 대한 권한을 확인합니다. */
    public String generateHMACKey(String messagePayload, String content_type, String requestType, String endpoint,
        String secretkey, String principal){
            String salt=generateSalt();
            String timestamp=generateTimeStamp(Datetime.now());
            String contentMd5=generateMD5Digest(messagePayload);
            String contentType=content_type;
            String signatureData=generateSignature(requestType, contentMD5, contentType, salt, timestamp, endpoint);
            
            Blob data=Crypto.generateMac(MACENCRIPTION, Blob.valueOf(signatureData), Blob.valueOf(secretkey));
            String signature= EncodingUtil.base64Encode(data);
		    return principal+':'+ signature + ':' + salt + ':' + timestamp;
    }


}