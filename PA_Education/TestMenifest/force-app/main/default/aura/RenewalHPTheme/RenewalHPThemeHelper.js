/**
 * Created by gyubin on 2022/04/15.
 */

({
    i18n: {},
    i18nInitializer: function() {
        fetch('/homepage/resource/1650003971000/i18n', {
            method: 'get'
        }).then((res) =>
            res.json()
        ).then(json => {
                this.i18n = json
            }
        )
    }
});