/**
 * (예외처리 클래스) 법인카드 승인내역 등록 및 수정 CLASS. 
 * 승인내역(CATS_TMP_APPROVAL__c)에 데이터를 생성 또는 수정.
 * 
 * 작성자 : 김원준, wonjun@daeucna.com
 * 최초작성일자 : 2024-12-05
 * 
 * ================================
 * [수행내용]
 * (1) LIST형태로 받은 데이터를 각각 Map 단위로 등록(INSERT)한다.
 * (2) 만약, 각 Map에 있는 일련번호(Seq__c) 값이 승인내역(CATS_TMP_APPROVAL__c)에 존재하면 수정(UPDATE) 한다.
 * ================================
 */
public with sharing class IFAPPROVALTRANImpl implements UserInterface {
    public IFAPPROVALTRANImpl() {}

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
                        "TRANSDATE": "",
                        "TRANSTIME": "",
                        "CARDTYPE1": "",
                        "CARDTYPE2": "",
                        "CURRCODE": "",
                        "APPRAMT": "",
                        "VAT": "",
                        "TIPS": "",
                        "APPRTOT": "",
                        "APPREXCH": "",
                        "USDAPPRTOT": "",
                        "INSTTYPE": "",
                        "INSTMONTH": "",
                        "ABROAD": "",
                        "SLIPNO": "",
                        "TERMINALNO": "",
                        "PURCH": "",
                        "ACQUISSUER": "",
                        "MERCHBIZNO": "",
                        "MERCHNO": "",
                        "MERCHNAME": "",
                        "MASTER": "",
                        "MERCHTEL": "",
                        "MERCHZIPCODE": "",
                        "MERCHADDR1": "",
                        "MERCHADDR2": "",
                        "MERCHSTATUS": "",
                        "MCCNAME": "",
                        "MCCCODE": "",
                        "PARTAPPRCANCYN": "",
                        "SERVTYPEYN": "",
                        "COLLNO": "",
                        "ORIGINTRANSDATE": "",
                        "ORIGINAPPRNO": "",
                        "ORIGINTRANSTIME": "",
                        "ORIGINMERCHNAME": "",
                        "CARD_CHECK_GB": "",
                        "ORIGINMERCHBIZNO": "",
                        "TAXTYPE": "",
                        "MERCHCESSDATE": "",
                        "TAXTYPEDATE": "",
                        "APPRAMT1": "",
                        "VAT1": "",
                        "VATYN": "",
                        "WORKDATE": "",
                        "ERRYN": "",
                        "TRACQ": "",
                        "FILE_YN": "",
                        "ERP_YN": "",
                        "CARDLIMITAPPR": "",
                        "SETTDATE": "",
                        "BCMCCNAME": "",
                        "BCMCCCODE": "",
                        "MEMBCODE": "",
                        "TIPS1": "",
                        "OIL_TYPE": "",
                        "OIL_QTY": ""
                    }
                        .
                        .
                        .
                    {}            
                ]
            }        
        */        

        logger.add('-----------------------------------------------------------------------------------------------------------------------');
        logger.add('Interface ID : ' + ifId + ', 법인카드 승인내역 등록, 수정 CLASS.  ');
        logger.add('-----------------------------------------------------------------------------------------------------------------------');            

        List<Object> getIfList = (List<Object>) vo.get('IF_LIST'); //수정할 법인카드 승인내역 리스트를 가져온다.

        if(getIfList.size() > 200) {
            throw new BizException('법인카드 승인내역 리스트의 길이가 200 건을 초과했습니다. 200건 미만으로 요청해주세요.');
        }

        Savepoint sp = Database.setSavepoint(); // 트랜잭션의 시작점 설정.

        // 등록 프로그램 시작. 실패 시 Rollback.        
        try {

            if (getIfList.size() > 0) {
                
                List<CATS_TMP_APPROVAL__c> upsertList = new List<CATS_TMP_APPROVAL__c>(); // 법인카드 승인내역 UPSERT 리스트

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
                        String CARDNO               = MetaDataHelper.getString2Object(data.get('CARDNO'));
                        String APPRNO               = MetaDataHelper.getString2Object(data.get('APPRNO'));
                        String TRANSDATE            = MetaDataHelper.getString2Object(data.get('TRANSDATE'));
                        String TRANSTIME            = MetaDataHelper.getString2Object(data.get('TRANSTIME'));
                        String CARDTYPE1            = MetaDataHelper.getString2Object(data.get('CARDTYPE1'));
                        String CARDTYPE2            = MetaDataHelper.getString2Object(data.get('CARDTYPE2'));
                        String CURRCODE             = MetaDataHelper.getString2Object(data.get('CURRCODE'));
                        String APPRAMT              = MetaDataHelper.getString2Object(data.get('APPRAMT'));
                        String VAT                  = MetaDataHelper.getString2Object(data.get('VAT'));
                        String TIPS                 = MetaDataHelper.getString2Object(data.get('TIPS'));
                        String APPRTOT              = MetaDataHelper.getString2Object(data.get('APPRTOT'));
                        String APPREXCH             = MetaDataHelper.getString2Object(data.get('APPREXCH'));
                        String USDAPPRTOT           = MetaDataHelper.getString2Object(data.get('USDAPPRTOT'));
                        String INSTTYPE             = MetaDataHelper.getString2Object(data.get('INSTTYPE'));
                        String INSTMONTH            = MetaDataHelper.getString2Object(data.get('INSTMONTH'));
                        String ABROAD               = MetaDataHelper.getString2Object(data.get('ABROAD'));
                        String SLIPNO               = MetaDataHelper.getString2Object(data.get('SLIPNO'));
                        String TERMINALNO           = MetaDataHelper.getString2Object(data.get('TERMINALNO'));
                        String PURCH                = MetaDataHelper.getString2Object(data.get('PURCH'));
                        String ACQUISSUER           = MetaDataHelper.getString2Object(data.get('ACQUISSUER'));
                        String MERCHBIZNO           = MetaDataHelper.getString2Object(data.get('MERCHBIZNO'));
                        String MERCHNO              = MetaDataHelper.getString2Object(data.get('MERCHNO'));
                        String MERCHNAME            = MetaDataHelper.getString2Object(data.get('MERCHNAME'));
                        String MASTER               = MetaDataHelper.getString2Object(data.get('MASTER'));
                        String MERCHTEL             = MetaDataHelper.getString2Object(data.get('MERCHTEL'));
                        String MERCHZIPCODE         = MetaDataHelper.getString2Object(data.get('MERCHZIPCODE'));
                        String MERCHADDR1           = MetaDataHelper.getString2Object(data.get('MERCHADDR1'));
                        String MERCHADDR2           = MetaDataHelper.getString2Object(data.get('MERCHADDR2'));
                        String MERCHSTATUS          = MetaDataHelper.getString2Object(data.get('MERCHSTATUS'));
                        String MCCNAME              = MetaDataHelper.getString2Object(data.get('MCCNAME'));
                        String MCCCODE              = MetaDataHelper.getString2Object(data.get('MCCCODE'));
                        String PARTAPPRCANCYN       = MetaDataHelper.getString2Object(data.get('PARTAPPRCANCYN'));
                        String SERVTYPEYN           = MetaDataHelper.getString2Object(data.get('SERVTYPEYN'));
                        String COLLNO               = MetaDataHelper.getString2Object(data.get('COLLNO'));
                        String ORIGINTRANSDATE      = MetaDataHelper.getString2Object(data.get('ORIGINTRANSDATE'));
                        String ORIGINAPPRNO         = MetaDataHelper.getString2Object(data.get('ORIGINAPPRNO'));
                        String ORIGINTRANSTIME      = MetaDataHelper.getString2Object(data.get('ORIGINTRANSTIME'));
                        String ORIGINMERCHNAME      = MetaDataHelper.getString2Object(data.get('ORIGINMERCHNAME'));
                        String CARD_CHECK_GB        = MetaDataHelper.getString2Object(data.get('CARD_CHECK_GB'));
                        String ORIGINMERCHBIZNO     = MetaDataHelper.getString2Object(data.get('ORIGINMERCHBIZNO'));
                        String TAXTYPE              = MetaDataHelper.getString2Object(data.get('TAXTYPE'));
                        String MERCHCESSDATE        = MetaDataHelper.getString2Object(data.get('MERCHCESSDATE'));
                        String TAXTYPEDATE          = MetaDataHelper.getString2Object(data.get('TAXTYPEDATE'));
                        String APPRAMT1             = MetaDataHelper.getString2Object(data.get('APPRAMT1'));
                        String VAT1                 = MetaDataHelper.getString2Object(data.get('VAT1'));
                        String VATYN                = MetaDataHelper.getString2Object(data.get('VATYN'));
                        String WORKDATE             = MetaDataHelper.getString2Object(data.get('WORKDATE'));
                        String ERRYN                = MetaDataHelper.getString2Object(data.get('ERRYN'));
                        String TRACQ                = MetaDataHelper.getString2Object(data.get('TRACQ'));
                        String FILE_YN              = MetaDataHelper.getString2Object(data.get('FILE_YN'));
                        String ERP_YN               = MetaDataHelper.getString2Object(data.get('ERP_YN'));
                        String CARDLIMITAPPR        = MetaDataHelper.getString2Object(data.get('CARDLIMITAPPR'));
                        String SETTDATE             = MetaDataHelper.getString2Object(data.get('SETTDATE'));
                        String BCMCCNAME            = MetaDataHelper.getString2Object(data.get('BCMCCNAME'));
                        String BCMCCCODE            = MetaDataHelper.getString2Object(data.get('BCMCCCODE'));
                        String MEMBCODE             = MetaDataHelper.getString2Object(data.get('MEMBCODE'));
                        String TIPS1                = MetaDataHelper.getString2Object(data.get('TIPS1'));
                        String OIL_TYPE             = MetaDataHelper.getString2Object(data.get('OIL_TYPE'));
                        String OIL_QTY              = MetaDataHelper.getString2Object(data.get('OIL_QTY'));
                        
                        CATS_TMP_APPROVAL__c catsTmpApproval = new CATS_TMP_APPROVAL__c();

                        // upsert할 오브젝트를 생성 및 리스트에 추가한다.
                        catsTmpApproval.Seq__c                                                      = MetaDataHelper.getDecimal2String(SEQ);
                        if (!String.isEmpty(DATACODE)) catsTmpApproval.DataCode__c                  = DATACODE;
                        if (!String.isEmpty(COMPANYID)) catsTmpApproval.CompanyID__c                = COMPANYID;
                        if (!String.isEmpty(SENDDATE)) catsTmpApproval.SendDate__c                  = SENDDATE;
                        if (!String.isEmpty(SEQNO)) catsTmpApproval.SeqNo__c                        = SEQNO;
                        if (!String.isEmpty(READFLAG)) catsTmpApproval.ReadFlag__c                  = READFLAG;
                        if (!String.isEmpty(STRINGCLASS)) catsTmpApproval.Class__c                  = STRINGCLASS;
                        if (!String.isEmpty(CARDNO)) catsTmpApproval.CardNo__c                      = CARDNO;
                        if (!String.isEmpty(APPRNO)) catsTmpApproval.ApprNo__c                      = APPRNO;
                        if (!String.isEmpty(TRANSDATE)) catsTmpApproval.TransDate__c                = TRANSDATE;
                        if (!String.isEmpty(TRANSTIME)) catsTmpApproval.TransTime__c                = TRANSTIME;
                        if (!String.isEmpty(CARDTYPE1)) catsTmpApproval.CardType1__c                = CARDTYPE1;
                        if (!String.isEmpty(CARDTYPE2)) catsTmpApproval.CardType2__c                = CARDTYPE2;
                        if (!String.isEmpty(CURRCODE)) catsTmpApproval.CurrCode__c                  = CURRCODE;
                        if (!String.isEmpty(APPRAMT)) catsTmpApproval.ApprAmt__c                    = MetaDataHelper.getDecimal2String(APPRAMT);
                        if (!String.isEmpty(VAT)) catsTmpApproval.VAT__c                            = MetaDataHelper.getDecimal2String(VAT);
                        if (!String.isEmpty(TIPS)) catsTmpApproval.Tips__c                          = MetaDataHelper.getDecimal2String(TIPS);
                        if (!String.isEmpty(APPRTOT)) catsTmpApproval.ApprTot__c                    = MetaDataHelper.getDecimal2String(APPRTOT);
                        if (!String.isEmpty(APPREXCH)) catsTmpApproval.ApprExch__c                  = MetaDataHelper.getDecimal2String(APPREXCH);
                        if (!String.isEmpty(USDAPPRTOT)) catsTmpApproval.USDApprTot__c              = MetaDataHelper.getDecimal2String(USDAPPRTOT);
                        if (!String.isEmpty(INSTTYPE)) catsTmpApproval.InstType__c                  = INSTTYPE;
                        if (!String.isEmpty(INSTMONTH)) catsTmpApproval.InstMonth__c                = INSTMONTH;
                        if (!String.isEmpty(ABROAD)) catsTmpApproval.Abroad__c                      = ABROAD;
                        if (!String.isEmpty(SLIPNO)) catsTmpApproval.SlipNo__c                      = SLIPNO;
                        if (!String.isEmpty(TERMINALNO)) catsTmpApproval.TerminalNo__c              = TERMINALNO;
                        if (!String.isEmpty(PURCH)) catsTmpApproval.Purch__c                        = PURCH;
                        if (!String.isEmpty(ACQUISSUER)) catsTmpApproval.AcquIssuer__c              = ACQUISSUER;
                        if (!String.isEmpty(MERCHBIZNO)) catsTmpApproval.MerchBizNo__c              = MERCHBIZNO;
                        if (!String.isEmpty(MERCHNO)) catsTmpApproval.MerchNo__c                    = MERCHNO;
                        if (!String.isEmpty(MERCHNAME)) catsTmpApproval.MerchName__c                = MERCHNAME;
                        if (!String.isEmpty(MASTER)) catsTmpApproval.Master__c                      = MASTER;
                        if (!String.isEmpty(MERCHTEL)) catsTmpApproval.MerchTel__c                  = MERCHTEL;
                        if (!String.isEmpty(MERCHZIPCODE)) catsTmpApproval.MerchZipcode__c          = MERCHZIPCODE;
                        if (!String.isEmpty(MERCHADDR1)) catsTmpApproval.MerchAddr1__c              = MERCHADDR1;
                        if (!String.isEmpty(MERCHADDR2)) catsTmpApproval.MerchAddr2__c              = MERCHADDR2;
                        if (!String.isEmpty(MERCHSTATUS)) catsTmpApproval.MerchStatus__c            = MERCHSTATUS;
                        if (!String.isEmpty(MCCNAME)) catsTmpApproval.MCCName__c                    = MCCNAME;
                        if (!String.isEmpty(MCCCODE)) catsTmpApproval.MCCCode__c                    = MCCCODE;
                        if (!String.isEmpty(PARTAPPRCANCYN)) catsTmpApproval.PartApprCancYN__c      = PARTAPPRCANCYN;
                        if (!String.isEmpty(SERVTYPEYN)) catsTmpApproval.ServTypeYN__c              = SERVTYPEYN;
                        if (!String.isEmpty(COLLNO)) catsTmpApproval.CollNo__c                      = COLLNO;
                        if (!String.isEmpty(ORIGINTRANSDATE)) catsTmpApproval.OriginTransDate__c    = ORIGINTRANSDATE;
                        if (!String.isEmpty(ORIGINAPPRNO)) catsTmpApproval.OriginApprNo__c          = ORIGINAPPRNO;
                        if (!String.isEmpty(ORIGINTRANSTIME)) catsTmpApproval.OriginTransTime__c    = ORIGINTRANSTIME;
                        if (!String.isEmpty(ORIGINMERCHNAME)) catsTmpApproval.OriginMerchName__c    = ORIGINMERCHNAME;
                        if (!String.isEmpty(CARD_CHECK_GB)) catsTmpApproval.CARD_CHECK_GB__c        = CARD_CHECK_GB;
                        if (!String.isEmpty(ORIGINMERCHBIZNO)) catsTmpApproval.OriginMerchBizNo__c  = ORIGINMERCHBIZNO;
                        if (!String.isEmpty(TAXTYPE)) catsTmpApproval.TaxType__c                    = TAXTYPE;
                        if (!String.isEmpty(MERCHCESSDATE)) catsTmpApproval.MerchCessDate__c        = MERCHCESSDATE;
                        if (!String.isEmpty(TAXTYPEDATE)) catsTmpApproval.TaxTypeDate__c            = TAXTYPEDATE;
                        if (!String.isEmpty(APPRAMT1)) catsTmpApproval.ApprAmt1__c                  = MetaDataHelper.getDecimal2String(APPRAMT1);
                        if (!String.isEmpty(VAT1)) catsTmpApproval.VAT1__c                          = MetaDataHelper.getDecimal2String(VAT1);
                        if (!String.isEmpty(VATYN)) catsTmpApproval.VATYN__c                        = VATYN;
                        if (!String.isEmpty(WORKDATE)) catsTmpApproval.WorkDate__c                  = WORKDATE;
                        if (!String.isEmpty(ERRYN)) catsTmpApproval.ErrYN__c                        = ERRYN;
                        if (!String.isEmpty(TRACQ)) catsTmpApproval.TrAcq__c                        = TRACQ;
                        if (!String.isEmpty(FILE_YN)) catsTmpApproval.FILE_YN__c                    = FILE_YN;
                        if (!String.isEmpty(ERP_YN)) catsTmpApproval.ERP_YN__c                      = ERP_YN;
                        if (!String.isEmpty(CARDLIMITAPPR)) catsTmpApproval.CardLimitAppr__c        = MetaDataHelper.getDecimal2String(CARDLIMITAPPR);
                        if (!String.isEmpty(SETTDATE)) catsTmpApproval.SettDate__c                  = SETTDATE;
                        if (!String.isEmpty(BCMCCNAME)) catsTmpApproval.BCMccName__c                = BCMCCNAME;
                        if (!String.isEmpty(BCMCCCODE)) catsTmpApproval.BCMccCode__c                = BCMCCCODE;
                        if (!String.isEmpty(MEMBCODE)) catsTmpApproval.MembCode__c                  = MEMBCODE;
                        if (!String.isEmpty(TIPS1)) catsTmpApproval.Tips1__c                        = MetaDataHelper.getDecimal2String(TIPS1);
                        if (!String.isEmpty(OIL_TYPE)) catsTmpApproval.OIL_TYPE__c                  = OIL_TYPE;
                        if (!String.isEmpty(OIL_QTY)) catsTmpApproval.OIL_QTY__c                    = MetaDataHelper.getDecimal2String(OIL_QTY);

                        upsertList.add(catsTmpApproval);

                    }    
                }

            upsert upsertList Seq__c;
            System.debug('upsertList size : ' + upsertList.size());   

            
            // 응답파라미터 생성.
            /*
            List<String> catsTmpApprSeqs = new List<String>();

            for (CATS_TMP_APPROVAL__c tempCatsTmpAppr : upsertList) {
                String tempSeq = String.valueOf(tempCatsTmpAppr.Seq__c);
                catsTmpApprSeqs.add(tempSeq);
            }

            rstMap.put('catsTmpApprSeqs', catsTmpApprSeqs);
            */
            } else {
                throw new BizException('법인카드 승인내역 리스트가 없습니다. 승인내역 데이터를 확인해주세요');
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Exception error message : ' + e.getMessage());
            throw e;
        }

        return rstMap;

       }
}