/*! 
 * The neccessary function
 * to be used in
 * development mode
 */
function loadCSS(fileName){
    var el = document.querySelector('link[data-src="'+fileName+'"]');
    var href = el.getAttribute("href").split("?");
    href = href[0];
    el.setAttribute("href", href+"?ext="+Math.random());
    el.remove();
    document.getElementsByTagName("head")[0].appendChild(el);
    return el;
};

var reloadCSS = function()
{
    var csss = $('link[data-src]');
    $('link[data-src]').each(function(i, e){
        loadCSS($(this).attr('data-src'));
    });

}
