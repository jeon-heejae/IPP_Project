public with sharing class AccountService {
    public Account createAccount( String accountName, String accountNumber, String tickerSymbol ) {
      Account newAcct = new Account(
        Name = accountName,
        AccountNumber = accountNumber,
        TickerSymbol = tickerSymbol
      );


      // 로그 크기 모니터링 예시
      System.debug(LoggingLevel.INFO, 
          'Current log size: ' + Limits.getLogLength());

      return newAcct;
    }
  }