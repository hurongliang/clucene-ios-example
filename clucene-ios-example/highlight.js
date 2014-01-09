function getHighlightClassName(){
    return "dynamicHighlight";
}

function getSelectionClassName(){
    return "dynamicSelection";
}

(function(){
 function createHighlightClass(){
    var style = $('<style>.'+getHighlightClassName()+'{background-color:yellow;color:black;}</style>');
    $('html > head').append(style);
 }
 
 function createSelectionClass(){
    var style = $('<style>.'+getSelectionClassName()+'{background-color:blue;color:white;}</style>');
    $('html > head').append(style);
 }
 
 createHighlightClass();
 createSelectionClass();
})();
// We're using a global variable to store the number of occurrences
//var MyApp_SearchResultCount = 0;

// helper function, recursively searches in elements and their child nodes
function highlightAllOccurencesOfStringForElement(element,keyword) {
    if (element) {
        if (element.nodeType == 3) {        // Text node
            while (true) {
                var value = element.nodeValue;  // Search for keyword in text node
                var idx = value.toLowerCase().indexOf(keyword);
                
                if (idx < 0) break;             // not found, abort
                
                var span = document.createElement("span");
                var text = document.createTextNode(value.substr(idx,keyword.length));
                span.appendChild(text);
                span.setAttribute("class",getHighlightClassName());
                text = document.createTextNode(value.substr(idx+keyword.length));
                element.deleteData(idx, value.length - idx);
                var next = element.nextSibling;
                element.parentNode.insertBefore(span, next);
                element.parentNode.insertBefore(text, next);
                element = text;
               // MyApp_SearchResultCount++;	// update the counter
            }
        } else if (element.nodeType == 1) { // Element node
            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    highlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}

// the main entry point to start the search
function highlightAllOccurencesOfString(keyword) {
    removeAllHighlights();
    highlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
}

// helper function, recursively removes the highlights in elements and their childs
function removeAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            if (element.getAttribute("class") == getHighlightClassName()) {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    if (removeAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                if (normalize) {
                    element.normalize();
                }
            }
        }
    }
    return false;
}

// the main entry point to remove the highlights
function removeAllHighlights() {
    //MyApp_SearchResultCount = 0;
    removeAllHighlightsForElement(document.body);
}

var __matchIndex = -1;
function scrollToNextMatch(){
    clearSelection();
    
    var $allMatches = $("."+getHighlightClassName());
    var matchesCount = $allMatches.length;
    
    if(matchesCount<=0)
        return;
    
    if(++__matchIndex<matchesCount){
        var $matchSpan = $($allMatches[__matchIndex]);
        selectObject($matchSpan);
        
        $("html,body").animate({
                               scrollTop:$matchSpan.offset().top
                               },200);
    }else{
        __matchIndex = matchesCount-1;
        sendCommand("scroll","next_match");
    }
}

function scrollToPrevMatch(){
    clearSelection();
    
    var $allMatches = $("."+getHighlightClassName());
    var matchesCount = $allMatches.length;
    
    if(matchesCount<=0)
        return;
    
    if(--__matchIndex>=0){
        var $matchSpan = $($allMatches[__matchIndex]);
        selectObject($matchSpan);
        
        $("html,body").animate({
                               scrollTop:$matchSpan.offset().top
                               },200);
    }else{
        __matchIndex = 0;
        sendCommand("scroll","prev_match");
    }
}

function selectObject($obj){
    $obj.removeClass(getHighlightClassName()).addClass(getSelectionClassName());
}

function clearSelection(){
    $("."+getSelectionClassName()).removeClass(getSelectionClassName()).addClass(getHighlightClassName());
}