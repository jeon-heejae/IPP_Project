import { LightningElement,track } from 'lwc';
import getData from '@salesforce/apex/coinController.searchData';

export default class CoinTable extends LightningElement {

    columns=[
        {label: '순위', fieldName: 'Rank', type:'number', sortable:true},
        {label: '종목', fieldName: 'Name', type:'text', sortable:true},
        {label: '기호', fieldName: 'Symbol', type:'text', sortable:true},
        {label: '가격(KRW)', fieldName: 'Price', type:'number', sortable:true},
        {label: '총 시가', fieldName: 'Market_cap', type:'text', sortable:true},
        {label: '거래량(24H)', fieldName: 'volume_24h', type:'text', sortable:true},
        {label: '변동(24H)', fieldName: 'percent_change_24h', type:'text', sortable:true},
        {label: '변동(7D)', fieldName: 'percent_change_7d', type:'text', sortable:true}
    ];

    data=[];
    last_updated='';

 
    connectedCallback(){
        this.initializeComponent();
    }

    initializeComponent(){
        getData()
            .then((result) => {
                if (result.length > 0) {
                    this.last_updated = result[0].last_updated; // 첫 번째 데이터의 업데이트 날짜로 설정
                }

                this.data=result.map((coin) => ({
                    Rank:coin.rank,
                    Name:coin.name,
                    Symbol:coin.symbol,
                    Price:coin.price,
                    Market_cap:coin.market_cap,
                    volume_24h:coin.volume_24h,
                    percent_change_24h:coin.percent_change_24h,
                    percent_change_7d:coin.percent_change_7d
            
                }));

                
            })
    }

    get getLast_updated(){
        return '최근 업데이트: '+ this.last_updated;
    }
}