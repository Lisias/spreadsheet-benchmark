// For this script we manually generated the data to run the experiment on with the genSheet function.
// The call only needs to be made once per each sheet size.
// An example call is commented out in the main loop function.

var DATA_SHEET = "datasheet_url"
var sizes = [150, 6000, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000];

// ---------------------------------------- FORMULA ----------------------------------------
var urls = ["url1", "url2", "..."];

// ---------------------------------------- NO FORMULA ----------------------------------------
//var urls = ["url1", "url2", "..."];

var EXPER_NAME = "cumulative_sum_good tests formula"
function loop() {
  var results = [];
  var tenruns = []; // to average across 10 trials
  //genSheet(sizes[2], urls[2]);
  for (j = 0; j < 10; j ++) {
    for (i = 0; i < sizes.length; i++) {
      var ret = cumulative_sum_good(urls[i], sizes[i]);
      results.push(ret);
    }
    tenruns.push(results);
    results = [];
  }
  averageStats(tenruns);
}

// times is arry of 10 arrays, each size # sizes tested
// this function removes the min and max outliers and average the remaining 8 times for each size spreadsheet
function averageStats(times) {
  var results_sheet = SpreadsheetApp.openByUrl(DATA_SHEET).getActiveSheet();
  var perSize = []; // get the all times for one size sheet
  for (i = 0; i < times[0].length; i++) {
    perSize.push([]);
  }
  for (i = 0; i < times.length; i++) {
    for (j = 0; j < times[i].length; j++) {
      perSize[j].push(times[i][j]);
    }
  }

  var results = [];
  for (z = 0; z < perSize.length; z++) {
    cur = perSize[z];
    writeInter(results_sheet, cur);
    cur.splice(cur.indexOf(Math.min.apply(null, cur)), 1);
    cur.splice(cur.indexOf(Math.max.apply(null, cur)), 1);
    var sum = 0;
    for (j = 0; j < cur.length; j++) {
      sum+=cur[j];
    }
    results.push(sum/cur.length);
  }

  writeToSheet(results_sheet, results);
}

// this function writes all of the trial times for each size sheet to a datasheet and
// highlights the averaged times for each size sheet
// helper function called by averageStats
function writeToSheet(sheet, results) {
  var time = new Date();
  var lastRow = sheet.getLastRow()+1;
  sheet.getRange(lastRow, 1).setValue(Utilities.formatDate(time, 'America/Chicago', 'MMMM dd, yyyy HH:mm:ss Z'));
  lastRow++;
  sheet.getRange(lastRow, 1).setValue(EXPER_NAME);
  lastRow++;
  for (i = 0; i < results.length; i++) {
      sheet.getRange(lastRow, i+1).setValue(sizes[i]);
  }
  lastRow++;
  for (i = 0; i < results.length; i++) {
    sheet.getRange(lastRow, i+1).setValue(results[i]).setBackground("orange");
  }
}

// writes the intermediate trial times for one sized sheet
// helper function called by writeToSheet
function writeInter(sheet, results) {
  var lastRow = sheet.getLastRow()+1;
  for (i = 0; i < results.length; i++) {
    sheet.getRange(lastRow, i+1).setValue(results[i]);
  }
}

// create the formula chain
function genSheet(size, url) {
  var sheet = SpreadsheetApp.openByUrl(url).getActiveSheet();
  var data = sheet.getRange(1,1,size,2).getValues();
    data[0][0]="1";
    data[0][1]="=A1";
  for (z = 1; z < size; z++) {
    data[z][0]= z + 1;
    data[z][1]="=B" + z + "+A" + (z+1);
  }
 sheet.getRange(1,1,size,2).setValues(data);
}


function cumulative_sum_good(size, url) {
  var sheet = SpreadsheetApp.openByUrl(url).getActiveSheet();
  var oldVal = sheet.getRange(1,1).getValue();
  console.log(oldVal);
  var date = new Date();
  sheet.getRange(1,1).setValue(oldVal + 1);
  var count = sheet.getRange(size,2).getValue();
  var endDate = new Date();
  console.log("da da da count is " + count);
  ret = endDate.getTime() - date.getTime();
  return ret;
}