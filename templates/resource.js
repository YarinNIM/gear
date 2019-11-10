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
            return item + (_.env != "production"?("?ext="+Math.random()):"");
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

document.addEventListener('DOMContentLoaded',function(e){
    _.require(JS.init, function(){
        console.log("Initial script loaded...");
        var evt = document.createEvent("CustomEvent");
        evt.initEvent("initScriptLoaded", true, true, {detail:JS.init});
        document.dispatchEvent(evt);
    });
});

const baseURL = function(param) { return _.baseURL + (param || ''); };
const parentURL = function(param) { return _.parentURL + (param || ''); };
const locale = function (key, bind = {}) 
{
    let trans = key.split('.').reduce(function(inLocale, i) {
        return inLocale[i] || key;
    }, _.Locales || {});

    return Object.keys(bind).reduce(function(inStr, index) {
        return inStr.replace(`:${index}`, bind[index]);
    }, trans || key);
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
