import * as Backbone from 'backbone';
import $ from 'jquery';
import MTV from './views/app-view.js';

Backbone.history.start({ pushState: true, root: '/' });

$(() => {
    let baseDir = '/tei/w-sep/';
    new MTV(
    	{"files" : [baseDir+'S07326-w-sep.xml', baseDir+'S00483-w-sep.xml', baseDir+'S01520-w-sep.xml'],
    	"base" : "S07326-w-sep",
    	"collation" : '/test/m_collation.xml',
    	"el": "#TEI"}
    );
});