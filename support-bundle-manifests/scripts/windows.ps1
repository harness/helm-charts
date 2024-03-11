Import-Module powershell-yaml

# Function to convert human-readable time to epoch time
function ConvertTo-Epoch {
    param (
        [int]$duration,
        [string]$unit
    )

    $current_time = [datetime]::UtcNow
    switch ($unit) {
        "days" {
            $current_time.AddDays(-$duration).ToUnixTimeSeconds()
            break
        }
        "hours" {
            $current_time.AddHours(-$duration).ToUnixTimeSeconds()
            break
        }
        "minutes" {
            $current_time.AddMinutes(-$duration).ToUnixTimeSeconds()
            break
        }
        default {
            Write-Host "Invalid input. Please specify 'days' or 'hours'."
            exit 1
        }
    }
}

# Function to convert DD-MM-YYYY date format to epoch time
function ConvertTo-EpochFromDate {
    param (
        [string]$input_date
    )
    $epoch_time = (Get-Date $input_date).ToUniversalTime().ToUnixTimeSeconds()
    return $epoch_time
}

# Check if all required arguments are provided
if ($args.Count -lt 2) {
    Write-Output "Usage: $PSCommandPath <namespace> <release_name>"
    Write-Output "Flags"
    Write-Output "--module <module-name>(optional): If not provided, all modules will be selected"
    Write-Output "--last <x> <minutes/hours/days>(optional): Log duration to fetch"
    Write-Output "--between <start_time> <end_time> (YYYY-DD-MM)(optional): Log duration to fetch"
    Write-Output "--number-of-files <num_files>(optional): Number of log files to fetch (default: 2)"
    Write-Output "--filepath <filepath>(optional): File path of logs"
    Write-Output "provide '*.log' in the filepath at the end"
    exit 1
}

# Assign arguments to variables
$NAMESPACE = $args[0]
$RELEASE_NAME = $args[1]
$NUM_FILES = "2"
$MODULE = ""
$START_TIME = ""
$END_TIME = ""

# Parse command-line arguments
for ($i = 2; $i -lt $args.Length; $i++) {
    switch ($args[$i]) {
        "--last" {
            $START_TIME = ConvertTo-Epoch $args[$i+1] $args[$i+2]
            $i += 2
            break
        }
        "--between" {
            $time1 = ConvertTo-EpochFromDate $args[$i+1]
            $time2 = ConvertTo-EpochFromDate $args[$i+2]
            if ($time1 -gt $time2) {
                $START_TIME = $time2
                $END_TIME = $time1
            } else {
                $START_TIME = $time1
                $END_TIME = $time2
            }
            $i += 2
            break
        }
        "--number-of-files" {
            $NUM_FILES = $args[$i+1]
            $i++
            break
        }
        "--module" {
            $MODULE = $args[$i+1]
            $i++
            break
        }
        "--filepath" {
            $FILEPATH = $args[$i+1]
            $i++
            break
        }
        default {
            Write-Host "Invalid argument: $($args[$i])"
            exit 1
        }
    }
}

if ([string]::IsNullOrEmpty($MODULE)) {
    $MODULE = "all"
}

if ([string]::IsNullOrEmpty($FILEPATH)) {
    $FILEPATH="/opt/harness/logs/pod*.log"
}

$BASE_URL = "https://raw.githubusercontent.com/harness/helm-charts/391993240b8b4e36fb61c3801136216ac91adbc3/support-bundle-manifests"

switch ($MODULE) {
    "all" {
        $DOWNLOAD_URL = "$BASE_URL/support-bundle-all.yaml"
        break
    }
    default {
        $DOWNLOAD_URL = "$BASE_URL/module-wise/support-bundle-$MODULE.yaml"
        break
    }
}

$MANIFEST_FILENAME="support-bundle.yaml"
# Download file
Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $MANIFEST_FILENAME

# Modify YAML file
$yamlContent = Get-Content $MANIFEST_FILENAME | ConvertFrom-Yaml

$yamlContent.spec.collectors | ForEach-Object {
    if ($_.Keys -eq "configmap") {
        $_.configmap.namespace = $NAMESPACE
    } elseif ($_.Keys -eq "exec") {
        $_.exec.namespace = $NAMESPACE
        $_.exec.args = @($NUM_FILES, $FILEPATH, $START_TIME, $END_TIME)
    } elseif ($_.Keys -eq "logs") {
        $_.logs.namespace = $NAMESPACE
    } elseif ($_.Keys -eq "clusterResources") {
        $_.clusterResources.namespaces = @($NAMESPACE)
    } elseif ($_.Keys -eq "helm") {
        $_.helm.releaseName = $RELEASE_NAME
    }
}

$yamlContent | ConvertTo-Yaml | Set-Content $MANIFEST_FILENAME
