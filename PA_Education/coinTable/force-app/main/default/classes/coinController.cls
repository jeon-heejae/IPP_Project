public with sharing class coinController {
   @AuraEnabled
   public static List<Map<String,Object>> searchData(){
    
    String endPointUrl='https://api.coinpaprika.com/v1/tickers?quotes=KRW';

    Http http=new Http();
    HttpRequest request=new HttpRequest();
    HttpResponse response=new HttpResponse();

    request.setEndpoint(endPointUrl);
    request.setMethod('GET');
    request.setTimeout(110000);
    response=http.send(request);
    List <Object> results=(List<Object>) JSON.deserializeUntyped(response.getBody());
    //Map <String,Object> mapResults=(Map<String,Object>) results[0];
    List<Map<String,Object>> listFinalResults=new List<Map<String,Object>>();

    if(response.getStatusCode()==200){
        for(Object objReults:results){
            Map <String,Object> mapResults=(Map<String,Object>) objReults;
            Integer intRank=(Integer) mapResults.get('rank');
            if(intRank>100){
                break;
            }
            
            Map<String,Object> mapFinalResult=new Map<String,Object>();
            mapFinalResult.put('rank',intRank); //순위
            mapFinalResult.put('name',(String) mapResults.get('name')); //종목
            mapFinalResult.put('symbol',(String) mapResults.get('symbol')); //기호

            Map<String,Object> mapQuotes=(Map<String,Object>)mapResults.get('quotes');
            //System.debug(mapQuotes);
            Map<String,Object> mapKRW=(Map<String,Object>)mapQuotes.get('KRW');
            //System.debug(mapKRW);

            String strLast_updated=(String) mapResults.get('last_updated');
            String strLast_updated_process = formatDate(strLast_updated);
            mapFinalResult.put('last_updated',strLast_updated_process); //최근 업데이트 날짜

            Decimal price=(Decimal) mapKRW.get('price');
            Decimal price_prcess=price.setScale(1,System.RoundingMode.HALF_UP); //소수점 1번째 자리로 반올림
            mapFinalResult.put('price', price_prcess); //가격(KRW)

            Decimal market_cap=(Decimal) mapKRW.get('market_cap');
            Decimal market_cap_process=market_cap/1000000000000.0; //조단위로 표현하기 위해 조로 나눔
            String strMarket_cap=market_cap_process.setScale(2,System.RoundingMode.HALF_UP) +'T'; //T는 조(Trillion)의 약자
            mapFinalResult.put('market_cap', strMarket_cap); //총 시가

            Decimal volume_24h=(Decimal) mapKRW.get('volume_24h');
            Decimal volume_24h_process=volume_24h/1000000000000.0;
            String strVolume_24h=volume_24h_process.setScale(2,System.RoundingMode.HALF_UP)+'T';
            mapFinalResult.put('volume_24h', strVolume_24h); //거래량(24H)

            Decimal percent_change_24h=(Decimal) mapKRW.get('percent_change_24h');
            String strPercent_change_24h=percent_change_24h+ '%';
            mapFinalResult.put('percent_change_24h', strPercent_change_24h); //변동(24H)
        
            Decimal percent_change_7d=(Decimal) mapKRW.get('percent_change_7d');
            String strPercent_change_7d=percent_change_7d+ '%';
            mapFinalResult.put('percent_change_7d', strPercent_change_7d); //변동(7D)

            listFinalResults.add(mapFinalResult);
        }
        
        System.debug(listFinalResults.size());
        return listFinalResults;
    }
    else{
        throw new AuraHandledException('검색 중 오류가 발생했습니다. 상태 코드: ' + response.getStatusCode());
    }

   }

   private static String formatDate(String strDate) {
    //String strDate='2025-01-21T05:33:29Z';
    String strProcessing=strDate.substring(0,10);
    String strProcessing2=strDate.substring(11,16);
    String formattedDate=strProcessing+' '+strProcessing2;
    System.debug('f:'+ formattedDate);
    return formattedDate;
}
}