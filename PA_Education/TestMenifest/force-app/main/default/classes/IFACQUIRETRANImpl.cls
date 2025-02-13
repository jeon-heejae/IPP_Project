/**
 * (예외처리 클래스) 법인카드 매입내역 등록 및 수정 CLASS. 
 * 매입내역(CATS_TMP_ACQUIRE__c)에 데이터를 생성 또는 수정.
 * 
 * 작성자 : 김원준, wonjun@daeucna.com
 * 최초작성일자 : 2024-12-05
 * 
 * ================================
 * [수행내용]
 * (1) LIST형태로 받은 데이터를 각각 Map 단위로 등록(INSERT)한다.
 * (2) 만약, 각 Map에 있는 일련번호(Seq__c) 값이 매입내역(CATS_TMP_ACQUIRE__c)에 존재하면 수정(UPDATE) 한다.
 * ================================
 */
public with sharing class IFACQUIRETRANImpl implements UserInterface {
    public IFACQUIRETRANImpl() {}

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
                        "CARDNO": "",
                        "APPRNO": "",
                        "COLLNO": "",
                        "ORGNCOLLNO": "",
                        "SLIPNO": "",
                        "APPRDATE": "",
                        "PURCHDATE": "",
                        "PURCHTIME": "",
                        "CURRCODE": "",
                        "APPRTOT": "",
                        "ACQUTOT": "",
                        "ACQUEXCH": "",
                        "USDACQUTOT": "",
                        "CONVFEE": "",
                        "PURCHTOT": "",
                        "INSTTYPE": "",
                        "SETTDATE": "",
                        "ABROAD": "",
                        "PURCHYN": "",
                        "MERCHBIZNO": "",
                        "MERCHNO": "",
                        "MERCHNAME": "",
                        "MASTER": "",
                        "MERCHTEL": "",
                        "MERCHZIPCODE": "",
                        "MERCHADDR1": "",
                        "MERCHADDR2": "",
                        "MCCNAME": "",
                        "MCCCODE": "",
                        "PARTACQUCANCYN": "",
                        "NONEAPPRYN": "",
                        "SERVTYPEYN": "",
                        "TIPS": "",
                        "DISCAMT": "",
                        "CURRACQUTOT": "",
                        "ACQUFEE": "",
                        "APPRAMT": "",
                        "VAT": "",
                        "ORIGINMERCHNAME": "",
                        "CARD_CHECK_GB": "",
                        "ORIGINMERCHBIZNO": "",
                        "MERCHCESSDATE": "",
                        "TAXTYPE": "",
                        "TAXTYPEDATE": "",
                        "APPRAMT1": "",
                        "VAT1": "",
                        "VATYN": "",
                        "WORKDATE": "",
                        "ERRYN": "",
                        "TRACQ": "",
                        "CHK_CAN_IPGUMDT": "",
                        "FILE_YN": "",
                        "ERP_YN": "",
                        "BCMCCNAME": "",
                        "BCMCCCODE": "",
                        "MEMBCODE": "",
                        "TIPS1": "",
                        "BILAMT": "",
                        "SAVE_POINT_AMT": "",
                        "TRDATE": "",
                        "CITY_ENG": "",
                        "NATION_ENG": "",
                        "VCARDNO": "",
                        "TMARKET_YN": ""
                    }
                        .
                        .
                        .
                    {}            
                ]
            }        
        */

        logger.add('-----------------------------------------------------------------------------------------------------------------------');
        logger.add('Interface ID : ' + ifId + ', 법인카드 매입내역 등록, 수정 CLASS.  ');
        logger.add('-----------------------------------------------------------------------------------------------------------------------');        

        List<Object> getIfList = (List<Object>) vo.get('IF_LIST'); //수정할 법인카드 매입내역 리스트를 가져온다.

        if(getIfList.size() > 200) {
            throw new BizException('법인카드 매입내역 리스트의 길이가 200 건을 초과했습니다. 200건 미만으로 요청해주세요.');
        }

        Savepoint sp = Database.setSavepoint(); // 트랜잭션의 시작점 설정.

        // 등록 프로그램 시작. 실패 시 Rollback.        
        try {

            if (getIfList.size() > 0) {
                
                List<CATS_TMP_ACQUIRE__c> upsertList = new List<CATS_TMP_ACQUIRE__c>(); // 법인카드 매입내역 UPSERT 리스트

                for (Object obj : getIfList) {
                    if (obj instanceof Map<String, Object>) {
                        Map <String, Object> data = (Map<String, Object>) obj;

                        String SEQ              = MetaDataHelper.getString2Object(data.get('SEQ'));
                        String DATACODE         = MetaDataHelper.getString2Object(data.get('DATACODE'));
                        String COMPANYID        = MetaDataHelper.getString2Object(data.get('COMPANYID'));
                        String SENDDATE         = MetaDataHelper.getString2Object(data.get('SENDDATE'));
                        String SEQNO            = MetaDataHelper.getString2Object(data.get('SEQNO'));
                        String READFLAG         = MetaDataHelper.getString2Object(data.get('READFLAG'));
                        String STRINGCLASS      = MetaDataHelper.getString2Object(data.get('CLASS'));
                        String CARDNO           = MetaDataHelper.getString2Object(data.get('CARDNO'));
                        String APPRNO           = MetaDataHelper.getString2Object(data.get('APPRNO'));
                        String COLLNO           = MetaDataHelper.getString2Object(data.get('COLLNO'));
                        String ORGNCOLLNO       = MetaDataHelper.getString2Object(data.get('ORGNCOLLNO'));
                        String SLIPNO           = MetaDataHelper.getString2Object(data.get('SLIPNO'));
                        String APPRDATE         = MetaDataHelper.getString2Object(data.get('APPRDATE'));
                        String PURCHDATE        = MetaDataHelper.getString2Object(data.get('PURCHDATE'));
                        String PURCHTIME        = MetaDataHelper.getString2Object(data.get('PURCHTIME'));
                        String CURRCODE         = MetaDataHelper.getString2Object(data.get('CURRCODE'));
                        String APPRTOT          = MetaDataHelper.getString2Object(data.get('APPRTOT'));
                        String ACQUTOT          = MetaDataHelper.getString2Object(data.get('ACQUTOT'));
                        String ACQUEXCH         = MetaDataHelper.getString2Object(data.get('ACQUEXCH'));
                        String USDACQUTOT       = MetaDataHelper.getString2Object(data.get('USDACQUTOT'));
                        String CONVFEE          = MetaDataHelper.getString2Object(data.get('CONVFEE'));
                        String PURCHTOT         = MetaDataHelper.getString2Object(data.get('PURCHTOT'));
                        String INSTTYPE         = MetaDataHelper.getString2Object(data.get('INSTTYPE'));
                        String SETTDATE         = MetaDataHelper.getString2Object(data.get('SETTDATE'));
                        String ABROAD           = MetaDataHelper.getString2Object(data.get('ABROAD'));
                        String PURCHYN          = MetaDataHelper.getString2Object(data.get('PURCHYN'));
                        String MERCHBIZNO       = MetaDataHelper.getString2Object(data.get('MERCHBIZNO'));
                        String MERCHNO          = MetaDataHelper.getString2Object(data.get('MERCHNO'));
                        String MERCHNAME        = MetaDataHelper.getString2Object(data.get('MERCHNAME'));
                        String MASTER           = MetaDataHelper.getString2Object(data.get('MASTER'));
                        String MERCHTEL         = MetaDataHelper.getString2Object(data.get('MERCHTEL'));
                        String MERCHZIPCODE     = MetaDataHelper.getString2Object(data.get('MERCHZIPCODE'));
                        String MERCHADDR1       = MetaDataHelper.getString2Object(data.get('MERCHADDR1'));
                        String MERCHADDR2       = MetaDataHelper.getString2Object(data.get('MERCHADDR2'));
                        String MCCNAME          = MetaDataHelper.getString2Object(data.get('MCCNAME'));
                        String MCCCODE          = MetaDataHelper.getString2Object(data.get('MCCCODE'));
                        String PARTACQUCANCYN   = MetaDataHelper.getString2Object(data.get('PARTACQUCANCYN'));
                        String NONEAPPRYN       = MetaDataHelper.getString2Object(data.get('NONEAPPRYN'));
                        String SERVTYPEYN       = MetaDataHelper.getString2Object(data.get('SERVTYPEYN'));
                        String TIPS             = MetaDataHelper.getString2Object(data.get('TIPS'));
                        String DISCAMT          = MetaDataHelper.getString2Object(data.get('DISCAMT'));
                        String CURRACQUTOT      = MetaDataHelper.getString2Object(data.get('CURRACQUTOT'));
                        String ACQUFEE          = MetaDataHelper.getString2Object(data.get('ACQUFEE'));
                        String APPRAMT          = MetaDataHelper.getString2Object(data.get('APPRAMT'));
                        String VAT              = MetaDataHelper.getString2Object(data.get('VAT'));
                        String ORIGINMERCHNAME  = MetaDataHelper.getString2Object(data.get('ORIGINMERCHNAME'));
                        String CARD_CHECK_GB    = MetaDataHelper.getString2Object(data.get('CARD_CHECK_GB'));
                        String ORIGINMERCHBIZNO = MetaDataHelper.getString2Object(data.get('ORIGINMERCHBIZNO'));
                        String MERCHCESSDATE    = MetaDataHelper.getString2Object(data.get('MERCHCESSDATE'));
                        String TAXTYPE          = MetaDataHelper.getString2Object(data.get('TAXTYPE'));
                        String TAXTYPEDATE      = MetaDataHelper.getString2Object(data.get('TAXTYPEDATE'));
                        String APPRAMT1         = MetaDataHelper.getString2Object(data.get('APPRAMT1'));
                        String VAT1             = MetaDataHelper.getString2Object(data.get('VAT1'));
                        String VATYN            = MetaDataHelper.getString2Object(data.get('VATYN'));
                        String WORKDATE         = MetaDataHelper.getString2Object(data.get('WORKDATE'));
                        String ERRYN            = MetaDataHelper.getString2Object(data.get('ERRYN'));
                        String TRACQ            = MetaDataHelper.getString2Object(data.get('TRACQ'));
                        String CHK_CAN_IPGUMDT  = MetaDataHelper.getString2Object(data.get('CHK_CAN_IPGUMDT'));
                        String FILE_YN          = MetaDataHelper.getString2Object(data.get('FILE_YN'));
                        String ERP_YN           = MetaDataHelper.getString2Object(data.get('ERP_YN'));
                        String BCMCCNAME        = MetaDataHelper.getString2Object(data.get('BCMCCNAME'));
                        String BCMCCCODE        = MetaDataHelper.getString2Object(data.get('BCMCCCODE'));
                        String MEMBCODE         = MetaDataHelper.getString2Object(data.get('MEMBCODE'));
                        String TIPS1            = MetaDataHelper.getString2Object(data.get('TIPS1'));
                        String BILAMT           = MetaDataHelper.getString2Object(data.get('BILAMT'));
                        String SAVE_POINT_AMT   = MetaDataHelper.getString2Object(data.get('SAVE_POINT_AMT'));
                        String TRDATE           = MetaDataHelper.getString2Object(data.get('TRDATE'));
                        String CITY_ENG         = MetaDataHelper.getString2Object(data.get('CITY_ENG'));
                        String NATION_ENG       = MetaDataHelper.getString2Object(data.get('NATION_ENG'));
                        String VCARDNO          = MetaDataHelper.getString2Object(data.get('VCARDNO'));
                        String TMARKET_YN       = MetaDataHelper.getString2Object(data.get('TMARKET_YN'));

                        CATS_TMP_ACQUIRE__c catsTmpAcquire = new CATS_TMP_ACQUIRE__c();

                        // upsert할 오브젝트를 생성 및 리스트에 추가한다.
                        catsTmpAcquire.Seq__c                                                       = MetaDataHelper.getDecimal2String(Seq);
                        if (!String.isEmpty(DATACODE)) catsTmpAcquire.DataCode__c                   = DATACODE;
                        if (!String.isEmpty(COMPANYID)) catsTmpAcquire.CompanyID__c                 = COMPANYID;
                        if (!String.isEmpty(SENDDATE)) catsTmpAcquire.SendDate__c                   = SENDDATE;
                        if (!String.isEmpty(SEQNO)) catsTmpAcquire.SeqNo__c                         = SEQNO;
                        if (!String.isEmpty(READFLAG)) catsTmpAcquire.ReadFlag__c                   = READFLAG;
                        if (!String.isEmpty(STRINGCLASS)) catsTmpAcquire.Class__c                   = STRINGCLASS;
                        if (!String.isEmpty(CARDNO)) catsTmpAcquire.CardNo__c                       = CARDNO;
                        if (!String.isEmpty(APPRNO)) catsTmpAcquire.ApprNo__c                       = APPRNO;
                        if (!String.isEmpty(COLLNO)) catsTmpAcquire.CollNo__c                       = COLLNO;
                        if (!String.isEmpty(ORGNCOLLNO)) catsTmpAcquire.OrgnCollNo__c               = ORGNCOLLNO;
                        if (!String.isEmpty(SLIPNO)) catsTmpAcquire.SlipNo__c                       = SLIPNO;
                        if (!String.isEmpty(APPRDATE)) catsTmpAcquire.ApprDate__c                   = APPRDATE;
                        if (!String.isEmpty(PURCHDATE)) catsTmpAcquire.PurchDate__c                 = PURCHDATE;
                        if (!String.isEmpty(PURCHTIME)) catsTmpAcquire.PurchTime__c                 = PURCHTIME;
                        if (!String.isEmpty(CURRCODE)) catsTmpAcquire.CurrCode__c                   = CURRCODE;
                        if (!String.isEmpty(APPRTOT)) catsTmpAcquire.ApprTot__c                     = MetaDataHelper.getDecimal2String(APPRTOT);
                        if (!String.isEmpty(ACQUTOT)) catsTmpAcquire.AcquTot__c                     = MetaDataHelper.getDecimal2String(ACQUTOT);
                        if (!String.isEmpty(ACQUEXCH)) catsTmpAcquire.AcquExch__c                   = MetaDataHelper.getDecimal2String(ACQUEXCH);
                        if (!String.isEmpty(USDACQUTOT)) catsTmpAcquire.USDAcquTot__c               = MetaDataHelper.getDecimal2String(USDACQUTOT);
                        if (!String.isEmpty(CONVFEE)) catsTmpAcquire.ConvFee__c                     = MetaDataHelper.getDecimal2String(CONVFEE);
                        if (!String.isEmpty(PURCHTOT)) catsTmpAcquire.PurchTot__c                   = MetaDataHelper.getDecimal2String(PURCHTOT);
                        if (!String.isEmpty(INSTTYPE)) catsTmpAcquire.InstType__c                   = INSTTYPE;
                        if (!String.isEmpty(SETTDATE)) catsTmpAcquire.SettDate__c                   = SETTDATE;
                        if (!String.isEmpty(ABROAD)) catsTmpAcquire.Abroad__c                       = ABROAD;
                        if (!String.isEmpty(PURCHYN)) catsTmpAcquire.PurchYN__c                     = PURCHYN;
                        if (!String.isEmpty(MERCHBIZNO)) catsTmpAcquire.MerchBizNo__c               = MERCHBIZNO;
                        if (!String.isEmpty(MERCHNO)) catsTmpAcquire.MerchNo__c                     = MERCHNO;
                        if (!String.isEmpty(MERCHNAME)) catsTmpAcquire.MerchName__c                 = MERCHNAME;
                        if (!String.isEmpty(MASTER)) catsTmpAcquire.Master__c                       = MASTER;
                        if (!String.isEmpty(MERCHTEL)) catsTmpAcquire.MerchTel__c                   = MERCHTEL;
                        if (!String.isEmpty(MERCHZIPCODE)) catsTmpAcquire.MerchZipcode__c           = MERCHZIPCODE;
                        if (!String.isEmpty(MERCHADDR1)) catsTmpAcquire.MerchAddr1__c               = MERCHADDR1;
                        if (!String.isEmpty(MERCHADDR2)) catsTmpAcquire.MerchAddr2__c               = MERCHADDR2;
                        if (!String.isEmpty(MCCNAME)) catsTmpAcquire.MccName__c                     = MCCNAME;
                        if (!String.isEmpty(MCCCODE)) catsTmpAcquire.MccCode__c                     = MCCCODE;
                        if (!String.isEmpty(PARTACQUCANCYN)) catsTmpAcquire.PartAcquCancYN__c       = PARTACQUCANCYN;
                        if (!String.isEmpty(NONEAPPRYN)) catsTmpAcquire.NoneApprYN__c               = NONEAPPRYN;
                        if (!String.isEmpty(SERVTYPEYN)) catsTmpAcquire.ServTypeYN__c               = SERVTYPEYN;
                        if (!String.isEmpty(TIPS)) catsTmpAcquire.Tips__c                           = MetaDataHelper.getDecimal2String(TIPS);
                        if (!String.isEmpty(DISCAMT)) catsTmpAcquire.DiscAmt__c                     = MetaDataHelper.getDecimal2String(DISCAMT);
                        if (!String.isEmpty(CURRACQUTOT)) catsTmpAcquire.CurrAcquTot__c             = MetaDataHelper.getDecimal2String(CURRACQUTOT);
                        if (!String.isEmpty(ACQUFEE)) catsTmpAcquire.AcquFee__c                     = MetaDataHelper.getDecimal2String(ACQUFEE);
                        if (!String.isEmpty(APPRAMT)) catsTmpAcquire.ApprAmt__c                     = MetaDataHelper.getDecimal2String(APPRAMT);
                        if (!String.isEmpty(VAT)) catsTmpAcquire.VAT__c                             = MetaDataHelper.getDecimal2String(VAT);
                        if (!String.isEmpty(ORIGINMERCHNAME)) catsTmpAcquire.OriginMerchName__c     = ORIGINMERCHNAME;
                        if (!String.isEmpty(CARD_CHECK_GB)) catsTmpAcquire.CARD_CHECK_GB__c         = CARD_CHECK_GB;
                        if (!String.isEmpty(ORIGINMERCHBIZNO)) catsTmpAcquire.OriginMerchBizNo__c   = ORIGINMERCHBIZNO;
                        if (!String.isEmpty(MERCHCESSDATE)) catsTmpAcquire.MerchCessDate__c         = MERCHCESSDATE;
                        if (!String.isEmpty(TAXTYPE)) catsTmpAcquire.TaxType__c                     = TAXTYPE;
                        if (!String.isEmpty(TAXTYPEDATE)) catsTmpAcquire.TaxTypeDate__c             = TAXTYPEDATE;
                        if (!String.isEmpty(APPRAMT1)) catsTmpAcquire.ApprAmt1__c                   = MetaDataHelper.getDecimal2String(APPRAMT1);
                        if (!String.isEmpty(VAT1)) catsTmpAcquire.VAT1__c                           = MetaDataHelper.getDecimal2String(VAT1);
                        if (!String.isEmpty(VATYN)) catsTmpAcquire.VATYN__c                         = VATYN;
                        if (!String.isEmpty(WORKDATE)) catsTmpAcquire.WorkDate__c                   = WORKDATE;
                        if (!String.isEmpty(ERRYN)) catsTmpAcquire.ErrYN__c                         = ERRYN;
                        if (!String.isEmpty(TRACQ)) catsTmpAcquire.TrAcq__c                         = TRACQ;
                        if (!String.isEmpty(CHK_CAN_IPGUMDT)) catsTmpAcquire.CHK_CAN_IPGUMDT__c     = CHK_CAN_IPGUMDT;
                        if (!String.isEmpty(FILE_YN)) catsTmpAcquire.FILE_YN__c                     = FILE_YN;
                        if (!String.isEmpty(ERP_YN)) catsTmpAcquire.ERP_YN__c                       = ERP_YN;
                        if (!String.isEmpty(BCMCCNAME)) catsTmpAcquire.BCMccName__c                 = BCMCCNAME;
                        if (!String.isEmpty(BCMCCCODE)) catsTmpAcquire.BCMccCode__c                 = BCMCCCODE;
                        if (!String.isEmpty(MEMBCODE)) catsTmpAcquire.MembCode__c                   = MEMBCODE;
                        if (!String.isEmpty(TIPS1)) catsTmpAcquire.Tips1__c                         = TIPS1;
                        if (!String.isEmpty(BILAMT)) catsTmpAcquire.BILAMT__c                       = MetaDataHelper.getDecimal2String(BILAMT);
                        if (!String.isEmpty(SAVE_POINT_AMT)) catsTmpAcquire.SAVE_POINT_AMT__c       = MetaDataHelper.getDecimal2String(SAVE_POINT_AMT);
                        if (!String.isEmpty(TRDATE)) catsTmpAcquire.TRDATE__c                       = TRDATE;
                        if (!String.isEmpty(CITY_ENG)) catsTmpAcquire.CITY_ENG__c                   = CITY_ENG;
                        if (!String.isEmpty(NATION_ENG)) catsTmpAcquire.NATION_ENG__c               = NATION_ENG;
                        if (!String.isEmpty(VCARDNO)) catsTmpAcquire.VCARDNO__c                     = VCARDNO;
                        if (!String.isEmpty(TMARKET_YN)) catsTmpAcquire.TMARKET_YN__c               = TMARKET_YN;

                        upsertList.add(catsTmpAcquire);

                    }    
                }

            upsert upsertList Seq__c;
            System.debug('upsertList size : ' + upsertList.size());   

            
            // 응답파라미터 생성.
            /*
            List<String> catsTmpAcquSeqs= new List<String>();

            for (CATS_TMP_ACQUIRE__c tempCatsTmpAcqu : upsertList) {
                String tempSeq = String.valueOf(tempCatsTmpAcqu.Seq__c);
                catsTmpAcquSeqs.add(tempSeq);
            }

            rstMap.put('catsTmpAcquSeqs', catsTmpAcquSeqs);
            */
            } else {
                throw new BizException('법인카드 매입내역 리스트가 없습니다. 매입내역 데이터를 확인해주세요');
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Exception error message : ' + e.getMessage());
            throw e;
        }

        return rstMap;

       }        
}