/*!
 * To check if the Object is empty or not
 */
_.isEmpty = function(obj)
{
    for(var k in obj) { if(obj.hasOwnProperty(k)) return false; }
    return true;
};

_.requireJS = function(js, cb)
{
    const ext = _.isProduction ? '':('&ext='+Math.random());
    $script(js + '?vsn={{ vsn }}'+ext, cb); 
};

_.require = function(src, cb)
{
    if(!this.isEmpty(src)){
        var src = src.map(function(item){
            return item+(ENV=="DEV"?("?ext="+Math.random()):"");
        });
        var name ="name"+Math.random();
        $script(src, cb);
    }else{
        if(String(cb) != "undefined"){
            var timer = window.setTimeout(function(){
                cb();
                window.clearTimeout(timer);
            },10);
        }

    }
};

/*  Distpach a custom event
 * name {string}: Event name
 * props {object}: Properties parsed to event
 */
_.dispatchEvent = function(name, props)
{
    var evt = document.createEvent('CustomEvent');
    evt.initEvent(name, true, true, props);
    document.dispatchEvent(evt);
};


document.addEventListener('DOMContentLoaded',function(e)
    {
        _.require(JS.init, function(){
            console.log("Initial script loaded...");
            /* History.init({baseURL:App.baseURL}); */
            _.rDom = React.createElement;
            _.rRender = function(rd, t, cb){
                ReactDOM.unmountComponentAtNode(document.getElementById(t));
                ReactDOM.render(rd, document.getElementById(t), cb); 
            };
            var evt = document.createEvent("CustomEvent");
            evt.initEvent("initScriptLoaded", true, true, {detail:JS.init});
            document.dispatchEvent(evt);
        });
    });

var baseURL = function(param) { return _.baseURL + (param || ''); };
var parentURL = function(param) { return _.parentURL + (param || ''); };

_.Locales = _.Locales || {};
_.Locale = 
    {
        LANG: LANG || 'en',
        inject:function(str, obj = {})
        {
            for (var key in obj)
            {
                str = str.replace(`:${key}`, obj[key]);
            }
            return str;
        },

        get:function(key, replace = {})
        {
            let trans = key.split('.').reduce((t, i) => t[i] || key, _.Locales);
            return this.inject(trans || key, replace);
        },

        question:function(key, force, dom) { return this.get(key, force, dom, '?') },
        label: function(key, force, dom) { return this.get(key, force, dom, ':'); }
    };

_.addCSRF = function(data)
{
    var data = data || {};
    data[_.token.name] = _.token.hash;
    return data;
};

_.removeKeys = function(obj, keys)
{
    keys.forEach(function(key){
        delete obj[key];
    });
};

