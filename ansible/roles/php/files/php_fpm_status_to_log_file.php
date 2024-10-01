<?php
// Collect php-fpm status metrics from the php-fpm status URL and write them to
// a tab separated log file

// URL to the Apache server php-fpm status page
$url = "http://127.0.0.1:8080/xx-fpm.status?json";
$log_file = '/var/log/php-fpm/php-fpm-status.log';

// The URI to view the FPM status page. If this value is not set, no URI will be
// recognized as a status page. It shows the following informations:
//   pool                 - the name of the pool;
//   process manager      - static, dynamic or ondemand;
//   start time           - the date and time FPM has started;
//   start since          - number of seconds since FPM has started;
//   accepted conn        - the number of request accepted by the pool;
//   listen queue         - the number of request in the queue of pending
//                          connections (see backlog in listen(2));
//   max listen queue     - the maximum number of requests in the queue
//                          of pending connections since FPM has started;
//   listen queue len     - the size of the socket queue of pending connections;
//   idle processes       - the number of idle processes;
//   active processes     - the number of active processes;
//   total processes      - the number of idle + active processes;
//   max active processes - the maximum number of active processes since FPM
//                          has started;
//   max children reached - number of times, the process limit has been reached,
//                          when pm tries to start more children (works only for
//                          pm 'dynamic' and 'ondemand');

// Raw output from php-fpm status
// pool:                 www
// process manager:      dynamic
// start time:           26/Sep/2024:10:49:53 +0000
// start since:          2724
// accepted conn:        13
// listen queue:         0
// max listen queue:     0
// listen queue len:     0
// idle processes:       4
// active processes:     1
// total processes:      5
// max active processes: 1
// max children reached: 0
// slow requests:        0


// Fetch the status page content and convert from JSON to PHP hash
$timestamp = date("c");
$status_json = file_get_contents($url);
$data = json_decode($status_json, true);

// Generate the log file line
$log_line = $timestamp . "\t" . $data['accepted conn'] . "\t" . $data['listen queue'] . "\t" . $data['max listen queue'] . "\t" . $data['listen queue len'] . "\t" . $data['idle processes'] . "\t" . $data['active processes'] . "\t" . $data['total processes'] . "\t" . $data['max active processes'] . "\t" . $data['max children reached'] . "\t" . $data['slow requests'] . "\n";

// Open the file in append mode and write the JSON output
$file_handle = fopen($log_file, 'a');
if ($file_handle === FALSE) {
  die("Error opening file for appending.");
}

// Append JSON output to the file on a single line
if (fwrite($file_handle, $log_line) === FALSE) {
  die("Error writing apache status log file.");
}

// Close the file handle
fclose($file_handle);
?>