const TEST_FAILED = "RESULT:FAIL";
const TEST_PASSED = "RESULT:PASS";

const TEST_FILE = process.argv[process.argv.length - 1];

originalExit = process.exit;

function remappedExit(val) {
  if (val !== null && val !== 0) {
    console.log(TEST_FAILED);
  } else {
    console.log(TEST_PASSED);
  }
  originalExit(val);
}

process.exit = remappedExit;

process.on('uncaughtException', function(err) {
  // Some tests have their own listener, in that case let the test run
  if (process.listeners('uncaughtException').length == 1) {
   console.error('Caught exception:', err);
   remappedExit(1);
  }
});

const common = require('./common');
common.allowGlobals(originalExit);

// If you need to debug the node arguments, uncomment the following code
/*
process.argv.forEach(function(value, index, array) {
  console.log("arg " + index + ": " + value);
})
*/

const test = require(TEST_FILE);
