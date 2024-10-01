<?php
// Collect apache status metrics from the Apache Server status URL and write them to
// a tab separated log file

// URL to the Apache server status page
$url = "http://127.0.0.1:8080/server-status?auto";
$log_file = '/var/log/httpd/apache-status.log';

// Stats to collect
$stats_to_collect = array("CurrentTime", "ReqPerSec", "BytesPerSec", "BusyWorkers", "IdleWorkers");

// Fetch the status page content
$status_content = file_get_contents($url);

if ($status_content === FALSE) {
    die("Error fetching the Apache server status.");
}

// Parse the status content
$status_lines = explode("\n", $status_content);
$status_data = array();

foreach ($status_lines as $line) {
    // Split each line by colon and space
    $parts = explode(": ", $line, 2);
    if (count($parts) == 2) {
        $key = trim($parts[0]);

        // Only continue if the $key is a stat we want to collect
        if (array_search($key, $stats_to_collect) === false){
           continue;
        }

        $value = trim($parts[1]);

        // Convert numeric values to their respective types and format floats to 1 decimal place
        if (is_numeric($value)) {
            if (strpos($value, '.') !== false) {
                $value = number_format((float)$value, 1, '.', '');
            } else {
                $value = (int)$value;
            }
        }

        // Add to the associative array
        $status_data[$key] = $value;
    }
}

// Generate the log file line
$log_line = $status_data['CurrentTime'] . "\t" . $status_data['ReqPerSec'] . "\t" . $status_data['BytesPerSec'] . "\t" . $status_data['BusyWorkers'] . "\t" . $status_data['IdleWorkers'] . "\n";

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