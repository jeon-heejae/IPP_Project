/**
 * (예외처리 클래스) 법인카드 청구내역 등록 및 수정 CLASS. 
 * 승인내역(CATS_TMP_BILL__c)에 데이터를 생성 또는 수정.
 * 
 * 작성자 : 김원준, wonjun@daeucna.com
 * 최초작성일자 : 2024-12-05
 * 
 * ================================
 * [수행내용]
 * (1) LIST형태로 받은 데이터를 각각 Map 단위로 등록(INSERT)한다.
 * (2) 만약, 각 Map에 있는 일련번호(Seq__c) 값이 청구내역(CATS_TMP_BILL__c)에 존재하면 수정(UPDATE) 한다.
 * ================================
 */
public with sharing class IFBILLTRANImpl implements UserInterface {
    public IFBILLTRANImpl() {}

       // 인터페이스 구현
       public Map<String, Object> execute(ValueObject inputVo, List<String> logger) {
        Map<String, Object> rstMap = new Map<String, Object>(); // 결과값
        ValueRow vo = inputVo.getValueRow(); // 0번째 row 를 가져옴
        String ifId = vo.getString('Interface_id');
        System.debug('ifId : ' + ifId);
        
        /*
            요청 파라미터 Payload
            {
                "IF_LIST": [
                    {
                        "SEQ": "",
                        "DATACODE": "",
                        "COMPANYID": "",
                        "SENDDATE": "",
                        "SEQNO": "",
                        "READFLAG": "",
                        "CLASS": "",
                        "BILTYPE": "",
                        "CORPBIZNO": "",
                        "CORPNO": "",
                        "ESTBNO": "",
                        "CARDNO": "",
                        "APPRNO": "",
                        "SLIPNO": "",
                        "COLLNO": "",
                        "ORGNAPPRDATE": "",
                        "BILWORKDATE": "",
                        "BILAMT": "",
                        "BILFEE": "",
                        "MEMBSHIPFEE": "",
                        "ACQUEXCH": "",
                        "USDACQUTOT": "",
                        "CONVFEE": "",
                        "BILTOT": "",
                        "INSTTYPE": "",
                        "INSTMONTH": "",
                        "RESTINSTMONTH": "",
                        "SETTDATE": "",
                        "MERCHBIZNO": "",
                        "MERCHNAME": "",
                        "SERVTYPEYN": "",
                        "DISCAMT": "",
                        "ESTBNAME": "",
                        "USERNO": "",
                        "USERNAME": "",
                        "ORIGINAPPRTOT": "",
                        "ORIGINTRANSTIME": "",
                        "ORIGINMERCHNAME": "",
                        "CARD_CHECK_GB": "",
                        "ORIGINMERCHBIZNO": "",
                        "WORKDATE": "",
                        "ERRYN": "",
                        "TRACQ": "",
                        "FILE_YN": "",
                        "ERP_YN": "",
                        "MEMID": "",
                        "MEMBCODE": "",
                        "SAVE_POINT_AMT": ""

                    }
                        .
                        .
                        .
                    {}            
                ]
            }        
        */        
    
        logger.add('-----------------------------------------------------------------------------------------------------------------------');
        logger.add('Interface ID : ' + ifId + ', 법인카드 청구내역 등록, 수정 CLASS.  ');
        logger.add('-----------------------------------------------------------------------------------------------------------------------');        

        List<Object> getIfList = (List<Object>) vo.get('IF_LIST'); //수정할 법인카드 청구내역 리스트를 가져온다.

        if(getIfList.size() > 200) {
            throw new BizException('법인카드 청구내역 리스트의 길이가 200 건을 초과했습니다. 200건 미만으로 요청해주세요.');
        }

        Savepoint sp = Database.setSavepoint(); // 트랜잭션의 시작점 설정.

        // 등록 프로그램 시작. 실패 시 Rollback.   
        try {

            if (getIfList.size() > 0) {
                
                List<CATS_TMP_BILL__c> upsertList = new List<CATS_TMP_BILL__c>(); // 법인카드 청구내역 UPSERT 리스트

                for (Object obj : getIfList) {
                    if (obj instanceof Map<String, Object>) {
                        Map <String, Object> data = (Map<String, Object>) obj;

                        String SEQ                  = MetaDataHelper.getString2Object(data.get('SEQ'));
                        String DATACODE             = MetaDataHelper.getString2Object(data.get('DATACODE'));
                        String COMPANYID            = MetaDataHelper.getString2Object(data.get('COMPANYID'));
                        String SENDDATE             = MetaDataHelper.getString2Object(data.get('SENDDATE'));
                        String SEQNO                = MetaDataHelper.getString2Object(data.get('SEQNO'));
                        String READFLAG             = MetaDataHelper.getString2Object(data.get('READFLAG'));
                        String STRINGCLASS          = MetaDataHelper.getString2Object(data.get('CLASS'));
                        String BILTYPE              = MetaDataHelper.getString2Object(data.get('BILTYPE'));
                        String CORPBIZNO            = MetaDataHelper.getString2Object(data.get('CORPBIZNO'));
                        String CORPNO               = MetaDataHelper.getString2Object(data.get('CORPNO'));
                        String ESTBNO               = MetaDataHelper.getString2Object(data.get('ESTBNO'));
                        String CARDNO               = MetaDataHelper.getString2Object(data.get('CARDNO'));
                        String APPRNO               = MetaDataHelper.getString2Object(data.get('APPRNO'));
                        String SLIPNO               = MetaDataHelper.getString2Object(data.get('SLIPNO'));
                        String COLLNO               = MetaDataHelper.getString2Object(data.get('COLLNO'));
                        String ORGNAPPRDATE         = MetaDataHelper.getString2Object(data.get('ORGNAPPRDATE'));
                        String BILWORKDATE          = MetaDataHelper.getString2Object(data.get('BILWORKDATE'));
                        String BILAMT               = MetaDataHelper.getString2Object(data.get('BILAMT'));
                        String BILFEE               = MetaDataHelper.getString2Object(data.get('BILFEE'));
                        String MEMBSHIPFEE          = MetaDataHelper.getString2Object(data.get('MEMBSHIPFEE'));
                        String ACQUEXCH             = MetaDataHelper.getString2Object(data.get('ACQUEXCH'));
                        String USDACQUTOT           = MetaDataHelper.getString2Object(data.get('USDACQUTOT'));
                        String CONVFEE              = MetaDataHelper.getString2Object(data.get('CONVFEE'));
                        String BILTOT               = MetaDataHelper.getString2Object(data.get('BILTOT'));
                        String INSTTYPE             = MetaDataHelper.getString2Object(data.get('INSTTYPE'));
                        String INSTMONTH            = MetaDataHelper.getString2Object(data.get('INSTMONTH'));
                        String RESTINSTMONTH        = MetaDataHelper.getString2Object(data.get('RESTINSTMONTH'));
                        String SETTDATE             = MetaDataHelper.getString2Object(data.get('SETTDATE'));
                        String MERCHBIZNO           = MetaDataHelper.getString2Object(data.get('MERCHBIZNO'));
                        String MERCHNAME            = MetaDataHelper.getString2Object(data.get('MERCHNAME'));
                        String SERVTYPEYN           = MetaDataHelper.getString2Object(data.get('SERVTYPEYN'));
                        String DISCAMT              = MetaDataHelper.getString2Object(data.get('DISCAMT'));
                        String ESTBNAME             = MetaDataHelper.getString2Object(data.get('ESTBNAME'));
                        String USERNO               = MetaDataHelper.getString2Object(data.get('USERNO'));
                        String USERNAME             = MetaDataHelper.getString2Object(data.get('USERNAME'));
                        String ORIGINAPPRTOT        = MetaDataHelper.getString2Object(data.get('ORIGINAPPRTOT'));
                        String ORIGINTRANSTIME      = MetaDataHelper.getString2Object(data.get('ORIGINTRANSTIME'));
                        String ORIGINMERCHNAME      = MetaDataHelper.getString2Object(data.get('ORIGINMERCHNAME'));
                        String CARD_CHECK_GB        = MetaDataHelper.getString2Object(data.get('CARD_CHECK_GB'));
                        String ORIGINMERCHBIZNO     = MetaDataHelper.getString2Object(data.get('ORIGINMERCHBIZNO'));
                        String WORKDATE             = MetaDataHelper.getString2Object(data.get('WORKDATE'));
                        String ERRYN                = MetaDataHelper.getString2Object(data.get('ERRYN'));
                        String TRACQ                = MetaDataHelper.getString2Object(data.get('TRACQ'));
                        String FILE_YN              = MetaDataHelper.getString2Object(data.get('FILE_YN'));
                        String ERP_YN               = MetaDataHelper.getString2Object(data.get('ERP_YN'));
                        String MEMID                = MetaDataHelper.getString2Object(data.get('MEMID'));
                        String MEMBCODE             = MetaDataHelper.getString2Object(data.get('MEMBCODE'));
                        String SAVE_POINT_AMT       = MetaDataHelper.getString2Object(data.get('SAVE_POINT_AMT'));


                        CATS_TMP_BILL__c catsTmpBill = new CATS_TMP_BILL__c();

                        // upsert할 오브젝트를 생성 및 리스트에 추가한다.
                        catsTmpBill.Seq__c                                                      = MetaDataHelper.getDecimal2String(Seq);
                        if (!String.isEmpty(DATACODE)) catsTmpBill.DataCode__c                  = DATACODE;
                        if (!String.isEmpty(COMPANYID)) catsTmpBill.CompanyID__c                = COMPANYID;
                        if (!String.isEmpty(SENDDATE)) catsTmpBill.SendDate__c                  = SENDDATE;
                        if (!String.isEmpty(SEQNO)) catsTmpBill.SeqNo__c                        = SEQNO;
                        if (!String.isEmpty(READFLAG)) catsTmpBill.ReadFlag__c                  = READFLAG;
                        if (!String.isEmpty(STRINGCLASS)) catsTmpBill.Class__c                  = STRINGCLASS;
                        if (!String.isEmpty(BILTYPE)) catsTmpBill.BilType__c                    = BILTYPE;
                        if (!String.isEmpty(CORPBIZNO)) catsTmpBill.CorpBizNo__c                = CORPBIZNO;
                        if (!String.isEmpty(CORPNO)) catsTmpBill.CorpNo__c                      = CORPNO;
                        if (!String.isEmpty(ESTBNO)) catsTmpBill.EstbNo__c                      = ESTBNO;
                        if (!String.isEmpty(CARDNO)) catsTmpBill.CardNo__c                      = CARDNO;
                        if (!String.isEmpty(APPRNO)) catsTmpBill.ApprNo__c                      = APPRNO;
                        if (!String.isEmpty(SLIPNO)) catsTmpBill.SlipNo__c                      = SLIPNO;
                        if (!String.isEmpty(COLLNO)) catsTmpBill.CollNo__c                      = COLLNO;
                        if (!String.isEmpty(ORGNAPPRDATE)) catsTmpBill.OrgnApprDate__c          = ORGNAPPRDATE;
                        if (!String.isEmpty(BILWORKDATE)) catsTmpBill.BilWorkDate__c            = BILWORKDATE;
                        if (!String.isEmpty(BILAMT)) catsTmpBill.BilAmt__c                      = MetaDataHelper.getDecimal2String(BILAMT);
                        if (!String.isEmpty(BILFEE)) catsTmpBill.BilFee__c                      = MetaDataHelper.getDecimal2String(BILFEE);
                        if (!String.isEmpty(MEMBSHIPFEE)) catsTmpBill.MembshipFee__c            = MetaDataHelper.getDecimal2String(MEMBSHIPFEE);
                        if (!String.isEmpty(ACQUEXCH)) catsTmpBill.AcquExch__c                  = MetaDataHelper.getDecimal2String(ACQUEXCH);
                        if (!String.isEmpty(USDACQUTOT)) catsTmpBill.USDAcquTot__c              = MetaDataHelper.getDecimal2String(USDACQUTOT);
                        if (!String.isEmpty(CONVFEE)) catsTmpBill.ConvFee__c                    = MetaDataHelper.getDecimal2String(CONVFEE);
                        if (!String.isEmpty(BILTOT)) catsTmpBill.BilTot__c                      = MetaDataHelper.getDecimal2String(BILTOT);
                        if (!String.isEmpty(INSTTYPE)) catsTmpBill.InstType__c                  = INSTTYPE;
                        if (!String.isEmpty(INSTMONTH)) catsTmpBill.InstMonth__c                = INSTMONTH;
                        if (!String.isEmpty(RESTINSTMONTH)) catsTmpBill.RestInstMonth__c        = RESTINSTMONTH;
                        if (!String.isEmpty(SETTDATE)) catsTmpBill.SettDate__c                  = SETTDATE;
                        if (!String.isEmpty(MERCHBIZNO)) catsTmpBill.MerchBizNo__c              = MERCHBIZNO;
                        if (!String.isEmpty(MERCHNAME)) catsTmpBill.MerchName__c                = MERCHNAME;
                        if (!String.isEmpty(SERVTYPEYN)) catsTmpBill.ServTypeYN__c              = SERVTYPEYN;
                        if (!String.isEmpty(DISCAMT)) catsTmpBill.DiscAmt__c                    = MetaDataHelper.getDecimal2String(DISCAMT);
                        if (!String.isEmpty(ESTBNAME)) catsTmpBill.EstbName__c                  = ESTBNAME;
                        if (!String.isEmpty(USERNO)) catsTmpBill.UserNo__c                      = USERNO;
                        if (!String.isEmpty(USERNAME)) catsTmpBill.UserName__c                  = USERNAME;
                        if (!String.isEmpty(ORIGINAPPRTOT)) catsTmpBill.OriginApprTot__c        = MetaDataHelper.getDecimal2String(ORIGINAPPRTOT);
                        if (!String.isEmpty(ORIGINTRANSTIME)) catsTmpBill.OriginTransTime__c    = ORIGINTRANSTIME;
                        if (!String.isEmpty(ORIGINMERCHNAME)) catsTmpBill.OriginMerchName__c    = ORIGINMERCHNAME;
                        if (!String.isEmpty(CARD_CHECK_GB)) catsTmpBill.CARD_CHECK_GB__c        = CARD_CHECK_GB;
                        if (!String.isEmpty(ORIGINMERCHBIZNO)) catsTmpBill.OriginMerchBizNo__c  = ORIGINMERCHBIZNO;
                        if (!String.isEmpty(WORKDATE)) catsTmpBill.WorkDate__c                  = WORKDATE;
                        if (!String.isEmpty(ERRYN)) catsTmpBill.ErrYN__c                        = ERRYN;
                        if (!String.isEmpty(TRACQ)) catsTmpBill.TrAcq__c                        = TRACQ;
                        if (!String.isEmpty(FILE_YN)) catsTmpBill.FILE_YN__c                    = FILE_YN;
                        if (!String.isEmpty(ERP_YN)) catsTmpBill.ERP_YN__c                      = ERP_YN;
                        if (!String.isEmpty(MEMID)) catsTmpBill.MEMID__c                        = MEMID;
                        if (!String.isEmpty(MEMBCODE)) catsTmpBill.MembCode__c                  = MEMBCODE;
                        if (!String.isEmpty(SAVE_POINT_AMT)) catsTmpBill.SAVE_POINT_AMT__c      = MetaDataHelper.getDecimal2String(SAVE_POINT_AMT);

                        upsertList.add(catsTmpBill);

                    }    
                }

            upsert upsertList Seq__c;
            System.debug('upsertList size : ' + upsertList.size());   

            
            // 응답파라미터 생성.
            /*
            List<String> catsTmpBillSeqs= new List<String>();

            for (CATS_TMP_BILL__c tempCatsTmpBill : upsertList) {
                String tempSeq = String.valueOf(tempCatsTmpBill.Seq__c);
                catsTmpBillSeqs.add(tempSeq);
            }

            rstMap.put('catsTmpBillSeqs', catsTmpBillSeqs);
            */

            } else {
                throw new BizException('법인카드 청구내역 리스트가 없습니다. 청구내역 데이터를 확인해주세요');
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Exception error message : ' + e.getMessage());
            throw e;
        }

        return rstMap;

       }   
}