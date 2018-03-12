import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import babel from 'rollup-plugin-babel';

export default {
  entry: 'src/index.js',
  format: 'iife',
  dest: 'dist/mtjsviewer.js',
  sourceMap: true,
  moduleName: 'mtjsviewer',
  plugins: [
  	babel({"exclude": 'node_modules/**', "presets": [
      ["es2015", { "modules": false }]], "plugins": ["external-helpers"]}),
    nodeResolve({
      jsnext: true,
      main: true,
      // skip: [ 'some-big-dependency' ],
      browser: true,
      // extensions: [ '.js', '.json' ]
      // preferBuiltins: false
    }),
    commonjs({
      include: 'node_modules/**',
      sourceMap: true,  // Default: true
      namedExports: { './node_modules/backbone/backbone.js': ['View', 'history', 'Collection', 'Model' ] }
    })
    ]
}
