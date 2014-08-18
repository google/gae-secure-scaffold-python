/**
 * @fileoverview Entry point for GAE Scaffold application.
 */

goog.provide('app');
goog.require('goog.events');

/**
 * Entry point for GAE scaffold application.
 */
app.main = function() {
  console.log('app.main() entry point');
}

goog.exportSymbol('app.main', app.main);

goog.events.listen(window, goog.events.EventType.LOAD, app.main);
